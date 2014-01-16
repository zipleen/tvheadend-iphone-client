//
//  TVHSettingsWebControllerViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 28/10/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHSettingsWebControllerViewController.h"
#import "TVHSettings.h"
#import "UIView+ClosestParent.h"

@interface TVHSettingsWebControllerViewController () <UITextFieldDelegate>
@property (weak, nonatomic) TVHSettings *settings;
@end

@implementation TVHSettingsWebControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settings = [TVHSettings sharedInstance];
    self.title = NSLocalizedString(@"Website Address in Status", @"..in Settings server edit");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"webserverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UITextField *textField = (UITextField *)[cell viewWithTag:201];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:200];
    UISwitch *switchfield = (UISwitch *)[cell viewWithTag:202];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = NO;
    textField.returnKeyType = UIReturnKeyDone;
    textField.hidden = NO;
    switchfield.hidden = YES;
    if ( indexPath.row == 0 && indexPath.section == 0 ) {
        textLabel.text = NSLocalizedString(@"URL", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.text = [self.settings web1Url];
    }
    if ( indexPath.row == 1 && indexPath.section == 0 ) {
        textLabel.text = NSLocalizedString(@"Username", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.text = [self.settings web1User];
    }
    if ( indexPath.row == 2 && indexPath.section == 0 ) {
        textLabel.text = NSLocalizedString(@"Password", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.secureTextEntry = YES;
        textField.text = [self.settings web1Pass];
    }
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = UITextAlignmentLeft;
    //textField.tag = indexPath.row + (indexPath.section * 10) + 100;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    textField.enabled = YES;
    
    [cell.contentView addSubview:textField];

    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
    
    if ( indexPath.row == 0 ) {
        [self.settings setWeb1Url:textField.text];
    }
    
    if ( indexPath.row == 1 ) {
        [self.settings setWeb1User:textField.text];
    }
    
    if ( indexPath.row == 2 ) {
        [self.settings setWeb1Pass:textField.text];
    }
    
    return YES;
}


@end
