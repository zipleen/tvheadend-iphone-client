//
//  TVHSettingsServersViewController.m
//  TvhClient
//
//  Created by zipleen on 3/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSettingsServersViewController.h"
#import "TVHSettings.h"


@interface TVHSettingsServersViewController () <UITextFieldDelegate>
@property (nonatomic, weak) TVHSettings *settings;
@property (nonatomic, strong) NSMutableDictionary *server;
@end

@implementation TVHSettingsServersViewController

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
    if (section == 0) {
        return NSLocalizedString(@"TVHeadend Server Details", @"..in Settings server edit");
    }
    if (section == 1) {
        return NSLocalizedString(@"Authentication", @"..in Settings server edit");
    }
    if (section == 2) {
        return NSLocalizedString(@"Advanced Options", @"..in Settings server edit");
    }
    if (section == 3) {
        return NSLocalizedString(@"SSH Port Forward", @"..in Settings server edit");
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 3;
    }
    if ( section == 1 ) {
        return 2;
    }
    if ( section == 2 ) {
        return 2;
    }
    if ( section == 3 ) {
        return 4;
    }
    return 0;
}

- (NSInteger)indexOfSettingsArray:(NSInteger)section row:(NSInteger)row {
    NSInteger c = 0;
    if ( section >= 1 ) {
        c = c + 3;
    }
    if ( section >= 2 ) {
        c = c + 2;
    }
    if ( section >= 3 ) {
        c = c + 2;
    }
    return c + row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServerPropertiesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
    if ( indexPath.row == 0 && indexPath.section == 0 ) {
        textLabel.text = NSLocalizedString(@"Name", @"..in Settings server edit");
        textField.placeholder = @"";
    }
    if ( indexPath.row == 1 && indexPath.section == 0  ) {
        textLabel.text = NSLocalizedString(@"Address", @"..in Settings server edit");
        textField.placeholder = @"IP or Address";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    if ( indexPath.row == 2 && indexPath.section == 0  ) {
        textLabel.text = NSLocalizedString(@"Port", @"..in Settings server edit");
        textField.placeholder = @"9981";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    if ( indexPath.row == 0 && indexPath.section == 1 ) {
        textLabel.text = NSLocalizedString(@"Username", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    if ( indexPath.row == 1 && indexPath.section == 1 ) {
        textLabel.text = NSLocalizedString(@"Password", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.secureTextEntry = YES;
    }
    if ( indexPath.row == 0 && indexPath.section == 2 ) {
        textLabel.text = NSLocalizedString(@"Use HTTPS", @"..in Settings server edit");
        textField.hidden = YES;
        switchfield.hidden = NO;
        if ( [[self.server objectForKey:TVHS_USE_HTTPS] isEqualToString:@""] ) {
            [switchfield setOn:NO];
        } else {
            [switchfield setOn:YES];
        }
        [switchfield addTarget:self action: @selector(setUseHttps:) forControlEvents:UIControlEventValueChanged];
    }
    if ( indexPath.row == 1 && indexPath.section == 2 ) {
        textLabel.text = NSLocalizedString(@"Web Root", @"..in Settings server edit");
        textField.placeholder = @"/";
        textField.keyboardType = UIKeyboardTypeURL;
    }
    if ( indexPath.row == 0 && indexPath.section == 3  ) {
        textLabel.text = NSLocalizedString(@"Address", @"..in Settings server edit");
        textField.placeholder = @"SSH Host Address";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    if ( indexPath.row == 1 && indexPath.section == 3  ) {
        textLabel.text = NSLocalizedString(@"SSH Port", @"..in Settings server edit");
        textField.placeholder = @"22";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    if ( indexPath.row == 2 && indexPath.section == 3  ) {
        textLabel.text = NSLocalizedString(@"SSH Username", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    if ( indexPath.row == 3 && indexPath.section == 3  ) {
        textLabel.text = NSLocalizedString(@"SSH Password", @"..in Settings server edit");
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.secureTextEntry = YES;
    }
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = UITextAlignmentLeft;
    //textField.tag = indexPath.row + (indexPath.section * 10) + 100;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    textField.enabled = YES;
    textField.text = [self.server objectForKey:TVHS_SERVER_KEYS[[self indexOfSettingsArray:indexPath.section row:indexPath.row]] ] ;
    
    [cell.contentView addSubview:textField];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row == 0 && indexPath.section == 2 ) {
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
    UITableViewCell* myCell = (UITableViewCell*)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: myCell];
    
    [self.server setValue:textField.text
                   forKey:TVHS_SERVER_KEYS[ [self indexOfSettingsArray:indexPath.section
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
        [self.settings setServerProperties:server forServerId:self.selectedServer];
        [self.settings setSelectedServer:[self.settings selectedServer]];
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
