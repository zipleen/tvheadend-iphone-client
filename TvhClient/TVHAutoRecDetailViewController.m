//
//  TVHAutoRecDetailViewController.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHAutoRecDetailViewController.h"
#import "TVHSettingsGenericFieldViewController.h"
#import "NSString+FileSize.h"

#import "TVHChannelStore.h"
#import "TVHTagStore.h"

@interface TVHAutoRecDetailViewController () <UITextFieldDelegate>

@end

@implementation TVHAutoRecDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.itemTitle setText:[self.item title]];
    [self.itemTitle setDelegate:self];
    
    [self.itemEnable setOn:[self.item enabled]];
    [self.itemChannel.detailTextLabel setText:[self.item channel]];
    [self.itemTag.detailTextLabel setText:[self.item tag]];
    [self.itemGenre.detailTextLabel setText:[self.item genre]];
    [self.itemWeekdays.detailTextLabel
     setText:[NSString stringOfWeekdaysLocalizedFromArray:[self.item.weekdays componentsSeparatedByString:@","] joinedByString:@","]];
    [self.itemStartAround.detailTextLabel setText:[NSString stringWithFormat:@"%d",[self.item approx_time]]];
    [self.itemPriority.detailTextLabel setText:[self.item pri]];
    [self.itemDvrConfig.detailTextLabel setText:[self.item config_name]];
    
    [self.itemCreatedBy setText:[self.item creator]];
    [self.itemCreatedBy setDelegate:self];
    
    [self.itemComment setText:[self.item comment]];
    [self.itemComment setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}


#pragma mark - Table view data source
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row > 0 && indexPath.row < 8 ) {
        [self performSegueWithIdentifier:@"AutoRecSelectField" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"AutoRecSelectField"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        // channel
        if ( path.section == 0 && path.row == 1 ) {
            TVHChannelStore *channelStore = [TVHChannelStore sharedInstance];
            NSArray *objectChannelList = [channelStore channels];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Channel", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Channel", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemChannel.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemChannel.detailTextLabel setText:text];
            }];
        }
        
        // tag
        if ( path.section == 0 && path.row == 2 ) {
            TVHTagStore *tagStore = [TVHTagStore sharedInstance];
            NSArray *objectTagList = [tagStore tags];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectTagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Tag", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Tag", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemTag.detailTextLabel setText:text];
            }];
        }
        
        // genre - missing
        if ( path.section == 0 && path.row == 3 ) {
            TVHTagStore *tagStore = [TVHTagStore sharedInstance];
            NSArray *objectTagList = [tagStore tags];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectTagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Tag", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Tag", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemTag.detailTextLabel setText:text];
            }];
        }
        
        // weekdays
        if ( path.section == 0 && path.row == 4 ) {
            TVHTagStore *tagStore = [TVHTagStore sharedInstance];
            NSArray *objectTagList = [tagStore tags];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectTagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Tag", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Tag", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemTag.detailTextLabel setText:text];
            }];
        }
    }
}


- (void)viewDidUnload {
    [self setItemTitle:nil];
    [self setItemChannel:nil];
    [self setItemTag:nil];
    [self setItemGenre:nil];
    [self setItemWeekdays:nil];
    [self setItemStartAround:nil];
    [self setItemPriority:nil];
    [self setItemDvrConfig:nil];
    [self setItemCreatedBy:nil];
    [self setItemComment:nil];
    [self setItemEnable:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}
@end
