// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

#import "LegacyColors.h"
#import "LegacyConstraints.h"
#import "LegacySegmentedControl.h"
#import "LegacySymbols.h"

#ifndef NSBezelStyleTexturedRounded
#define NSBezelStyleTexturedRounded NSTexturedRoundedBezelStyle
#endif

#ifndef NSBackgroundStyleEmphasized
#define NSBackgroundStyleEmphasized NSBackgroundStyleDark
#endif

#ifndef NSEventModifierFlagOption
#define NSEventModifierFlagOption NSAlternateKeyMask
#endif
#ifndef NSEventModifierFlagCommand
#define NSEventModifierFlagCommand NSCommandKeyMask
#endif

static inline NSEvent* NSAppCurrentEvent(void)
{
    return [NSApp currentEvent];
}

#ifndef NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#endif

#ifndef nullable
#define nullable
#endif
#ifndef nonnull
#define nonnull
#endif
#ifndef __kindof
#define __kindof
#endif
#ifndef _Nullable
#define _Nullable
#endif
#ifndef _Nonnull
#define _Nonnull
#endif

#ifndef API_AVAILABLE
#define API_AVAILABLE(...)
#endif

#ifndef NS_TYPED_EXTENSIBLE_ENUM
#define NS_TYPED_EXTENSIBLE_ENUM
#endif

#ifndef __AVAILABILITY_INTERNAL__MAC_NSURLSESSION_AVAILABLE
#define __AVAILABILITY_INTERNAL__MAC_NSURLSESSION_AVAILABLE
#endif

#ifndef NSMenuItemValidation
#define NSMenuItemValidation NSUserInterfaceValidations
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
@interface NSTitlebarAccessoryViewController : NSViewController
@property(nonatomic) NSLayoutAttribute layoutAttribute;
@property(nonatomic, getter=isHidden) BOOL hidden;
@property(nonatomic) BOOL automaticallyAdjustsSize;
@end

@interface NSWindow (TransmissionTitlebarAccessoryCompatibility)
- (void)addTitlebarAccessoryViewController:(NSTitlebarAccessoryViewController*)controller;
@end
#endif

void TRLayoutLegacyTitlebarAccessoryWindow(NSWindow* window);

#ifndef NSModalResponseOK
typedef NSInteger NSModalResponse;
static NSModalResponse const NSModalResponseOK = 1;

#ifndef NSControlStateValueOn
typedef NSInteger NSControlStateValue;
static NSControlStateValue const NSControlStateValueMixed = NSMixedState;
static NSControlStateValue const NSControlStateValueOff = NSOffState;
static NSControlStateValue const NSControlStateValueOn = NSOnState;
#endif

#ifndef NSAlertStyleWarning
#define NSAlertStyleWarning NSWarningAlertStyle
#endif

#ifndef NSAlertStyleCritical
#define NSAlertStyleCritical NSCriticalAlertStyle
#endif

#ifndef NSAlertStyleInformational
#define NSAlertStyleInformational NSInformationalAlertStyle
#endif

#ifndef NSWindowCollectionBehaviorFullScreenNone
#define NSWindowCollectionBehaviorFullScreenNone 0
#endif

#ifndef NSCompositingOperationSourceOver
#define NSCompositingOperationSourceOver NSCompositeSourceOver
#endif

#ifndef NSCompositingOperationSourceAtop
#define NSCompositingOperationSourceAtop NSCompositeSourceAtop
#endif

#ifndef NSCompositingOperationSourceIn
#define NSCompositingOperationSourceIn NSCompositeSourceIn
#endif

#ifndef NSCompositingOperationCopy
#define NSCompositingOperationCopy NSCompositeCopy
#endif
static NSModalResponse const NSModalResponseCancel = 0;
#endif

typedef void (^TRSheetCompletionHandler)(NSModalResponse returnCode);

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@interface NSWindow (TransmissionCompatibility)
- (void)beginSheet:(NSWindow*)sheet completionHandler:(TRSheetCompletionHandler)handler;
- (void)endSheet:(NSWindow*)sheet;
@end

@interface NSAlert (TransmissionCompatibility)
- (void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(TRSheetCompletionHandler)handler;
@end
#endif

NS_ASSUME_NONNULL_BEGIN

// Compatibility declarations to build `@available(macOS 13.0, *)` code with older Xcode 12.5.1 (the last macOS 11.0 compatible Xcode)
#ifndef __MAC_13_0

typedef NS_ENUM(NSInteger, NSColorWellStyle) {
    NSColorWellStyleMinimal = 1,
} API_AVAILABLE(macos(13.0));

@interface NSColorWell ()
@property(assign) NSColorWellStyle colorWellStyle API_AVAILABLE(macos(13.0));
@end

#endif

NS_ASSUME_NONNULL_END

#ifndef NSTextAlignmentRight
#define NSTextAlignmentRight NSRightTextAlignment
#endif
#ifndef NSTextAlignmentCenter
#define NSTextAlignmentCenter NSCenterTextAlignment
#endif
#ifndef NSTextAlignmentLeft
#define NSTextAlignmentLeft NSLeftTextAlignment
#endif

#ifndef NSActivityIdleSystemSleepDisabled
typedef NSUInteger NSActivityOptions;
#define NSActivityIdleSystemSleepDisabled 0
#define NSActivityUserInitiatedAllowingIdleSystemSleep 0
#define NSProcessInfoPowerStateDidChangeNotification @"NSProcessInfoPowerStateDidChangeNotification"
@interface NSProcessInfo (TransmissionActivityCompatibility)
- (id<NSObject>)beginActivityWithOptions:(NSActivityOptions)options reason:(NSString*)reason;
- (void)endActivity:(id<NSObject>)activity;
- (BOOL)lowPowerModeEnabled;
@end
#endif
