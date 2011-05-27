//
//  Phone.h
//  HiBye
//
//  Created by shani hajbi on 1/5/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Person;

@interface Phone :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) Person * person;

@end



