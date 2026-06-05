// This file Copyright (c) Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "CocoaCompatibility.h"

#import <objc/runtime.h>

@interface TRSheetCallback : NSObject

@property(nonatomic, copy) TRSheetCompletionHandler handler;

- (instancetype)initWithCompletionHandler:(TRSheetCompletionHandler)handler;
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo;
- (void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo;

@end

@implementation TRSheetCallback

- (instancetype)initWithCompletionHandler:(TRSheetCompletionHandler)handler
{
    if ((self = [super init]))
    {
        _handler = [handler copy];
    }

    return self;
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:nil];
    if (self.handler)
    {
        self.handler(returnCode);
    }

    CFBridgingRelease(contextInfo);
}

- (void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    if (self.handler)
    {
        self.handler(returnCode);
    }

    CFBridgingRelease(contextInfo);
}

@end

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@implementation NSWindow (TransmissionCompatibility)

- (void)beginSheet:(NSWindow*)sheet completionHandler:(TRSheetCompletionHandler)handler
{
    TRSheetCallback* callback = handler ? [[TRSheetCallback alloc] initWithCompletionHandler:handler] : nil;
    void* contextInfo = callback ? (void*)CFBridgingRetain(callback) : NULL;

    [NSApp beginSheet:sheet modalForWindow:self modalDelegate:callback
        didEndSelector:callback ? @selector(sheetDidEnd:returnCode:contextInfo:) : NULL
           contextInfo:contextInfo];
}

- (void)endSheet:(NSWindow*)sheet
{
    [NSApp endSheet:sheet];
    [sheet orderOut:nil];
}

@end

@implementation NSAlert (TransmissionCompatibility)

