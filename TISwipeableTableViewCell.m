//
//  TISwipeableTableViewCell.m
//  SwipeableExample
//
//  Created by Marcel Müller on 08.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TISwipeableTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TISwipeableTableViewCellView
- (void)drawRect:(CGRect)rect {
	
	if (!self.hidden){
		[(TISwipeableTableViewCell *)[self superview] drawContentView:rect];
	}
	else
	{
		[super drawRect:rect];
	}
}
@end

@implementation TISwipeableTableViewCellBackView
- (void)drawRect:(CGRect)rect {
	
	if (!self.hidden){
		[(TISwipeableTableViewCell *)[self superview] drawBackView:rect];
	}
	else
	{
		[super drawRect:rect];
	}
}

@end

@interface TISwipeableTableViewCell (Private)
- (CAAnimationGroup *)bounceAnimationWithHideDuration:(CGFloat)hideDuration initialXOrigin:(CGFloat)originalX;
@end

@implementation TISwipeableTableViewCell
@synthesize backView;
@synthesize contentViewMoving;
@synthesize selected;
@synthesize shouldSupportSwiping;
@synthesize shouldBounce;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		contentView = [[TISwipeableTableViewCellView alloc] initWithFrame:CGRectZero];
		[contentView setClipsToBounds:YES];
		[contentView setOpaque:YES];
		[contentView setBackgroundColor:[UIColor clearColor]];
		
		backView = [[TISwipeableTableViewCellBackView alloc] initWithFrame:CGRectZero];
		[backView setOpaque:YES];
		[backView setClipsToBounds:YES];
		[backView setHidden:YES];
		[backView setBackgroundColor:[UIColor clearColor]];
		
		[self addSubview:backView];
		[self addSubview:contentView];
		
		[contentView release];
		[backView release];
		
		[self setContentViewMoving:NO];
		[self setSelected:NO];
		[self setShouldSupportSwiping:YES];
		[self setShouldBounce:YES];
		[self hideBackView];
    }
	
    return self;
}

- (void)prepareForReuse {
	
	[self resetViews];
	[super prepareForReuse];
}

- (void)setFrame:(CGRect)aFrame {
	
	[super setFrame:aFrame];
	
	CGRect bound = [self bounds];
	bound.size.height -= 1;
	[backView setFrame:bound];	
	[contentView setFrame:bound];
}

- (void)setNeedsDisplay {
	
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
	[backView setNeedsDisplay];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
	// Having an accessory buggers swiping right up, so we override.
	// It's easier just to draw the accessory yourself.
}

- (void)setAccessoryView:(UIView *)accessoryView {
	// Same as above.
}

- (void)setSelected:(BOOL)flag {
	
	selected = flag;
	[self setNeedsDisplay];
}

// Implement the following in a subclass
- (void)drawContentView:(CGRect)rect {
	
}

- (void)drawBackView:(CGRect)rect {
	
}

// Optional implementation
- (void)backViewWillAppear {
	
}

- (void)backViewDidAppear {
	
}

- (void)backViewWillDisappear {
	
}

- (void)backViewDidDisappear {
	
}

//===============================//

- (void)revealBackView {
	
	if (!contentViewMoving && backView.hidden){
		
		[self setContentViewMoving:YES];
		
		[backView.layer setHidden:NO];
		[backView setNeedsDisplay];
		
		[contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
		[contentView.layer setPosition:CGPointMake(contentView.frame.size.width, contentView.layer.position.y)];
		
		CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation setRemovedOnCompletion:NO];
		[animation setDelegate:self];
		[animation setDuration:0.14];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[contentView.layer addAnimation:animation forKey:@"reveal"];
		
		[self backViewWillAppear];
	}
}

