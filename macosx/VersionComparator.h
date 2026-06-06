// This file Copyright © 2023 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Foundation/Foundation.h>

#ifndef TR_ENABLE_SPARKLE
#define TR_ENABLE_SPARKLE 1
#endif

#if TR_ENABLE_SPARKLE
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
