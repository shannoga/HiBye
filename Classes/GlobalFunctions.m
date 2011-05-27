//
//  GlobalFunctions.m
//  HiBye
//
//  Created by shani hajbi on 9/11/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "GlobalFunctions.h"
#import "Person.h"
#import "DatesFunctions.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>
#import "HiByeAppDelegate.h"
#import "Mail.h"
#import "Phone.h"
#import "Url.h"
#import "Address.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@implementation GlobalFunctions
#define D_DAY	86400


+ (BOOL)isDeviceAniPad {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(void)sendPersonToArchive:(Person*)person{

	[person setState:[NSNumber numberWithInteger:-1]];
	
	NSString *vcard = @"BEGIN:VCARD\nVERSION:3.0\n";
	vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"N:%@;%@;;;\n",person.lastName,person.firstName]];
	vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"FN:%@\n",person.compName]];
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook,[person.ID intValue]);
	ABMutableMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
	
	for (CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
		NSString *phoneNumber  = (NSString*)ABMultiValueCopyValueAtIndex(multiPhones, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);
		NSString *phoneNumberLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		CFRelease(locLabel);
	
		
		Phone *phone =(Phone*)[NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:person.managedObjectContext];
		phone.number =  phoneNumber;
		phone.label = phoneNumberLabel;
		phone.person = person;
		[person addPhonesObject:phone];
    if (i==0) {
		vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"TEL;type=%@;type=pref:%@\n",[phoneNumberLabel uppercaseString],phoneNumber]];
    }else{
		vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"TEL;type=%@:%@\n",[phoneNumberLabel uppercaseString],phoneNumber]];
    }
		[person release];
		CFRelease(phoneNumber);
		CFRelease(phoneNumberLabel);
	
	}

CFRelease(multiPhones);	


ABMutableMultiValueRef multiEmail = ABRecordCopyValue(ref, kABPersonEmailProperty);

	for (CFIndex i = 0; i < ABMultiValueGetCount(multiEmail); i++) {
		NSString *mail = (NSString*)ABMultiValueCopyValueAtIndex(multiEmail, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiEmail, i);
		NSString *mailLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
    
		Mail *mailEntity =(Mail*)[NSEntityDescription insertNewObjectForEntityForName:@"Mail" inManagedObjectContext:person.managedObjectContext];
		mailEntity.mail = mail;
		mailEntity.label = mailLabel;
		mailEntity.person = person;
		[person addMailsObject:mailEntity];
    if (i==0) {
		vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"EMAIL;type=%@;type=pref:%@\n",[mailLabel uppercaseString],mail]];
    }else {
		vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"EMAIL;type=%@:%@\n",[mailLabel uppercaseString],mail]];    
    }
		CFRelease(locLabel); 
		[mail release];
		[mailLabel release];
	}
CFRelease(multiEmail);


