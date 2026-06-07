// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#if __has_feature(modules)
@import AppKit;
@import Foundation;
#else
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#endif

#if __has_include(<UserNotifications/UserNotifications.h>)
#define TR_HAS_USER_NOTIFICATIONS 1
#else
#define TR_HAS_USER_NOTIFICATIONS 0
#endif

#if TR_HAS_USER_NOTIFICATIONS
typedef NSUInteger UNAuthorizationOptions;
typedef NSUInteger UNNotificationActionOptions;
typedef NSUInteger UNNotificationCategoryOptions;
typedef NSUInteger UNNotificationPresentationOptions;

static UNAuthorizationOptions const UNAuthorizationOptionBadge = (1 << 0);
static UNAuthorizationOptions const UNAuthorizationOptionSound = (1 << 1);
static UNAuthorizationOptions const UNAuthorizationOptionAlert = (1 << 2);
static UNNotificationActionOptions const UNNotificationActionOptionForeground = (1 << 2);
static UNNotificationCategoryOptions const UNNotificationCategoryOptionNone = 0;

@class UNMutableNotificationContent;
@class UNNotification;
@class UNNotificationRequest;
@class UNNotificationResponse;
@class UNNotificationTrigger;

extern NSString* const UNNotificationDefaultActionIdentifier;

@interface UNUserNotificationCenter : NSObject
@property(nonatomic, TR_OBJC_WEAK) id delegate;
+ (UNUserNotificationCenter*)currentNotificationCenter;
- (void)setNotificationCategories:(NSSet*)categories;
- (void)requestAuthorizationWithOptions:(UNAuthorizationOptions)options
                      completionHandler:(void (^)(BOOL granted, NSError* error))completionHandler;
- (void)addNotificationRequest:(UNNotificationRequest*)request
         withCompletionHandler:(void (^)(NSError* error))completionHandler;
@end

@interface UNNotificationAction : NSObject
+ (instancetype)actionWithIdentifier:(NSString*)identifier title:(NSString*)title options:(UNNotificationActionOptions)options;
@end

@interface UNNotificationCategory : NSObject
+ (instancetype)categoryWithIdentifier:(NSString*)identifier
                               actions:(NSArray*)actions
                     intentIdentifiers:(NSArray*)intentIdentifiers
                               options:(UNNotificationCategoryOptions)options;
@end

@interface UNNotificationContent : NSObject
@property(nonatomic, readonly) NSDictionary* userInfo;
@end

@interface UNMutableNotificationContent : UNNotificationContent
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* body;
@property(nonatomic, copy) NSString* categoryIdentifier;
@property(nonatomic, copy) NSDictionary* userInfo;
@end

@interface UNNotificationRequest : NSObject
@property(nonatomic, readonly) UNNotificationContent* content;
+ (instancetype)requestWithIdentifier:(NSString*)identifier
                              content:(UNNotificationContent*)content
                              trigger:(UNNotificationTrigger*)trigger;
@end

@interface UNNotification : NSObject
@property(nonatomic, readonly) UNNotificationRequest* request;
@end

@interface UNNotificationResponse : NSObject
@property(nonatomic, readonly) UNNotification* notification;
@property(nonatomic, readonly) NSString* actionIdentifier;
@end
#endif

#if __has_include(<Foundation/NSUserNotification.h>)
#define TR_HAS_LEGACY_USER_NOTIFICATIONS 1
#import <Foundation/NSUserNotification.h>
#else
#define TR_HAS_LEGACY_USER_NOTIFICATIONS 0
#endif

#import "SystemNotificationController.h"

namespace
{

NSString* const ActionShowIdentifier = @"actionShow";
NSString* const CategoryShowIdentifier = @"categoryShow";
NSString* const UserInfoHashKey = @"Hash";
NSString* const UserInfoLocationKey = @"Location";
NSString* const UserInfoIdentifierKey = @"TransmissionNotificationIdentifier";

} // namespace

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
#define TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN \
    _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#define TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END _Pragma("clang diagnostic pop")
