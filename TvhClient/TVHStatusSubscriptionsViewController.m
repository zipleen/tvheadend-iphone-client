//
//  TVHStatusSubscriptionsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHStatusSubscriptionsViewController.h"
#import "CKRefreshControl.h"
#import "TVHShowNotice.h"
#import "TVHCometPollStore.h"
#import "TVHChannelStore.h"
#import "NSString+FileSize.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface TVHStatusSubscriptionsViewController (){
    NIKFontAwesomeIconFactory *factory;
    NIKFontAwesomeIconFactory *factoryBar;
    UIActivityIndicatorView *act;
}

@property (strong, nonatomic) TVHStatusSubscriptionsStore *statusSubscriptionsStore;
@property (strong, nonatomic) TVHAdaptersStore *adapterStore;
@property (strong, nonatomic) TVHCometPollStore *cometPoll;
@end

@implementation TVHStatusSubscriptionsViewController

- (TVHStatusSubscriptionsStore*) statusSubscriptionsStore {
    if ( _statusSubscriptionsStore == nil) {
        _statusSubscriptionsStore = [TVHStatusSubscriptionsStore sharedInstance];
    }
    return _statusSubscriptionsStore;
}

- (TVHAdaptersStore*) adapterStore {
    if ( _adapterStore == nil) {
        _adapterStore = [TVHAdaptersStore sharedInstance];
    }
    return _adapterStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.adapterStore setDelegate:self];
    [self.statusSubscriptionsStore setDelegate:self];
    
    self.cometPoll = [TVHCometPollStore sharedInstance];
    
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
    if ([[self.navigationController.navigationBar subviews] count]>=2) {
        [[[self.navigationController.navigationBar subviews] objectAtIndex:2] addSubview:act];
    }
    [self.navigationItem.rightBarButtonItem setImage:[factoryBar createImageForIcon:NIKFontAwesomeIconRefresh]];
}

- (void)viewDidUnload {
    self.adapterStore = nil;
    self.cometPoll = nil;
    self.statusSubscriptionsStore = nil;
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
    [self.adapterStore fetchAdapters];
    [self.statusSubscriptionsStore fetchStatusSubscriptions];
    [self changePollingIcon];
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadStatusSubscriptions {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didLoadAdapters {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.tableView reloadData];
    [self.statusSubscriptionsStore fetchStatusSubscriptions];
    [self.adapterStore fetchAdapters];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return NSLocalizedString(@"Active Subscriptions", nil);
    }
    if ( section == 1 ) {
        return NSLocalizedString(@"Adapters", nil);
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( section == 0 ) {
        if ( [self.statusSubscriptionsStore count] == 0 ) {
            return NSLocalizedString(@"No active subscriptions.", nil);
        }
    }
    if ( section == 1 ) {
        if ( [self.adapterStore count] == 0 ) {
            return NSLocalizedString(@"No adapters found.", nil);
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
        
        TVHStatusSubscription *subscription = [self.statusSubscriptionsStore objectAtIndex:indexPath.row];
        TVHChannel *channel = [[TVHChannelStore sharedInstance] channelWithName:subscription.channel];
        
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
        [stateIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconSignal]];
        [errorIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconExclamationSign]];
        [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
        [clientIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconHdd]];
        
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
        UIProgressView *progress = (UIProgressView *)[cell viewWithTag:110];
        
        TVHAdapter *adapter = [self.adapterStore objectAtIndex:indexPath.row];
        
        deviceNameLabel.text = adapter.devicename;
        adapterPathLabel.text = adapter.path;
        bwLabel.text = [NSString stringFromFileSizeInBits:adapter.bw];
        serviceLabel.text = adapter.currentMux;
        snrLabel.text = [NSString stringWithFormat:@"%.1f dB", adapter.snr];
        uncLabel.text = [NSString stringWithFormat:@"%d", adapter.uncavg];
        berLabel.text = [NSString stringWithFormat:@"%d", adapter.ber];
        signalLabel.text = [NSString stringWithFormat:@"%d %%", adapter.signal];
        progress.progress = (float)adapter.signal/100;
        [bwIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconCloudDownload]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

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

@end
