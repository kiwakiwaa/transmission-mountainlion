// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

void TRSetSegmentTag(NSSegmentedControl* control, NSInteger tag, NSInteger segment);
NSInteger TRSelectedSegmentTag(NSSegmentedControl* control);
void TRSetSegmentToolTip(NSSegmentedControl* control, NSString* toolTip, NSInteger segment);
