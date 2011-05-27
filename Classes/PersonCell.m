//
//  PersonCell.m
//  SwipeableExample
//
//  Created by Tom Irving on 16/06/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "PersonCell.h"
#import "Person.h"
#import "GlobalFunctions.h"
#import "SectionHeaderView.h"
#import <EventKit/EventKit.h>

@implementation PersonCell
@synthesize person;
@synthesize backViewUIHolder;
@synthesize delegate;
BOOL recordCalls=YES;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		person=nil;
		backViewUIHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
		backViewUIHolder.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin);
		backViewUIHolder.autoresizesSubviews = YES;
		recipientsArray = [[NSMutableArray alloc] init];
               

    }
    return self;
}


- (void)setPerson:(Person *)aPerson {
	if (aPerson != person) {
		[person release];
		[aPerson retain];
		person = aPerson;
	}
    
	[self setNeedsDisplay];
}


- (void)backViewWillAppear {
	
	CGRect rect ;
	UIImage *btnImage;
	
		rect = CGRectMake(20, 5, 85, 33); 
		UIButton *callbutton = [UIButton buttonWithType:UIButtonTypeCustom];
		btnImage = [UIImage imageNamed:@"phone.png"];
		[callbutton setImage:btnImage forState:UIControlStateNormal];
		callbutton.frame = rect;
		[callbutton addTarget:self action:@selector(call) forControlEvents:(UIControlEventTouchUpInside)];
		callbutton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin);

		[backViewUIHolder addSubview:callbutton];
	
	
	
		rect = CGRectMake(110, 5, 85, 33); 
		UIButton *massegebutton = [UIButton buttonWithType:UIButtonTypeCustom];
		btnImage = [UIImage imageNamed:@"mail.png"];
		[massegebutton setImage:btnImage forState:UIControlStateNormal];
		massegebutton.frame = rect;
		[massegebutton addTarget:self action:@selector(sendMassege) forControlEvents:(UIControlEventTouchUpInside)];
	massegebutton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin);

		[backViewUIHolder addSubview:massegebutton];
		
	
	
	
	rect = CGRectMake(220, 5, 85, 33); 
	UIButton *mapbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	btnImage = [UIImage imageNamed:@"map.png"];
	[mapbutton setImage:btnImage forState:UIControlStateNormal];
	mapbutton.frame = rect;
	[mapbutton addTarget:self action:@selector(visitSite) forControlEvents:(UIControlEventTouchUpInside)];
	mapbutton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin);

	[backViewUIHolder addSubview:mapbutton];
	
	backViewUIHolder.alpha=0;
	[self addSubview:backViewUIHolder];
	
	[UIView animateWithDuration:.5
					 animations:^{
						 backViewUIHolder.alpha=1;
					 }];
	// Add UI elements to the backView here.
}

- (void)backViewDidDisappear {
	// Remove any subviews from the backView.
	[backViewUIHolder removeFromSuperview];
}

- (void)drawContentView:(CGRect)rect {
	
	
	if (self.selected) {
		[[UIImage imageNamed:@"selectiongradient.png"] drawInRect:rect];
	}
	
	if(person.state == [NSNumber numberWithInteger:0]){
		[[UIColor redColor] set];
    }else if(person.state != [NSNumber numberWithInteger:0]){
        [[UIColor darkGrayColor] set];
    }
	
	UIFont * textFont = [UIFont fontWithName:@"Futura" size:18];
	
	CGSize textSize = [person.compName sizeWithFont:textFont constrainedToSize:rect.size];
	[person.compName drawInRect:CGRectMake(55, 
								4,
								textSize.width, textSize.height)
			withFont:textFont];
	
	[[UIColor orangeColor] set];
	
	textFont = [UIFont fontWithName:@"Futura" size:13];
	textSize = [person.category sizeWithFont:textFont constrainedToSize:rect.size];
	[person.category drawInRect:CGRectMake(55, 25,
										   textSize.width, textSize.height)
					   withFont:textFont];
	
	NSString *img = [NSString stringWithFormat:@"%@.png", person.category_en];
    UIImage *backgroundImage = [UIImage imageNamed:img];
    
	CGRect personCategoryRectangle = CGRectMake((55-[backgroundImage size].width)/2 ,(44-[backgroundImage size].height)/2, [backgroundImage size].width, [backgroundImage size].height);
	[backgroundImage drawInRect:personCategoryRectangle];
    
	
	
	
	
}

- (void)drawBackView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIImage imageNamed:@"meshpattern.png"] drawAsPatternInRect:rect];
	[self drawShadowsWithHeight:10 opacity:0.3 InRect:rect forContext:context];
}

