// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "LegacyArchiving.h"

NSData* TRArchivedDataForObject(id object)
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    return [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:nil];
#else
    return [NSKeyedArchiver archivedDataWithRootObject:object];
#endif
}

id TRUnarchiveObjectFromData(NSData* data, NSSet* allowedClasses)
{
    if (data == nil)
    {
        return nil;
    }

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101300
    return [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:data error:nil];
#else
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
#endif
}
