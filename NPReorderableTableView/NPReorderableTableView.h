//
//  NPReorderableTableView.h
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NPReorderableTableView : UITableView
@property (nonatomic, readonly) NSIndexPath *draggingIndexPath;
@property (nonatomic, assign) BOOL allowsDragging;
@property (nonatomic, assign) BOOL showsInvalidMove;

/**
 *  Determines if the table is dragging the given index path
 *
 *  @param indexPath The indexPath of the cell in question
 *
 *  @return YES if the table is currently dragging and if indexPath matches the picked up index path.
 */
- (BOOL)isDraggingIndexPath:(NSIndexPath *)indexPath;

@end
