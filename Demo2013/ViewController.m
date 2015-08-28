//
//  ViewController.m
//  Demo2013
//
//  Created by Antonio081014 on 8/27/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

#import "ViewController.h"
#import "ScrollingCell.h"

@interface ViewController () <UICollectionViewDataSource, ScrollingCellDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIScrollView *outterScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.outterScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2);
    self.outterScrollView.showsHorizontalScrollIndicator = NO;
    self.outterScrollView.showsVerticalScrollIndicator = NO;
}

#pragma ScrollingCell Delegate
- (void)scrollingCellDidBeginPulling:(ScrollingCell *)cell
{
    self.outterScrollView.scrollEnabled = NO;
}

- (void)scrollingCell:(ScrollingCell *)cell didChangePullOffset:(CGFloat)offset
{
    self.outterScrollView.contentOffset = CGPointMake(offset, 0);
}

- (void)scrollingCellDidEndPulling:(ScrollingCell *)cell
{
    self.outterScrollView.scrollEnabled = YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 80;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScrollingCell *cell = (ScrollingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.color = [self randomColor];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
const static CGFloat UICollectionCellDefaultHeight = 50.f;
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), UICollectionCellDefaultHeight);
}

- (UIColor *)randomColor
{
    CGFloat r = 1.0 * (arc4random() % 256) / 255.f;
    CGFloat g = 1.0 * (arc4random() % 256) / 255.f;
    CGFloat b = 1.0 * (arc4random() % 256) / 255.f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

@end
