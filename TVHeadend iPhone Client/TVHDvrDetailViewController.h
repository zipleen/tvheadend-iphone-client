//
//  TVHDvrDetailViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHDvrItem.h"

@interface TVHDvrDetailViewController : UIViewController
@property (weak, nonatomic) TVHDvrItem *dvrItem;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *description;

@end
