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
#import "TVHAdapterMuxViewController.h"
#import "TVHProgressBar.h"
#import "TVHStatusSplitViewController.h"

#import "TVHDebugLogViewController.h"
#import "TVHWebLogViewController.h"

@interface TVHStatusSubscriptionsViewController (){
    NIKFontAwesomeIconFactory *factory;
    NIKFontAwesomeIconFactory *factoryBar;
    UIActivityIndicatorView *act;
    NSDate *lastTableUpdate;
}

@property (weak, nonatomic) id <TVHStatusSubscriptionsStore> statusSubscriptionsStore;
@property (weak, nonatomic) id <TVHAdaptersStore> adapterStore;
@property (weak, nonatomic) id <TVHStatusInputStore> inputStore;
@property (weak, nonatomic) id <TVHCometPoll> cometPoll;
@end

@implementation TVHStatusSubscriptionsViewController

- (id <TVHStatusSubscriptionsStore>)statusSubscriptionsStore {
    if ( _statusSubscriptionsStore == nil) {
        _statusSubscriptionsStore = [[TVHSingletonServer sharedServerInstance] statusStore];
        
        if( [_statusSubscriptionsStore delegate] ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLoadAdapters)
                                                         name:@"didLoadAdapters"
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
                                                         name:@"didLoadStatusSubscriptions"
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
                                                         name:@"didLoadStatusInputs"
                                                       object:_adapterStore];
        } else {
            [_inputStore setDelegate:self];
        }
    }
    return _inputStore;
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
    
    int navigationControllerCount = [[self.navigationController.navigationBar subviews] count];
    if ( navigationControllerCount >= 2 ) {
        if ( DEVICE_HAS_IOS7 && ! IS_IPAD ) {
            shiftButton += 1;
        }
        [[[self.navigationController.navigationBar subviews] objectAtIndex:navigationControllerCount-(1+shiftButton)] addSubview:act];
    }
    [self.navigationItem.rightBarButtonItem setImage:[factoryBar createImageForIcon:NIKFontAwesomeIconRefresh]];
    lastTableUpdate = [NSDate dateWithTimeIntervalSinceNow:-1];
    
    self.title = NSLocalizedString(@"Status", @"");
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:_adapterStore];
    [[NSNotificationCenter defaultCenter] removeObserver:_statusSubscriptionsStore];
    self.adapterStore = nil;
    self.cometPoll = nil;
    self.statusSubscriptionsStore = nil;
    self.inputStore = nil;
    [self setSwitchButton:nil];
    [super viewDidUnload];
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

- (void)didLoadStatusSubscriptions {
    if ( [[NSDate date] compare:[lastTableUpdate dateByAddingTimeInterval:1]] == NSOrderedDescending ) {
        [self.tableView reloadData];
        lastTableUpdate = [NSDate date];
        [self.refreshControl endRefreshing];
    }
}

- (void)didLoadAdapters {
    if ( [[NSDate date] compare:[lastTableUpdate dateByAddingTimeInterval:1]] == NSOrderedDescending ) {
        [self.tableView reloadData];
        lastTableUpdate = [NSDate date];
        [self.refreshControl endRefreshing];
    }
}

- (void)didLoadStatusInputs {
    if ( [[NSDate date] compare:[lastTableUpdate dateByAddingTimeInterval:1]] == NSOrderedDescending ) {
        [self.tableView reloadData];
        lastTableUpdate = [NSDate date];
        [self.refreshControl endRefreshing];
    }
}

- (void)pullToRefreshViewShouldRefresh {
    [self.tableView reloadData];
    [self.statusSubscriptionsStore fetchStatusSubscriptions];
    [self.adapterStore fetchAdapters];
    [self.inputStore fetchStatusInputs];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section == 0 && self.statusSubscriptionsStore ) {
        return NSLocalizedString(@"Active Subscriptions", nil);
    }
    if ( section == 1 && self.adapterStore ) {
        return NSLocalizedString(@"Adapters", nil);
    }
    if ( section == 2 && self.inputStore ) {
        return NSLocalizedString(@"Stream Inputs", nil);
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( section == 0 ) {
        if ( [self.statusSubscriptionsStore count] == 0 && self.statusSubscriptionsStore ) {
            return NSLocalizedString(@"No active subscriptions.", nil);
        }
    }
    if ( section == 1 ) {
        if ( [self.adapterStore count] == 0 && self.adapterStore ) {
            return NSLocalizedString(@"No adapters found.", nil);
        }
    }
    if ( section == 2 ) {
        if ( [self.inputStore count] == 0 && self.inputStore ) {
            return NSLocalizedString(@"No Stream found.", nil);
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return [self.statusSubscriptionsStore count];
    }
    if ( section == 1 ) {
        return [self.adapterStore count];
    }
    if ( section == 2 ) {
        return [self.inputStore count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ( indexPath.section == 0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionStoreSubscriptionItems" ];
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
        errorsLabel.text = [NSString stringWithFormat:@"%d", subscription.errors];
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
    }
    if ( indexPath.section == 1 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionStoreAdapterItems" ];
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
        uncLabel.text = [NSString stringWithFormat:@"%d", adapter.uncavg];
        berLabel.text = [NSString stringWithFormat:@"%d", adapter.ber];
        signalLabel.text = [NSString stringWithFormat:@"%d %%", adapter.signal];
        progress.progress = (float)adapter.signal/100;
        [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
        [bwIcon setContentMode:UIViewContentModeScaleAspectFit];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ( indexPath.section == 2 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionStoreAdapterItems" ];
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
        
        TVHStatusInput *input = [self.inputStore objectAtIndex:indexPath.row];
        
        deviceNameLabel.text = input.stream;
        adapterPathLabel.text = input.input;
        bwLabel.text = [NSString stringFromFileSizeInBits:input.bps];
        serviceLabel.text = input.stream;
        snrLabel.text = [NSString stringWithFormat:@"%.1f dB", input.snr];
        uncLabel.text = [NSString stringWithFormat:@"%d", input.unc];
        berLabel.text = [NSString stringWithFormat:@"%d", input.ber];
        signalLabel.text = [NSString stringWithFormat:@"%d %%", input.signal];
        progress.progress = (float)input.signal/100;
        [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
        [bwIcon setContentMode:UIViewContentModeScaleAspectFit];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 1 ) {
        if ( indexPath.row  < [self.adapterStore count] ) {
            [self performSegueWithIdentifier:@"Show DVB Mux" sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Show DVB Mux"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHAdapter *adapter = [self.adapterStore objectAtIndex:path.row];
        
        TVHAdapterMuxViewController *mux = segue.destinationViewController;
        [mux setAdapter:adapter];
        [mux setTitle:adapter.name];
    }
}

#pragma mark - Table view delegate

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
