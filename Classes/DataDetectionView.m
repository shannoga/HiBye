//
//  DataDetectionView.m
//  HiBye
//
//  Created by shani hajbi on 1/30/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import "DataDetectionView.h"


@implementation DataDetectionView



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		
    }
    return self;
}

-(void)setDataDetection:(NSMutableArray*)arr{
	
    phoneAlpha =[[[arr objectAtIndex:0] objectForKey:@"alpha"] floatValue];
    mailAlpha =[[[arr objectAtIndex:1] objectForKey:@"alpha"] floatValue];
    urlAlpha =[[[arr objectAtIndex:2] objectForKey:@"alpha"] floatValue];
	noteAlpha =[[[arr objectAtIndex:3] objectForKey:@"alpha"] floatValue];
    phoneCount =[[arr objectAtIndex:0] objectForKey:@"count"];
    mailCount =[[arr objectAtIndex:1] objectForKey:@"count"];
    urlCount =[[arr objectAtIndex:2] objectForKey:@"count"];
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [[UIColor darkGrayColor] set];
    UIFont *font = [UIFont fontWithName:@"Futura" size:12];
    [[phoneCount stringValue] drawAtPoint:CGPointMake(20, 10) withFont:font];
    
    UIImage *item = [UIImage imageNamed:@"phone.png"];
	[item drawAtPoint:CGPointMake(40, 10) blendMode:kCGBlendModeOverlay alpha:phoneAlpha];
	
    
    [[mailCount stringValue] drawAtPoint:CGPointMake(80, 10) withFont:font];
    
	item = [UIImage imageNamed:@"mail.png"];
	[item drawAtPoint:CGPointMake(100, 10) blendMode:kCGBlendModeOverlay alpha:mailAlpha];
	
    
    [[urlCount stringValue] drawAtPoint:CGPointMake(140, 10) withFont:font];
    
	item = [UIImage imageNamed:@"mail.png"];
	[item drawAtPoint:CGPointMake(160, 10) blendMode:kCGBlendModeOverlay alpha:urlAlpha];
	
	item = [UIImage imageNamed:@"mail.png"];
	[item drawAtPoint:CGPointMake(200, 10) blendMode:kCGBlendModeOverlay alpha:noteAlpha];

}
- (void)dealloc {
    [super dealloc];
}


@end
