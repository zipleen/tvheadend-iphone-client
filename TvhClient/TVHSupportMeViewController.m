//
//  TVHSupportMeViewController.m
//  TvhClient
//
//  Created by zipleen on 4/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSupportMeViewController.h"
#import "TVHIAPHelper.h"
#import "TVHSettings.h"

@interface TVHSupportMeViewController ()
@property (nonatomic, strong) NSArray *products;
@end

@implementation TVHSupportMeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    if ( ! [[TVHSettings sharedInstance] removeAds] ) {
        [TVHIAPHelper sharedInstance];
        if( ! [[TVHIAPHelper sharedInstance] productPurchased:@"com.zipleen.TvhClient.removead"] ) {
            [[TVHIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                if (success) {
                    _products = products;
                }
            }];
            
            // On iOS 6 ADBannerView introduces a new initializer, use it when available.
            if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
                _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            } else {
                _bannerView = [[ADBannerView alloc] init];
            }
            
            CGRect contentFrame = self.view.bounds;
            if (contentFrame.size.width < contentFrame.size.height) {
                _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            } else {
                _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
            }
            
            CGRect bannerFrame = _bannerView.frame;
            if (_bannerView.bannerLoaded) {
                contentFrame.size.height -= _bannerView.frame.size.height;
                bannerFrame.origin.y = contentFrame.size.height;
            } else {
                bannerFrame.origin.y = contentFrame.size.height;
            }
            
            [self.bannerView setDelegate:self];
            [self.view addSubview:self.bannerView];
        }
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    // 1
    [self.bannerView removeFromSuperview];
    // 2
    _admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // 3
    self.admobBannerView.adUnitID = TVH_ADMOB;
    self.admobBannerView.rootViewController = self;
    self.admobBannerView.delegate = self;
    // 4
    [self.view addSubview:self.admobBannerView];
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [self.admobBannerView loadRequest:request];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.admobBannerView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
#ifdef TESTING
    NSLog(@"buying %@", productIdentifier);
#endif
    [[TVHSettings sharedInstance] setRemoveAds];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyRemoveAd:(UIButton *)sender {
    if ( self.products.count > 0 ) {
        SKProduct *product = [self.products objectAtIndex:0];
    
        NSLog(@"Buying %@...", product.productIdentifier);
        [[TVHIAPHelper sharedInstance] buyProduct:product];
    }
}

- (IBAction)restorePurchase:(UIBarButtonItem *)sender {
    [[TVHIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma MARK table crap

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( ! [[TVHSettings sharedInstance] removeAds] ) {
        return NSLocalizedString(@"Support Me", @"");
    }
    return @"";
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( [[TVHSettings sharedInstance] removeAds] ) {
        return NSLocalizedString(@"Thank you for supporting the app!", @"");
    }
    return NSLocalizedString(@"If you like this app, please consider removing the ad to help supporting it's development and availability.", @"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [[TVHSettings sharedInstance] removeAds] ) {
        return 0;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SupportMeTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIButton *button = (UIButton*)[cell viewWithTag:100];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:101];
    if( indexPath.row == 0 ) {
        textLabel.text = NSLocalizedString(@"Remove Ad", @"");
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        button.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if( indexPath.row == 1 ) {
        textLabel.text = NSLocalizedString(@"Visit Webpage", @"");
        button.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == 1 ) {
        NSURL *myURL = [NSURL URLWithString:@"https://github.com/zipleen/tvheadend-iphone-client/wiki/Support-Me" ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