#else
#define TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN
#define TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END
#endif

@interface SystemNotificationController ()
@end

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
@interface SystemNotificationController (NSUserNotificationCenterDelegate)<NSUserNotificationCenterDelegate>
@end
#endif

@implementation SystemNotificationController

- (void)configureUserNotifications
{
#if TR_HAS_USER_NOTIFICATIONS
    if (@available(macOS 10.14, *))
    {
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;

        UNNotificationAction* actionShow = [UNNotificationAction actionWithIdentifier:ActionShowIdentifier
                                                                                title:NSLocalizedString(@"Show", "notification button")
                                                                              options:UNNotificationActionOptionForeground];
        UNNotificationCategory* categoryShow = [UNNotificationCategory categoryWithIdentifier:CategoryShowIdentifier
                                                                                      actions:@[ actionShow ]
                                                                            intentIdentifiers:@[]
                                                                                      options:UNNotificationCategoryOptionNone];
        [UNUserNotificationCenter.currentNotificationCenter setNotificationCategories:[NSSet setWithObject:categoryShow]];
        [UNUserNotificationCenter.currentNotificationCenter
            requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL /*granted*/, NSError* _Nullable error) {
                              if (error.code > 0)
                              {
                                  NSLog(@"UserNotifications not configured: %@", error.localizedDescription);
                              }
                          }];
        return;
    }
#endif

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN
    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END
#endif
}

- (void)handleLaunchNotificationFromApplicationNotification:(NSNotification*)notification
{
#if TR_HAS_USER_NOTIFICATIONS
    if (@available(macOS 10.14, *))
    {
        UNNotificationResponse* launchNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
        if (launchNotification)
        {
            [self userNotificationCenter:UNUserNotificationCenter.currentNotificationCenter
                didReceiveNotificationResponse:launchNotification withCompletionHandler:^{
                }];
        }
        return;
    }
#endif

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN
    NSUserNotification* launchNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
    if (launchNotification)
    {
        [self userNotificationCenter:NSUserNotificationCenter.defaultUserNotificationCenter didActivateNotification:launchNotification];
    }
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END
#endif
}

- (void)deliverDownloadCompleteNotificationWithTorrentName:(NSString*)torrentName
                                                hashString:(NSString*)hashString
                                                  location:(NSString*)location
{
    NSString* title = NSLocalizedString(@"Download Complete", "notification title");
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:hashString forKey:UserInfoHashKey];
    if (location)
    {
        userInfo[UserInfoLocationKey] = location;
    }

    [self deliverNotificationWithIdentifier:[@"Download Complete " stringByAppendingString:hashString] title:title
                                       body:torrentName
                                   userInfo:userInfo
                              hasShowAction:YES];
}

- (void)deliverSeedingCompleteNotificationWithTorrentName:(NSString*)torrentName
                                               hashString:(NSString*)hashString
                                                 location:(NSString*)location
{
    NSString* title = NSLocalizedString(@"Seeding Complete", "notification title");
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:hashString forKey:UserInfoHashKey];
    if (location)
    {
        userInfo[UserInfoLocationKey] = location;
    }

    [self deliverNotificationWithIdentifier:[@"Seeding Complete " stringByAppendingString:hashString] title:title
                                       body:torrentName
                                   userInfo:userInfo
                              hasShowAction:YES];
}

- (void)deliverSpeedLimitChangedNotificationIsLimited:(BOOL)isLimited
{
    NSString* title = isLimited ? NSLocalizedString(@"Speed Limit Auto Enabled", "notification title") :
                                  NSLocalizedString(@"Speed Limit Auto Disabled", "notification title");
    NSString* body = NSLocalizedString(@"Bandwidth settings changed", "notification description");

    [self deliverNotificationWithIdentifier:@"Bandwidth settings changed" title:title body:body userInfo:nil hasShowAction:NO];
}

