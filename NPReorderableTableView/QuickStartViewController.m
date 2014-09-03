//
//  QuickStartViewController.m
//  NPReorderableTableView
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import "QuickStartViewController.h"
#import "NPReorderableTableView.h"
@interface QuickStartViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NPReorderableTableView *tableView;
@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation QuickStartViewController

#pragma mark - REQUIRED

- (void)registerTableViewCells {
    // 1) REQUIRED: Register for your cells. You MUST register some kind of placeholder cell.
    // The method name and identifier value is not important here.

    // EXAMPLE:
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"required_placeholder"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"your_cell_class"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if (self.tableView.dragging && [indexPath isEqual:self.tableView.dropIndexPath]) {
        // 2) REQUIRED: Use your placeholder cell if we are dragging and being asked for the dragged index

        // EXAMPLE:
        cell = [tableView dequeueReusableCellWithIdentifier:@"required_placeholder"];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];

    } else {
        //Your cell. you can treat this as usual.
        cell = [tableView dequeueReusableCellWithIdentifier:@"your_cell_class"];
        cell.textLabel.text = self.testData[indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 3) REQUIRED: update your data set
    //
    // Must be syncronized on the main thread or you will encounter internal consistancy assertions.
    // Try to avoic heavy operations as this will be called multiple times.

    //EXAMPLE:
    id buffer = self.testData[sourceIndexPath.row];
    [self.testData removeObjectAtIndex:sourceIndexPath.row];
    [self.testData insertObject:buffer atIndex:destinationIndexPath.row];
}


#pragma mark - Optional

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // OPTIONAL: Disallow dragging on specific indexpaths or entire sections.
    //
    // This avoids picking up the cell but not dropping it.
    // To protect against dropping see -tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:

    //EXAMPLE:
    if (indexPath.row > 13) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    // OPTIONAL: Redirect/block dropping cells.
    // This avoids dropping cells where they arent wanted but does not keep cells from being picked up.
    // To protect against picking up cells see -tableView:canMoveRowAtIndexPath:

    //EXAMPLE:
    NSIndexPath *newIndexPath = proposedDestinationIndexPath;
    if (newIndexPath.row >= 13) {
        newIndexPath = [NSIndexPath indexPathForRow:13 inSection:newIndexPath.section];
    }
    return newIndexPath;
}


#pragma mark - Example setup
// Create your table as you normally would.
// The following is intended only to set up the executable example.

- (NPReorderableTableView *)tableView {
    if (!_tableView) {
        self.tableView = [[NPReorderableTableView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.tableView];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        [self registerTableViewCells];
    }
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    self.title = @"NPReorderableTableView";
    self.tableView.frame = self.view.bounds;
    self.testData = [@[@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10",@"11", @"12",@"13", @"14",@"15 - Restricted", @"16 - Restricted",@"17 - Restricted", @"18 - Restricted"] mutableCopy];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testData.count;
}

@end
