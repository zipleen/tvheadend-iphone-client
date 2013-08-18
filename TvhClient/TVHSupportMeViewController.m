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
#import <QuartzCore/QuartzCore.h>
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

@interface TVHSupportMeViewController () {
    BOOL pageControlBeingUsed;
}
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
            [self updateScrollView];
            //[self.tableView reloadData];
        }
    }];
    
    self.scrollView.delegate = self;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void)updateScrollView {
    // remove all subviews ?
    for (UIView *v in [self.scrollView subviews]) {
        [v removeFromSuperview];
    }
    
    for (int i = 0; i < [self.products count]; i++) {
        SKProduct *product = self.products[i];
        
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [UIColor clearColor];
        
        if ( [[TVHIAPHelper sharedInstance] productPurchased:product.productIdentifier] ) {
            // pic
            UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[IAP_PICS objectForKey:product.productIdentifier]]];
            [pic setFrame:CGRectMake(0, 0, [self.view bounds].size.width , [self.view bounds].size.height)];
            [pic setContentMode:UIViewContentModeScaleAspectFill];
            [pic setClipsToBounds:YES];
            [subview addSubview:pic];
            
            // text
            UILabel *tks = [[UILabel alloc] initWithFrame:CGRectMake(40, 90, 320, 29)];
            tks.text = NSLocalizedString(@"Thanks for your support!", "");
            tks.backgroundColor = [UIColor clearColor];
            tks.textColor = [UIColor lightTextColor];
            tks.font = [UIFont fontWithName:@"Helvetica Neue" size:28];
            if ( ! IS_IPAD ) {
                [tks setFrame:CGRectMake(10, 20, 320, 29)];
            }
            [subview addSubview:tks];
        } else {
            NSUInteger offset_x = ( [self.view bounds].size.width - 300 ) / 2;
            
            // 10
            UIView *rect = [[UIView alloc] initWithFrame:CGRectMake(offset_x, 70, 300, 320)];
            rect.backgroundColor = [UIColor lightGrayColor];
            [subview addSubview:rect];
            rect.layer.cornerRadius = 5;
            rect.layer.masksToBounds = YES;
            rect.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
            
            // button - 192
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offset_x+182, 90, 108, 29)];
            [button setTitle:[NSString stringWithFormat:@"Buy %@", product.priceAsString] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buyRemoveAd:) forControlEvents:UIControlEventTouchDown];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [subview addSubview:button];
        
            // 20
            UILabel *tks = [[UILabel alloc] initWithFrame:CGRectMake(( [self.view bounds].size.width - 280 ) / 2, 20, 280, 29)];
            tks.text = NSLocalizedString(@"You're free to support me!", "");
            tks.backgroundColor = [UIColor clearColor];
            tks.textAlignment = NSTextAlignmentCenter;
            tks.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
            [subview addSubview:tks];
            
            // text - 40
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(offset_x+20, 90, 280, 26)];
            title.text = product.localizedTitle;
            title.backgroundColor = [UIColor clearColor];
            title.font = [UIFont fontWithName:@"Helvetica Neue" size:18];
            [subview addSubview:title];
            
            // description - 20
            UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(offset_x+20, 115, 280, 216)];
            desc.text = product.localizedDescription;
            desc.numberOfLines = 7;
            desc.backgroundColor = [UIColor clearColor];
            desc.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
            [subview addSubview:desc];
        }
        
        [self.scrollView addSubview:subview];
    }
    
    self.pageControl.numberOfPages = [self.products count];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.products count], self.scrollView.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
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
    [self updateScrollView];
}

- (IBAction)buyRemoveAd:(UIButton *)sender {
    
    if ( self.products.count > self.pageControl.currentPage ) {
        SKProduct *product = [self.products objectAtIndex:self.pageControl.currentPage];
        
        NSLog(@"Buying %@...", product.productIdentifier);
        [[TVHIAPHelper sharedInstance] buyProduct:product];
    }
}

- (IBAction)restorePurchase:(UIBarButtonItem *)sender {
    [[TVHIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (IBAction)changePage:(id)sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}



@end
