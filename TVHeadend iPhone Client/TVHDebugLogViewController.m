//
//  TVHDebugLogViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 02/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDebugLogViewController.h"
#import "TVHCometPollStore.h"

@interface TVHDebugLogViewController ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation TVHDebugLogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDebugLogNotification:)
                                                 name:@"logmessageNotificationClassReceived"
                                               object:nil];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[TVHCometPollStore sharedInstance] selector:@selector(fetchCometPollStatus) userInfo:nil repeats:YES];
}

- (void) receiveDebugLogNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"logmessageNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        NSString *log = [message objectForKey:@"logtxt"];
        self.debugLog.text = [NSString stringWithFormat:@"%@\n%@", self.debugLog.text , log];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDebugLog:nil];
    [super viewDidUnload];
}
@end
