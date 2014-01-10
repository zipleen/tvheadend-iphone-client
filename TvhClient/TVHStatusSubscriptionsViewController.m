//
//  TVHStatusSubscriptionsViewController.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHStatusSubscriptionsViewController.h"
#import "CKRefreshControl.h"
#import "TVHShowNotice.h"
#import "NSString+FileSize.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "TVHSingletonServer.h"
#import "TVHAdapter.h"
#import "TVHStatusInput.h"
#import "TVHNetwork.h"
#import "TVHAdapterMuxViewController.h"
#import "TVHProgressBar.h"
#import "TVHStatusSplitViewController.h"
#import "TVHDebugLogViewController.h"
#import "TVHWebLogViewController.h"
#import "TVHSettings.h"

#define SubscriptionsSection 0
#define AdaptersSection 1
#define StreamInputsSection 2
#define NetworksSection 3

@interface TVHStatusSubscriptionsViewController (){
    NIKFontAwesomeIconFactory *factory;
    NIKFontAwesomeIconFactory *factoryBar;
    UIActivityIndicatorView *act;
    NSDate *lastTableUpdate;
}

@property (weak, nonatomic) id <TVHStatusSubscriptionsStore> statusSubscriptionsStore;
@property (weak, nonatomic) id <TVHAdaptersStore> adapterStore;
@property (weak, nonatomic) id <TVHStatusInputStore> inputStore;
@property (weak, nonatomic) id <TVHNetworkStore> networkStore;
@property (weak, nonatomic) id <TVHCometPoll> cometPoll;
@end

@implementation TVHStatusSubscriptionsViewController

- (id <TVHStatusSubscriptionsStore>)statusSubscriptionsStore {
    if ( _statusSubscriptionsStore == nil) {
        _statusSubscriptionsStore = [[TVHSingletonServer sharedServerInstance] statusStore];
        
        if( [_statusSubscriptionsStore delegate] ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLoadAdapters)
                                                         name:TVHAdapterStoreDidLoadNotification
                                                       object:_statusSubscriptionsStore];
        } else {
            [_statusSubscriptionsStore setDelegate:self];
        }
    }
    return _statusSubscriptionsStore;
}

- (id <TVHAdaptersStore>)adapterStore {
    if ( _adapterStore == nil) {
        _adapterStore = [[TVHSingletonServer sharedServerInstance] adapterStore];
        
        if( [_adapterStore delegate] ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLoadStatusSubscriptions)
                                                         name:TVHStatusSubscriptionStoreDidLoadNotification
                                                       object:_adapterStore];
        } else {
            [_adapterStore setDelegate:self];
        }
    }
    return _adapterStore;
}

- (id <TVHStatusInputStore>)inputStore {
    if ( _inputStore == nil) {
        _inputStore = [[TVHSingletonServer sharedServerInstance] inputStore];
        
        if( [_inputStore delegate] ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLoadStatusInputs)
                                                         name:TVHStatusInputStoreDidLoadNotification
                                                       object:_adapterStore];
        } else {
            [_inputStore setDelegate:self];
        }
    }
    return _inputStore;
}

