//
//  TVHAdapterMuxViewController.m
//  TvhClient
//
//  Created by zipleen on 30/07/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHAdapterMuxViewController.h"
#import "TVHProgressBar.h"
#import "TVHAdapterMux.h"

@interface TVHAdapterMuxViewController ()
@property (strong, nonatomic) NSMutableArray *muxes;
@end

@implementation TVHAdapterMuxViewController

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
	self.muxes = [[self.adapter arrayAdapterMuxes] mutableCopy];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRefreshAdapterMux:)
                                                 name:@"didRefreshAdapterMux"
                                               object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.muxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"dvbMuxItems" ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dvbMuxItems"];
    }
    
    UILabel *network = (UILabel *)[cell viewWithTag:100];
    UILabel *freq = (UILabel *)[cell viewWithTag:101];
    UILabel *mod = (UILabel *)[cell viewWithTag:102];
    UILabel *pol = (UILabel *)[cell viewWithTag:103];
    UILabel *fe_status = (UILabel *)[cell viewWithTag:104];
    UILabel *networkid = (UILabel *)[cell viewWithTag:105];
    UILabel *muxid = (UILabel *)[cell viewWithTag:106];
    UILabel *progressText = (UILabel *)[cell viewWithTag:108];
    TVHProgressBar *quality = (TVHProgressBar *)[cell viewWithTag:107];
    [quality setTintColor:PROGRESS_BAR_PLAYBACK];
    CGRect progressBarFrame = {
        .origin.x = quality.frame.origin.x,
        .origin.y = quality.frame.origin.y,
        .size.width = quality.frame.size.width,
        .size.height = 4,
    };
    [quality setFrame:progressBarFrame];
    
    TVHAdapterMux *mux = [self.muxes objectAtIndex:indexPath.row];
    network.text = mux.network;
    freq.text = mux.freq;
    mod.text = mux.mod;
    pol.text = mux.pol;
    fe_status.text = [NSString stringWithFormat:@"Frontend Status: %@", mux.fe_status];
    networkid.text = [NSString stringWithFormat:@"NetId: %d", mux.onid];
    muxid.text = [NSString stringWithFormat:@"MuxId: %d", mux.muxid];
    [quality setProgress:mux.quality/100];
    progressText.text = [NSString stringWithFormat:@"%d%%", mux.quality];
    
    return cell;
}

- (void)didRefreshAdapterMux:(NSNotification *)notification {
    if ( self.muxes ) {
        if ( [[notification name] isEqualToString:@"didRefreshAdapterMux"] ) {
            TVHAdapterMux *changedMux = (TVHAdapterMux*)[notification object];
            NSUInteger indexInArray = [self.muxes indexOfObject:changedMux];
            if ( indexInArray != NSNotFound ) {
                [self.muxes replaceObjectAtIndex:indexInArray withObject:changedMux];
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexInArray inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
            
        }
    }
}

@end
