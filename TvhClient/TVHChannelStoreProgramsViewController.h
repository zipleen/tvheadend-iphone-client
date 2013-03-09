//
//  TVHChannelListProgramsViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHChannel.h"

@interface TVHChannelStoreProgramsViewController : UITableViewController
- (IBAction)playStream:(id)sender;
@property (nonatomic, weak) TVHChannel *channel;
@end