- (void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(TRSheetCompletionHandler)handler
{
    TRSheetCallback* callback = handler ? [[TRSheetCallback alloc] initWithCompletionHandler:handler] : nil;
    void* contextInfo = callback ? (void*)CFBridgingRetain(callback) : NULL;

    [self beginSheetModalForWindow:window modalDelegate:callback
                    didEndSelector:callback ? @selector(alertDidEnd:returnCode:contextInfo:) : NULL
                       contextInfo:contextInfo];
}

@end
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
static char TRLegacyTitlebarAccessoryControllersKey;

static NSMutableArray* TRLegacyTitlebarAccessoryControllersForWindow(NSWindow* window, BOOL create)
{
    NSMutableArray* controllers = objc_getAssociatedObject(window, &TRLegacyTitlebarAccessoryControllersKey);
    if (controllers == nil && create)
    {
        controllers = [NSMutableArray array];
        objc_setAssociatedObject(window, &TRLegacyTitlebarAccessoryControllersKey, controllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return controllers;
}

void TRLayoutLegacyTitlebarAccessoryWindow(NSWindow* window)
{
    NSView* contentView = window.contentView;
    if (contentView == nil)
    {
        return;
    }

    NSArray* controllers = TRLegacyTitlebarAccessoryControllersForWindow(window, NO);
    CGFloat accessoryHeight = 0.0;
    NSMutableArray* visibleControllers = [NSMutableArray arrayWithCapacity:controllers.count];
    for (NSTitlebarAccessoryViewController* controller in controllers)
    {
        NSView* view = controller.view;
        if (view != nil && !controller.isHidden)
        {
            [visibleControllers addObject:controller];
            accessoryHeight += NSHeight(view.frame) > 0.0 ? NSHeight(view.frame) : 24.0;
        }
        else
        {
            view.hidden = YES;
        }
    }

    NSRect bounds = contentView.bounds;
    CGFloat y = NSHeight(bounds);
    for (NSTitlebarAccessoryViewController* controller in visibleControllers)
    {
        NSView* view = controller.view;
        CGFloat height = NSHeight(view.frame) > 0.0 ? NSHeight(view.frame) : 24.0;
        y -= height;
        view.hidden = NO;
        view.frame = NSMakeRect(0.0, y, NSWidth(bounds), height);
        view.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    }

    CGFloat bottomHeight = 0.0;
    NSScrollView* scrollView = nil;
    for (NSView* subview in contentView.subviews)
    {
        BOOL isAccessory = NO;
        for (NSTitlebarAccessoryViewController* controller in controllers)
        {
            if (subview == controller.view)
            {
                isAccessory = YES;
                break;
            }
        }
        if (isAccessory)
        {
            continue;
        }

        if ([subview isKindOfClass:[NSScrollView class]])
        {
            scrollView = (NSScrollView*)subview;
        }
        else if (NSMinY(subview.frame) <= 1.0)
        {
            bottomHeight = MAX(bottomHeight, NSHeight(subview.frame));
        }
    }

    if (scrollView != nil)
    {
        scrollView.frame = NSMakeRect(0.0, bottomHeight, NSWidth(bounds), MAX(0.0, NSHeight(bounds) - bottomHeight - accessoryHeight));
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
}

@implementation NSTitlebarAccessoryViewController

@synthesize layoutAttribute = _layoutAttribute;
@synthesize hidden = _hidden;
@synthesize automaticallyAdjustsSize = _automaticallyAdjustsSize;

- (void)setHidden:(BOOL)hidden
{
    _hidden = hidden;
    self.view.hidden = hidden;
    TRLayoutLegacyTitlebarAccessoryWindow(self.view.window);
}

@end

@implementation NSWindow (TransmissionTitlebarAccessoryCompatibility)
- (void)addTitlebarAccessoryViewController:(NSTitlebarAccessoryViewController*)controller
{
    NSView* view = controller.view;
    if (view == nil)
    {
        return;
    }

    NSMutableArray* controllers = TRLegacyTitlebarAccessoryControllersForWindow(self, YES);
    if (![controllers containsObject:controller])
    {
        [controllers addObject:controller];
    }

    if (view.superview != self.contentView)
    {
        [self.contentView addSubview:view];
    }

    TRLayoutLegacyTitlebarAccessoryWindow(self);
}
@end
#else
void TRLayoutLegacyTitlebarAccessoryWindow(NSWindow* window)
{
}
#endif

static void TRStrokeLine(NSPoint start, NSPoint end)
{
    NSBezierPath* line = [NSBezierPath bezierPath];
    [line moveToPoint:start];
    [line lineToPoint:end];
    [line stroke];
}

static void TRStrokeChevron(CGFloat left, CGFloat mid, CGFloat right, CGFloat top, CGFloat bottom)
{
    NSBezierPath* chevron = [NSBezierPath bezierPath];
    chevron.lineWidth = 1.7;
    [chevron moveToPoint:NSMakePoint(left, top)];
    [chevron lineToPoint:NSMakePoint(mid, bottom)];
    [chevron lineToPoint:NSMakePoint(right, top)];
    [chevron stroke];
}

static void TRStrokeCircle(CGFloat x, CGFloat y, CGFloat size)
{
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x, y, size, size)] stroke];
}

static void TRDrawDocumentIcon(BOOL plusBadge)
{
    NSBezierPath* doc = [NSBezierPath bezierPath];
    doc.lineWidth = 1.4;
    [doc moveToPoint:NSMakePoint(4.0, 2.0)];
    [doc lineToPoint:NSMakePoint(4.0, 16.0)];
    [doc lineToPoint:NSMakePoint(11.0, 16.0)];
    [doc lineToPoint:NSMakePoint(15.0, 12.0)];
    [doc lineToPoint:NSMakePoint(15.0, 2.0)];
    [doc closePath];
    [doc stroke];
    TRStrokeLine(NSMakePoint(11.0, 16.0), NSMakePoint(11.0, 12.0));
    TRStrokeLine(NSMakePoint(11.0, 12.0), NSMakePoint(15.0, 12.0));

    if (plusBadge)
    {
        NSBezierPath* badge = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(9.0, 1.0, 8.0, 8.0)];
        [[NSColor whiteColor] setFill];
        [badge fill];
        [[NSColor blackColor] setStroke];
        badge.lineWidth = 1.2;
        [badge stroke];
        TRStrokeLine(NSMakePoint(13.0, 3.0), NSMakePoint(13.0, 7.0));
        TRStrokeLine(NSMakePoint(11.0, 5.0), NSMakePoint(15.0, 5.0));
    }
}

static void TRDrawGearIcon(void)
{
    TRStrokeCircle(5.0, 5.0, 8.0);
    TRStrokeCircle(7.5, 7.5, 3.0);
    TRStrokeLine(NSMakePoint(9.0, 1.5), NSMakePoint(9.0, 4.0));
    TRStrokeLine(NSMakePoint(9.0, 14.0), NSMakePoint(9.0, 16.5));
    TRStrokeLine(NSMakePoint(1.5, 9.0), NSMakePoint(4.0, 9.0));
    TRStrokeLine(NSMakePoint(14.0, 9.0), NSMakePoint(16.5, 9.0));
    TRStrokeLine(NSMakePoint(3.7, 3.7), NSMakePoint(5.4, 5.4));
    TRStrokeLine(NSMakePoint(12.6, 12.6), NSMakePoint(14.3, 14.3));
    TRStrokeLine(NSMakePoint(3.7, 14.3), NSMakePoint(5.4, 12.6));
    TRStrokeLine(NSMakePoint(12.6, 5.4), NSMakePoint(14.3, 3.7));
}

