//
//  NPReorderableTableView.h
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPReorderableTableView : UITableView
@property (nonatomic, readonly) NSIndexPath *dragIndexPath;
@property (nonatomic, readonly) NSIndexPath *dropIndexPath;
@property (nonatomic, assign) BOOL allowsDragging;
@property (nonatomic, assign) BOOL showsInvalidMove;


@end
