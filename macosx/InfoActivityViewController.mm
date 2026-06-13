// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#include <libtransmission/transmission.h>
#include <libtransmission/utils.h> //tr_getRatio()

#import "InfoActivityViewController.h"
#import "LegacyStackView.h"
#import "LegacyFormatters.h"
#import "NSStringAdditions.h"
#import "PiecesView.h"
#import "Torrent.h"

typedef NS_ENUM(NSUInteger, PiecesControlSegment) {
    PiecesControlSegmentProgress = 0,
    PiecesControlSegmentAvailable = 1,
};

static CGFloat const kStackViewInset = 12.0;
static CGFloat const kStackViewHorizontalSpacing = 20.0;
static CGFloat const kStackViewVerticalSpacing = 8.0;

@interface InfoActivityViewController ()

@property(nonatomic, copy) NSArray* fTorrents;

@property(nonatomic) BOOL fSet;

@property(nonatomic) IBOutlet NSTextField* fDateAddedField;
@property(nonatomic) IBOutlet NSTextField* fDateCompletedField;
@property(nonatomic) IBOutlet NSTextField* fDateActivityField;
@property(nonatomic) IBOutlet NSTextField* fStateField;
@property(nonatomic) IBOutlet NSTextField* fProgressField;
@property(nonatomic) IBOutlet NSTextField* fHaveField;
@property(nonatomic) IBOutlet NSTextField* fDownloadedTotalField;
@property(nonatomic) IBOutlet NSTextField* fUploadedTotalField;
@property(nonatomic) IBOutlet NSTextField* fFailedHashField;
@property(nonatomic) IBOutlet NSTextField* fRatioField;
@property(nonatomic) IBOutlet NSTextField* fDownloadTimeField;
@property(nonatomic) IBOutlet NSTextField* fSeedTimeField;
@property(nonatomic) IBOutlet NSTextView* fErrorMessageView;

@property(nonatomic) IBOutlet PiecesView* fPiecesView;
@property(nonatomic) IBOutlet NSSegmentedControl* fPiecesControl;

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
@property(nonatomic) IBOutlet LegacyStackView* fActivityStackView;
#else
@property(nonatomic) IBOutlet NSStackView* fActivityStackView;
#endif
@property(nonatomic) IBOutlet NSView* fDatesView;
@property(nonatomic, readonly) CGFloat fHeightChange;
@property(nonatomic, readwrite) CGFloat fCurrentHeight;
@property(nonatomic, readonly) CGFloat fHorizLayoutHeight;
@property(nonatomic, readonly) CGFloat fHorizLayoutWidth;
@property(nonatomic, readonly) CGFloat fVertLayoutHeight;

@end

@implementation InfoActivityViewController

- (instancetype)init
{
    if ((self = [super initWithNibName:@"InfoActivityView" bundle:nil]))
    {
        self.title = NSLocalizedString(@"Activity", "Inspector view -> title");
    }

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    TRCheckExpectedStackViewClass(self.fActivityStackView, NSStringFromClass(self.class), @"fActivityStackView");
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
    self.fActivityStackView.translatesAutoresizingMaskIntoConstraints = YES;
    self.fActivityStackView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
#endif
    [self checkWindowSize];
}

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
- (CGFloat)layoutWidth
{
    return self.view.window ? NSWidth(self.view.window.frame) : NSWidth(self.view.frame);
}

- (void)layoutLegacyStackView
{
    self.fActivityStackView.frame = NSInsetRect(self.view.bounds, kStackViewInset, kStackViewInset);
    [self.fActivityStackView layoutLegacySubviews];
}
#endif

- (CGFloat)fHorizLayoutHeight
{
    return NSHeight(self.fTransferView.frame) + 2 * kStackViewInset;
}

- (CGFloat)fHorizLayoutWidth
{
    return NSWidth(self.fTransferView.frame) + NSWidth(self.fDatesView.frame) + (2 * kStackViewInset) + kStackViewHorizontalSpacing;
}

- (CGFloat)fVertLayoutHeight
{
    return NSHeight(self.fTransferView.frame) + NSHeight(self.fDatesView.frame) + (2 * kStackViewInset) + kStackViewVerticalSpacing;
}

- (CGFloat)fHeightChange
{
    return self.oldHeight - self.fCurrentHeight;
}

