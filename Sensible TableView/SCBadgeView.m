/*
 *  SCBadgeView.m
 *  Sensible TableView
 *
 *
 *	THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY UNITED STATES 
 *	INTELLECTUAL PROPERTY LAW AND INTERNATIONAL TREATIES. UNAUTHORIZED REPRODUCTION OR 
 *	DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES. YOU SHALL NOT DEVELOP NOR
 *	MAKE AVAILABLE ANY WORK THAT COMPETES WITH A SENSIBLE COCOA PRODUCT DERIVED FROM THIS 
 *	SOURCE CODE. THIS SOURCE CODE MAY NOT BE RESOLD OR REDISTRIBUTED ON A STAND ALONE BASIS.
 *
 *	USAGE OF THIS SOURCE CODE IS BOUND BY THE LICENSE AGREEMENT PROVIDED WITH THE 
 *	DOWNLOADED PRODUCT.
 *
 *  Copyright 2010 Sensible Cocoa. All rights reserved.
 *
 *
 *	This notice may not be removed from this file.
 *
 */

#import "SCBadgeView.h"


@implementation SCBadgeView

@synthesize text;
@synthesize font;
@synthesize color;

- (id)initWithFrame:(CGRect)aRect
{
	if( (self = [super initWithFrame:aRect]) )
	{
		text = nil;
		font = [[UIFont boldSystemFontOfSize: 16] retain];
		color = [[UIColor colorWithRed:140.0f/255 green:153.0f/255 blue:180.0f/255 alpha:1] retain];
		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void)dealloc
{
	[text release];
	[font release];
	[color release];
	
	[super dealloc];
}

// overrides superclass
- (void)drawRect:(CGRect)rect
{
	if(!self.text)
		return;
	
	UIColor *badgeColor = self.color;
	UIView *spview = self.superview;
	while (spview)
	{
		if([spview isKindOfClass:[UITableViewCell class]])
		{
			UITableViewCell *ownerCell = (UITableViewCell *)spview;
			
			if(ownerCell.highlighted || ownerCell.selected)
				badgeColor = [UIColor whiteColor];
			
			break;
		}
		
		spview = spview.superview;
	}
	
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, [badgeColor CGColor]);
	CGContextBeginPath(context);
	CGFloat radius = self.bounds.size.height / 2.0;
	CGContextAddArc(context, radius, radius, radius, M_PI/2 , 3*M_PI/2, NO);
	CGContextAddArc(context, self.bounds.size.width - radius, radius, radius, 3*M_PI/2, M_PI/2, NO);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	CGContextSetBlendMode(context, kCGBlendModeClear);
	
	CGSize textSize = [self.text sizeWithFont:self.font];
	CGRect textBounds = CGRectMake(round((self.bounds.size.width-textSize.width)/2), 
								   round((self.bounds.size.height-textSize.height)/2), 
								   textSize.width, textSize.height);
	[self.text drawInRect:textBounds withFont:self.font];
}

- (void)setColor:(UIColor *)_color
{
	[color release];
	color = [_color copy];
	
	[self setNeedsDisplay];
}

- (void)setText:(NSString *)_text
{
	[text release];
	text = [_text copy];
	
	[self setNeedsDisplay];
}

- (void)setFont:(UIFont *)_font
{
	[font release];
	font = [_font retain];
	
	[self setNeedsDisplay];
}

@end
