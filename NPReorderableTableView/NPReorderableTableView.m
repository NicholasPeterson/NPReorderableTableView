//
//  NPReorderableTableView.m
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import "NPReorderableTableView.h"

@interface NPReorderableTableView () <UIGestureRecognizerDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILongPressGestureRecognizer *triggerGesture;
@property (nonatomic, strong, readwrite) NSIndexPath *dragIndexPath;
@property (nonatomic, strong, readwrite) NSIndexPath *dropIndexPath;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIImageView *cellGhost;
@property (nonatomic) CGPoint touchPoint;

//States
@property (nonatomic, assign) BOOL internalDragging;
@property (nonatomic, assign, getter = validMove) BOOL validMove;

@end

@implementation NPReorderableTableView

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.triggerGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(triggerGestureActivated:)];
    self.triggerGesture.delegate = self;
    [self addGestureRecognizer:self.triggerGesture];
    self.allowsDragging = YES;
    self.showsInvalidMove = YES;
    self.dataSource = self;
}

- (void)reset {
    self.internalDragging = NO;
    [self.cellGhost removeFromSuperview];
    self.cellGhost = nil;
    self.dropIndexPath = nil;
    self.dragIndexPath = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;

    //Cancel any current gesture
    self.triggerGesture.enabled = NO;
    self.triggerGesture.enabled = YES;
}

- (BOOL)isDragging {
    return self.internalDragging;
}

- (void)setAllowsDragging:(BOOL)allowsDragging {
    if (_allowsDragging == allowsDragging) return; ///////////////

    if (!allowsDragging) [self reset];
    self.triggerGesture.enabled = allowsDragging;

    _allowsDragging = allowsDragging;
}

#pragma mark - Drag Logic

- (void)triggerGestureActivated:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        self.internalDragging = YES;
        [self beginDragging];
        break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        self.internalDragging = NO;
        [self endDragging];
        break;

        default:
        break;
    }
}

- (void)beginDragging {
    self.touchPoint = [self.triggerGesture locationInView:self];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(syncDisplay:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    NSIndexPath *indexPath = [self indexPathForRowAtPoint:self.touchPoint];
    self.dragIndexPath = indexPath;
    self.dropIndexPath = indexPath;

    UITableViewCell *cell = [self cellForRowAtIndexPath:self.dragIndexPath];
    cell.highlighted = NO;
    self.cellGhost = [[UIImageView alloc] initWithImage:[self ghostImageWithCell:cell]];
    [self addSubview:self.cellGhost];
    self.cellGhost.frame = cell.frame;

    [self dragDidStartAnimation];
    [self reloadRowsAtIndexPaths:@[self.dropIndexPath] withRowAnimation: UITableViewRowAnimationNone];
}

- (void)updateDragWithPoint:(CGPoint)touchPoint {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:touchPoint];
    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        indexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:self.dragIndexPath toProposedIndexPath:indexPath];
    }

    if (![indexPath isEqual:self.dropIndexPath]) {
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.dropIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];

        self.dropIndexPath = indexPath;
        [self endUpdates];
    }
}

- (void)endDragging {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:self.touchPoint];

    [UIView animateWithDuration:0.2 animations:^{
        self.cellGhost.transform = CGAffineTransformIdentity;
        self.cellGhost.frame = [self rectForRowAtIndexPath:indexPath];
    }completion:^(BOOL finished) {
        if (finished) {
            [self commitDrop];
            [self reset];
        }
    }];
}

- (void)dragDidStartAnimation {
    [UIView beginAnimations:@"zoom" context:nil];
    self.cellGhost.alpha = 0.9f;
    self.cellGhost.transform = CGAffineTransformMakeScale(1.08f, 1.08f);
    self.cellGhost.center = CGPointMake(self.center.x, self.touchPoint.y);
    [UIView commitAnimations];
}