- (NSRect)viewRect
{
    NSRect viewRect = self.view.frame;

    CGFloat difference = self.fHeightChange;
    viewRect.size.height -= difference;

    return viewRect;
}

- (void)checkLayout
{
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
    if (self.layoutWidth >= self.fHorizLayoutWidth + 1)
    {
        self.fActivityStackView.orientation = TRLegacyStackViewOrientationHorizontal;

        //add some padding between views in horizontal layout
        self.fActivityStackView.spacing = kStackViewHorizontalSpacing;
        self.fCurrentHeight = self.fHorizLayoutHeight;
    }
    else
    {
        self.fActivityStackView.orientation = TRLegacyStackViewOrientationVertical;
        self.fActivityStackView.spacing = kStackViewVerticalSpacing;
        self.fCurrentHeight = self.fVertLayoutHeight;
    }

    [self layoutLegacyStackView];
#else
    if (NSWidth(self.view.window.frame) >= self.fHorizLayoutWidth + 1)
    {
        self.fActivityStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;

        //add some padding between views in horizontal layout
        self.fActivityStackView.spacing = kStackViewHorizontalSpacing;
        self.fCurrentHeight = self.fHorizLayoutHeight;
    }
    else
    {
        self.fActivityStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
        self.fActivityStackView.spacing = kStackViewVerticalSpacing;
        self.fCurrentHeight = self.fVertLayoutHeight;
    }
#endif
}

- (void)checkWindowSize
{
    self.oldHeight = self.fCurrentHeight;

    [self updateWindowLayout];
}

- (void)updateWindowLayout
{
    [self checkLayout];

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
    if (!self.view.window)
    {
        return;
    }
#endif

    CGFloat difference = self.fHeightChange;

    NSRect windowRect = self.view.window.frame;
    windowRect.origin.y += difference;
    windowRect.size.height -= difference;

    self.view.window.minSize = NSMakeSize(self.view.window.minSize.width, NSHeight(windowRect));
    self.view.window.maxSize = NSMakeSize(FLT_MAX, NSHeight(windowRect));

    self.view.frame = [self viewRect];
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1090
    [self layoutLegacyStackView];
#endif
    [self.view.window setFrame:windowRect display:YES animate:YES];
}

- (void)setInfoForTorrents:(NSArray*)torrents
{
    //don't check if it's the same in case the metadata changed
    self.fTorrents = torrents;

    self.fSet = NO;
}

- (void)updateInfo
{
    if (!self.fSet)
    {
        [self setupInfo];
    }

    NSInteger const numberSelected = self.fTorrents.count;
    if (numberSelected == 0)
    {
        return;
    }

    uint64_t have = 0;
    uint64_t haveVerified = 0;
    uint64_t downloadedTotal = 0;
    uint64_t uploadedTotal = 0;
    uint64_t failedHash = 0;
    NSDate* lastActivity = nil;
    for (Torrent* torrent in self.fTorrents)
    {
        have += torrent.haveTotal;
        haveVerified += torrent.haveVerified;
        downloadedTotal += torrent.downloadedTotal;
        uploadedTotal += torrent.uploadedTotal;
        failedHash += torrent.failedHash;

        NSDate* nextLastActivity;
        if ((nextLastActivity = torrent.dateActivity))
        {
            lastActivity = lastActivity ? [lastActivity laterDate:nextLastActivity] : nextLastActivity;
        }
    }

    if (have == 0)
    {
        self.fHaveField.stringValue = [NSString stringForFileSize:0];
    }
    else
    {
        NSString* verifiedString = [NSString stringWithFormat:NSLocalizedString(@"%@ verified", "Inspector -> Activity tab -> have"),
                                                              [NSString stringForFileSize:haveVerified]];
        if (have == haveVerified)
        {
            self.fHaveField.stringValue = verifiedString;
        }
        else
        {
            self.fHaveField.stringValue = [NSString stringWithFormat:@"%@ (%@)", [NSString stringForFileSize:have], verifiedString];
        }
    }

    self.fDownloadedTotalField.stringValue = [NSString stringForFileSize:downloadedTotal];
    self.fUploadedTotalField.stringValue = [NSString stringForFileSize:uploadedTotal];
    self.fFailedHashField.stringValue = [NSString stringForFileSize:failedHash];

    self.fDateActivityField.objectValue = lastActivity;

    if (numberSelected == 1)
    {
        Torrent* torrent = self.fTorrents[0];

        self.fStateField.stringValue = torrent.stateString;

        NSString* progressString = [NSString percentString:torrent.progress longDecimals:YES];
        if (torrent.folder)
        {
            NSString* progressSelectedString = [NSString
                stringWithFormat:NSLocalizedString(@"%@ selected", "Inspector -> Activity tab -> progress"),
                                 [NSString percentString:torrent.progressDone longDecimals:YES]];
            progressString = [progressString stringByAppendingFormat:@" (%@)", progressSelectedString];
        }
        self.fProgressField.stringValue = progressString;

        self.fRatioField.stringValue = [NSString stringForRatio:torrent.ratio];

        NSString* errorMessage = torrent.errorMessage;
        if (![errorMessage isEqualToString:self.fErrorMessageView.string])
            self.fErrorMessageView.string = errorMessage;

        self.fDateCompletedField.objectValue = torrent.dateCompleted;

        //uses a relative date, so can't be set once
        self.fDateAddedField.objectValue = torrent.dateAdded;

        self.fDownloadTimeField.stringValue = TRShortDurationString(torrent.secondsDownloading);
        self.fSeedTimeField.stringValue = TRShortDurationString(torrent.secondsSeeding);

        [self.fPiecesView updateView];
    }
    else if (numberSelected > 1)
    {
        self.fRatioField.stringValue = [NSString stringForRatio:tr_getRatio(uploadedTotal, downloadedTotal)];
    }
}