- (void)drawShadowsWithHeight:(CGFloat)shadowHeight opacity:(CGFloat)opacity InRect:(CGRect)rect forContext:(CGContextRef)context {
	
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	
	CGFloat topComponents[8] = {0, 0, 0, opacity, 0, 0, 0, 0};
	CGGradientRef topGradient = CGGradientCreateWithColorComponents(space, topComponents, nil, 2);
	CGPoint finishTop = CGPointMake(rect.origin.x, rect.origin.y + shadowHeight);
	CGContextDrawLinearGradient(context, topGradient, rect.origin, finishTop, kCGGradientDrawsAfterEndLocation);
	
	CGFloat bottomComponents[8] = {0, 0, 0, 0, 0, 0, 0, opacity};
	CGGradientRef bottomGradient = CGGradientCreateWithColorComponents(space, bottomComponents, nil, 2);
	CGPoint startBottom = CGPointMake(rect.origin.x, rect.size.height - shadowHeight);
	CGPoint finishBottom = CGPointMake(rect.origin.x, rect.size.height);
	CGContextDrawLinearGradient(context, bottomGradient, startBottom, finishBottom, kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(topGradient);
	CGGradientRelease(bottomGradient);
}

- (void)dealloc {
	[backViewUIHolder release];
	[person release];
    [super dealloc];
}



#pragma mark -
#pragma mark call/sendMassage/map



-(NSMutableArray*)getPhoneNumbers:(BOOL)withEmailAddresses{

	NSMutableArray *arr = [[NSMutableArray alloc] init];
	NSDictionary *dic;
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook,[person.ID intValue]);
	
	if ([GlobalFunctions canSendSMS]||[GlobalFunctions canCall]) {
		CFStringRef phoneNumber,phoneLabel,phoneNumberLabel;
		ABMutableMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
		for (CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
			phoneNumber  =ABMultiValueCopyValueAtIndex(multiPhones, i);
			phoneLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);
			phoneNumberLabel =ABAddressBookCopyLocalizedLabel(phoneLabel);
			dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"tel:%@",(NSString*)phoneNumber],[NSString stringWithFormat:@"%@: %@",phoneNumberLabel,(NSString*)phoneNumber],[NSNumber numberWithBool:YES],nil]
											forKeys:[NSArray arrayWithObjects:@"recipient",@"display",@"isPhone",nil]];
			[arr addObject:dic];
			CFRelease(phoneLabel);
			CFRelease(phoneNumber);
			CFRelease(phoneNumberLabel);
		}
		
		CFRelease(multiPhones);	
	}
	
	
	if(withEmailAddresses){
		
		CFStringRef mailAddress,locLabel,mailLabel;
		ABMutableMultiValueRef multiEmail = ABRecordCopyValue(ref, kABPersonEmailProperty);
		
		for (CFIndex i = 0; i < ABMultiValueGetCount(multiEmail); i++) {
			mailAddress = ABMultiValueCopyValueAtIndex(multiEmail, i);
			locLabel = ABMultiValueCopyLabelAtIndex(multiEmail, i);
			mailLabel = ABAddressBookCopyLocalizedLabel(locLabel);
			dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:(NSString*)mailAddress,[NSString stringWithFormat:@"%@: %@",(NSString*)mailLabel,(NSString*)mailAddress],[NSNumber numberWithBool:NO],nil]
											forKeys:[NSArray arrayWithObjects:@"recipient",@"display",@"isPhone",nil]];
			[arr addObject:dic];
			
			CFRelease(locLabel); 
			CFRelease(mailAddress); 
			CFRelease(mailLabel); 
		}
		CFRelease(multiEmail);
		
		
	}
	CFRelease(addressBook);
	NSMutableArray *returnedArr = [NSMutableArray arrayWithArray:arr];
	[arr release];
	
	return returnedArr;
	
}

-(NSMutableArray*)getURLs{
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	NSDictionary *dic;
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook,[person.ID intValue]);
	
	
	
	CFStringRef urlAddress,locLabel,urlLabel;
	ABMutableMultiValueRef multiUrl = ABRecordCopyValue(ref, kABPersonURLProperty);
	
	for (CFIndex i = 0; i < ABMultiValueGetCount(multiUrl); i++) {
		urlAddress = ABMultiValueCopyValueAtIndex(multiUrl, i);
		locLabel = ABMultiValueCopyLabelAtIndex(multiUrl, i);
		urlLabel = ABAddressBookCopyLocalizedLabel(locLabel);
		dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:(NSString*)urlAddress,[NSString stringWithFormat:@"%@: %@",(NSString*)urlLabel,(NSString*)urlAddress],nil]
										forKeys:[NSArray arrayWithObjects:@"recipient",@"display",nil]];
		[arr addObject:dic];
		
		CFRelease(locLabel); 
		CFRelease(urlAddress); 
		CFRelease(urlLabel); 
	}
	CFRelease(multiUrl);	
	CFRelease(addressBook);
	NSMutableArray *returnedArr = [NSMutableArray arrayWithArray:arr];
	[arr release];
	
	return returnedArr;
}


