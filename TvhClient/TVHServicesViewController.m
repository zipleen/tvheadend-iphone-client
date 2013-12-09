//
//  TVHServicesViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 09/11/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServicesViewController.h"
#import "TVHService.h"
#import "TVHChannel.h"
#import "TVHPlayStreamHelpController.h"

@interface TVHServicesViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@property (strong, nonatomic) NSMutableArray *services;
@end

@implementation TVHServicesViewController

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
	self.services = [[self.adapter arrayServicesForMux:self.adapterMux] mutableCopy];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ %@", [self.adapterMux network], [self.adapterMux freq]];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%d Services", [self.services count]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"servicesItems" ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"servicesItems"];
    }
    
    UILabel *svcname = (UILabel *)[cell viewWithTag:100];
    UILabel *channelName = (UILabel *)[cell viewWithTag:101];
    
    TVHService *service = [self.services objectAtIndex:indexPath.row];
    
    if ( service.svcname ) {
        svcname.text = service.svcname;
    } else {
        svcname.text = [NSString stringWithFormat:@"Type: %@ Sid: %d", service.type, service.sid];
    }
    channelName.text = [service.mappedChannel name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    TVHService *service = [self.services objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.help playStream:cell withChannel:service withVC:self];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
