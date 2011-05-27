//
//  ArchivedPersonView.m
//  HiBye
//
//  Created by shani hajbi on 1/9/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import "ArchivedPersonView.h"
#import "Mail.h"
#import "Phone.h"
#import "Url.h"
#import "Address.h"

@implementation ArchivedPersonView
@synthesize person;

#define inSectionSpace 20
#define sectionSpace 25
#define beforeTitleSpace 10
#define lx 20
#define cx 100
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
		self.showsVerticalScrollIndicator =  YES;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	UIFont *font =  [UIFont fontWithName:@"Arial" size:50];
	CGPoint point = CGPointMake(0,0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.7);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetTextDrawingMode(context, kCGTextFillStroke);
	CGContextSaveGState(context);
	[@"Label" drawAtPoint:point withFont:font];
	
	CGContextRestoreGState(context);
	
	
	UIFont *bfont = [UIFont boldSystemFontOfSize:18];
	UIFont *rbfont = [UIFont boldSystemFontOfSize:14];
	UIFont *rfont = [UIFont systemFontOfSize:14];
	//[[UIColor brownColor] set];
	NSInteger yPos = 40;
	//CGSize stringSize = [person.compName sizeWithFont:bfont];
	point = CGPointMake(20,yPos);
	[person.compName drawAtPoint:point withFont:bfont];
	yPos+=inSectionSpace;
	
	point = CGPointMake(20,yPos);
	[person.category drawAtPoint:point withFont:rfont];
	yPos+=sectionSpace;
	
	point = CGPointMake(20,yPos);
	[person.note drawAtPoint:point withFont:rfont];
	yPos+=inSectionSpace;
	
	
	yPos+=beforeTitleSpace;	
	point = CGPointMake(20,yPos);
	[NSLocalizedString(@"Phone numbers",@"") drawAtPoint:point withFont:bfont];
	yPos+=inSectionSpace;
	
	
	NSMutableArray *phones =[[NSMutableArray alloc] initWithArray:[person.phones allObjects]];
	while ([phones count]) {
		Phone *phone = (Phone*)[phones objectAtIndex:0];
		
		point = CGPointMake(lx,yPos);
		[(NSString*)phone.label drawAtPoint:point withFont:rbfont];
		point = CGPointMake(cx,yPos);
		[phone.number drawAtPoint:point withFont:rfont];
		
		[phones removeObjectAtIndex:0];
		yPos+=inSectionSpace;
	}
	[phones release];
	
	yPos+=beforeTitleSpace;	
	point = CGPointMake(20,yPos);
	[NSLocalizedString(@"Emails",@"") drawAtPoint:point withFont:bfont];
	yPos+=inSectionSpace;
	
	NSMutableArray *mails =[[NSMutableArray alloc] initWithArray:[person.mails allObjects]];
	
	while ([mails count]) {
		Mail *mail = (Mail*)[mails objectAtIndex:0];
		
		point = CGPointMake(lx,yPos);
		[(NSString*)mail.label drawAtPoint:point withFont:rbfont];
		point = CGPointMake(cx,yPos);
		[mail.mail drawAtPoint:point withFont:rfont];
		
		[mails removeObjectAtIndex:0];
		yPos+=inSectionSpace;
	}
	[mails release];
	yPos+=beforeTitleSpace;					
	point = CGPointMake(20,yPos);
	[NSLocalizedString(@"URL's",@"") drawAtPoint:point withFont:bfont];
	yPos+=inSectionSpace;
	
		NSMutableArray *urls =[[NSMutableArray alloc] initWithArray:[person.urls allObjects]];
	while ([urls count]) {
		Url *url = (Url*)[urls objectAtIndex:0];
		
		
		point = CGPointMake(lx,yPos);
		[(NSString*)url.label drawAtPoint:point withFont:rbfont];
		point = CGPointMake(cx,yPos);
		[url.url drawAtPoint:point withFont:rfont];
		
		[urls removeObjectAtIndex:0];
		yPos+=inSectionSpace;
	}
	
	[urls release];
	
		
	yPos+=beforeTitleSpace;	
	point = CGPointMake(20,yPos);
	[NSLocalizedString(@"Addresse's",@"") drawAtPoint:point withFont:bfont];
	yPos+=inSectionSpace;
	
	NSMutableArray *addresses =[[NSMutableArray alloc] initWithArray:[person.addresses allObjects]];
	
	while ([addresses count]) {
		Address *address = (Address*)[addresses objectAtIndex:0];
		point = CGPointMake(cx,yPos);
		[address.street drawAtPoint:point withFont:rfont];
		yPos+=inSectionSpace;
		
		point = CGPointMake(cx,yPos);
		[address.city drawAtPoint:point withFont:rfont];
		yPos+=inSectionSpace;
		
		point = CGPointMake(cx,yPos);
		[address.country drawAtPoint:point withFont:rfont];
		yPos+=inSectionSpace;
		
		point = CGPointMake(cx,yPos);
		[address.state drawAtPoint:point withFont:rfont];
		yPos+=inSectionSpace;
		
		point = CGPointMake(cx,yPos);
		[address.zip drawAtPoint:point withFont:rfont];
		yPos+=inSectionSpace;
		[addresses removeObjectAtIndex:0];
	}
	[addresses release];
	

	[self setContentSize:CGSizeMake(320, yPos)];
}


- (void)dealloc {
    [super dealloc];
}


@end
