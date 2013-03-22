//
//  TVHDebugLogViewController.m
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHDebugLogViewController.h"
#import "TVHCometPollStore.h"

@interface TVHDebugLogViewController ()
@property (strong, nonatomic) TVHLogStore *logStore;
@property (strong, nonatomic) TVHCometPollStore *cometPoll;
@end

@implementation TVHDebugLogViewController

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
    self.logStore = [TVHLogStore sharedInstance];
    [self.logStore setDelegate:self];
    
    self.cometPoll = [TVHCometPollStore sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearLog:)
                                                 name:@"resetAllObjects"
                                               object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setDebugButton:nil];
    self.logStore = nil;
    self.cometPoll = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    if ( [self.cometPoll isDebugActive] ) {
        self.debugButton.style = UIBarButtonItemStyleDone;
    } else {
        self.debugButton.style = UIBarButtonItemStyleBordered;
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row % 2 ) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = [self.logStore objectAtIndex:indexPath.row];
    
    CGSize size = [str
                   sizeWithFont:[UIFont systemFontOfSize:12]
                   constrainedToSize:CGSizeMake(310, CGFLOAT_MAX)];
    return size.height + 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogCellItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *logCell = (UILabel *)[cell viewWithTag:100];
    
    
    CGSize size = [logCell.text
                   sizeWithFont:[UIFont systemFontOfSize:12]
                   constrainedToSize:CGSizeMake(310, CGFLOAT_MAX)];
    logCell.frame = CGRectMake(0, 0, 320, size.height);
    logCell.text = [self.logStore objectAtIndex:indexPath.row];
    return cell;
}

- (void)didLoadLog {
    [self.tableView reloadData];
    int countLines = [self.logStore count];
    if ( countLines > 0 ) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: countLines-1 inSection: 0];
        [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated: YES];
    }
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
    [self.tableView reloadData];
}
@end
