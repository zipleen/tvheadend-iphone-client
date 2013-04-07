//
//  TVHSettingsViewController.m
//  TvhClient
//
//  Created by zipleen on 3/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSettingsViewController.h"
#import "TVHSettingsServersViewController.h"
#import "TVHSettingsGenericTextViewController.h"
#import "TVHSettingsGenericFieldViewController.h"
#import "TVHChannelStore.h"
#import "TVHSettings.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

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
}

- (void)viewDidAppear:(BOOL)animated {
    self.servers = [self.settings availableServers];
    [self.tableView reloadData];
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
        return NSLocalizedString(@"TVHeadend Servers", nil);
    }
    if (section == 1) {
        return NSLocalizedString(@"Advanced Settings", nil);
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
        return 5;
    }
    if ( section == 2 ) {
        return 3;
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
            cell.textLabel.text = NSLocalizedString(@"Add New TVHeadend", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.imageView setImage:nil];
        }
    }
    if ( indexPath.section == 1 ) {
        
        if ( indexPath.row == 0 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsDetailCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsDetailCell"];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Cache Data for", nil);
            NSInteger minutes = [self.settings cacheTime];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", (minutes/60) ,NSLocalizedString(@"minutes", nil)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ( indexPath.row == 1 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsSwitchCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsSwitchCell"];
            }
            
            UISwitch *switchfield = (UISwitch *)[cell viewWithTag:300];
            [switchfield setOn:[self.settings autoStartPolling]];
            [switchfield addTarget:self action: @selector(autoStartPolling:) forControlEvents:UIControlEventValueChanged];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:301];
            textLabel.text = NSLocalizedString(@"Auto Start Polling", nil);
        }
        if ( indexPath.row == 2 ) {
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
            textLabel.text = NSLocalizedString(@"Custom Player URL", nil);
            textLabel.adjustsFontSizeToFitWidth = YES;
        }
        if ( indexPath.row == 3 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsDetailCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsDetailCell"];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Order Channels", nil);
            if ( [self.settings sortChannel] == TVHS_SORT_CHANNEL_BY_NAME ) {
                cell.detailTextLabel.text = NSLocalizedString(@"by Name", nil);
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"by Number", nil);
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ( indexPath.row == 4 ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsOptionsSwitchCell"];
            if(cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsOptionsSwitchCell"];
            }
            
            UISwitch *switchfield = (UISwitch *)[cell viewWithTag:300];
            [switchfield setOn:[self.settings sendAnonymousStatistics]];
            [switchfield addTarget:self action: @selector(sendAnonymousStatistics:) forControlEvents:UIControlEventValueChanged];
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:301];
            textLabel.text = NSLocalizedString(@"Anonymous Statistics", nil);
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
            cell.textLabel.text = NSLocalizedString(@"Support", nil);
        }
        if ( indexPath.row == 1 ) {
            icon = NIKFontAwesomeIconInfoSign;
            cell.textLabel.text = NSLocalizedString(@"About", nil);
        }
        if ( indexPath.row == 2 ) {
            icon = NIKFontAwesomeIconFileAlt;
            cell.textLabel.text = NSLocalizedString(@"Licenses", nil);
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


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set server
    if ( indexPath.section == 0 && [self.tableView isEditing] == NO ) {
        if ( indexPath.row < [self.servers count] ) {
            [self.settings setSelectedServer:indexPath.row];
            [self.tableView reloadData];
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
    
    if ( indexPath.section == 1 && indexPath.row == 0 ) {
        [self performSegueWithIdentifier:@"SettingsGenericField" sender:self];
    }
    
    if ( indexPath.section == 1 && indexPath.row == 3 ) {
        [self performSegueWithIdentifier:@"SettingsGenericField" sender:self];
    }
    
    if ( indexPath.section == 2 ) {
        [self performSegueWithIdentifier:@"SettingsGenericText" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"SettingsServers"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHSettingsServersViewController *vc = segue.destinationViewController;
        [vc setTitle:NSLocalizedString(@"TVHeadend Server", nil)];
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
            [vc setTitle:NSLocalizedString(@"About", nil)];
            [vc setDisplayText:[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"about" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL]];
        }
        if ( path.row == 2 ) {
            [vc setTitle:NSLocalizedString(@"Licenses", nil)];
            [vc setDisplayText:[NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"licenses" ofType:@"txt"] encoding:NSUTF8StringEncoding error:NULL]];
        }
    }
    if ( [segue.identifier isEqualToString:@"SettingsGenericField"] ) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        if ( path.section == 1 && path.row == 3 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Order Channels", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Order Channels", nil)];
            [vc setOptions:@[NSLocalizedString(@"by Name", nil), NSLocalizedString(@"by Number", nil)] ];
            [vc setSelectedOption:[self.settings sortChannel]];
            [vc setResponseBack:^(NSInteger order) {
                [[TVHSettings sharedInstance] setSortChannel:order];
                [[TVHChannelStore sharedInstance] resetChannelStore];
            }];
        }
        if ( path.section == 1 && path.row == 0 ) {
            TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
            [vc setTitle:NSLocalizedString(@"Cache Data", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Cache Data for", nil)];
            [vc setOptions:@[@"0 minutes", @"3 minute", @"6 minutes", @"9 minutes", @"12 minutes"]];
            [vc setSelectedOption:[self.settings cacheTime]/3/60];
            [vc setResponseBack:^(NSInteger order) {
                [[TVHSettings sharedInstance] setCacheTime:order*3*60];
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell*)[[textField superview]superview]];
    if ( indexPath.row == 0 ) {
        [self.settings setCacheTime:[textField.text doubleValue]];
    }
    if ( indexPath.row == 2 ) {
        [self.settings setCustomPrefix:textField.text];
    }
    return YES;
}

- (IBAction)autoStartPolling: (UISwitch*) sender {
    [self.settings setAutoStartPolling:sender.on];
}

- (IBAction)sendAnonymousStatistics: (UISwitch*) sender {
    [self.settings setSendAnonymousStatistics:sender.on];
}

@end
