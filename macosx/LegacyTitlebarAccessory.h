// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

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
