//
//  TVHSettingsViewController.m
//  TvhClient
//
//  Created by zipleen on 3/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHSettingsViewController.h"
#import "TVHSettingsServersViewController.h"
#import "TVHSettingsGenericTextViewController.h"
#import "TVHSettingsGenericFieldViewController.h"
#import "TVHSettings.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "TVHSingletonServer.h"
#import "UIView+ClosestParent.h"

#define TVHS_TRANSCODE_RESOLUTIONS @[@"288", @"384", @"480", @"576", @"720"]

@interface TVHSettingsViewController () <UITextFieldDelegate> {
    NIKFontAwesomeIconFactory *factory;
}
@property (nonatomic, weak) TVHSettings *settings;
@property (nonatomic, weak) NSArray *servers;
@end

@implementation TVHSettingsViewController

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
    self.settings = [TVHSettings sharedInstance];
    self.servers = [self.settings availableServers];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    
    self.title = NSLocalizedString(@"Settings", @"");
}

- (void)viewDidAppear:(BOOL)animated {
    self.servers = [self.settings availableServers];
    [self.tableView reloadData];
    
    [TVHAnalytics sendView:NSStringFromClass([self class])];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                    self.tableView);
}

- (void)viewDidUnload {
    self.settings = nil;
    self.servers = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( section == 0 ) {
        __weak TVHServer *server = [TVHSingletonServer sharedServerInstance];
        if ( [server realVersion] ) {
            return [NSString stringWithFormat:@"Tvheadend Version: %@ (%@)", [server realVersion], [server version]];
        }
    }
    if ( section == 2 ) {
        NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        return [NSString stringWithFormat:@"TvhClient Version: %@ (%@)", shortVersion, version];
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"TVHeadend Servers", @"Title 1 in settings screen");
    }
    if (section == 1) {
        return NSLocalizedString(@"Advanced Settings", @"Title 2 in settings screen");
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3  ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return [self.servers count] + 1;
    }
    if ( section == 1 ) {
        if ( IS_IPAD ) {
            return 8;
        } else {
            return 6;
        }
    }
    if ( section == 2 ) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NIKFontAwesomeIcon icon = NIKFontAwesomeIconHdd;
    
    if ( indexPath.section == 0 ) {
        icon = NIKFontAwesomeIconDesktop;
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsServerList"];
        if(cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsServerList"];
        }
        
        if ( indexPath.row < [self.servers count] ) {
            cell.textLabel.text = [self.settings serverProperty:TVHS_SERVER_NAME forServer:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ( indexPath.row == [self.settings selectedServer] ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [cell.imageView setImage:[factory createImageForIcon:icon]];
        }
        if ( indexPath.row == [self.servers count] ) {
            cell.textLabel.text = NSLocalizedString(@"Add New TVHeadend", @".. in settings screen");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:nil];
        }
    }
    if ( indexPath.section == 1 ) {
        
        if ( indexPath.row == 0 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsSwitchCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsSwitchCell"];
            }
            
            UISwitch *switchfield = (UISwitch *)[cell viewWithTag:300];
            [switchfield setOn:[self.settings autoStartPolling]];
            [switchfield addTarget:self action: @selector(autoStartPolling:) forControlEvents:UIControlEventValueChanged];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:301];
            textLabel.text = NSLocalizedString(@"Auto Start Polling", @".. in settings screen");
        }
        if ( indexPath.row == 1 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsTextCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsTextCell"];
            }
            
            // cacheTime
            UITextField *textField = (UITextField *)[cell viewWithTag:200];
            textField.adjustsFontSizeToFitWidth = YES;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.returnKeyType = UIReturnKeyDone;
            textField.textAlignment = UITextAlignmentLeft;
            textField.delegate = self;
            textField.clearButtonMode = UITextFieldViewModeNever;
            textField.text = [self.settings customPrefix];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:201];
            textLabel.text = NSLocalizedString(@"Custom Player URL", @".. in settings screen");
            textLabel.adjustsFontSizeToFitWidth = YES;
        }
        if ( indexPath.row == 2 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsDetailCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsDetailCell"];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Order Channels", @".. in settings screen");
            if ( [self.settings sortChannel] == TVHS_SORT_CHANNEL_BY_NAME ) {
                cell.detailTextLabel.text = NSLocalizedString(@"by Name", @".. in settings screen");
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"by Number", @".. in settings screen");
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ( indexPath.row == 3 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsSwitchCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsSwitchCell"];
            }
            
            UISwitch *switchfield = (UISwitch *)[cell viewWithTag:300];
            [switchfield setOn:[self.settings sendAnonymousStatistics]];
            [switchfield addTarget:self action: @selector(sendAnonymousStatistics:) forControlEvents:UIControlEventValueChanged];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:301];
            textLabel.text = NSLocalizedString(@"Anonymous Statistics", @".. in settings screen");
        }
        if ( indexPath.row == 4 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsSwitchCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsSwitchCell"];
            }
            
            UISwitch *switchfield = (UISwitch *)[cell viewWithTag:300];
            [switchfield setOn:[self.settings useBlackBorders]];
            [switchfield addTarget:self action: @selector(useBlackBorders:) forControlEvents:UIControlEventValueChanged];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:301];
            textLabel.text = NSLocalizedString(@"Draw Image Border", @".. in settings screen");
        }
        
        if ( indexPath.row == 5 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsDetailCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsDetailCell"];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Transcode Resolution", @".. in settings screen");
            cell.detailTextLabel.text = [self.settings transcodeResolution];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if ( IS_IPAD ) {
            if ( indexPath.row == 6 ) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsDetailCell"];
                if(cell==nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsDetailCell"];
                }
                
                cell.textLabel.text = NSLocalizedString(@"Right Panel", @".. in settings screen");
                if ( [self.settings splitRightMenu] == TVHS_SPLIT_RIGHT_MENU_DYNAMIC ) {
                    cell.detailTextLabel.text = NSLocalizedString(@"Dynamic based on screen", @".. in settings screen");
                } else if ( [self.settings splitRightMenu] == TVHS_SPLIT_RIGHT_MENU_STATUS ) {
                    cell.detailTextLabel.text = NSLocalizedString(@"Show Status", @".. in settings screen");
                } else if ( [self.settings splitRightMenu] == TVHS_SPLIT_RIGHT_MENU_LOG ) {
                    cell.detailTextLabel.text = NSLocalizedString(@"Show Log", @".. in settings screen");
                } else if ( [self.settings splitRightMenu] == TVHS_SPLIT_RIGHT_MENU_NONE ) {
                    cell.detailTextLabel.text = NSLocalizedString(@"None", @".. in settings screen");
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if ( indexPath.row == 7 ) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsTextCell"];
                if(cell==nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsTextCell"];
                }
                
                UITextField *textField = (UITextField *)[cell viewWithTag:200];
                textField.enabled = NO;
                
                UILabel *textLabel = (UILabel *)[cell viewWithTag:201];
                textLabel.text = NSLocalizedString(@"Website Address in Status", @".. in settings screen");
                textLabel.adjustsFontSizeToFitWidth = YES;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    if ( indexPath.section == 2 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsServerList"];
        if(cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsServerList"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ( indexPath.row == 0 ) {
            icon = NIKFontAwesomeIconHeart;
            cell.textLabel.text = NSLocalizedString(@"Support Me", @".. in settings screen");
        }
        if ( indexPath.row == 1 ) {
            icon = NIKFontAwesomeIconGithub;
            cell.textLabel.text = NSLocalizedString(@"Got an issue?", @".. in settings screen");
        }
        if ( indexPath.row == 2 ) {
            icon = NIKFontAwesomeIconQuestionSign;
            cell.textLabel.text = NSLocalizedString(@"FAQ", @".. in settings screen");
        }
        if ( indexPath.row == 3 ) {
            icon = NIKFontAwesomeIconInfoSign;
            cell.textLabel.text = NSLocalizedString(@"About", @".. in settings screen");
        }
        if ( indexPath.row == 4 ) {
            icon = NIKFontAwesomeIconFileAlt;
            cell.textLabel.text = NSLocalizedString(@"Licenses", @".. in settings screen");
        }
        [cell.imageView setImage:[factory createImageForIcon:icon]];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 && indexPath.row < [self.servers count] ) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.settings removeServer:indexPath.row];
        self.servers = [self.settings availableServers];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set server
    if ( indexPath.section == 0 && [self.tableView isEditing] == NO ) {
        if ( indexPath.row < [self.servers count] ) {
            [self.settings setSelectedServer:indexPath.row];
            [self.tableView reloadData];
            [TVHAnalytics sendEventWithCategory:@"uiAction"
                                                            withAction:@"changeServer"
                                                             withLabel:@"changeServer"
                                                             withValue:[NSNumber numberWithInt:0]];
        } else {
            [self performSegueWithIdentifier:@"SettingsServers" sender:self];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return ;
    }
    
    // edit server
    if ( indexPath.section == 0 ) {
        [self performSegueWithIdentifier:@"SettingsServers" sender:self];
    }
    
    if ( indexPath.section == 1 && indexPath.row == 2 ) {
        [self performSegueWithIdentifier:@"SettingsGenericField" sender:self];
    }
    
    if ( indexPath.section == 1 && indexPath.row == 5 ) {
        [self performSegueWithIdentifier:@"SettingsGenericField" sender:self];
    }
    
    if ( indexPath.section == 1 && indexPath.row == 6 ) {
        [self performSegueWithIdentifier:@"SettingsGenericField" sender:self];
    }
    
    if ( indexPath.section == 1 && indexPath.row == 7 ) {
        [self performSegueWithIdentifier:@"SettingsWebserver" sender:self];
    }
    
    if ( indexPath.section == 2 && indexPath.row == 0 ) {
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/zipleen/tvheadend-iphone-client/wiki/Support"]];
        [self performSegueWithIdentifier:@"Support Me" sender:self];
    }
    
    if ( indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) ) {
        [self performSegueWithIdentifier:@"SettingsGenericText" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"SettingsServers"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHSettingsServersViewController *vc = segue.destinationViewController;
        [vc setTitle:NSLocalizedString(@"TVHeadend Server", @".. in settings screen")];
        if ( path.row < [self.servers count] ) {
            [vc setSelectedServer:path.row];
        } else {
            [vc setSelectedServer:-1];
        }
    }
    if ( [segue.identifier isEqualToString:@"SettingsGenericText"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHSettingsGenericTextViewController *vc = segue.destinationViewController;
        if ( path.row == 1 ) {
            [vc setTitle:NSLocalizedString(@"Issues", @".. in settings screen")];
            vc.url = @"https://github.com/zipleen/tvheadend-iphone-client/issues";
        }
        
        if ( path.row == 2 ) {
            [vc setTitle:NSLocalizedString(@"FAQ", @".. in settings screen")];
            vc.url = @"https://github.com/zipleen/tvheadend-iphone-client/wiki/FAQ";
        }
        
        if ( path.row == 3 ) {
            [vc setTitle:NSLocalizedString(@"About", @".. in settings screen")];
            vc.url = [[NSBundle bundleForClass:[self class]] pathForResource:@"about" ofType:@"html"];
        }
        if ( path.row == 4 ) {
            [vc setTitle:NSLocalizedString(@"Licenses", @".. in settings screen")];
            vc.url = [[NSBundle bundleForClass:[self class]] pathForResource:@"licenses" ofType:@"html"];
        }
    }
    if ( [segue.identifier isEqualToString:@"SettingsGenericField"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        if ( path.section == 1 && path.row == 2 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Order Channels", @".. in settings screen")];
            [vc setSectionHeader:NSLocalizedString(@"Order Channels", @".. in settings screen")];
            [vc setOptions:@[NSLocalizedString(@"by Name", @".. in settings screen"), NSLocalizedString(@"by Number", @".. in settings screen")] ];
            [vc setSelectedOption:[self.settings sortChannel]];
            [vc setResponseBack:^(NSInteger order) {
                [[TVHSettings sharedInstance] setSortChannel:order];
                
            }];
        }
        
        if ( path.section == 1 && path.row == 5 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Transcode Resolution", @".. in settings screen")];
            [vc setSectionHeader:NSLocalizedString(@"Choose transcode resolution", @".. in settings screen")];
            [vc setOptions:TVHS_TRANSCODE_RESOLUTIONS ];
            [vc setSelectedOption:[TVHS_TRANSCODE_RESOLUTIONS indexOfObject:[self.settings transcodeResolution]]];
            [vc setResponseBack:^(NSInteger order) {
                [[TVHSettings sharedInstance] setTranscodeResolution:[TVHS_TRANSCODE_RESOLUTIONS objectAtIndex:order]];
            }];
        }
        
        if ( path.section == 1 && path.row == 6 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Right Panel", @".. in settings screen")];
            [vc setSectionHeader:NSLocalizedString(@"Choose what you want to see on the right panel (App restart required)", @".. in settings screen")];
            [vc setOptions:@[NSLocalizedString(@"Dynamic based on screen", @".. in settings screen"), NSLocalizedString(@"Show Status", @".. in settings screen"), NSLocalizedString(@"Show Log", @".. in settings screen"), NSLocalizedString(@"None", @".. in settings screen")] ];
            [vc setSelectedOption:[self.settings splitRightMenu]];
            [vc setResponseBack:^(NSInteger order) {
                [[TVHSettings sharedInstance] setSplitRightMenu:order];
                
            }];
        }
    }
}

- (IBAction)doneSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
    if ( indexPath.row == 1 ) {
        [self.settings setCustomPrefix:textField.text];
    }
    return YES;
}

- (IBAction)autoStartPolling:(UISwitch*)sender {
    if ( sender.on == NO ) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Auto Start Polling", @".. in settings screen")
                                                             message:NSLocalizedString(@"POLLING_MESSAGE", @".. in settings screen")
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
        [errorAlert show];
    }
    [self.settings setAutoStartPolling:sender.on];
}

- (IBAction)sendAnonymousStatistics:(UISwitch*)sender {
    [self.settings setSendAnonymousStatistics:sender.on];
}

- (IBAction)useBlackBorders:(UISwitch*)sender {
    [self.settings setUseBlackBorders:sender.on];
}

@end
