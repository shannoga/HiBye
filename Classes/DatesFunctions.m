//
//  DatesFunctions.m
//  HiBye
//
//  Created by shani hajbi on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatesFunctions.h"

#define D_DAY	86400
#define D_WEEK	604800
#define D_MONTH 2419200

@implementation DatesFunctions



+ (NSDate *) dateWithIntervalFromNow: (NSUInteger) days factor:(NSUInteger)factor {
	NSTimeInterval aTimeInterval = [[NSDate date]
									timeIntervalSinceReferenceDate] + factor * days;
	NSDate *newDate = [NSDate
					   dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;	
	[newDate release];
}

+ (NSNumber*) daysBeforeDate:CurrntDelitionDate {
	NSTimeInterval ti = [CurrntDelitionDate timeIntervalSinceDate:[NSDate date]];
	NSInteger i =  (NSInteger) (ti / D_DAY);
	NSNumber *n = [NSNumber numberWithInt:i];
	return n;
}

+ (NSDate *) returnDateFromPicker:(NSInteger)date numberFromPicker:(NSInteger)number {
    NSDate *dateToSet;
	NSArray *factor = [NSArray arrayWithObjects:
						[NSNumber numberWithInteger:D_DAY],
						[NSNumber numberWithInteger:D_WEEK],
						[NSNumber numberWithInteger:D_MONTH],nil];

	dateToSet= [self dateWithIntervalFromNow:number factor:[[factor objectAtIndex:date]intValue]];
    
    return dateToSet;
}

+ (NSMutableDictionary*)returnPersonStatusDictionary:(NSInteger)personID {
 
    NSMutableDictionary *personDateInfo = [NSMutableDictionary dictionary];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
    
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, personID);
	
	ABMultiValueRef multi = ABRecordCopyValue(ref, kABPersonDateProperty);
	
	ABMutableMultiValueRef copyOfmulti = ABMultiValueCreateMutableCopy(multi);
	
	for (int i=0; i<ABMultiValueGetCount(copyOfmulti); i++) {
		
		NSString *dateLabel = (NSString*) ABMultiValueCopyLabelAtIndex(multi, i);
		
		
        if ([dateLabel isEqualToString:@"Delete/Alert"]||[dateLabel isEqualToString:@"Delete/Archive"]||[dateLabel isEqualToString:@"Delete/NoArchive"]){
         
            NSDate	*deletionDate = (NSDate*)ABMultiValueCopyValueAtIndex(multi, i);
			NSInteger deletionPolicy = 0;
			 if ([dateLabel isEqualToString:@"Delete/Archive"]) {
				deletionPolicy = 1;
			}else if ([dateLabel isEqualToString:@"Delete/NoArchive"]) {
				deletionPolicy = 2;
			}
			
            NSNumber *state = [NSNumber numberWithInteger:[self returnDateState:deletionDate deletionPolicy:deletionPolicy]];
			
			[personDateInfo setValue:[NSNumber numberWithBool:YES] forKey:@"hasDeleteDate"];
			[personDateInfo setValue:deletionDate forKey:@"deletionDate"];
			[personDateInfo setValue:[NSNumber numberWithInteger:deletionPolicy] forKey:@"delitionPolicy"];
			[personDateInfo setValue:state forKey:@"state"];
			[personDateInfo setValue:[self daysBeforeDate:deletionDate] forKey:@"daysLeft"];
			
			[deletionDate release];
        }else{
			
			[personDateInfo setValue:[NSNumber numberWithBool:NO] forKey:@"hasDeleteDate"];
		
            
        }
		[dateLabel release];
		
	}



	CFRelease(multi);
	CFRelease(copyOfmulti);
	CFRelease(addressBook);
    
	return personDateInfo;
}

+(NSInteger)returnDateState:(NSDate*)deletionDate deletionPolicy:(NSInteger)deletionPolicy{
	NSInteger state =0;
	if ([self daysBeforeDate:deletionDate] < 0 ) {
		
		switch (deletionPolicy) {
			case 1:
				state=-1;
				break;
			case 2:
				 state=-2;
				break;
			default:
				state=0; 
				break;
		}
     
        
	}else if ([[self daysBeforeDate:deletionDate] intValue] < 1 ) {
		state=1;
		
	}else if ([[self daysBeforeDate:deletionDate] intValue] < 7 ) {
		state=2;
		
	}else if ([[self daysBeforeDate:deletionDate] intValue]  > 7 ) {
		state=3;
		
	}
	return state;
}

+(NSInteger)checkDateLable:(NSInteger)personID {
	NSString *dateLabel;
	NSInteger checkResult = 0;
    
	ABAddressBookRef addressBook = ABAddressBookCreate();
    
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, personID);
	//	CFErrorRef error;
	ABMultiValueRef multi = ABRecordCopyValue(ref, kABPersonDateProperty);
	ABMutableMultiValueRef copyOfmulti = ABMultiValueCreateMutableCopy(multi);
	
	for (int i=0; i<ABMultiValueGetCount(copyOfmulti); i++) {
		
		dateLabel = (NSString*) ABMultiValueCopyLabelAtIndex(multi, i);
		
        if ([dateLabel isEqualToString:@"Delete/Alert"]){
            checkResult=1;
        }else if ([dateLabel isEqualToString:@"Delete/Archive"]){
            checkResult=2;
        }else if ([dateLabel isEqualToString:@"Delete/NoArchive"]){
            checkResult=3;
        }else{
            checkResult=0;
            
        }
        [dateLabel release];
	}
	
	CFRelease(multi);
	CFRelease(copyOfmulti);
	CFRelease(addressBook);
	
    
	return checkResult;
}


/*
 -(NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes
 {
 NSTimeInterval aTimeInterval = [[NSDate date]
 timeIntervalSinceReferenceDate] + 4 * dMinutes;
 NSDate *newDate = [NSDate
 dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
 return newDate;		
 }
 */

@end


