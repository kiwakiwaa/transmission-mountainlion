// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacyPowerActivity.h"

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
