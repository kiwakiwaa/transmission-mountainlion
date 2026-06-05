// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

#ifndef NSModalResponseOK
typedef NSInteger NSModalResponse;
static NSModalResponse const NSModalResponseOK = 1;
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