static NSImage* TRLegacySystemSymbolImage(NSString* symbolName)
{
    NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(18.0, 18.0)];
    BOOL didDraw = YES;

    [image lockFocus];
    [[NSColor blackColor] setStroke];
    [[NSColor blackColor] setFill];
    [NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
    [NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
    [NSBezierPath setDefaultLineWidth:1.5];

    if ([symbolName isEqualToString:@"doc.badge.plus"])
    {
        TRDrawDocumentIcon(YES);
    }
    else if ([symbolName isEqualToString:@"folder"])
    {
        NSBezierPath* folder = [NSBezierPath bezierPath];
        folder.lineWidth = 1.4;
        [folder moveToPoint:NSMakePoint(2.0, 4.0)];
        [folder lineToPoint:NSMakePoint(2.0, 13.0)];
        [folder lineToPoint:NSMakePoint(6.7, 13.0)];
        [folder lineToPoint:NSMakePoint(8.3, 15.0)];
        [folder lineToPoint:NSMakePoint(16.0, 15.0)];
        [folder lineToPoint:NSMakePoint(16.0, 4.0)];
        [folder closePath];
        [folder stroke];
        TRStrokeLine(NSMakePoint(9.0, 12.0), NSMakePoint(9.0, 6.0));
        TRStrokeChevron(6.2, 9.0, 11.8, 8.3, 5.5);
    }
    else if ([symbolName isEqualToString:@"magnifyingglass"])
    {
        TRStrokeCircle(3.0, 6.0, 8.0);
        TRStrokeLine(NSMakePoint(9.5, 6.5), NSMakePoint(15.0, 2.0));
    }
    else if ([symbolName isEqualToString:@"square.grid.3x3.fill.square"])
    {
        for (NSUInteger row = 0; row < 3; ++row)
        {
            for (NSUInteger column = 0; column < 3; ++column)
            {
                NSRectFill(NSMakeRect(3.0 + column * 4.5, 3.0 + row * 4.5, 2.6, 2.6));
            }
        }
    }
    else if ([symbolName isEqualToString:@"antenna.radiowaves.left.and.right"])
    {
        TRStrokeLine(NSMakePoint(9.0, 3.0), NSMakePoint(9.0, 10.0));
        TRStrokeChevron(6.5, 9.0, 11.5, 10.0, 7.0);
        TRStrokeLine(NSMakePoint(6.5, 3.0), NSMakePoint(11.5, 3.0));
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(5.0, 6.0, 8.0, 8.0)] stroke];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(2.0, 3.0, 14.0, 14.0)] stroke];
    }
    else if ([symbolName isEqualToString:@"person.2"])
    {
        TRStrokeCircle(4.0, 9.5, 4.0);
        TRStrokeCircle(9.5, 8.5, 4.5);
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(2.5, 3.0, 7.0, 5.2) xRadius:2.5 yRadius:2.5] stroke];
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(8.0, 2.5, 8.0, 5.5) xRadius:2.8 yRadius:2.8] stroke];
    }
    else if ([symbolName isEqualToString:@"doc.on.doc"])
    {
        NSBezierPath* back = [NSBezierPath bezierPathWithRect:NSMakeRect(3.0, 5.0, 8.5, 10.0)];
        back.lineWidth = 1.2;
        [back stroke];
        TRDrawDocumentIcon(NO);
    }
    else if ([symbolName isEqualToString:@"gearshape"])
    {
        TRDrawGearIcon();
    }
    else if ([symbolName isEqualToString:@"lock.fill"])
    {
        [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(4.0, 3.0, 10.0, 8.0) xRadius:1.5 yRadius:1.5] stroke];
        NSBezierPath* shackle = [NSBezierPath bezierPath];
        shackle.lineWidth = 1.5;
        [shackle moveToPoint:NSMakePoint(6.0, 10.0)];
        [shackle curveToPoint:NSMakePoint(12.0, 10.0) controlPoint1:NSMakePoint(6.0, 15.0) controlPoint2:NSMakePoint(12.0, 15.0)];
        [shackle stroke];
    }
    else if ([symbolName isEqualToString:@"checkmark.circle"] || [symbolName isEqualToString:@"checkmark.circle.dotted"])
    {
        NSBezierPath* circle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(3.0, 3.0, 12.0, 12.0)];
        circle.lineWidth = 1.4;
        if ([symbolName isEqualToString:@"checkmark.circle.dotted"])
        {
            CGFloat dash[] = { 1.5, 1.5 };
            [circle setLineDash:dash count:2 phase:0.0];
        }
        [circle stroke];
        TRStrokeLine(NSMakePoint(6.0, 9.0), NSMakePoint(8.0, 6.8));
        TRStrokeLine(NSMakePoint(8.0, 6.8), NSMakePoint(12.2, 11.2));
    }
    else if ([symbolName isEqualToString:@"circle"])
    {
        TRStrokeCircle(3.0, 3.0, 12.0);
    }
    else if ([symbolName isEqualToString:@"chevron.up.chevron.down"])
    {
        TRStrokeChevron(4.0, 9.0, 14.0, 7.0, 12.0);
        TRStrokeChevron(4.0, 9.0, 14.0, 11.0, 6.0);
    }
    else if ([symbolName isEqualToString:@"finder"])
    {
        NSBezierPath* face = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(3.0, 3.0, 12.0, 12.0) xRadius:2.0 yRadius:2.0];
        face.lineWidth = 1.3;
        [face stroke];
        TRStrokeLine(NSMakePoint(9.0, 3.0), NSMakePoint(9.0, 15.0));
        TRStrokeLine(NSMakePoint(5.5, 10.5), NSMakePoint(6.8, 10.5));
        TRStrokeLine(NSMakePoint(11.2, 10.5), NSMakePoint(12.5, 10.5));
        TRStrokeLine(NSMakePoint(6.0, 6.5), NSMakePoint(12.0, 6.5));
    }
    else if ([symbolName isEqualToString:@"pencil"])
    {
        TRStrokeLine(NSMakePoint(4.0, 3.0), NSMakePoint(14.0, 13.0));
        TRStrokeLine(NSMakePoint(11.5, 15.0), NSMakePoint(15.0, 11.5));
        TRStrokeLine(NSMakePoint(3.0, 2.0), NSMakePoint(5.5, 2.8));
    }
    else if ([symbolName isEqualToString:@"arrow.up.arrow.down"])
    {
        TRStrokeLine(NSMakePoint(6.0, 4.0), NSMakePoint(6.0, 14.0));
        TRStrokeChevron(3.5, 6.0, 8.5, 11.0, 14.0);
        TRStrokeLine(NSMakePoint(12.0, 14.0), NSMakePoint(12.0, 4.0));
        TRStrokeChevron(9.5, 12.0, 14.5, 7.0, 4.0);
    }
    else if ([symbolName isEqualToString:@"arrow.up"])
    {
        TRStrokeLine(NSMakePoint(9.0, 4.0), NSMakePoint(9.0, 14.0));
        TRStrokeChevron(4.5, 9.0, 13.5, 10.0, 14.0);
    }
    else if ([symbolName isEqualToString:@"arrow.down"])
    {
        TRStrokeLine(NSMakePoint(9.0, 14.0), NSMakePoint(9.0, 4.0));
        TRStrokeChevron(4.5, 9.0, 13.5, 8.0, 4.0);
    }
    else if ([symbolName isEqualToString:@"pin"])
    {
        TRStrokeCircle(6.0, 10.0, 6.0);
        TRStrokeLine(NSMakePoint(9.0, 10.0), NSMakePoint(9.0, 2.5));
        TRStrokeLine(NSMakePoint(6.0, 7.0), NSMakePoint(12.0, 7.0));
    }
    else if ([symbolName isEqualToString:@"speedometer"])
    {
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(3.0, 3.0, 12.0, 12.0)] stroke];
        TRStrokeLine(NSMakePoint(9.0, 9.0), NSMakePoint(13.0, 11.0));
        TRStrokeLine(NSMakePoint(5.0, 7.0), NSMakePoint(4.0, 7.0));
        TRStrokeLine(NSMakePoint(14.0, 7.0), NSMakePoint(13.0, 7.0));
    }
    else if ([symbolName isEqualToString:@"network"])
    {
        TRStrokeCircle(7.0, 7.0, 4.0);
        TRStrokeCircle(2.5, 11.5, 3.0);
        TRStrokeCircle(12.5, 11.5, 3.0);
        TRStrokeCircle(7.5, 2.5, 3.0);
        TRStrokeLine(NSMakePoint(6.0, 11.5), NSMakePoint(7.5, 10.5));
        TRStrokeLine(NSMakePoint(12.0, 11.5), NSMakePoint(10.5, 10.5));
        TRStrokeLine(NSMakePoint(9.0, 7.0), NSMakePoint(9.0, 5.5));
    }
    else
    {
        didDraw = NO;
    }

    [image unlockFocus];

    if (!didDraw)
    {
        return nil;
    }

    [image setTemplate:YES];
    return image;
}

