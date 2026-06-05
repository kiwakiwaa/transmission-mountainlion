// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

#import "InfoViewController.h"

@interface InfoTrackersViewController : NSViewController<InfoViewController>

- (void)setInfoForTorrents:(NSArray*)torrents;
- (void)updateInfo;

- (void)saveViewSize;
- (void)clearView;

- (IBAction)addRemoveTracker:(id)sender;

@end
