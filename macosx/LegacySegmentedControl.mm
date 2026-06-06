// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacySegmentedControl.h"

void TRSetSegmentTag(NSSegmentedControl* control, NSInteger tag, NSInteger segment)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    [control setTag:tag forSegment:segment];
#else
    (void)control;
    (void)tag;
    (void)segment;
#endif
}

NSInteger TRSelectedSegmentTag(NSSegmentedControl* control)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    return [control selectedTag];
#else
    return [control selectedSegment];
#endif
}

void TRSetSegmentToolTip(NSSegmentedControl* control, NSString* toolTip, NSInteger segment)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    [control setToolTip:toolTip forSegment:segment];
#else
    (void)segment;
    [control setToolTip:toolTip];
#endif
}
