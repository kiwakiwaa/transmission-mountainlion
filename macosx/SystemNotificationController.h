// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Foundation/Foundation.h>

@class SystemNotificationController;

@protocol SystemNotificationControllerDelegate<NSObject>

- (void)systemNotificationController:(SystemNotificationController*)controller
    didActivateDefaultActionWithUserInfo:(NSDictionary*)userInfo;
- (void)systemNotificationController:(SystemNotificationController*)controller
    didActivateShowActionWithUserInfo:(NSDictionary*)userInfo;

@end

@interface SystemNotificationController : NSObject

@property(nonatomic, TR_OBJC_WEAK) id<SystemNotificationControllerDelegate> delegate;

- (void)configureUserNotifications;
- (void)handleLaunchNotificationFromApplicationNotification:(NSNotification*)notification;

- (void)deliverDownloadCompleteNotificationWithTorrentName:(NSString*)torrentName
                                                hashString:(NSString*)hashString
                                                  location:(NSString*)location;
- (void)deliverSeedingCompleteNotificationWithTorrentName:(NSString*)torrentName
                                               hashString:(NSString*)hashString
                                                 location:(NSString*)location;
- (void)deliverSpeedLimitChangedNotificationIsLimited:(BOOL)isLimited;
- (void)deliverTorrentFileAutoAddedNotificationWithFileName:(NSString*)fileName;

@end
