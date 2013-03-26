//
//  TVHSettingsGenericTextViewController.h
//  TvhClient
//
//  Created by zipleen on 3/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHSettingsGenericTextViewController : UIViewController
@property (strong, nonatomic) NSString *displayText;
@property (weak, nonatomic) IBOutlet UITextView *genericText;

@end
