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
@property (nonatomic, strong) NSMutableDictionary *dynamicBehaviorDict;
@end
@implementation SpringyFlowLayout

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
    
    CGSize contentSize = [self collectionViewContentSize];
    // Not a good idea to load all of the attributes here at one time.
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    
    // Checking behaviors count is critical here.
    /**
     * <UIDynamicAnimator: 0x17552430> (0.056427s) in <SpringyFlowLayout: 0x1763fc30> {{0, 0}, {320, 4790}}: 
     * body <PKPhysicsBody> type:<Rectangle> representedObject:[<UICollectionViewLayoutAttributes: 0x1754eef0> 
     * index path: (<NSIndexPath: 0x17525650> {length = 2, path = 0 - 0}); frame = (0 0; 320 50); ] 0x17648c40  PO:(159.999985,25.000000) AN:(0.000000) VE:(0.000000,0.000000) AV:(0.000000) dy:(1) cc:(0) ar:(1) rs:(0) fr:(0.200000) re:(0.200000) de:(1.000000) gr:(0) 
     * without representedObject for item <UICollectionViewLayoutAttributes: 0x17540650> 
     * index path: (<NSIndexPath: 0x17558960> {length = 2, path = 0 - 0}); frame = (0 0; 320 50);
     */
    if (self.dynamicAnimator.behaviors.count == 0) {
        for (UICollectionViewLayoutAttributes *item in items) {
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
            spring.length = 0;
            spring.damping = 0.5;
            spring.frequency = 0.8;
            
            [self.dynamicAnimator addBehavior:spring];
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    UICollectionViewLayoutAttributes *item = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//    UIDynamicBehavior *behavior = [self.dynamicBehaviorDict valueForKey:itemIndexPath.description];
//    [self.dynamicAnimator removeBehavior:behavior];
//    [self.dynamicBehaviorDict removeObjectForKey:itemIndexPath.description];
//    return item;
//}
//
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    UICollectionViewLayoutAttributes *item = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
//    spring.length = 0;
//    spring.damping = 0.5;
//    spring.frequency = 0.8;
//    [self.dynamicAnimator addBehavior:spring];
//    [self.dynamicBehaviorDict setValue:spring forKey:itemIndexPath.description];
//    return item;
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = (UIScrollView *)self.collectionView;
    CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors) {
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 500;
        
        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        center.y += scrollDelta * MIN(scrollResistance, 1.0);
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }
    return NO;
}
@end
