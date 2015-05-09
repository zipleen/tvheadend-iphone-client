//
//  TVHSettingsServersViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 3/21/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHSettingsServersViewController.h"
#import "TVHSettings.h"
#import "UIView+ClosestParent.h"

#define TVH_SETTINGS_SECTION_SERVER_DETAILS 0
#define TVH_SETTINGS_SECTION_AUTH 1
#define TVH_SETTINGS_SECTION_ADVANCED_OPTIONS 2
#define TVH_SETTINGS_SECTION_SSH 3

@interface TVHSettingsServersViewController () <UITextFieldDelegate>
@property (nonatomic, weak) TVHSettings *settings;
@property (nonatomic, strong) NSMutableDictionary *server;
@end

@implementation TVHSettingsServersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settings = [TVHSettings sharedInstance];
    
    if ( self.selectedServer == -1 ) {
        self.server = [[self.settings newServer] mutableCopy];
    } else {
        self.server = [[self.settings serverProperties:self.selectedServer] mutableCopy];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == TVH_SETTINGS_SECTION_SERVER_DETAILS) {
        return NSLocalizedString(@"TVHeadend Server Details", @"..in Settings server edit");
    }
    if (section == TVH_SETTINGS_SECTION_AUTH) {
        return NSLocalizedString(@"Authentication", @"..in Settings server edit");
    }
    if (section == TVH_SETTINGS_SECTION_ADVANCED_OPTIONS) {
        return NSLocalizedString(@"Advanced Options", @"..in Settings server edit");
    }
    if (section == TVH_SETTINGS_SECTION_SSH) {
        return NSLocalizedString(@"SSH Port Forward", @"..in Settings server edit");
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifdef TESTING
    return 4;
#else
    return 3;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == TVH_SETTINGS_SECTION_SERVER_DETAILS ) {
        return 4;
    }
    if ( section == TVH_SETTINGS_SECTION_AUTH ) {
        return 2;
    }
    if ( section == TVH_SETTINGS_SECTION_ADVANCED_OPTIONS ) {
        return 4;
    }
    if ( section == TVH_SETTINGS_SECTION_SSH ) {
        return 4;
    }
    return 0;
}