- (void)hideBackView {
	
	if (!contentViewMoving && !backView.hidden){
		
		[self setContentViewMoving:YES];
		
		CGFloat hideDuration = 0.09;
		
		[backView.layer setOpacity:0.0];
		CABasicAnimation * hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[hideAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
		[hideAnimation setToValue:[NSNumber numberWithFloat:0.0]];
		[hideAnimation setDuration:hideDuration];
		[hideAnimation setRemovedOnCompletion:NO];
		[hideAnimation setDelegate:self];
		[backView.layer addAnimation:hideAnimation forKey:@"hide"];
		
		CGFloat originalX = contentView.layer.position.x;
		[contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
		[contentView.layer setPosition:CGPointMake(0, contentView.layer.position.y)];
		[contentView.layer addAnimation:[self bounceAnimationWithHideDuration:hideDuration initialXOrigin:originalX] 
								 forKey:@"bounce"];
		
		
		[self backViewWillDisappear];
	}
}

- (void)resetViews {
	
	[contentView.layer removeAllAnimations];
	[backView.layer removeAllAnimations];
	
	[self setContentViewMoving:NO];
	
	[contentView.layer setAnchorPoint:CGPointMake(0, 0.5)];
	[contentView.layer setPosition:CGPointMake(0, contentView.layer.position.y)];
	
	[backView.layer setHidden:YES];
	[backView.layer setOpacity:1.0];
	
	[self backViewDidDisappear];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	
	if (anim == [contentView.layer animationForKey:@"reveal"]){
		[contentView.layer removeAnimationForKey:@"reveal"];
		
		[self backViewDidAppear];
		[self setSelected:NO];
		[self setContentViewMoving:NO];
	}
	
	if (anim == [contentView.layer animationForKey:@"bounce"]){
		[contentView.layer removeAnimationForKey:@"bounce"];
		[self resetViews];
	}
	
	if (anim == [backView.layer animationForKey:@"hide"]){
		[backView.layer removeAnimationForKey:@"hide"];
	}
}

- (CAAnimationGroup *)bounceAnimationWithHideDuration:(CGFloat)hideDuration initialXOrigin:(CGFloat)originalX {
	
	CABasicAnimation * animation0 = [CABasicAnimation animationWithKeyPath:@"position.x"];
	[animation0 setFromValue:[NSNumber numberWithFloat:originalX]];
	[animation0 setToValue:[NSNumber numberWithFloat:0]];
	[animation0 setDuration:hideDuration];
	[animation0 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[animation0 setBeginTime:0];
	
	CAAnimationGroup * hideAnimations = [CAAnimationGroup animation];
	[hideAnimations setAnimations:[NSArray arrayWithObject:animation0]];
	
	CGFloat fullDuration = hideDuration;
	
	if (shouldBounce){
		
		CGFloat bounceDuration = 0.04;
		
		CABasicAnimation * animation1 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation1 setFromValue:[NSNumber numberWithFloat:0]];
		[animation1 setToValue:[NSNumber numberWithFloat:-20]];
		[animation1 setDuration:bounceDuration];
		[animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation1 setBeginTime:hideDuration];
		
		CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation2 setFromValue:[NSNumber numberWithFloat:-20]];
		[animation2 setToValue:[NSNumber numberWithFloat:15]];
		[animation2 setDuration:bounceDuration];
		[animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation2 setBeginTime:(hideDuration + bounceDuration)];
		
		CABasicAnimation * animation3 = [CABasicAnimation animationWithKeyPath:@"position.x"];
		[animation3 setFromValue:[NSNumber numberWithFloat:15]];
		[animation3 setToValue:[NSNumber numberWithFloat:0]];
		[animation3 setDuration:bounceDuration];
		[animation3 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
		[animation3 setBeginTime:(hideDuration + (bounceDuration * 2))];
		
		[hideAnimations setAnimations:[NSArray arrayWithObjects:animation0, animation1, animation2, animation3, nil]];
		
		fullDuration = hideDuration + (bounceDuration * 3);
	}
	
	[hideAnimations setDuration:fullDuration];
	[hideAnimations setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[hideAnimations setDelegate:self];
	[hideAnimations setRemovedOnCompletion:NO];
	
	return hideAnimations;
}

- (NSString *)description {
	
	NSString * extraInfo = backView.hidden ? @"ContentView visible": @"BackView visible";
	
	return [NSString stringWithFormat:@"<TISwipeableTableViewCell %p '%@'>", self, extraInfo];
}

@end
