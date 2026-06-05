// This file Copyright © 2023 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Foundation/Foundation.h>

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1090
#import <Sparkle/SUVersionComparisonProtocol.h>
#else
@protocol SUVersionComparison<NSObject>
- (NSComparisonResult)compareVersion:(NSString*)versionA toVersion:(NSString*)versionB;
@end

#endif

NS_ASSUME_NONNULL_BEGIN

@interface VersionComparator : NSObject<SUVersionComparison>

@end

NS_ASSUME_NONNULL_END
