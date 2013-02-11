//
//  TVHProgramDetailViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHEpg.h"
#import "TVHChannel.h"

@interface TVHProgramDetailViewController : UIViewController

@property (weak, nonatomic) TVHEpg *epg;
@property (weak, nonatomic) TVHChannel *channel;
@property (weak, nonatomic) IBOutlet UIImageView *programImage;
@property (weak, nonatomic) IBOutlet UILabel *programDescription;
@property (weak, nonatomic) IBOutlet UILabel *programTitle;

- (IBAction)addRecordToTVHeadend:(id)sender;

@end
