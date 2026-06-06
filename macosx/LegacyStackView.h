// This file Copyright (c) Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, TRLegacyStackViewOrientation) {
    TRLegacyStackViewOrientationHorizontal = 0,
    TRLegacyStackViewOrientationVertical = 1,
};

typedef NS_ENUM(NSInteger, TRLegacyStackViewVisibilityPriority) {
    TRLegacyStackViewVisibilityPriorityNotVisible = 0,
    TRLegacyStackViewVisibilityPriorityMustHold = 1000,
};

@interface LegacyStackView : NSView

@property(nonatomic) TRLegacyStackViewOrientation orientation;
@property(nonatomic) CGFloat spacing;

- (void)layoutLegacySubviews;

- (void)setVisibilityPriority:(TRLegacyStackViewVisibilityPriority)priority forView:(NSView*)view;

@end
