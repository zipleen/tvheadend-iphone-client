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
@property (weak, nonatomic) IBOutlet UITextView *programDescription;
@property (weak, nonatomic) IBOutlet UILabel *programTitle;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *record;

- (IBAction)addRecordToTVHeadend:(id)sender;
- (IBAction)playStream:(id)sender;

@end
