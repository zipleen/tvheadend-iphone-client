//
//  TVHAutoRecDetailViewController.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAutoRecDetailViewController.h"
#import "TVHSettingsGenericFieldViewController.h"
#import "NSString+FileSize.h"

#import "TVHSingletonServer.h"

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
    [self.itemTitle setDelegate:self];
    [self.itemCreatedBy setDelegate:self];
    [self.itemComment setDelegate:self];
    [self.itemEnable addTarget:self action: @selector(itemSetEnable:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.itemTitle setText:[self.item title]];
    [self.itemEnable setOn:[self.item enabled]];
    [self.itemChannel.detailTextLabel setText:[self.item channel]];
    [self.itemTag.detailTextLabel setText:[self.item tag]];
    [self.itemGenre.detailTextLabel setText:[self.item genre]];
    [self.itemWeekdays.detailTextLabel
     setText:[NSString stringOfWeekdaysLocalizedFromArray:[self.item.weekdays componentsSeparatedByString:@","] joinedByString:@","]];
    [self.itemStartAround.detailTextLabel setText:self.item.stringFromAproxTime];
    [self.itemPriority.detailTextLabel setText:[self.item pri]];
    [self.itemDvrConfig.detailTextLabel setText:[self.item config_name]];
    [self.itemCreatedBy setText:[self.item creator]];
    [self.itemComment setText:[self.item comment]];
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

- (void)itemSetEnable:(UISwitch*)switchField {
    [self.item setEnabled:switchField.on];
    [self.item updateValue:[NSNumber numberWithBool:switchField.on] forKey:@"enabled"];
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

- (NSArray*)arrayOfWeekdaysLocalized
{
    NSMutableArray *localizedStringOfweekday = [[[[NSDateFormatter alloc] init] shortWeekdaySymbols] mutableCopy];
    // hack for making 1==monday 7==sunday
    [localizedStringOfweekday addObject:[localizedStringOfweekday objectAtIndex:0]];
    [localizedStringOfweekday removeObjectAtIndex:0];
    return [localizedStringOfweekday copy];
}

- (NSArray*)arrayOfDayTimes
{
    NSMutableArray *days = [[NSMutableArray alloc] init];
    for ( int i = 0 ; i < 144; i++ ) {
        [days addObject:[TVHAutoRecItem stringFromMinutes:i*10] ];
    }
    return days;
}

- (NSArray*)arrayOfImportance
{
    return @[@"important", @"high", @"normal", @"low", @"unimportant"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row > 1 && indexPath.row < 9 && indexPath.row != 4 && indexPath.row != 8 && indexPath.row != 5 ) {
        [self performSegueWithIdentifier:@"AutoRecSelectField" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"AutoRecSelectField"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        // channel
        if ( path.section == 0 && path.row == 2 ) {
            id <TVHChannelStore> channelStore = [[TVHSingletonServer sharedServerInstance] channelStore];
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
                [self.item updateValue:text forKey:@"channel"];
                [self.item setChannel:text];
            }];
        }
        
        // tag
        if ( path.section == 0 && path.row == 3 ) {
            id <TVHTagStore> tagStore = [[TVHSingletonServer sharedServerInstance] tagStore];
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
                [self.item updateValue:text forKey:@"tag"];
                [self.item setTag:text];
            }];
        }
        
        // genre - missing
        /*if ( path.section == 0 && path.row == 4 ) {
            TVHTagStore *tagStore = [TVHTagStore sharedInstance];
            NSArray *objectTagList = [tagStore tags];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectTagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Genre", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Genre", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemTag.detailTextLabel setText:text];
            }];
        }*/
        
        // weekdays
        /*if ( path.section == 0 && path.row == 5 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Weekdays", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Weekdays", nil)];
            [vc setOptions:[self arrayOfWeekdaysLocalized]];
            //[vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                //NSString *text = [list objectAtIndex:order];
                //[self.itemTag.detailTextLabel setText:text];
            }];
        }*/
        
        // start around
        if ( path.section == 0 && path.row == 6 ) {
            NSArray *list = [self arrayOfDayTimes];
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Start Around", @"Auto rec edit - start around")];
            [vc setSectionHeader:NSLocalizedString(@"Start Around", @"Auto rec edit - start around")];
            [vc setOptions:list];
            [vc setSelectedOption:self.item.approx_time / 10];
            [vc setResponseBack:^(NSInteger order) {
                [self.item updateValue:[NSNumber numberWithInt:order*10] forKey:@"approx_time"];
                [self.item setApprox_time:order*10];
            }];
        }
        
        // priority
        if ( path.section == 0 && path.row == 7 ) {
            NSArray *list = [self arrayOfImportance];
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Priority", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Priority", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemPriority.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.item updateValue:text forKey:@"pri"];
                [self.item setPri:text];
            }];
        }
        
        // dvr config
        /*if ( path.section == 0 && path.row == 8 ) {
            TVHTagStore *tagStore = [TVHTagStore sharedInstance];
            NSArray *objectTagList = [tagStore tags];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectTagList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Dvr Config", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Dvr Config", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:self.itemTag.detailTextLabel.text]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self.itemTag.detailTextLabel setText:text];
            }];
        }*/
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
    [super viewDidUnload];
}

- (void)setItem:(TVHAutoRecItem *)item {
    _item = item;
    [_item setJsonClient:[[TVHSingletonServer sharedServerInstance] jsonClient]];
}

- (IBAction)saveButton:(id)sender {
    [self.view.window endEditing: YES];
    // check for the 3 titles
    if ( ! [self.itemTitle.text isEqualToString:[self.item title]] ) {
        [self.item updateValue:self.itemTitle.text forKey:@"title"];
    }
    if ( ! [self.itemComment.text isEqualToString:[self.item comment]] ) {
        [self.item updateValue:self.itemComment.text forKey:@"comment"];
    }
    if ( ! [self.itemCreatedBy.text isEqualToString:[self.item creator]] ) {
        [self.item updateValue:self.itemCreatedBy.text forKey:@"creator"];
    }
    [self.item updateAutoRec];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
