//
//  TVHSupportMeViewController.h
//  TvhClient
//
//  Created by zipleen on 4/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHSupportMeViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)buyRemoveAd:(UIButton *)sender;
- (IBAction)restorePurchase:(UIBarButtonItem *)sender;
- (IBAction)changePage:(id)sender;
@end
