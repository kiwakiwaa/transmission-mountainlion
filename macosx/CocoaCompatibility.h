// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

#import "ObjectiveCCompatibility.h"

#import "LegacyColors.h"
#import "LegacyConstraints.h"
#import "LegacyPowerActivity.h"
#import "LegacySegmentedControl.h"
#import "LegacySheets.h"
#import "LegacySymbols.h"
#import "LegacyTitlebarAccessory.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
#define NSBezelStyleTexturedRounded NSTexturedRoundedBezelStyle
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
#define NSBackgroundStyleEmphasized NSBackgroundStyleDark
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101200
#define NSEventModifierFlagOption NSAlternateKeyMask
#define NSEventModifierFlagCommand NSCommandKeyMask
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101300
#define TRPasteboardTypeFileURL NSFilenamesPboardType
#define TRPasteboardTypeURL NSURLPboardType
#else
#define TRPasteboardTypeFileURL NSPasteboardTypeFileURL
#define TRPasteboardTypeURL NSPasteboardTypeURL
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
#define TRURLQuarantinePropertiesKey @"NSURLQuarantinePropertiesKey"
#else
#define TRURLQuarantinePropertiesKey NSURLQuarantinePropertiesKey
#endif

static inline NSEvent* NSAppCurrentEvent(void)
{
    return [NSApp currentEvent];
}

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#ifndef NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#endif

#if !__has_feature(nullability)
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
#endif

#ifndef API_AVAILABLE
#define API_AVAILABLE(...)
#endif

#ifndef NS_UNAVAILABLE
#define NS_UNAVAILABLE
#endif

#ifndef CFBridgingRetain
#define CFBridgingRetain(X) ((__bridge_retained CFTypeRef)(X))
#endif

#ifndef CFBridgingRelease
#define CFBridgingRelease(X) ((__bridge_transfer id)(X))
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

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@interface NSPredicate (TRSecureCodingEvaluation)
- (void)allowEvaluation;
@end
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101300
typedef NSInteger NSControlStateValue;
static NSControlStateValue const NSControlStateValueMixed = NSMixedState;
static NSControlStateValue const NSControlStateValueOff = NSOffState;
static NSControlStateValue const NSControlStateValueOn = NSOnState;
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101000
#define NSAlertStyleWarning NSWarningAlertStyle
#define NSAlertStyleCritical NSCriticalAlertStyle
#define NSAlertStyleInformational NSInformationalAlertStyle
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101200
#define TRFullScreenWindowMask NSFullScreenWindowMask
#define TRLeftMouseDownMask NSLeftMouseDownMask
#else
#define TRFullScreenWindowMask NSWindowStyleMaskFullScreen
#define TRLeftMouseDownMask NSEventMaskLeftMouseDown
#endif

#ifndef NSWindowCollectionBehaviorFullScreenNone
#define NSWindowCollectionBehaviorFullScreenNone 0
#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101200
#define NSCompositingOperationSourceOver NSCompositeSourceOver
#define NSCompositingOperationSourceAtop NSCompositeSourceAtop
#define NSCompositingOperationSourceIn NSCompositeSourceIn
#define NSCompositingOperationCopy NSCompositeCopy
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

#if MAC_OS_X_VERSION_MAX_ALLOWED < 101200
#define NSTextAlignmentRight NSRightTextAlignment
#define NSTextAlignmentCenter NSCenterTextAlignment
#define NSTextAlignmentLeft NSLeftTextAlignment
#endif
