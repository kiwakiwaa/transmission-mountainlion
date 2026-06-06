// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacyConstraints.h"

void TRSetConstraintActive(NSLayoutConstraint* constraint, BOOL active)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    constraint.active = active;
#else
    id firstItem = [constraint firstItem];
    if (![firstItem respondsToSelector:@selector(addConstraint:)])
    {
        return;
    }

    if (active)
    {
        [firstItem addConstraint:constraint];
    }
    else
    {
        [firstItem removeConstraint:constraint];
    }
#endif
}