- (id <TVHNetworkStore>)networkStore {
    if ( _networkStore == nil) {
        _networkStore = [[TVHSingletonServer sharedServerInstance] networkStore];
        
        if( [_networkStore delegate] ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLoadNetwork)
                                                         name:TVHNetworkStoreDidLoadNotification
                                                       object:_networkStore];
        } else {
            [_networkStore setDelegate:self];
        }
    }
    return _networkStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    int shiftButton = 0;
    
    if ( self.splitViewController ) {
        NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
        UIBarButtonItem *logButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showSplitLog:)];
        [buttons addObject:logButton];
        shiftButton++;
        
        if ( [[TVHSettings sharedInstance] web1Url] ) {
            UIBarButtonItem *webButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Web", nil)
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showSplitWeb:)];
            [buttons addObject:webButton];
            shiftButton++;
        }
        self.navigationItem.rightBarButtonItems = [buttons copy];
    }
    
    self.cometPoll = [[TVHSingletonServer sharedServerInstance] cometStore];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    factory.size = 32;
    factory.square = YES;
    
    factoryBar = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factoryBar.size = 16;
    
    // from: http://stackoverflow.com/questions/10469550/add-uiactivityindicatorview-into-uibarbuttonitem-on-uinavigationbar-ios
    act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [act setFrame:CGRectMake(8, 5, 20, 20)];
    [act setUserInteractionEnabled:NO];
    if ( DEVICE_HAS_IOS7 ) {
        [act setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    NSUInteger navigationControllerCount = [[self.navigationController.navigationBar subviews] count];
    if ( navigationControllerCount >= 2 ) {
        if ( DEVICE_HAS_IOS7 && ! IS_IPAD ) {
            shiftButton += 1;
        }
        [[[self.navigationController.navigationBar subviews] objectAtIndex:navigationControllerCount-(1+shiftButton)] addSubview:act];
    }
    [self.navigationItem.rightBarButtonItem setImage:[factoryBar createImageForIcon:NIKFontAwesomeIconRefresh]];
    lastTableUpdate = [NSDate dateWithTimeIntervalSinceNow:-1];
    
    self.title = NSLocalizedString(@"Status", @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetControllerData)
                                                 name:TVHWillDestroyServerNotification
                                               object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.adapterStore = nil;
    self.cometPoll = nil;
    self.statusSubscriptionsStore = nil;
    self.inputStore = nil;
    [self setSwitchButton:nil];
    [super viewDidUnload];
}

- (void)resetControllerData
{
    [self pullToRefreshViewShouldRefresh];
}

- (void)changePollingIcon {
    
    if ( [self.cometPoll isTimerStarted] ) {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"empty.png"]];
        [act startAnimating];
    } else {
        [self.navigationItem.rightBarButtonItem setImage:[factoryBar createImageForIcon:NIKFontAwesomeIconRefresh]];
        [act stopAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.adapterStore fetchAdapters];
    //[self.statusSubscriptionsStore fetchStatusSubscriptions];
    [self changePollingIcon];
}

- (void)viewDidAppear:(BOOL)animated {
    [TVHAnalytics sendView:NSStringFromClass([self class])];
}

