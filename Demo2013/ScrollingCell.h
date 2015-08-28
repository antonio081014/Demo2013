//
//  ScrollingCellTableViewCell.h
//  Demo2013
//
//  Created by Antonio081014 on 8/27/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollingCellDelegate;

@interface ScrollingCell : UICollectionViewCell
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, weak) id<ScrollingCellDelegate> delegate;
@end

@protocol ScrollingCellDelegate <NSObject>
- (void)scrollingCellDidBeginPulling:(ScrollingCell *)cell;
- (void)scrollingCell:(ScrollingCell *)cell didChangePullOffset:(CGFloat)offset;
- (void)scrollingCellDidEndPulling:(ScrollingCell *)cell;
@end
