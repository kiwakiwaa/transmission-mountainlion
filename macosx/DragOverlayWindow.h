// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

@interface DragOverlayWindow : NSWindow

- (instancetype)initForWindow:(NSWindow*)window;

- (void)setTorrents:(NSArray*)files;
- (void)setFile:(NSString*)file;
- (void)setURL:(NSString*)url;

- (void)fadeIn;
- (void)fadeOut;

@end
