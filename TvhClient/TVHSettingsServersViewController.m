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
    if (section == 1) {
        return NSLocalizedString(@"Authentication", nil);
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 ) {
        return 3;
    }
    if ( section == 1 ) {
        return 2;
    }
    return 0;
}

- (NSInteger)indexOfSettingsArray:(NSInteger)section row:(NSInteger)row {
    NSInteger c = 0;
    if ( section == 1 ) {
        c = c + 3;
    }
    return c + row;
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
    if ( indexPath.row == 0 && indexPath.section == 0 ) {
        cell.textLabel.text = NSLocalizedString(@"Label", nil);
        textField.placeholder = @"Name";
    }
    if ( indexPath.row == 1 && indexPath.section == 0  ) {
        cell.textLabel.text = NSLocalizedString(@"IP", nil);
        textField.placeholder = @"Server Address";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }
    if ( indexPath.row == 2 && indexPath.section == 0  ) {
        cell.textLabel.text = NSLocalizedString(@"Port", nil);
        textField.placeholder = @"9981";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    if ( indexPath.row == 0 && indexPath.section == 1 ) {
        cell.textLabel.text = NSLocalizedString(@"Username", nil);
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    if ( indexPath.row == 1 && indexPath.section == 1 ) {
        cell.textLabel.text = NSLocalizedString(@"Password", nil);
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.secureTextEntry = YES;
    }
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = UITextAlignmentLeft;
    textField.tag = indexPath.row + (indexPath.section * 10);
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    textField.enabled = YES;
    textField.text = [self.settings serverProperty:TVHS_SERVER_KEYS[[self indexOfSettingsArray:indexPath.section row:indexPath.row]] forServer:self.selectedServer] ;
    
    [cell.contentView addSubview:textField];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    UITableViewCell* myCell = (UITableViewCell*)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: myCell];
    
    [self.settings setServerProperty:textField.text forServer:self.selectedServer ForKey:TVHS_SERVER_KEYS[[self indexOfSettingsArray:indexPath.section row:indexPath.row]]];
    return YES;
}

@end
