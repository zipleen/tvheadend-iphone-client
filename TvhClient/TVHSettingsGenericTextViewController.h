//
//  TVHSettingsGenericTextViewController.h
//  TvhClient
//
//  Created by zipleen on 3/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@interface TVHSettingsGenericTextViewController : UIViewController
@property (strong, nonatomic) NSString *displayText;
@property (weak, nonatomic) IBOutlet UITextView *genericText;

@end
