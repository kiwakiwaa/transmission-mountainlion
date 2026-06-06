// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "NSApplicationAdditions.h"

@implementation NSApplication (NSApplicationAdditions)

- (BOOL)isDarkMode
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101400
    return [self.effectiveAppearance.name isEqualToString:NSAppearanceNameDarkAqua];
#else
    return NO;
#endif
}

@end