ABMultiValueRef streets = ABRecordCopyValue(ref, kABPersonAddressProperty);
	for (CFIndex j = 0; j<ABMultiValueGetCount(streets);j++){
		CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(streets, j);
		CFStringRef typeTmp = ABMultiValueCopyLabelAtIndex(streets, j);
		CFStringRef lbl = ABAddressBookCopyLocalizedLabel(typeTmp);
		NSString *street = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStreetKey) copy];
		NSString *city = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressCityKey) copy];
		NSString *state = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressStateKey) copy];
		NSString *zip = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressZIPKey) copy];
		NSString *country = [(NSString *)CFDictionaryGetValue(dict, kABPersonAddressCountryKey) copy];
    
    
		
		vcard  = [vcard stringByAppendingString:@"item1.ADR;type=OTHER;type=pref:;;"];
   
		
		Address *addressEntity =(Address*)[NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:person.managedObjectContext];
		addressEntity.label = (NSString*)lbl;
		addressEntity.street = street;
		addressEntity.city = city;
		addressEntity.state = state;
		addressEntity.zip = zip;
		addressEntity.country = country;

		vcard  = [vcard stringByAppendingString:@"\n"];
		[street release];
		[city release];
		[state release];
		[zip release];
		[country release];
		CFRelease(dict);
		CFRelease(lbl);
		CFRelease(typeTmp);
		addressEntity.person = person;
		[person addAddressesObject:addressEntity];
	}
	CFRelease(streets);
	
	
	
	ABMutableMultiValueRef multiURL = ABRecordCopyValue(ref, kABPersonURLProperty);
	
	for (CFIndex i = 0; i < ABMultiValueGetCount(multiURL); i++) {
		
		NSString *url = (NSString*)ABMultiValueCopyValueAtIndex(multiURL, i);
		CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, i);
		NSString *urlLabel =(NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
		
		Url *urlEntity =(Url*)[NSEntityDescription insertNewObjectForEntityForName:@"Url" inManagedObjectContext:person.managedObjectContext];
		urlEntity.url = url;
		urlEntity.label = urlLabel;
		urlEntity.person = person;
		[person addUrlsObject:urlEntity];
	

		if (i==0) {
			vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"item2.URL;type=pref:%@\n",url ]];
			vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"item2.X-ABLabel:%@\n",[urlLabel uppercaseString]]];
		}else if (i==1) {
			vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"item3.URL;type=pref:%@\n",url ]];
			vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"item3.X-ABLabel:%@>\n",[urlLabel uppercaseString]]];
		} 
		CFRelease(locLabel);
		[urlLabel release];
		[url release];
	}
		CFRelease(multiURL);



	vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"NOTE:%@\n",person.note]];
	vcard  = [vcard stringByAppendingString:[NSString stringWithFormat:@"X-ABUID:%@\n",person.ID]];

	vcard  = [vcard stringByAppendingString:@"END:VCARD"];
	
	NSArray *pathArray =
	NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *fileName = [NSString stringWithFormat:@"%@.vcf",person.compName];
	NSString *path =  [[pathArray objectAtIndex:0] stringByAppendingPathComponent:fileName];	
	
	NSError *error;
	[vcard writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
	

	ABAddressBookRemoveRecord(addressBook, ref, nil);
	ABAddressBookSave(addressBook, nil);

	CFRelease(addressBook);
	
	if (![person.managedObjectContext save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

/**/////////////////////////////////////////////setTimerToNewPerson/////////////////////////////////////////////////////////////**/

#pragma mark -
#pragma mark Setting values to new added contacts


/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/


/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/


+(void)deletePersonFromAB:(ABRecordID)recordId{
    
ABAddressBookRef addressBook = ABAddressBookCreate(); 
ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
ABAddressBookRemoveRecord(addressBook, ref, nil);
ABAddressBookSave(addressBook, nil);
CFRelease(addressBook);
    
}
/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(void)removePersonFromHiBye:(NSInteger)recordId HiByeGroupId:(NSInteger)hiByeGruopId{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, recordId);
    
    ABMutableMultiValueRef dates = ABRecordCopyValue(ref, kABPersonDateProperty);
    ABMutableMultiValueRef mutableDatesList = ABMultiValueCreateMutableCopy(dates);
    CFRelease(dates);
    
    ABMultiValueRemoveValueAndLabelAtIndex(mutableDatesList, 0);
    ABRecordSetValue(ref, kABPersonDateProperty, mutableDatesList, nil); 
    
    CFRelease(mutableDatesList);
    
    //remove person from Hibye group
    
    ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressBook,hiByeGruopId);
    ABGroupRemoveMember(HiByeGroup,ref,nil);
    ABAddressBookAddRecord (addressBook,ref,nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(addressBook);
    
    
}
/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(ABRecordRef)getRefFromId:(ABRecordID)recordId{

ABAddressBookRef addressBook = ABAddressBookCreate();
ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook,recordId);
CFRelease(addressBook);
return ref;

}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(NSInteger)getIDFromRef:(ABRecordRef)recordRef{
    
  //  ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordID ID = ABRecordGetRecordID(recordRef);    
	NSInteger recordId = (NSInteger)ID;
  //  CFRelease(addressBook);
    
    return recordId;
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(void)addDummy:(NSUInteger)count GroupId:(NSInteger)groupId{

	CFErrorRef error = NULL; 
	ABAddressBookRef addressbook = ABAddressBookCreate();
	
	while (count>0) {
		
	ABRecordRef newPerson = ABPersonCreate();
	ABRecordSetValue(newPerson, kABPersonFirstNameProperty,@"HiBye", &error);
	ABRecordSetValue(newPerson, kABPersonLastNameProperty, @"Dummy", &error);
	ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressbook, groupId);
	ABAddressBookAddRecord(addressbook, newPerson, &error);
	ABGroupAddMember(HiByeGroup,newPerson,nil);
	CFRelease(newPerson);
	count--;
	}
	
	ABAddressBookSave(addressbook, &error);
	CFRelease(addressbook);
	
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(void)removeDummy:(NSUInteger)count{
	/*
	CFErrorRef error = NULL; 
	ABAddressBookRef addressbook = ABAddressBookCreate();
	CFArrayRef existingDummis = ABAddressBookCopyPeopleWithName(addressbook,(CFStringRef)@"HiBye Dummy");
	// NSInteger numberExistingDummis=CFArrayGetCount(existingDummis);
	ABRecordRef ref;
	for (int i =0; i< count; i++) {
		ref =CFArrayGetValueAtIndex(existingDummis, i);
		ABAddressBookRemoveRecord(addressbook, ref, nil);
	}
	//CFRelease(ref);
	ABAddressBookSave(addressbook, &error);
	CFRelease(existingDummis);
	CFRelease(addressbook);
	*/
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(NSInteger)getNumberOfDummis{
	ABAddressBookRef addressbook = ABAddressBookCreate();
	CFArrayRef existingDummis = ABAddressBookCopyPeopleWithName(addressbook,(CFStringRef)@"HiBye Dummy");
	 NSInteger numberExistingDummis=CFArrayGetCount(existingDummis);
	CFRelease(addressbook);
	CFRelease(existingDummis);
	return numberExistingDummis;
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(BOOL)CheckToSeeIfInHiBye:(ABRecordID)recordID{
    BOOL inHiBye=NO;

    ABAddressBookRef addressBook = ABAddressBookCreate();

    ABRecordRef checkRef = ABAddressBookGetPersonWithRecordID(addressBook, recordID);

    //chacks to see if selected contact is allready in hiby
    ABMutableMultiValueRef multi;
    multi = ABRecordCopyValue(checkRef, kABPersonDateProperty);
    for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
    NSString *dateLabel = (NSString*) ABMultiValueCopyLabelAtIndex(multi, i);
    if ([self checkContactLabel:dateLabel]){
        inHiBye = YES;
    }
    [dateLabel release];
}

CFRelease(multi);
CFRelease(addressBook);
    return inHiBye;
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+(BOOL)checkContactLabel:(NSString*)dateLabel{
    if ([dateLabel isEqualToString:@"Delete/Alert"] ||[dateLabel isEqualToString:@"Delete/Archive"]||[dateLabel isEqualToString:@"Delete/NoArchive"] ){
        return YES;
    }else{
        return NO;
    }
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/

+ (void)alert:(NSString*)message {
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message
												   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/
+ (BOOL)setCategoryImageToPerson:(NSString*)imageName Ref:(ABRecordRef)ref{
	UIImage *img = [UIImage imageNamed:imageName];
	NSData *dataRef = UIImagePNGRepresentation(img); 
	CFDataRef cfdata = CFDataCreate(NULL, [dataRef bytes], [dataRef length]);	
	BOOL didSet = ABPersonSetImageData(ref, cfdata, nil);
	CFRelease(cfdata);
	return didSet;
}
/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/


+ (NSString*)GetCompNameFromRef:(ABRecordRef)ref{
	//ABAddressBookRef addressbook = ABAddressBookCreate();
	CFStringRef name = ABRecordCopyCompositeName(ref);
	NSString *compName = (NSString*)name;
	
	//CFRelease(addressbook);
	CFRelease(name);
	return compName;
}
/**//////////////////////////////////////////////////////////////////////////////////////////////////////////**/


+(NSMutableDictionary*)setDefaultTimerSettingsToPerson:(ABRecordRef)ref{
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	CFErrorRef error = NULL; 
	//set default category name;
	ABRecordSetValue(ref, kABPersonJobTitleProperty, CFSTR("No Category"), &error);
	
	//get the current settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger daysLeft = [defaults integerForKey:@"daysLeft"];
	[dic setObject:[NSNumber numberWithInt:daysLeft] forKey:@"daysLeft"];
	
	
	//set deletion date with default user
	 
	NSDate *deletionDate = [DatesFunctions dateWithIntervalFromNow:daysLeft factor:D_DAY];
	[dic setObject:deletionDate forKey:@"deletionDate"];
	
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	CFStringRef dateLabel = [self getLabelForDeletionPolicy:[defaults integerForKey:@"deletionPolicy"]];
	
	[dic setObject:(NSString*)dateLabel forKey:@"dateLabel"];
	[dic setObject:[NSNumber numberWithInt:[DatesFunctions returnDateState:deletionDate deletionPolicy:0]] forKey:@"state"];
	ABMultiValueAddValueAndLabel(multi,deletionDate,dateLabel, nil);
	ABRecordSetValue(ref, kABPersonDateProperty, multi, nil);
	CFRelease(multi);
	
	return dic;
}

+(CFStringRef)getLabelForDeletionPolicy:(NSInteger)deleitionPolicy {
	
	CFStringRef label = nil;

	switch (deleitionPolicy) {
		case 1:
			label=(CFStringRef)@"Delete/Archive";

			break;
		case 2:
			label=(CFStringRef)@"Delete/NoArchive";

			break;
		default:
			label=(CFStringRef)@"Delete/Alert";

			break;
	}

	
	return label;
	
}

+(NSNumber*)getDeletionPolicy:(NSString*)dateLabel{
	
	NSNumber *deletePolicy = [NSNumber numberWithInt:0];
    
		
	if([dateLabel isEqualToString:@"Delete/Archive"]){
		deletePolicy=[NSNumber numberWithInt:1];
	}else if([dateLabel isEqualToString:@"Delete/NoArchive"]){
		deletePolicy=[NSNumber numberWithInt:2];
	}	
	
	return deletePolicy;
}


//**checks if the device capabiltys**//

+(BOOL)canCall{
	BOOL canIt=NO;
	NSURL *url = [NSURL URLWithString:@"tel://9124819812952"];
	if ([[UIApplication sharedApplication] canOpenURL:url]){
		canIt=YES;
	}
	return canIt;
}

+(BOOL)canSendMail{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	BOOL canIt=NO;
	if (mailClass != nil) { 			
		if ([mailClass canSendMail]) {
			canIt=YES;
		}
	}
	return canIt;
}

+(BOOL)canSendSMS{
	
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	BOOL canIt=NO;
	if (messageClass != nil) { 			
		// Check whether the current device is configured for sending SMS messages
		if ([messageClass canSendText]) {
			canIt=YES;
		}
		else {	
			//feedbackMsg.hidden = NO;
			//feedbackMsg.text = @"Device not configured to send SMS.";
			
		}
	}
	else {
		//feedbackMsg.hidden = NO;
		//feedbackMsg.text = @"Device not configured to send SMS.";
	}
	
	return canIt;
}
@end
