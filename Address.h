//
//  Address.h
//  HiBye
//
//  Created by shani hajbi on 1/5/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Person;

@interface Address :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) Person * person;
@property (nonatomic, retain) NSString * label;

@end



