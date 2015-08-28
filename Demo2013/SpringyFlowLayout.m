//
//  SpringyFlowLayout.m
//  Demo2013
//
//  Created by Antonio081014 on 8/28/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

#import "SpringyFlowLayout.h"
@interface SpringyFlowLayout()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic) CGFloat latestDelta;
@end
@implementation SpringyFlowLayout

- (NSMutableSet *)visibleIndexPathsSet
{
    if (!_visibleIndexPathsSet) {
        _visibleIndexPathsSet = [NSMutableSet set];
    }
    return _visibleIndexPathsSet;
}

- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // Need to overflow our actual visible rect slightly to avoid flickering.
    CGRect originalRect = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size};
    CGRect visibleRect = CGRectInset(originalRect, -100, -100);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }]];
    
    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        return !currentlyVisible;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = 0.0f;
        springBehaviour.damping = 0.5f;
        springBehaviour.frequency = 0.8f;
        
        // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
            
            if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            }
            else {
                center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            }
            item.center = center;
        }
        
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = (UIScrollView *)self.collectionView;
    CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
    self.latestDelta = scrollDelta;
    
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors) {
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 500;
        
        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        center.y += scrollDelta * MIN(scrollResistance, 1.0);
        if (scrollDelta < 0) {
            center.y += MAX(scrollDelta, scrollDelta * scrollResistance);
        }
        else {
            center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
        }

        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }
    return NO;
}
@end
