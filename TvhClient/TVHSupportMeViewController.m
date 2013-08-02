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
#import "UIView+ClosestParent.h"

@implementation SKProduct (priceAsString)

- (NSString *)priceAsString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self priceLocale]];
    
    NSString *str = [formatter stringFromNumber:[self price]];
    return str;
}

@end

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
            [self.tableView reloadData];
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
    [self.tableView reloadData];
    //[[TVHSettings sharedInstance] setRemoveAds];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buyRemoveAd:(UIButton *)sender {
    UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
    
    if ( self.products.count > indexPath.row ) {
        SKProduct *product = [self.products objectAtIndex:indexPath.row];
    
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
    return NSLocalizedString(@"Support Me - Pay what you want", @"");
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
    
    return [self.products count];
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
    UILabel *thanksLabel = (UILabel*)[cell viewWithTag:103];
    SKProduct *product = self.products[indexPath.row];
    
    textLabel.text = product.localizedTitle;
    
    if ( [[TVHIAPHelper sharedInstance] productPurchased:product.productIdentifier] ) {
        button.hidden = YES;
        thanksLabel.hidden = NO;
    } else {
        [button setTitle:[NSString stringWithFormat:@"Buy %@", product.priceAsString] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        button.hidden = NO;
        thanksLabel.hidden = YES;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