- (void)setPiecesView:(id)sender
{
    BOOL const availability = [sender selectedSegment] == PiecesControlSegmentAvailable;
    [NSUserDefaults.standardUserDefaults setBool:availability forKey:@"PiecesViewShowAvailability"];
    [self updatePiecesView:nil];
}

- (void)updatePiecesView:(id)sender
{
    BOOL const piecesAvailableSegment = [NSUserDefaults.standardUserDefaults boolForKey:@"PiecesViewShowAvailability"];

    [self.fPiecesControl setSelected:piecesAvailableSegment forSegment:PiecesControlSegmentAvailable];
    [self.fPiecesControl setSelected:!piecesAvailableSegment forSegment:PiecesControlSegmentProgress];

    [self.fPiecesView updateView];
}

- (void)clearView
{
    [self.fPiecesView clearView];
}

#pragma mark - Private

- (void)setupInfo
{
    NSUInteger const count = self.fTorrents.count;
    if (count != 1)
    {
        if (count == 0)
        {
            self.fHaveField.stringValue = @"";
            self.fDownloadedTotalField.stringValue = @"";
            self.fUploadedTotalField.stringValue = @"";
            self.fFailedHashField.stringValue = @"";
            self.fDateActivityField.objectValue = @""; //using [field setStringValue: @""] causes "December 31, 1969 7:00 PM" to be displayed, at least on 10.7.3
            self.fRatioField.stringValue = @"";
        }

        self.fStateField.stringValue = @"";
        self.fProgressField.stringValue = @"";

        self.fErrorMessageView.string = @"";

        //using [field setStringValue: @""] causes "December 31, 1969 7:00 PM" to be displayed, at least on 10.7.3
        self.fDateAddedField.objectValue = @"";
        self.fDateCompletedField.objectValue = @"";

        self.fDownloadTimeField.stringValue = @"";
        self.fSeedTimeField.stringValue = @"";

        [self.fPiecesControl setSelected:NO forSegment:PiecesControlSegmentAvailable];
        [self.fPiecesControl setSelected:NO forSegment:PiecesControlSegmentProgress];
        self.fPiecesControl.enabled = NO;
        self.fPiecesView.torrent = nil;
    }
    else
    {
        Torrent* torrent = self.fTorrents[0];

        BOOL const piecesAvailableSegment = [NSUserDefaults.standardUserDefaults boolForKey:@"PiecesViewShowAvailability"];
        [self.fPiecesControl setSelected:piecesAvailableSegment forSegment:PiecesControlSegmentAvailable];
        [self.fPiecesControl setSelected:!piecesAvailableSegment forSegment:PiecesControlSegmentProgress];
        self.fPiecesControl.enabled = YES;

        self.fPiecesView.torrent = torrent;
    }

    self.fSet = YES;
}

@end
