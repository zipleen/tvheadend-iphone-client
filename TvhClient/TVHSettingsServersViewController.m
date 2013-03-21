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
        self.selectedServer = [self.settings addNewServer];
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
        return NSLocalizedString(@"TVHeadend Server Details", nil);
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServerPropertiesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    playerTextField.adjustsFontSizeToFitWidth = YES;
    playerTextField.textColor = [UIColor blackColor];
    if ( indexPath.row == 0 ) {
        cell.textLabel.text = NSLocalizedString(@"Name", nil);
        playerTextField.placeholder = @"Name";
        playerTextField.keyboardType = UIKeyboardTypeDefault;
        playerTextField.returnKeyType = UIReturnKeyDone;
        playerTextField.secureTextEntry = NO;
    }
    if ( indexPath.row == 1 ) {
        cell.textLabel.text = NSLocalizedString(@"IP", nil);
        playerTextField.placeholder = @"Server Address";
        playerTextField.keyboardType = UIKeyboardTypeAlphabet;
        playerTextField.returnKeyType = UIReturnKeyDone;
        playerTextField.secureTextEntry = NO;
    }
    if ( indexPath.row == 2 ) {
        cell.textLabel.text = NSLocalizedString(@"Port", nil);
        playerTextField.placeholder = @"9981";
        playerTextField.keyboardType = UIKeyboardTypeNumberPad;
        playerTextField.returnKeyType = UIReturnKeyDefault; //UIReturnKeyDone
        playerTextField.secureTextEntry = NO;
    }
    if ( indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Username", nil);
        playerTextField.placeholder = @"";
        playerTextField.keyboardType = UIKeyboardTypeDefault;
        playerTextField.returnKeyType = UIReturnKeyDefault;
        playerTextField.secureTextEntry = NO;
    }
    if ( indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"Password", nil);
        playerTextField.placeholder = @"";
        playerTextField.keyboardType = UIKeyboardTypeDefault;
        playerTextField.returnKeyType = UIReturnKeyDone;
        playerTextField.secureTextEntry = YES;
    }
    playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    playerTextField.textAlignment = UITextAlignmentLeft;
    playerTextField.tag = indexPath.row;
    playerTextField.delegate = self;
    playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    [playerTextField setEnabled: YES];
    playerTextField.text = [self.settings serverProperty:TVHS_SERVER_KEYS[indexPath.row] forServer:self.selectedServer] ;
    
    [cell.contentView addSubview:playerTextField];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.settings setServerProperty:textField.text forServer:self.selectedServer ForKey:TVHS_SERVER_KEYS[textField.tag]];
    return YES;
}

@end
