//
//  NPViewController.m
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import "NPViewController.h"
#import "NPReorderableTableView.h"
@interface NPViewController () <UITableViewDataSource>

@property (nonatomic, strong) NPReorderableTableView *tableView;
@property (nonatomic, strong) NSMutableArray *testData;

@end

@implementation NPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[NPReorderableTableView alloc] initWithFrame:self.view.bounds];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Identifier"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Placeholder"];

    self.testData = [@[@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10",@"11", @"12",@"13", @"14",@"15", @"16",@"17", @"18"] mutableCopy];

    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
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

    if (self.tableView.reordering && [indexPath isEqual:self.tableView.dropIndexPath ]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
        cell.textLabel.text = self.testData[indexPath.row];

    }

    return cell;
}
-(NSMutableArray *)dataInSection:(NSUInteger)section {
    return self.testData[section];
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    id buffer = self.testData[sourceIndexPath.row];
    [self.testData removeObjectAtIndex:sourceIndexPath.row];
    [self.testData insertObject:buffer atIndex:destinationIndexPath.row];
}

@end
