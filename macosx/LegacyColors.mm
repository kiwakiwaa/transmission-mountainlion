// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacyColors.h"

NSColor* TRLabelColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor labelColor];
#else
    return [NSColor controlTextColor];
#endif
}

NSColor* TRSecondaryLabelColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor secondaryLabelColor];
#else
    return [NSColor disabledControlTextColor];
#endif
}

NSColor* TRSystemRedColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemRedColor];
#else
    return [NSColor redColor];
#endif
}

NSColor* TRSystemOrangeColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemOrangeColor];
#else
    return [NSColor orangeColor];
#endif
}

NSColor* TRSystemYellowColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemYellowColor];
#else
    return [NSColor yellowColor];
#endif
}

NSColor* TRSystemGreenColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemGreenColor];
#else
    return [NSColor greenColor];
#endif
}

NSColor* TRSystemBlueColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemBlueColor];
#else
    return [NSColor blueColor];
#endif
}

NSColor* TRSystemPurpleColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemPurpleColor];
#else
    return [NSColor purpleColor];
#endif
}

NSColor* TRSystemGrayColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemGrayColor];
#else
    return [NSColor grayColor];
#endif
}

NSColor* TRSystemTealColor(void)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [NSColor systemTealColor];
#else
    return [NSColor cyanColor];
#endif
}
