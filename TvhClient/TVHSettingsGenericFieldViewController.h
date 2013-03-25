//
//  TVHSettingsGenericFieldViewController.h
//  TvhClient
//
//  Created by zipleen on 3/25/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHSettingsGenericFieldViewController : UITableViewController
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *sectionHeader;
@property (nonatomic) NSInteger selectedOption;
@property (copy) void (^responseBack)(NSInteger row);
@end
