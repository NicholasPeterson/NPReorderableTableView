//
//  NPReorderableTableView.m
//  NPDragDrop
//
//  Created by Nicholas Peterson on 8/6/14.
//  Copyright (c) 2014 Nicholas Peterson. All rights reserved.
//

#import "NPReorderableTableView.h"

@interface NPReorderableTableView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *triggerGesture;
@property (nonatomic, retain) NSIndexPath *dragIndexPath;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) UIImageView *cellGhost;
@property (nonatomic) CGPoint touchPoint;
@property (nonatomic, readwrite) BOOL reordering;

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
}

- (void)reset {
    [self.cellGhost removeFromSuperview];
    self.cellGhost = nil;
    self.dropIndexPath = nil;
    self.dragIndexPath = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark - Drag Logic

- (void)triggerGestureActivated:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        self.reordering = YES;
        [self beginDragging];
        break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        self.reordering = NO;
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
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];


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

- (UIImage *)ghostImageWithCell:(UITableViewCell *)cell
{
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.opaque, 0.0f);
    [cell drawViewHierarchyInRect:cell.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return ([self indexPathForRowAtPoint:[gestureRecognizer locationInView:self]] != nil);
}

- (void)syncDisplay:(CADisplayLink *)displayLink {
    self.touchPoint = [self.triggerGesture locationInView:self];
    [self updateScroll];
    
    if (![self indexPathForRowAtPoint:self.touchPoint]) return;
    if (self.touchPoint.y >= 0 && self.touchPoint.y <= self.contentSize.height + 50) {
        self.cellGhost.center = CGPointMake(self.center.x, self.touchPoint.y);
    }

    [self updateDragWithPoint:self.touchPoint];
}

- (void)commitDrop {
    if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    [self.dataSource tableView:self moveRowAtIndexPath:self.dragIndexPath toIndexPath:self.dropIndexPath];
    [self reloadRowsAtIndexPaths:@[self.dropIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Scroll

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
    CGFloat offscreenScrollMax = self.contentSize.height + self.contentInset.bottom - self.bounds.size.height;

    if (!self.reordering || !offscreenScrollMax) return;

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