NSImage* TRImageForSystemSymbol(NSString* symbolName, NSString* description)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 110000
    NSImage* systemImage = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:description];
    if (systemImage != nil)
    {
        return systemImage;
    }
#endif

    NSImage* fallbackImage = TRLegacySystemSymbolImage(symbolName);
    if (fallbackImage != nil)
    {
        fallbackImage.accessibilityDescription = description;
        return fallbackImage;
    }

    static NSDictionary* imageNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageNames = @{
            @"doc.badge.plus" : @"CreateLarge",
            @"folder" : NSImageNameFolder,
            @"globe" : @"Globe",
            @"nosign" : @"CleanupTemplate",
            @"info.circle" : NSImageNameInfo,
            @"pause.circle.fill" : @"PauseOff",
            @"arrow.clockwise.circle.fill" : @"ResumeOff",
            @"pause" : @"PauseOff",
            @"arrow.clockwise" : @"ResumeOff",
            @"magnifyingglass" : @"RevealOff",
        };
    });

    NSString* imageName = [imageNames objectForKey:symbolName] ?: symbolName;
    return [NSImage imageNamed:imageName];
}

void TRSetSegmentTag(NSSegmentedControl* control, NSInteger tag, NSInteger segment)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    [control setTag:tag forSegment:segment];
#else
    (void)control;
    (void)tag;
    (void)segment;
