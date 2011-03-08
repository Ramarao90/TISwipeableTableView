//
//  TISwipeableTableViewCell.h
//  SwipeableExample
//
//  Created by Marcel Müller on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TISwipeableTableViewCellView : UIView
@end

@interface TISwipeableTableViewCellBackView : UIView
@end

@interface TISwipeableTableViewCell : UITableViewCell {
	
	UIView * contentView;
	UIView * backView;
	
	BOOL contentViewMoving;
	BOOL selected;
	BOOL shouldSupportSwiping;
	BOOL shouldBounce;
}

@property (nonatomic, readonly) UIView * backView;
@property (nonatomic, assign) BOOL contentViewMoving;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, assign) BOOL shouldSupportSwiping;
@property (nonatomic, assign) BOOL shouldBounce;

- (void)drawContentView:(CGRect)rect;
- (void)drawBackView:(CGRect)rect;

- (void)backViewWillAppear;
- (void)backViewDidAppear;
- (void)backViewWillDisappear;
- (void)backViewDidDisappear;

- (void)revealBackView;
- (void)hideBackView;
- (void)resetViews;

@end
