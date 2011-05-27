//
//  Person.h
//  HiBye
//
//  Created by shani hajbi on 1/5/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Address;
@class Mail;
@class Phone;
@class Url;

@interface Person :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSDate * ddate;
@property (nonatomic, retain) NSNumber * deletion_policy;
@property (nonatomic, retain) NSString * category_en;
@property (nonatomic, retain) NSString * compName;
@property (nonatomic, retain) NSSet* addresses;
@property (nonatomic, retain) NSSet* mails;
@property (nonatomic, retain) NSSet* phones;
@property (nonatomic, retain) NSSet* urls;

@end


@interface Person (CoreDataGeneratedAccessors)
- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet *)value;
- (void)removeAddresses:(NSSet *)value;

- (void)addMailsObject:(Mail *)value;
- (void)removeMailsObject:(Mail *)value;
- (void)addMails:(NSSet *)value;
- (void)removeMails:(NSSet *)value;

- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSSet *)value;
- (void)removePhones:(NSSet *)value;

- (void)addUrlsObject:(Url *)value;
- (void)removeUrlsObject:(Url *)value;
- (void)addUrls:(NSSet *)value;
- (void)removeUrls:(NSSet *)value;

@end