- (void)pullToRefreshViewShouldRefresh {
    [self.tableView reloadData];
    [self.statusSubscriptionsStore fetchStatusSubscriptions];
    [self.adapterStore fetchAdapters];
    [self.inputStore fetchStatusInputs];
    [self.networkStore fetchNetworks];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section == SubscriptionsSection && self.statusSubscriptionsStore ) {
        return NSLocalizedString(@"Active Subscriptions", nil);
    }
    if ( section == AdaptersSection && self.adapterStore ) {
        return NSLocalizedString(@"Adapters", nil);
    }
    if ( section == StreamInputsSection && self.inputStore ) {
        return NSLocalizedString(@"Stream Inputs", nil);
    }
    if ( section == NetworksSection && self.networkStore ) {
        return NSLocalizedString(@"Networks", nil);
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( section == SubscriptionsSection ) {
        if ( [self.statusSubscriptionsStore count] == 0 && self.statusSubscriptionsStore ) {
            return NSLocalizedString(@"No active subscriptions.", nil);
        }
    }
    if ( section == AdaptersSection ) {
        if ( [self.adapterStore count] == 0 && self.adapterStore ) {
            return NSLocalizedString(@"No adapters found.", nil);
        }
    }
    if ( section == StreamInputsSection ) {
        if ( [self.inputStore count] == 0 && self.inputStore ) {
            return NSLocalizedString(@"No Stream found.", nil);
        }
    }
    if ( section == NetworksSection ) {
        if ( [self.networkStore count] == 0 && self.networkStore ) {
            return NSLocalizedString(@"No Networks found.", nil);
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == SubscriptionsSection ) {
        return [self.statusSubscriptionsStore count];
    }
    if ( section == AdaptersSection ) {
        return [self.adapterStore count];
    }
    if ( section == StreamInputsSection ) {
        return [self.inputStore count];
    }
    if ( section == NetworksSection ) {
        return [self.networkStore count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == SubscriptionsSection ) {
        cell = [self cellForActiveSubscription:tableView atRowIndexPath:indexPath];
    }
    if ( indexPath.section == AdaptersSection ) {
        cell = [self cellForAdapter:tableView atRowIndexPath:indexPath];
    }
    if ( indexPath.section == StreamInputsSection ) {
        cell = [self cellForStreamInput:tableView atRowIndexPath:indexPath];
    }
    if ( indexPath.section == NetworksSection ) {
        cell = [self cellForNetwork:tableView atRowIndexPath:indexPath];
    }

    return cell;
}

- (UITableViewCell *)cellForActiveSubscription:(UITableView *)tableView atRowIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionStoreSubscriptionItems" ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubscriptionStoreSubscriptionItems"];
    }
    
    UILabel *hostnameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *programLabel = (UILabel *)[cell viewWithTag:110];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *channelLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *serviceLabel = (UILabel *)[cell viewWithTag:104];
    //UILabel *startLabel = (UILabel *)[cell viewWithTag:105];
    UILabel *stateLabel = (UILabel *)[cell viewWithTag:106];
    UILabel *errorsLabel = (UILabel *)[cell viewWithTag:107];
    UILabel *bandwidthLabel = (UILabel *)[cell viewWithTag:108];
    UIImageView *channelIcon = (UIImageView *)[cell viewWithTag:120];
    UIImageView *stateIcon = (UIImageView *)[cell viewWithTag:121];
    UIImageView *errorIcon = (UIImageView *)[cell viewWithTag:122];
    UIImageView *bwIcon = (UIImageView *)[cell viewWithTag:123];
    UIImageView *clientIcon = (UIImageView *)[cell viewWithTag:124];
    UIImageView *client2Icon = (UIImageView *)[cell viewWithTag:125];
    
    TVHStatusSubscription *subscription = [self.statusSubscriptionsStore objectAtIndex:indexPath.row];
    TVHChannel *channel = [[[TVHSingletonServer sharedServerInstance] channelStore] channelWithName:subscription.channel];
    
    hostnameLabel.text = subscription.hostname;
    programLabel.text = [channel.currentPlayingProgram title];
    titleLabel.text = subscription.title;
    channelLabel.text = subscription.channel;
    serviceLabel.text = subscription.service;
    //startLabel.text = [subscription.start description];
    stateLabel.text = subscription.state;
    errorsLabel.text = [NSString stringWithFormat:@"%ld", (long)subscription.errors];
    bandwidthLabel.text = [NSString stringWithFormat:@"%@", [NSString stringFromFileSizeInBits:subscription.bw]];
    
    [channelIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconDesktop]];
    [channelIcon setContentMode:UIViewContentModeScaleAspectFit];
    [stateIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconSignal]];
    [stateIcon setContentMode:UIViewContentModeScaleAspectFit];
    [errorIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconExclamationSign]];
    [errorIcon setContentMode:UIViewContentModeScaleAspectFit];
    [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
    [bwIcon setContentMode:UIViewContentModeScaleAspectFit];
    [clientIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconHdd]];
    [clientIcon setContentMode:UIViewContentModeScaleAspectFit];
    [client2Icon setImage:[factory createImageForIcon:NIKFontAwesomeIconPlayCircle]];
    [client2Icon setContentMode:UIViewContentModeScaleAspectFit];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (UITableViewCell *)cellForAdapter:(UITableView *)tableView atRowIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionStoreAdapterItems" ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubscriptionStoreAdapterItems"];
    }
    
    UILabel *deviceNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *adapterPathLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *bwLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *serviceLabel = (UILabel *)[cell viewWithTag:104];
    UILabel *snrLabel = (UILabel *)[cell viewWithTag:105];
    UILabel *uncLabel = (UILabel *)[cell viewWithTag:106];
    UILabel *berLabel = (UILabel *)[cell viewWithTag:107];
    UILabel *signalLabel = (UILabel *)[cell viewWithTag:108];
    UIImageView *bwIcon = (UIImageView *)[cell viewWithTag:301];
    TVHProgressBar *progress = (TVHProgressBar *)[cell viewWithTag:110];
    [progress setTintColor:PROGRESS_BAR_PLAYBACK];
    CGRect progressBarFrame = {
        .origin.x = progress.frame.origin.x,
        .origin.y = progress.frame.origin.y,
        .size.width = progress.frame.size.width,
        .size.height = 4,
    };
    [progress setFrame:progressBarFrame];
    
    TVHAdapter *adapter = [self.adapterStore objectAtIndex:indexPath.row];
    
    deviceNameLabel.text = adapter.devicename;
    adapterPathLabel.text = [NSString stringWithFormat:@"%@ ( %@ )", adapter.name, adapter.path];
    bwLabel.text = [NSString stringFromFileSizeInBits:adapter.bw];
    serviceLabel.text = adapter.currentMux;
    snrLabel.text = [NSString stringWithFormat:@"%.1f dB", adapter.snr];
    uncLabel.text = [NSString stringWithFormat:@"%ld", (long)adapter.uncavg];
    berLabel.text = [NSString stringWithFormat:@"%ld", (long)adapter.ber];
    signalLabel.text = [NSString stringWithFormat:@"%ld %%", (long)adapter.signal];
    progress.progress = (float)adapter.signal/100;
    [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
    [bwIcon setContentMode:UIViewContentModeScaleAspectFit];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)cellForStreamInput:(UITableView *)tableView atRowIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusInputItems" ];
    if ( cell==nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StatusInputItems"];
    }
    
    UILabel *deviceNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *adapterPathLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *bwLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *serviceLabel = (UILabel *)[cell viewWithTag:104];
    UILabel *snrLabel = (UILabel *)[cell viewWithTag:105];
    UILabel *uncLabel = (UILabel *)[cell viewWithTag:106];
    UILabel *berLabel = (UILabel *)[cell viewWithTag:107];
    UILabel *signalLabel = (UILabel *)[cell viewWithTag:108];
    UIImageView *bwIcon = (UIImageView *)[cell viewWithTag:301];
    TVHProgressBar *progress = (TVHProgressBar *)[cell viewWithTag:110];
    [progress setTintColor:PROGRESS_BAR_PLAYBACK];
    CGRect progressBarFrame = {
        .origin.x = progress.frame.origin.x,
        .origin.y = progress.frame.origin.y,
        .size.width = progress.frame.size.width,
        .size.height = 4,
    };
    [progress setFrame:progressBarFrame];
    
    TVHStatusInput *input = [self.inputStore objectAtIndex:indexPath.row];
    
    deviceNameLabel.text = [NSString stringWithFormat:@"Subs: %ld Weight: %ld", (long)input.subs, (long)input.weight];
    adapterPathLabel.text = input.input;
    bwLabel.text = [NSString stringFromFileSizeInBits:input.bps];
    serviceLabel.text = input.stream;
    snrLabel.text = [NSString stringWithFormat:@"%.1f dB", input.snr];
    uncLabel.text = [NSString stringWithFormat:@"%ld", (long)input.unc];
    berLabel.text = [NSString stringWithFormat:@"%ld", (long)input.ber];
    signalLabel.text = [NSString stringWithFormat:@"%ld %%", (long)input.signal];
    progress.progress = (float)input.signal/100;
    [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
    [bwIcon setContentMode:UIViewContentModeScaleAspectFit];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (UITableViewCell *)cellForNetwork:(UITableView *)tableView atRowIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetworkItems" ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NetworkItems"];
    }
    
    UILabel *networkNameLabel = (UILabel *)[cell viewWithTag:105];
    UILabel *servicesLabel = (UILabel *)[cell viewWithTag:106];
    UILabel *muxesLabel = (UILabel *)[cell viewWithTag:107];
    
    TVHNetwork *network = [self.networkStore objectAtIndex:indexPath.row];
    
    networkNameLabel.text = network.networkname;
    servicesLabel.text = [NSString stringWithFormat:@"%ld", (long)network.num_svc];
    muxesLabel.text = [NSString stringWithFormat:@"%ld", (long)network.num_mux];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate - click actions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == AdaptersSection ) {
        if ( indexPath.row  < [self.adapterStore count] ) {
            [self performSegueWithIdentifier:@"Show DVB Mux" sender:self];
        }
    }
    
    if ( indexPath.section == NetworksSection  ) {
        if ( indexPath.row  < [self.networkStore count] ) {
            [self performSegueWithIdentifier:@"Show DVB Mux" sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Show DVB Mux"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHAdapterMuxViewController *mux = segue.destinationViewController;
        
        if ( path.section == AdaptersSection ) {
            TVHAdapter *adapter = [self.adapterStore objectAtIndex:path.row];
            [mux setAdapter:adapter];
            [mux setTitle:adapter.name];
        }
        if ( path.section == NetworksSection ) {
            TVHNetwork *network = [self.networkStore objectAtIndex:path.row];
            [mux setNetwork:network];
            [mux setTitle:network.networkname];
        }
    }
}

#pragma mark - TVH Model objects refresh delegates

- (void)didLoadStatusSubscriptions {
    [self doReloadData];
}

- (void)didLoadAdapters {
    [self doReloadData];
}

- (void)didLoadStatusInputs {
    [self doReloadData];
}

- (void)didLoadNetwork {
    [self doReloadData];
}

- (void)doReloadData
{
    if ( [[NSDate date] compare:[lastTableUpdate dateByAddingTimeInterval:1]] == NSOrderedDescending ) {
        [self.tableView reloadData];
        lastTableUpdate = [NSDate date];
        [self.refreshControl endRefreshing];
    }
}

- (void)willLoadAdapters {
    [self.refreshControl beginRefreshing];
    //[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
}

- (void)willLoadStatusSubscriptions {
    [self.refreshControl beginRefreshing];
    //[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
}

- (void)didErrorStatusSubscriptionsStore:(NSError *)error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    
    [self.refreshControl endRefreshing];
}