- (NSInteger)indexOfSettingsArray:(NSInteger)section row:(NSInteger)row {
    NSInteger indexCount = 0;
    for (int sectionCount = 0; sectionCount < section && sectionCount < [self numberOfSectionsInTableView:self.tableView] ; sectionCount++) {
        indexCount = indexCount + [self tableView:self.tableView numberOfRowsInSection:sectionCount];
    }
    return indexCount + row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerPropertiesCell" forIndexPath:indexPath];
    
    //UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(136, 10, 160, 30)];
    UITextField *textField = (UITextField *)[cell viewWithTag:201];
    UILabel *textLabel = (UILabel *)[cell viewWithTag:200];
    UISwitch *switchfield = (UISwitch *)[cell viewWithTag:202];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = NO;
    textField.returnKeyType = UIReturnKeyDone;
    textField.hidden = NO;
    switchfield.hidden = YES;
    if ( indexPath.section == TVH_SETTINGS_SECTION_SERVER_DETAILS ) {
        if ( indexPath.row == 0 ) {
            textLabel.text = NSLocalizedString(@"Name", @"..in Settings server edit");
            textField.placeholder = @"";
        }
        
        if ( indexPath.row == 1 ) {
            textLabel.text = NSLocalizedString(@"Address", @"..in Settings server edit");
            textField.placeholder = @"IP or Address";
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }
        
        if ( indexPath.row == 2 ) {
            textLabel.text = NSLocalizedString(@"Port", @"..in Settings server edit");
            textField.placeholder = @"9981";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        
        if ( indexPath.row == 3 ) {
            textLabel.text = NSLocalizedString(@"HTSP Port", @"..in Settings server edit");
            textField.placeholder = @"9982";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    }
    
    if ( indexPath.section == TVH_SETTINGS_SECTION_AUTH ) {
        if ( indexPath.row == 0 ) {
            textLabel.text = NSLocalizedString(@"Username", @"..in Settings server edit");
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeDefault;
        }
        
        if ( indexPath.row == 1 ) {
            textLabel.text = NSLocalizedString(@"Password", @"..in Settings server edit");
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.secureTextEntry = YES;
        }
    }
    
    if ( indexPath.section == TVH_SETTINGS_SECTION_ADVANCED_OPTIONS ) {
        if ( indexPath.row == 0 ) {
            textLabel.text = NSLocalizedString(@"Use HTTPS", @"..in Settings server edit");
            textField.hidden = YES;
            switchfield.hidden = NO;
            if ( [[self.server objectForKey:TVHS_USE_HTTPS] isEqualToString:@"s"] ) {
                [switchfield setOn:YES];
            } else {
                [switchfield setOn:NO];
            }
            // horrible hack :(
            [switchfield addTarget:self action: @selector(setUseHttps:) forControlEvents:UIControlEventValueChanged];
        }
        
        if ( indexPath.row == 1 ) {
            textLabel.text = NSLocalizedString(@"Web Root", @"..in Settings server edit");
            textField.placeholder = @"/";
            textField.keyboardType = UIKeyboardTypeURL;
        }
        
        if ( indexPath.row == 2 ) {
            textLabel.text = NSLocalizedString(@"SETTINGS_NETWORK_CACHING_TITLE", @"..in Settings server edit");
            textField.placeholder = @"Low:333 | Normal(default):999 | High:3333";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }
        
        if ( indexPath.row == 3 ) {
            textLabel.text = NSLocalizedString(@"SETTINGS_DEINTERLACE", @"..in Settings server edit");
            textField.placeholder = @"Disabled:0 | Enabled:1";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }
    }
    
    if ( indexPath.section == TVH_SETTINGS_SECTION_SSH ) {
        if ( indexPath.row == 0 ) {
            textLabel.text = NSLocalizedString(@"Address", @"..in Settings server edit");
            textField.placeholder = @"SSH Host Address";
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }
        
        if ( indexPath.row == 1 ) {
            textLabel.text = NSLocalizedString(@"SSH Port", @"..in Settings server edit");
            textField.placeholder = @"22";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        
        if ( indexPath.row == 2 ) {
            textLabel.text = NSLocalizedString(@"SSH Username", @"..in Settings server edit");
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }
        
        if ( indexPath.row == 3 ) {
            textLabel.text = NSLocalizedString(@"SSH Password", @"..in Settings server edit");
            textField.placeholder = @"";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.secureTextEntry = YES;
        }
    }
    
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = NSTextAlignmentLeft;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    textField.enabled = YES;
    textField.text = [self.server objectForKey:TVHS_SERVER_KEY_SETTINGS[[self indexOfSettingsArray:indexPath.section row:indexPath.row]] ] ;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row == 0 && indexPath.section == TVH_SETTINGS_SECTION_ADVANCED_OPTIONS ) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell viewWithTag:201];
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
    
    [self.server setValue:textField.text
                   forKey:TVHS_SERVER_KEY_SETTINGS[ [self indexOfSettingsArray:indexPath.section
                                                                           row:indexPath.row]
                                                   ]
     ];
    
    return YES;
}

- (IBAction)saveServer:(id)sender {
    [self.view.window endEditing: YES];
    NSDictionary *new = [self.settings newServer];
    NSDictionary *server = [self.server copy];
    if ( ! [new isEqualToDictionary:server] ) {
        self.selectedServer = [self.settings setServerProperties:server forServerId:self.selectedServer];
        [self.settings setSelectedServer:self.selectedServer];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setUseHttps:(UISwitch*)sender {
    if ( sender.on ) {
        [self.server setObject:@"s" forKey:TVHS_USE_HTTPS];
    } else {
        [self.server setObject:@"" forKey:TVHS_USE_HTTPS];
    }
}
@end
