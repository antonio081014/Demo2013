//
//  ScrollingCellTableViewCell.m
//  Demo2013
//
//  Created by Antonio081014 on 8/27/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

#import "ScrollingCell.h"

@interface ScrollingCell() <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) BOOL pulling;

@property (nonatomic) BOOL deceleratingBackToZero;
@property (nonatomic) CGFloat decelerationDistanceRatio;
@end

@implementation ScrollingCell

const static CGFloat PULL_THRESHOLD = 120.f;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x;
    if (offset > PULL_THRESHOLD && !self.pulling) {
        [self.delegate scrollingCellDidBeginPulling:self];
        self.pulling = YES;
    }
    
    if (self.pulling) {
        CGFloat pullOffset;
        
        if (self.deceleratingBackToZero) {
            pullOffset = offset * self.decelerationDistanceRatio;
        } else {
            pullOffset = MAX(0, offset - PULL_THRESHOLD);
        }
        
        [self.delegate scrollingCell:self didChangePullOffset:pullOffset];
        self.scrollView.transform = CGAffineTransformMakeTranslation(pullOffset, 0);
    }
}

- (void)scrollingEnded
{
    [self.delegate scrollingCellDidEndPulling:self];
    self.pulling = NO;
    
    self.deceleratingBackToZero = NO;
    self.scrollView.contentOffset = CGPointZero;
    
    self.scrollView.transform = CGAffineTransformIdentity;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingEnded];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingEnded];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat offset = self.scrollView.contentOffset.x;
    
    if ((*targetContentOffset).x == 0 && offset > 0) {
        self.deceleratingBackToZero = YES;
        
        CGFloat pullOffset = MAX(0, offset - PULL_THRESHOLD);
        self.decelerationDistanceRatio = pullOffset / offset;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.colorView = [[UIView alloc] init];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView addSubview:self.colorView];
    [self.contentView addSubview:self.scrollView];
    
    self.contentView.backgroundColor = [UIColor grayColor];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.colorView.backgroundColor = color;
}

- (void)layoutSubviews
{
    UIView *contentView = self.contentView;
    CGRect bounds = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y, 320, contentView.bounds.size.height);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, 320, self.contentView.frame.size.height);
    
    NSLog(@"%@", NSStringFromCGRect(bounds));
    
    CGFloat pageWidth = bounds.size.width + PULL_THRESHOLD;
    self.scrollView.frame = CGRectMake(0, 0, pageWidth, bounds.size.height);
    self.scrollView.contentSize = CGSizeMake(pageWidth * 2, bounds.size.height);
    
    self.colorView.frame = [self.scrollView convertRect:bounds fromCoordinateSpace:contentView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}

@end
