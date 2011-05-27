//
//  GlobalFunctions.h
//  HiBye
//
//  Created by shani hajbi on 9/11/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface GlobalFunctions : NSObject {

}

+(BOOL)isDeviceAniPad;

+(BOOL)checkContactLabel:(NSString*)dateLabel;

+(void)sendPersonToArchive:(Person*)personToArchive;



+ (void)alert:(NSString*)message;

+(void)deletePersonFromAB:(ABRecordID)recordId;

+(void)removePersonFromHiBye:(ABRecordID)recordId HiByeGroupId:(ABRecordID)hiByeGruopId;

+(ABRecordRef)getRefFromId:(ABRecordID)recordId;

+(NSInteger)getIDFromRef:(ABRecordRef)recordRef;

+(BOOL)CheckToSeeIfInHiBye:(ABRecordID)recordID;

+(void)addDummy:(NSUInteger)count GroupId:(NSInteger)groupId;

+(void)removeDummy:(NSUInteger)count;

+(NSInteger)getNumberOfDummis;

+ (NSString*)GetCompNameFromRef:(ABRecordRef)ref;
+ (BOOL)setCategoryImageToPerson:(NSString*)imageName Ref:(ABRecordRef)ref;

+(NSMutableDictionary*)setDefaultTimerSettingsToPerson:(ABRecordRef)ref;

+(CFStringRef)getLabelForDeletionPolicy:(NSInteger)deleitionPolicy;

+(NSNumber*)getDeletionPolicy:(NSString*)dateLabel;

+(BOOL)canCall;

+(BOOL)canSendMail;

+(BOOL)canSendSMS;
@end
