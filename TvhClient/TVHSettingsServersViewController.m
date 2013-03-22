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

@implementation TVHSettingsServersViewController {
    BOOL newServer;
}

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
    newServer = NO;
    
    if ( self.selectedServer == -1 ) {
        newServer = YES;
        self.selectedServer = [self.settings addNewServer];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if ( newServer ) {
        for (NSString *str in TVHS_SERVER_KEYS) {
            if ( ![[self.settings serverProperty:str forServer:self.selectedServer] isEqualToString:@""] ) {
                return ;
            }
        }
        [self.settings removeServer:self.selectedServer];
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
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = NO;
    textField.returnKeyType = UIReturnKeyDone;
    if ( indexPath.row == 0 ) {
        cell.textLabel.text = NSLocalizedString(@"Name", nil);
        textField.placeholder = @"Name";
    }
    if ( indexPath.row == 1 ) {
        cell.textLabel.text = NSLocalizedString(@"IP", nil);
        textField.placeholder = @"Server Address";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    if ( indexPath.row == 2 ) {
        cell.textLabel.text = NSLocalizedString(@"Port", nil);
        textField.placeholder = @"9981";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    if ( indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Username", nil);
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    if ( indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"Password", nil);
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.secureTextEntry = YES;
    }
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = UITextAlignmentLeft;
    textField.tag = indexPath.row;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    [textField setEnabled: YES];
    textField.text = [self.settings serverProperty:TVHS_SERVER_KEYS[indexPath.row] forServer:self.selectedServer] ;
    
    [cell.contentView addSubview:textField];
    
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
