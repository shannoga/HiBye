//
//  personDeatails.m
//  HiBye
//
//  Created by shani hajbi on 5/31/10.
//  Copyright 2010 shannoga. All rights reserved.
//

#import "ArchivedPersonDeatails.h"
#import "Person.h"
#import "PersonViewController.h"
#import "DatesFunctions.h"
#import "GlobalFunctions.h"
#import "Mail.h"
#import "Phone.h"
#import "Url.h"
#import "Address.h"
#import "ArchivedPersonView.h"
#import <dispatch/dispatch.h>

@implementation ArchivedPersonDeatails
@synthesize person,delegate,hiByeGroupId;

dispatch_queue_t myQueue;

#define D_DAY	86400

#pragma mark -
#pragma mark Initialization


- (void)loadView {
	defaults = [NSUserDefaults standardUserDefaults];
	
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	self.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.title=NSLocalizedString(@"Archive",@"");
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"restore" style:UIBarButtonItemStyleBordered
																			  target:self action:@selector(restoreOptions)] autorelease];
    
	ArchivedPersonView *archivedPersonView = [[ArchivedPersonView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	archivedPersonView.person=person;
	self.view = archivedPersonView;
	[archivedPersonView release];
	
	defaults = [NSUserDefaults standardUserDefaults];
	isIpad =[defaults boolForKey:@"isIpad"];
	
	myQueue = dispatch_queue_create("com.shannoga.restore", NULL);

}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside down
	if (!isIpad) {
		return (interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown);
	}
    return YES;
}


#pragma mark -
#pragma mark ActionSheet


-(void) restoreOptions {
	// open a dialog with an OK and cancel button
	
	
	
	NSString *fullName= person.compName;
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:fullName
															 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Permanently",@"With Default Timer",@"With Custom Timer",nil];
	
	//[fullName release];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	dispatch_async(myQueue, ^{[self restorePerson:buttonIndex]; });  
	
}


-(void)removeFromContext{
	NSManagedObjectContext *moc= person.managedObjectContext;
	[moc deleteObject:person];
	// Commit the change.
	NSError *error;
	if (![moc save:&error]) {
		//NSLog(@"problems with comiting cahnges");
	}

}