#endif
}

NSInteger TRSelectedSegmentTag(NSSegmentedControl* control)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    return [control selectedTag];
#else
    return [control selectedSegment];
#endif
}

void TRSetSegmentToolTip(NSSegmentedControl* control, NSString* toolTip, NSInteger segment)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    [control setToolTip:toolTip forSegment:segment];
#else
    (void)segment;
    [control setToolTip:toolTip];
#endif
}

void TRSetConstraintActive(NSLayoutConstraint* constraint, BOOL active)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    constraint.active = active;
#else
    id firstItem = [constraint firstItem];
    if (![firstItem respondsToSelector:@selector(addConstraint:)])
    {
        return;
    }

    if (active)
    {
        [firstItem addConstraint:constraint];
    }
    else
    {
        [firstItem removeConstraint:constraint];
    }
#endif
}

NSColor* TRLabelColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor labelColor];
#else
    return [NSColor controlTextColor];
#endif
}

NSColor* TRSecondaryLabelColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor secondaryLabelColor];
#else
    return [NSColor disabledControlTextColor];
#endif
}

NSColor* TRSystemRedColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemRedColor];
#else
    return [NSColor redColor];
#endif
}

NSColor* TRSystemOrangeColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemOrangeColor];
#else
    return [NSColor orangeColor];
#endif
}

NSColor* TRSystemYellowColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemYellowColor];
#else
    return [NSColor yellowColor];
#endif
}

NSColor* TRSystemGreenColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemGreenColor];
#else
    return [NSColor greenColor];
#endif
}

NSColor* TRSystemBlueColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemBlueColor];
#else
    return [NSColor blueColor];
#endif
}

NSColor* TRSystemPurpleColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemPurpleColor];
#else
    return [NSColor purpleColor];
#endif
}

NSColor* TRSystemGrayColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemGrayColor];
#else
    return [NSColor grayColor];
#endif
}

NSColor* TRSystemTealColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemTealColor];
#else
    return [NSColor cyanColor];
#endif
}

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@implementation NSProcessInfo (TransmissionActivityCompatibility)

- (id<NSObject>)beginActivityWithOptions:(NSActivityOptions)options reason:(NSString*)reason
{
    return nil;
}

- (void)endActivity:(id<NSObject>)activity
{
}

- (BOOL)lowPowerModeEnabled
{
    return NO;
}

@end
#endif