-(void)createEvent {
    
	// Get the event store object
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	
	// Create a new event
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    
	// Create NSDates to hold the start and end date
	NSDate *startDate = [[NSDate alloc] init];
	NSDate *endDate  = [[NSDate alloc] init];
	
	// Set properties of the new event object
	event.title     = [NSString stringWithFormat:@"out call to : %@",person.compName];
	event.notes = @"created automaticly by Hi-Bye";
    event.startDate = startDate;
    event.endDate   = endDate;
    event.accessibilityLabel = [NSString stringWithFormat:@"out call to : %@",person.compName];
	event.allDay    = NO;
	
	// set event's calendar to the default calendar
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
	
	// Create an NSError pointer
    NSError *err;
	
	// Save the event
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err]; 
    
    
	// Test for errors
	if (err == noErr) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Event Created" 
							  message:@"How about that?" 
							  delegate:nil
							  cancelButtonTitle:@"Okay" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	// Release objects
	[startDate release];
	[endDate release];
	[eventStore release];
    
	
}
-(void)call{
    
	UIActionSheet *actionSheet;
	[recipientsArray addObjectsFromArray:[self getPhoneNumbers:NO]];
	
	if ([recipientsArray count]>1) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
										 cancelButtonTitle:@"Cancel" 
									destructiveButtonTitle:nil 
										 otherButtonTitles:nil];
		actionSheet.tag =4;
		for (int i=0;i<[recipientsArray count];i++) {
			[actionSheet addButtonWithTitle:[[recipientsArray objectAtIndex:i]objectForKey:@"display"]];
		}
		
		[actionSheet showFromRect:CGRectMake(0, 0, 320, 320) inView:self.superview animated:YES];
		[actionSheet release];
	}else if ([recipientsArray count]==1) {
        
        if(recordCalls){
            [self createEvent];
        }
		NSURL *url = [NSURL URLWithString:[[recipientsArray objectAtIndex:0]objectForKey:@"recipient"]];
		NSLog(@"url = %@",url);
		[[UIApplication sharedApplication] openURL:url];
		[recipientsArray removeAllObjects];
	}else {
		[GlobalFunctions alert:@"Contact has no phone numbers"];
	}
}


-(void)sendMassege{
	
	[recipientsArray addObjectsFromArray:[self getPhoneNumbers:YES]];
	
	if ([recipientsArray count]>1) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		for (int i=0;i<[recipientsArray count];i++) {
			[actionSheet addButtonWithTitle:[[recipientsArray objectAtIndex:i]objectForKey:@"display"]];
		}
		actionSheet.tag =5;
		[actionSheet showFromRect:CGRectMake(0, 0, 320, 320) inView:self.superview animated:YES];		
        [actionSheet release];
        
	}else if ([recipientsArray count]==1)  {
		NSString *recipient = [[recipientsArray objectAtIndex:0]objectForKey:@"recipient"];
		
		if ([[[recipientsArray objectAtIndex:0]objectForKey:@"isPhone"] boolValue]) {
			[delegate personCell:self displaySMSComposerSheet:recipient];
		}else {
			[delegate personCell:self displayMailComposerSheet:recipient];
		}
		
		[recipientsArray removeAllObjects];
	}else {
		[GlobalFunctions alert:@"Contact has no phone numbers/Email addresses"];
	}
	
}

-(void)visitSite{
	UIActionSheet *actionSheet;
	[recipientsArray addObjectsFromArray:[self getURLs]];
	
	if ([recipientsArray count]>1) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self 
										 cancelButtonTitle:@"Cancel" 
									destructiveButtonTitle:nil 
										 otherButtonTitles:nil];
		actionSheet.tag =6;
		for (int i=0;i<[recipientsArray count];i++) {
			[actionSheet addButtonWithTitle:[[recipientsArray objectAtIndex:i]objectForKey:@"display"]];
		}
		[actionSheet showFromRect:CGRectMake(0, 0, 320, 320) inView:self.superview animated:YES];
		[actionSheet release];
	}else if ([recipientsArray count]==1) {
		NSURL *url = [NSURL URLWithString:[[recipientsArray objectAtIndex:0]objectForKey:@"recipient"]];
		[[UIApplication sharedApplication] openURL:url];
		[recipientsArray removeAllObjects];
	}else {
		[GlobalFunctions alert:@"Contact has no web adresses"];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSInteger index = buttonIndex-1;
	
	switch (actionSheet.tag) {
			
		case 6:
			if(buttonIndex!=0){ 
				NSURL *url = [NSURL URLWithString:[[recipientsArray objectAtIndex:index]objectForKey:@"recipient"]];
				NSLog(@"url = %@",url);
				[[UIApplication sharedApplication] openURL:url];
			}
			break;
		case 4:
			if(buttonIndex!=0){ 
                
				NSURL *url = [NSURL URLWithString:[[recipientsArray objectAtIndex:index]objectForKey:@"recipient"]];
				NSLog(@"url = %@",url);
				[[UIApplication sharedApplication] openURL:url];
			}
			break;
		case 5:
			if(buttonIndex!=0){ 
				index = buttonIndex-1;
				NSString *recipient = [[recipientsArray objectAtIndex:index]objectForKey:@"recipient"];
				if ([[[recipientsArray objectAtIndex:index]objectForKey:@"isPhone"] boolValue]) {
					[delegate personCell:self displaySMSComposerSheet:recipient];
				}else {
					[delegate personCell:self displayMailComposerSheet:recipient];
				}
			}
			break;
			
            
			
			
	}
	[recipientsArray removeAllObjects];
	
    
}


@end
