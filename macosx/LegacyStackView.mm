// This file Copyright (c) Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacyStackView.h"

@implementation LegacyStackView

- (instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _orientation = TRLegacyStackViewOrientationHorizontal;
        _spacing = 0.0;
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self layoutLegacySubviews];
}

- (void)setOrientation:(TRLegacyStackViewOrientation)orientation
{
    _orientation = orientation;
    [self layoutLegacySubviews];
}

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    [self layoutLegacySubviews];
}

- (void)setVisibilityPriority:(TRLegacyStackViewVisibilityPriority)priority forView:(NSView*)view
{
    view.hidden = priority == TRLegacyStackViewVisibilityPriorityNotVisible;
    [self layoutLegacySubviews];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
    [self layoutLegacySubviews];
}

- (void)layoutLegacySubviews
{
    NSArray* subviews = self.subviews;
    NSMutableArray* visibleSubviews = [NSMutableArray arrayWithCapacity:subviews.count];
    for (NSView* subview in subviews)
    {
        if (![subview isHidden])
        {
            [visibleSubviews addObject:subview];
        }
    }

    if (visibleSubviews.count == 0)
    {
        return;
    }

    CGFloat const spacing = self.spacing > 0.0 ? self.spacing : 4.0;

    if (self.orientation == TRLegacyStackViewOrientationHorizontal)
    {
        CGFloat fixedWidth = spacing * (visibleSubviews.count - 1);
        NSUInteger flexibleCount = 0;
        for (NSView* subview in visibleSubviews)
        {
            if ([subview isKindOfClass:[NSTextField class]])
            {
                ++flexibleCount;
            }
            else
            {
                fixedWidth += NSWidth(subview.frame);
            }
        }

        CGFloat flexibleWidth = 0.0;
        if (flexibleCount > 0)
        {
            flexibleWidth = floor(MAX(0.0, NSWidth(self.bounds) - fixedWidth) / flexibleCount);
        }

        CGFloat offset = 0.0;
        for (NSView* subview in visibleSubviews)
        {
            NSRect frame = subview.frame;
            if ([subview isKindOfClass:[NSTextField class]])
            {
                frame.size.width = flexibleWidth;
            }
            frame.origin.x = offset;
            frame.origin.y = floor((NSHeight(self.bounds) - NSHeight(frame)) / 2.0);
            subview.frame = frame;
            offset += NSWidth(frame) + spacing;
        }
    }
    else
    {
        CGFloat offset = NSHeight(self.bounds);
        for (NSView* subview in visibleSubviews)
        {
            NSRect frame = subview.frame;
            offset -= NSHeight(frame);
            frame.origin.x = 0.0;
            frame.origin.y = offset;
            frame.size.width = NSWidth(self.bounds);
            subview.frame = frame;
            offset -= spacing;
        }
    }
}

@end
