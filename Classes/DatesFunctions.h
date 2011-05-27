//
//  DatesFunctions.h
//  HiBye
//
//  Created by shani hajbi on 7/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DatesFunctions : NSObject {

}

+ (NSDate *) dateWithIntervalFromNow: (NSUInteger) days factor:(NSUInteger)factor;
+(NSInteger)returnDateState:(NSDate*)deletionDate deletionPolicy:(NSInteger)deletionPolicy;
+ (NSMutableDictionary*)returnPersonStatusDictionary:(NSInteger)personID;
+ (NSDate *) returnDateFromPicker:(NSInteger)date numberFromPicker:(NSInteger)number;
+ (NSNumber*)daysBeforeDate: (NSDate *) aDate;
+ (NSInteger)checkDateLable:(NSInteger)personID;

@end
