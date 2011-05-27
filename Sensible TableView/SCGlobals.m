/*
 *  SCGlobals.m
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

#import "SCGlobals.h"


@implementation SCHelper

+ (double)systemVersion
{
	return [[[UIDevice currentDevice] systemVersion] doubleValue];
}

+ (BOOL)is_iPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

@end




@implementation SCTransparentToolbar

- (id) init
{
	if( (self = [super init]) )
	{
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.translucent = YES;
	}
	
	return self;
}

- (id) initWithFrame:(CGRect) frame
{
	if( (self = [super initWithFrame:frame]) )
	{
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.translucent = YES;
	}
	
	return self;
}

// overrides super class
- (void)drawRect:(CGRect)rect 
{
    // prevent an drawing here (do nothing)
}

@end