- (void)didErrorAdaptersStore:(NSError *)error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    
    [self.refreshControl endRefreshing];
}

- (IBAction)switchPolling:(id)sender {
    if ( [self.cometPoll isTimerStarted] ) {
        [self.cometPoll stopRefreshingCometPoll];
    } else {
        [self.cometPoll startRefreshingCometPoll];
    }
    [self changePollingIcon];
}

#pragma mark iPad Split Button Actions

- (IBAction)showSplitLog:(id)sender {
    if( self.splitViewController ) {
        
        if ( ! [self.splitViewController isShowingMaster] ||
            [[self.splitViewController masterViewController] isKindOfClass:[UINavigationController class]] ) {
            
            if ( [[TVHSettings sharedInstance] statusShowLog] ) {
                [[TVHSettings sharedInstance] setStatusShowLog:NO];
            } else {
                [[TVHSettings sharedInstance] setStatusShowLog:YES];
            }
            [(TVHStatusSplitViewController*)self.splitViewController setSecondScreenAsDebug];
            [self.splitViewController toggleMasterView:sender];
        }
        [(TVHStatusSplitViewController*)self.splitViewController setSecondScreenAsDebug];
        
    }
}

- (IBAction)showSplitWeb:(id)sender {
    if( self.splitViewController ) {
        if ( ! [self.splitViewController isShowingMaster] ||
            [[self.splitViewController masterViewController] isKindOfClass:[TVHWebLogViewController class]] ) {
            
            if ( [[TVHSettings sharedInstance] statusShowLog] ) {
                [[TVHSettings sharedInstance] setStatusShowLog:NO];
            } else {
                [[TVHSettings sharedInstance] setStatusShowLog:YES];
            }
            [(TVHStatusSplitViewController*)self.splitViewController setSecondScreenAsWeb];
            [self.splitViewController toggleMasterView:sender];
        }
        [(TVHStatusSplitViewController*)self.splitViewController setSecondScreenAsWeb];
    }
}

@end