- (void)invalidMoveAnimation {
    [UIView beginAnimations:@"offTable" context:nil];
    self.cellGhost.alpha = 1.0f;
    self.cellGhost.transform = CGAffineTransformMakeRotation(M_PI/32);
    self.cellGhost.center = CGPointMake(self.center.x, self.touchPoint.y);
    [UIView commitAnimations];
}
- (NSIndexPath *)translatedIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) return nil; ////////

    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        indexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:self.dragIndexPath toProposedIndexPath:indexPath];
    }

    return indexPath;
}
- (void)showMoveValidity {

    NSIndexPath *indexPath = [self indexPathForRowAtPoint:self.touchPoint];
    NSIndexPath *translatedIndexPath = [self translatedIndexPath:indexPath];

    BOOL newIsValidMove = (indexPath && [translatedIndexPath isEqual:indexPath]);
    BOOL oldIsValidMove = self.validMove;

    if (oldIsValidMove != newIsValidMove) {
        if (newIsValidMove == NO) {
            [self invalidMoveAnimation];
        }else {
            [self dragDidStartAnimation];
        }
    }

    self.validMove = newIsValidMove;
}


- (void)updateGhostImagePostion {
    CGFloat centerPosition = self.touchPoint.y;
    CGFloat halfGhostHeight = self.cellGhost.bounds.size.height * 0.5f;

    if (centerPosition - self.contentOffset.y - halfGhostHeight < 0) {
        centerPosition = self.contentOffset.y + halfGhostHeight;
    }else if (centerPosition + halfGhostHeight > self.bounds.size.height + self.contentOffset.y) {
        centerPosition = (self.bounds.size.height+ self.contentOffset.y) - halfGhostHeight;
    }

    if (self.touchPoint.y > 0) {
        self.cellGhost.center = CGPointMake(self.center.x, centerPosition);

        if (self.showsInvalidMove) {
            [self showMoveValidity];
        }
    }
}

- (UIImage *)ghostImageWithCell:(UITableViewCell *)cell
{
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0.0f);
    [cell drawViewHierarchyInRect:cell.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return ([self indexPathForRowAtPoint:[gestureRecognizer locationInView:self]] != nil);
}

- (void)syncDisplay:(CADisplayLink *)displayLink {
    self.touchPoint = [self.triggerGesture locationInView:self];
    [self updateScroll];
    
    [self updateGhostImagePostion];
    if (![self indexPathForRowAtPoint:self.touchPoint]) return;

    [self updateDragWithPoint:self.touchPoint];
}

- (void)commitDrop {
    if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    [self.dataSource tableView:self moveRowAtIndexPath:self.dragIndexPath toIndexPath:self.dropIndexPath];
    [self reloadRowsAtIndexPaths:@[self.dropIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Scroll

- (BOOL)contentFitsOnTable {
    CGRect posedContentRect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    BOOL contentFitsInTable = CGRectContainsRect(self.bounds, posedContentRect);

    return contentFitsInTable;
}

- (CGFloat)scrollRateForUserPosition:(CGFloat)userPosition scrollThreshold:(CGFloat)threshold {
    CGFloat topThreshold =  self.contentOffset.y
                            + self.contentInset.top
                            + threshold;

    CGFloat bottomThreshold = self.bounds.size.height
                            + self.contentOffset.y
                            - self.contentInset.bottom
                            - threshold;

    CGFloat activatedThreshold = userPosition;
    activatedThreshold = MIN(activatedThreshold, bottomThreshold);
    activatedThreshold = MAX(activatedThreshold, topThreshold);

    return (userPosition - activatedThreshold) / threshold;
}

- (void)updateScroll {
    if (!self.internalDragging || [self contentFitsOnTable]) return; ////////////////////

    CGFloat offscreenScrollMax = self.contentSize.height + self.contentInset.bottom - self.bounds.size.height;

    CGFloat threshold = (self.bounds.size.height-self.contentInset.top)/6.0f;
    self.touchPoint = [self.triggerGesture locationInView:self];

    CGFloat scrollRate = [self scrollRateForUserPosition:self.touchPoint.y scrollThreshold:threshold];
    CGPoint offset = self.contentOffset;
    offset.y += (scrollRate * 10);
    offset.y = MAX(-self.contentInset.top, offset.y);
    offset.y = MIN(offscreenScrollMax, offset.y);

    self.contentOffset = offset;
}

@end
