//
//  TimerHeaderView.m
//  HiBye
//
//  Created by shani hajbi on 1/12/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import "TimerHeaderView.h"

#import "Timer.h"
@implementation TimerHeaderView
@synthesize lbl;
@synthesize formattedTimer;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		UIColor *clearColor = [UIColor clearColor];
		self.backgroundColor = clearColor;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		// set the label view to have a clear background and a 20 point font
		label.backgroundColor = clearColor;
		label.font = [UIFont fontWithName:@"Futura" size:14];
		label.textColor = [UIColor darkGrayColor];
		self.lbl = label;
		[self addSubview:lbl];
		[label release];
		
		//Timer *timer = [[Timer alloc] initWithFrame:CGRectMake(120, 3, 40, 20)];
		//[self addSubview:timer];
    }
    return self;
}



- (void)layoutSubviews {
	[super layoutSubviews];
	

	CGRect contentRect = self.bounds;
	// position the elment name in the content rect
	CGRect labelRect = contentRect;
	labelRect.origin.x = labelRect.origin.x+20;
	labelRect.origin.y = labelRect.origin.y;
	lbl.frame = labelRect;	
}



- (void)setTime:(NSNumber *)aTime {
	if (!formater) {
		formater = [[NSNumberFormatter alloc] init];
		[formater setRoundingMode:NSNumberFormatterRoundFloor];
	}
	if([aTime intValue]>1){
		[formater setPositiveFormat:@"0 Days"];
	}else {
		[formater setPositiveFormat:@"0 Day"];
	}
	
	
    lbl.text =[formater stringFromNumber:aTime];
	[lbl setNeedsDisplay];
	

}



- (void)dealloc {
    [super dealloc];
	[lbl release];
	[formater release];
}


@end