-(void)restorePerson:(NSInteger)btnId{
	
	
	CFErrorRef error = NULL; 
	CFStringRef lbl;
	
	ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
	
	
	ABRecordRef newPerson = ABPersonCreate();
	
	
		
	ABRecordSetValue(newPerson, kABPersonFirstNameProperty, person.firstName, &error);
	ABRecordSetValue(newPerson, kABPersonLastNameProperty, person.lastName, &error);
	
	
	
	ABRecordSetValue(newPerson, kABPersonJobTitleProperty, person.category, &error);
	ABRecordSetValue(newPerson, kABPersonNoteProperty, person.note, &error);
		
		
	ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	
	NSMutableArray *phones =[[NSMutableArray alloc] initWithArray:[person.phones allObjects]];
	while ([phones count]) {
		Phone *phone = (Phone*)[phones objectAtIndex:0];
		CFStringRef pl = (CFStringRef)phone.label;
		ABMultiValueAddValueAndLabel(multiPhone, phone.number, pl, NULL);
		[phones removeObjectAtIndex:0];
	}
	[phones release];
	ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
	CFRelease(multiPhone);
	
	
	
	ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	
	NSMutableArray *mails =[[NSMutableArray alloc] initWithArray:[person.mails allObjects]];

	while ([mails count]) {
		Mail *mail = (Mail*)[mails objectAtIndex:0];
		lbl = (CFStringRef)mail.label;
		ABMultiValueAddValueAndLabel(multiPhone,mail.mail, lbl, NULL);
		[mails removeObjectAtIndex:0];
	}
	[mails release];
	ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
	CFRelease(multiEmail);
	
	
	ABMutableMultiValueRef multiUrl = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	
	NSMutableArray *urls =[[NSMutableArray alloc] initWithArray:[person.urls allObjects]];
	while ([urls count]) {
		Url *url = (Url*)[urls objectAtIndex:0];
		lbl = (CFStringRef)url.label;
		ABMultiValueAddValueAndLabel(multiPhone,url.url, lbl, NULL);
		[urls removeObjectAtIndex:0];
		
	}
	[urls release];
	
	
	ABRecordSetValue(newPerson, kABPersonURLProperty, multiUrl, &error);
	CFRelease(multiUrl);
		
	ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	
	NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *addresses =[[NSMutableArray alloc] initWithArray:[person.addresses allObjects]];
	
	while ([addresses count]) {
		Address *address = (Address*)[addresses objectAtIndex:0];
		[addressDictionary setObject:address.country forKey:(NSString *) kABPersonAddressCountryKey];
		[addressDictionary setObject:address.street forKey:(NSString *) kABPersonAddressStreetKey];
		[addressDictionary setObject:address.city forKey:(NSString *)kABPersonAddressCityKey];
		[addressDictionary setObject:address.state forKey:(NSString *)kABPersonAddressStateKey];
		[addressDictionary setObject:address.zip forKey:(NSString *)kABPersonAddressZIPKey];
		[addresses removeObjectAtIndex:0];
	}
	[addresses release];

	
	//ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
	ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
	[addressDictionary release];
	CFRelease(multiAddress);

	if (btnId==1) {
		ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(iPhoneAddressBook,hiByeGroupId);
        
        if(HiByeGroup){
		BOOL didAddToGruop = ABGroupAddMember(HiByeGroup,newPerson,nil);
		NSLog(@"didAddToGruop = %d",didAddToGruop);
        }else{
            [GlobalFunctions alert:NSLocalizedString(@"Problem with Group ID", @"")];
        }
	
		//set default image;
		NSString *imageName=[NSString stringWithFormat:@"%@_B.png",person.category];
		[GlobalFunctions setCategoryImageToPerson:imageName Ref:newPerson];
	
	
		//get the current settings
	 
        NSInteger numOfDays = [defaults integerForKey:@"daysLeft"];
		NSInteger deletionPolicy = [defaults integerForKey:@"deletionPolicy"];
	
		//set deletion date with default user
		NSDate *deletionDate =  [DatesFunctions dateWithIntervalFromNow:numOfDays factor:D_DAY];
        person.ddate = deletionDate;
	
		ABMutableMultiValueRef multiDate = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		
		CFStringRef string =(CFStringRef) @"Delete/Alert";
		switch (deletionPolicy) {
			case 1:
				string=(CFStringRef)@"Delete/Archive";

				break;
			case 2:
				string=(CFStringRef)@"Delete/NoArchive";

				break;
		}
		
        person.deletion_policy = [NSNumber numberWithInteger:deletionPolicy];
        person.state = [NSNumber numberWithInt:[DatesFunctions returnDateState:deletionDate deletionPolicy:deletionPolicy]];
      
		ABMultiValueAddValueAndLabel(multiDate,deletionDate,string, nil);
		ABRecordSetValue(newPerson, kABPersonDateProperty, multiDate, nil);
		CFRelease(multiDate);
	}

	ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
	BOOL didAdd = ABAddressBookSave(iPhoneAddressBook, &error);
	if (!didAdd) {
		NSLog(@"Error %@", &error);
	}
	
	ABRecordID ID = ABRecordGetRecordID(newPerson);    
	person.ID = [NSNumber numberWithInt:ID];

	
	if (btnId==2) {
        
       
        PersonViewController *controller = [[PersonViewController alloc]init];
        
        controller.delegate=self;
        controller.hidesBottomBarWhenPushed = YES;
        controller.title =NSLocalizedString(@"Set new Timer",@"");
        
     
        controller.person = person;
         [person.managedObjectContext save:nil];

        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentModalViewController:navigation animated:YES];
        
        [controller release];
        [navigation release];	
       


    }
	
	
	
	

	CFRelease(newPerson);
	CFRelease(iPhoneAddressBook);
	
	NSArray *pathArray =
	NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *fileName = [NSString stringWithFormat:@"%@.vcf",person.compName];
	NSString *path =  [[pathArray objectAtIndex:0] stringByAppendingPathComponent:fileName];	
	
	NSError *fileManagererror = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (path!=nil) {
		[fileManager removeItemAtPath:path error:&fileManagererror];
	}else {
		NSLog(@"Error reading file at %@\n%@",path, [fileManagererror localizedFailureReason]);
	}

	if(btnId==0){
        [person.managedObjectContext deleteObject:person];
    }
	
	
	if (btnId==0 ||btnId==1 ) {
		[delegate archivedPersonDeatails:self didFinishWithRestore:YES withPerson:person];
	}
	
}


- (void)personViewController:(PersonViewController *)controller didFinishWithAdd:(BOOL)save{

    if(save){
		[person.managedObjectContext save:nil];
        [self dismissModalViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    
	[person release];
	[categories release];
    [super dealloc];
}


@end

