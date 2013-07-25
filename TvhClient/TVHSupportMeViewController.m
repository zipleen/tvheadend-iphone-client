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
    
    [[TVHIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
#ifdef TESTING
    NSString * productIdentifier = notification.object;
    NSLog(@"buying %@", productIdentifier);
#endif
    //[[TVHSettings sharedInstance] setRemoveAds];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buyRemoveAd:(UIButton *)sender {
    //if ( self.products.count > 0 ) {
        SKProduct *product = [self.products objectAtIndex:0];
    
        NSLog(@"Buying %@...", product.productIdentifier);
        [[TVHIAPHelper sharedInstance] buyProduct:product];
    //}
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
    return NSLocalizedString(@"Support Me - Offer what you want", @"");
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    /*if ( [[TVHSettings sharedInstance] removeAds] ) {
        return NSLocalizedString(@"Thank you for supporting the app!", @"");
    }*/
    return NSLocalizedString(@"If you find TvhClient useful, your support would be greatly appreciated!", @"");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
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
        textLabel.text = NSLocalizedString(@"Teeny of Thanks", @"");
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        button.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if( indexPath.row == 1 ) {
        textLabel.text = NSLocalizedString(@"Thanks a Sloth", @"");
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        button.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if( indexPath.row == 2 ) {
        textLabel.text = NSLocalizedString(@"Whale of Thanks", @"");
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        button.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