- (void)deliverTorrentFileAutoAddedNotificationWithFileName:(NSString*)fileName
{
    NSString* title = NSLocalizedString(@"Torrent File Auto Added", "notification title");

    [self deliverNotificationWithIdentifier:[@"Torrent File Auto Added " stringByAppendingString:fileName] title:title
                                       body:fileName
                                   userInfo:nil
                              hasShowAction:NO];
}

- (void)deliverNotificationWithIdentifier:(NSString*)identifier
                                    title:(NSString*)title
                                     body:(NSString*)body
                                 userInfo:(NSDictionary*)userInfo
                            hasShowAction:(BOOL)hasShowAction
{
#if TR_HAS_USER_NOTIFICATIONS
    if (@available(macOS 10.14, *))
    {
        UNMutableNotificationContent* content = [UNMutableNotificationContent new];
        content.title = title;
        content.body = body;
        if (hasShowAction)
        {
            content.categoryIdentifier = CategoryShowIdentifier;
        }
        if (userInfo)
        {
            content.userInfo = userInfo;
        }

        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:nil];
        return;
    }
#endif

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN
    NSUserNotification* notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = body;
    notification.hasActionButton = hasShowAction;
    if (hasShowAction)
    {
        notification.actionButtonTitle = NSLocalizedString(@"Show", "notification button");
    }
    notification.userInfo = [self legacyUserInfoByAddingIdentifier:identifier toUserInfo:userInfo];

    [self removeDeliveredLegacyNotificationWithIdentifier:identifier];
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
    TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END
#endif
}

#if TR_HAS_LEGACY_USER_NOTIFICATIONS
TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_BEGIN

- (NSDictionary*)legacyUserInfoByAddingIdentifier:(NSString*)identifier toUserInfo:(NSDictionary*)userInfo
{
    NSMutableDictionary* legacyUserInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    legacyUserInfo[UserInfoIdentifierKey] = identifier;
    return legacyUserInfo;
}

- (void)removeDeliveredLegacyNotificationWithIdentifier:(NSString*)identifier
{
    if (!identifier)
    {
        return;
    }

    for (NSUserNotification* notification in NSUserNotificationCenter.defaultUserNotificationCenter.deliveredNotifications)
    {
        if ([notification.userInfo[UserInfoIdentifierKey] isEqualToString:identifier])
        {
            [NSUserNotificationCenter.defaultUserNotificationCenter removeDeliveredNotification:notification];
        }
    }
}

- (BOOL)legacyNotificationUserInfoCanActivate:(NSDictionary*)userInfo
{
    return [userInfo[UserInfoHashKey] isKindOfClass:NSString.class];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter*)center shouldPresentNotification:(NSUserNotification*)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter*)center didActivateNotification:(NSUserNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if (![self legacyNotificationUserInfoCanActivate:userInfo])
    {
        return;
    }

    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked)
    {
        [self.delegate systemNotificationController:self didActivateShowActionWithUserInfo:userInfo];
    }
    else if (notification.activationType == NSUserNotificationActivationTypeContentsClicked)
    {
        [self.delegate systemNotificationController:self didActivateDefaultActionWithUserInfo:userInfo];
    }
}

TR_LEGACY_USER_NOTIFICATIONS_IGNORE_DEPRECATIONS_END
#endif

#if TR_HAS_USER_NOTIFICATIONS
#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter*)center
       willPresentNotification:(UNNotification*)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(-1);
}

- (void)userNotificationCenter:(UNUserNotificationCenter*)center
    didReceiveNotificationResponse:(UNNotificationResponse*)response
             withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary* userInfo = response.notification.request.content.userInfo;
    if (![userInfo[UserInfoHashKey] isKindOfClass:NSString.class])
    {
        completionHandler();
        return;
    }

    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier])
    {
        [self.delegate systemNotificationController:self didActivateDefaultActionWithUserInfo:userInfo];
    }
    else if ([response.actionIdentifier isEqualToString:ActionShowIdentifier])
    {
        [self.delegate systemNotificationController:self didActivateShowActionWithUserInfo:userInfo];
    }
    completionHandler();
}

#endif

@end
