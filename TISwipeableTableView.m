//
//  TISwipeableTableView.m
//  TISwipeableTableView
//
//  Created by Tom Irving on 28/05/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TISwipeableTableView.h"
#import "TISwipeableTableViewCell.h"

//==========================================================
// - TISwipeableTableView
//==========================================================

@interface TISwipeableTableView (Private)
- (BOOL)supportsSwipingForCellAtPoint:(CGPoint)point;
@end


@implementation TISwipeableTableView
@synthesize swipeDelegate;
@synthesize indexOfVisibleBackView;

// If you're not supporting 3.1.x, then gesture recognisers
// should be used instead.
#define kMinimumGestureLength 18
#define kMaximumVariance 8

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	
	if ((self = [super initWithFrame:frame style:style])){
		[self setDelaysContentTouches:NO];
	}
	
	return self;
}

- (void)highlightTouchedRow {
		
	UITableViewCell * testCell = [self cellForRowAtIndexPath:[self indexPathForRowAtPoint:gestureStartPoint]];
	if ([testCell isKindOfClass:[TISwipeableTableViewCell class]]){
		[(TISwipeableTableViewCell *)testCell setSelected:YES];
	}
}

- (BOOL)supportsSwipingForCellAtPoint:(CGPoint)point {
	
	NSIndexPath * indexPath = [self indexPathForRowAtPoint:point];
	UITableViewCell * testCell = [self cellForRowAtIndexPath:indexPath];
	
	BOOL supportsSwiping = NO;
	
	if ([testCell isKindOfClass:[TISwipeableTableViewCell class]]){
		supportsSwiping = ((TISwipeableTableViewCell *)testCell).shouldSupportSwiping;
	}
	
	// Thanks to Martin Destagnol (@mdestagnol) for this delegate method.
	if (supportsSwiping && [swipeDelegate respondsToSelector:@selector(tableView:shouldSwipeCellAtIndexPath:)]){
		supportsSwiping = [swipeDelegate tableView:self shouldSwipeCellAtIndexPath:indexPath];
	}
	
	return supportsSwiping;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self hideVisibleBackView:YES];
	
	UITouch * touch = [touches anyObject];
	gestureStartPoint = [touch locationInView:self];
	
	if ([self supportsSwipingForCellAtPoint:gestureStartPoint]){
		[self performSelector:@selector(highlightTouchedRow) withObject:nil afterDelay:0.06];	
	}
	else
	{
		[super touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([self supportsSwipingForCellAtPoint:gestureStartPoint]){
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highlightTouchedRow) object:nil];
		
		UITouch * touch = [touches anyObject];
		CGPoint currentPosition = [touch locationInView:self];
		
		CGFloat deltaX = fabsf(gestureStartPoint.x - currentPosition.x);
		CGFloat deltaY = fabsf(gestureStartPoint.y - currentPosition.y);
	
		if (deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance){
			
			[self setScrollEnabled:NO];
		
			TISwipeableTableViewCell * cell = (TISwipeableTableViewCell *)[self cellForRowAtIndexPath:[self indexPathForRowAtPoint:gestureStartPoint]];
			
			if (cell.backView.hidden && [touch.view isKindOfClass:[TISwipeableTableViewCellView class]]){
				
				[cell revealBackView];
				
				if ([swipeDelegate respondsToSelector:@selector(tableView:didSwipeCellAtIndexPath:)]){
					[swipeDelegate tableView:self didSwipeCellAtIndexPath:[self indexPathForRowAtPoint:gestureStartPoint]];
				}
				
				[self setIndexOfVisibleBackView:[self indexPathForCell:cell]];
			}
			
			[self setScrollEnabled:YES];
		}
	}
	else
	{
		[super touchesMoved:touches withEvent:event];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch * touch = [touches anyObject];
	
	if ([self supportsSwipingForCellAtPoint:gestureStartPoint]){
		
		TISwipeableTableViewCell * cell = (TISwipeableTableViewCell *)[self cellForRowAtIndexPath:[self indexPathForRowAtPoint:gestureStartPoint]];
	
		if ([touch.view isKindOfClass:[TISwipeableTableViewCellView class]] && cell.isSelected 
			&& !cell.contentViewMoving && [self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
			[self.delegate tableView:self didSelectRowAtIndexPath:[self indexPathForCell:cell]];
		}
		
		[self touchesCancelled:touches withEvent:event];
	}
	else
	{
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([self supportsSwipingForCellAtPoint:gestureStartPoint]){
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highlightTouchedRow) object:nil];
		[(TISwipeableTableViewCell *)[self cellForRowAtIndexPath:[self indexPathForRowAtPoint:gestureStartPoint]] setSelected:NO];
		
	}
	else
	{
		[super touchesCancelled:touches withEvent:event];
	}
}

- (void)hideVisibleBackView:(BOOL)animated {
	
	if (indexOfVisibleBackView){
		
		if (animated){
			[(TISwipeableTableViewCell *)[self cellForRowAtIndexPath:indexOfVisibleBackView] hideBackView];
		}
		else
		{
			[(TISwipeableTableViewCell *)[self cellForRowAtIndexPath:indexOfVisibleBackView] resetViews];
		}
		
		[self setIndexOfVisibleBackView:nil];
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TISwipeableTableView %p 'Handling swiping like a boss since 1861'>", self];
}
				 
- (void)dealloc {
	
	[self setDelegate:nil];
	[indexOfVisibleBackView release];
	[super dealloc];
}

@end
