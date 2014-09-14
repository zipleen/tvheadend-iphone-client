//
//  TVHAdapterMuxViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 30/07/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAdapterMuxViewController.h"
#import "TVHProgressBar.h"
#import "TVHMux.h"
#import "TVHServicesViewController.h"

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
    if ( self.network ) {
        self.muxes = [[self.network networkMuxes] mutableCopy];
    } else {
        self.muxes = [[self.adapter arrayAdapterMuxes] mutableCopy];
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRefreshAdapterMux:)
                                                 name:@"didRefreshAdapterMux"
                                               object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( self.network ) {
        return [NSString stringWithFormat:@"%@ / %@", self.network.networkname, self.network.charset];
    }
    return [self.adapter devicename];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( self.network ) {
        return [NSString stringWithFormat:@"%lu Muxes - %ld Services", (unsigned long)[self.muxes count], (long)[self.network num_svc]];
    }
    return [NSString stringWithFormat:@"%lu Muxes - %ld Services", (unsigned long)[self.muxes count], (long)[self.adapter services]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.muxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dvbMuxItems" forIndexPath:indexPath];
    
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
    
    TVHMux *mux = [self.muxes objectAtIndex:indexPath.row];
    
    UIColor *textColor;
    if ( mux.enabled == 1 ) {
        textColor = [UIColor blackColor];
    } else {
        textColor = [UIColor lightGrayColor];
    }
    
    // colour relative to status
    network.textColor = textColor;
    freq.textColor = textColor;
    mod.textColor = textColor;
    pol.textColor = textColor;
    fe_status.textColor = textColor;
    networkid.textColor = textColor;
    muxid.textColor = textColor;
    progressText.textColor = textColor;
    
    network.text = mux.network;
    freq.text = mux.freq ? mux.freq : mux.name;
    mod.text = mux.mod;
    pol.text = mux.pol;
    fe_status.text = [NSString stringWithFormat:@"Frontend Status: %@", mux.fe_status];
    networkid.text = [NSString stringWithFormat:@"NetId: %ld", (long)mux.onid];
    muxid.text = [NSString stringWithFormat:@"MuxId: %ld", (long)mux.muxid];
    [quality setProgress:mux.quality/100.0];
    progressText.text = [NSString stringWithFormat:@"%ld%%", (long)mux.quality];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row < [self.muxes count] ) {
        [self performSegueWithIdentifier:@"Show Services" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"Show Services"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHMux *adapterMux = [self.muxes objectAtIndex:path.row];
        
        TVHServicesViewController *serviceViewController = segue.destinationViewController;
        [serviceViewController setAdapterMux:adapterMux];
        [serviceViewController setAdapter:self.adapter];
        [serviceViewController setNetwork:self.network];
        [serviceViewController setTitle:adapterMux.freq ? adapterMux.freq : adapterMux.name];
    }
}

#pragma mark - refresh data

- (void)didRefreshAdapterMux:(NSNotification *)notification {
    if ( self.muxes ) {
        if ( [[notification name] isEqualToString:@"didRefreshAdapterMux"] ) {
            TVHMux *changedMux = (TVHMux*)[notification object];
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
