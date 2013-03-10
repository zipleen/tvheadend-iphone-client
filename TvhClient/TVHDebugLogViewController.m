//
//  TVHDebugLogViewController.m
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDebugLogViewController.h"

@interface TVHDebugLogViewController ()
@property (strong, nonatomic) TVHLogStore *logStore;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [self.logStore objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)didLoadLog {
    [self.tableView reloadData];
}

@end
