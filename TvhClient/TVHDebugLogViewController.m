//
//  TVHDebugLogViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 09/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDebugLogViewController.h"
#import "TVHSingletonServer.h"

@interface TVHDebugLogViewController () <UISearchBarDelegate>
@property (weak, nonatomic) TVHLogStore *logStore;
@property (strong, nonatomic) NSArray *logLines;
@property (weak, nonatomic) id <TVHCometPoll> cometPoll;
@end

@implementation TVHDebugLogViewController {
    BOOL shouldBeginEditing;
    NSDate *lastTableUpdate;
}

- (id <TVHCometPoll>)cometPoll
{
    if ( _cometPoll == nil ) {
        _cometPoll = [[TVHSingletonServer sharedServerInstance] cometStore];
    }
    return _cometPoll;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initDelegate {
    if( [self.logStore delegate] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoadLog)
                                                     name:@"didLoadLog"
                                                   object:self.logStore];
    } else {
        [self.logStore setDelegate:self];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logStore = [[TVHSingletonServer sharedServerInstance] logStore];
    [self initDelegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearLog:)
                                                 name:TVHWillDestroyServerNotification
                                               object:nil];
    
    lastTableUpdate = [NSDate dateWithTimeIntervalSinceNow:-1];
    self.searchBar.delegate = self;
    shouldBeginEditing = YES;
    self.title = NSLocalizedString(@"Log", @"");
    
    if ( self.splitViewController ) {
        NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
        UIBarButtonItem *split = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Resize", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(moveSplit:)];
        [buttons addObject:split];
        self.navigationItem.rightBarButtonItems = [buttons copy];
    }
    
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setDebugButton:nil];
    self.logStore = nil;
    self.logLines = nil;
    self.cometPoll = nil;
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    if ( [self.cometPoll isDebugActive] ) {
        self.debugButton.style = UIBarButtonItemStyleDone;
    } else {
        self.debugButton.style = UIBarButtonItemStyleBordered;
    }
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [TVHAnalytics sendView:NSStringFromClass([self class])];
}

- (void)reloadData {
    self.logLines = [self.logStore arrayLogLines];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row % 2 ) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.824 green:0.824 blue:0.824 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    }
}

- (NSString*)lineAtIndex:(NSUInteger)row {
    return [self.logLines objectAtIndex:[self.logLines count]-1-row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [self lineAtIndex:indexPath.row];
    unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGSize size = [str
                   sizeWithFont:[UIFont systemFontOfSize:12]
                   constrainedToSize:CGSizeMake(screenWidth-20, CGFLOAT_MAX)];
    return size.height + 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logLines count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCellItems" forIndexPath:indexPath];
    
    UILabel *logCell = (UILabel *)[cell viewWithTag:100];
    
    unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    CGSize size = [logCell.text
                   sizeWithFont:logCell.font
                   constrainedToSize:CGSizeMake(screenWidth-20, CGFLOAT_MAX)];
    logCell.frame = CGRectMake(10, 5, screenWidth-20, size.height);
    logCell.text = [self lineAtIndex:indexPath.row];
    
    if ( indexPath.row % 2 ) {
        logCell.backgroundColor = [UIColor colorWithRed:0.824 green:0.824 blue:0.824 alpha:1];
    } else {
        logCell.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    }
    
    return cell;
}

- (void)didLoadLog {
    if ( [[NSDate date] compare:[lastTableUpdate dateByAddingTimeInterval:1]] == NSOrderedDescending ) {
        [self reloadData];
        lastTableUpdate = [NSDate date];
    }
    /*int countLines = [self.logStore count];
    if ( countLines > 0 ) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: countLines-1 inSection: 0];
        [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated: YES];
    }*/
}

- (IBAction)debugButton:(UIBarButtonItem *)sender {
    [self.cometPoll toggleDebug];
    if ( [self.cometPoll isDebugActive] ) {
        self.debugButton.style = UIBarButtonItemStyleDone;
    } else {
        self.debugButton.style = UIBarButtonItemStyleBordered;
    }
}

- (IBAction)clearLog:(id)sender {
    [self.logStore clearLog];
    self.logStore = [[TVHSingletonServer sharedServerInstance] logStore];
    [self.logStore setDelegate:self];
    [self reloadData];
}

#pragma mark search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button - from http://stackoverflow.com/questions/1092246/uisearchbar-clearbutton-forces-the-keyboard-to-appear
        shouldBeginEditing = NO;
        [self.logStore setFilter:@""];
        [self reloadData];
        return;
    }
    [self.logStore setFilter:searchBar.text];
    [self reloadData];
    if ( [searchText isEqualToString:@""] ) {
        // why do I have to do this!??! if I put the resignFirstResponder here, it doesn't work...
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (IBAction)moveSplit:(id)sender {
    if( self.splitViewController ) {
        MGSplitViewDividerStyle newStyle = ((self.splitViewController.dividerStyle == MGSplitViewDividerStyleThin) ? MGSplitViewDividerStylePaneSplitter : MGSplitViewDividerStyleThin);
        [self.splitViewController setDividerStyle:newStyle animated:YES];
    }
}
@end
