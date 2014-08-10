//
//  NPViewController.m
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import "NPViewController.h"
#import "NPReorderableTableView.h"
@interface NPViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NPReorderableTableView *tableView;
@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (NPReorderableTableView *)tableView {
    if (!_tableView) {
        self.tableView = [[NPReorderableTableView alloc] initWithFrame:self.view.bounds];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Identifier"];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Placeholder"];
        [self.view addSubview:self.tableView];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        UILabel *invalidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
        invalidLabel.text = @"I am an invalid drag area";
        invalidLabel.backgroundColor = [UIColor whiteColor];
        invalidLabel.textAlignment = NSTextAlignmentCenter;
        invalidLabel.textColor = [UIColor lightGrayColor];
        self.tableView.tableHeaderView = invalidLabel;
    }
    return _tableView;
}


-(void)viewWillAppear:(BOOL)animated {
    self.tableView.frame = self.view.bounds;
    self.testData = [@[@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10",@"11", @"12",@"13", @"14",@"15 - dont move", @"16 - dont move",@"17 - dont move", @"18 - dont move"] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if (self.tableView.dragging && [indexPath isEqual:self.tableView.dropIndexPath ]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
        cell.textLabel.text = self.testData[indexPath.row];
    }

    return cell;
}

- (NSMutableArray *)dataInSection:(NSUInteger)section {
    return self.testData[section];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    id buffer = self.testData[sourceIndexPath.row];
    [self.testData removeObjectAtIndex:sourceIndexPath.row];
    [self.testData insertObject:buffer atIndex:destinationIndexPath.row];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *newIndexPath = proposedDestinationIndexPath;
    if (newIndexPath.row >= 13) {
        newIndexPath = [NSIndexPath indexPathForRow:13 inSection:newIndexPath.section];
    }
    return newIndexPath;
}

@end
