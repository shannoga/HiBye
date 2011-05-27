//
//  HiByeAppDelegate.m
//  HiBye
//
//  Created by shani hajbi on 10/20/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//

#import "HiByeAppDelegate.h"
#import "Person.h"
#import "PersonsDataSourceProtocol.h"
#import "PersonsTableViewController.h"
#import "PersonSortedByFirstNameDataSource.h"
#import "DatesFunctions.h"
#import "GlobalFunctions.h"


@implementation HiByeAppDelegate
#define D_DAY	86400


@synthesize window;
@synthesize navigationController;
@synthesize hiByeGroupId;


- init {
	if (self == [super init]) {
		// initialize  to nil
		window = nil;
		navigationController = nil;
		defaults = [NSUserDefaults standardUserDefaults];
        [self CheckForHiByeGroup];
	}
	return self;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

   
    // Override point for customization after application launch.
  
	[self setupPortraitUserInterface];
    return YES;
  
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    // The contacts controller we need to call
    //ContactsController *contacts = (ContactsController *)context;
    //[contacts synchronizeWithAddressBook:reference];
	//NSLog(@"got change from addressbook");
	//HiByeAppDelegate *hbad;
   // [hbad updateStore];
    
    
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	//ABAddressBookRef book = ABAddressBookCreate();
	//ABAddressBookRegisterExternalChangeCallback(book, addressBookChanged, self);
	[defaults setValue:[NSDate date] forKey:@"lastUseDate"];
    
    


    [defaults synchronize];
    NSLog(@"lastUseDate %@",[defaults objectForKey:@"lastUseDate"]);
	//[defaults setObject:[NSDate date]  forKey:@"lastUseDate"];
	NSUInteger dummiesCount = [defaults integerForKey:@"dummisCount"];
	BOOL	  dummisEnabeld = [defaults boolForKey:@"dummisEnabeld"];
	NSInteger CurrentDummis = [GlobalFunctions getNumberOfDummis];
	
	NSInteger dummiesToAddOrSubStruct = (dummiesCount - CurrentDummis); 

	if (!dummisEnabeld) {
		[GlobalFunctions removeDummy:CurrentDummis];
	}else if(dummisEnabeld){
	
		if (dummiesToAddOrSubStruct<0) {
			[GlobalFunctions removeDummy:dummiesToAddOrSubStruct*-1];
		}else if (dummiesToAddOrSubStruct>0) {
			[GlobalFunctions addDummy:(+dummiesToAddOrSubStruct) GroupId:hiByeGroupId];
		}
	}
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	[self updateStore];
}


- (UINavigationController *)newNavigationControllerWrappingViewControllerForDataSourceOfClass:(Class)datasourceClass {
    
    // the class type for the datasource is not crucial, but that it implements the 
    // ElementsDataSource protocol and the UITableViewDataSource Protocol is.
    id<PersonsDataSource> dataSource = [[datasourceClass alloc] init];
    
    // create the ElementsTableViewController and set the datasource
    PersonsTableViewController *theViewController;	
    theViewController = [[PersonsTableViewController alloc] initWithDataSource:dataSource];
    
	

	
    // create the navigation controller with the view controller
    UINavigationController *theNavigationController;
    theNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
    
    // before we return we can release the dataSource (it is now managed by the ElementsTableViewController instance
    [dataSource release];
    
    // and we can release the viewController because it is managed by the navigation controller
    [theViewController release];
    
    return theNavigationController;
    
    
}


- (void)setupPortraitUserInterface {
    
    // a local navigation variable
    // this is reused several times
    
    // Set up the portraitWindow and content view
    UIWindow *localWindow;
    localWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = localWindow;
    
    // the localPortraitWindow data is now retained by the application delegate
    // so we can release the local variable
    [localWindow release];
    
  
    
    // create the view controller and datasource for the ElementsSortedByNameDataSource
    // wrap it in a UINavigationController, and add that navigationController to the 
    // viewControllersArray array
    
    navigationController = [self newNavigationControllerWrappingViewControllerForDataSourceOfClass:[PersonSortedByFirstNameDataSource class]];

    // set the window subview as the tab bar controller
    [window addSubview:navigationController.view];
    
    // make the window visible
    
    [window makeKeyAndVisible];
    

}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Saves changes in the application's managed object context before the application terminates.
    NSError *error = nil;
    if (managedObjectContext) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

    }
}

- (void)dealloc {
	[navigationController release];
    [window release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [super dealloc];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator) {
         // [self CheckForHiByeGroup];
        // [self updateStore:hiByeGroupId];

        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"HiBye.sqlite"]];
    
    
    BOOL firstRun = NO;	
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path] isDirectory:NULL]) {
		firstRun = YES;		
	}
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } 
    
   if (firstRun) {
	   BOOL isIpad = [GlobalFunctions isDeviceAniPad];
	   NSMutableArray *activeCategories = [NSMutableArray arrayWithObjects:@"No Category",@"Dating",@"Events",@"Leads",@"Work",@"Traveling",@"Services",@"Stores",@"Professionals",nil];
	   NSMutableArray *customeCategories = [NSMutableArray arrayWithObjects:@"",nil];
	   [defaults setObject:activeCategories forKey:@"activeCategories"];
	   [defaults setObject:activeCategories forKey:@"allCategories"];
	   [defaults setObject:customeCategories forKey:@"customeCategories"];
	   [defaults setBool:isIpad forKey:@"isIpad"];
	   [defaults setBool:YES forKey:@"sortBy"];
	   [defaults setObject:[NSNumber numberWithInt:0] forKey:@"deletionPolicy"];
	   [defaults setObject:[NSNumber numberWithInt:14] forKey:@"daysLeft"];
	   [defaults setFloat:60.0 forKey:@"maxDaysLeft"];
	   [defaults setFloat:1.0 forKey:@"minDaysLeft"];
	   [defaults setInteger:1 forKey:@"dummisCount"];
	   [defaults setBool:NO forKey:@"dummisEnabeld"];
	   [defaults setObject:@"0,1,2,3,4,5,6,7,8" forKey:@"selectendIndexes"];
	   [defaults setObject:[NSDate date]  forKey:@"lastUseDate"];
	   
	   [defaults synchronize];
   }
   
    return persistentStoreCoordinator;
}



#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (void)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }else {
		NSLog(@"did save context");
	}

}

/**
 createNewHiByeGroup */

-(void) createNewHiByeGroup {
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef HiByeGroup = ABGroupCreate();
	ABRecordSetValue(HiByeGroup, kABGroupNameProperty,@"HiBye", nil);
	ABAddressBookAddRecord(addressBook, HiByeGroup, nil);
	ABAddressBookSave(addressBook, nil);
	CFRelease(addressBook);
	
	//write groupID
	hiByeGroupId = ABRecordGetRecordID(HiByeGroup);
	CFRelease(HiByeGroup);
}



-(void) CheckForHiByeGroup {
	

	BOOL hasHiByeGroup = NO;
	//checks to see if the group is created ad creats group for HiBye contacts
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFIndex groupCount = ABAddressBookGetGroupCount(addressBook);
	

		CFArrayRef groupLists= ABAddressBookCopyArrayOfAllGroups(addressBook);
		
		for (int i=0; i<groupCount; i++) {
			ABRecordRef currentCheckedGroup = CFArrayGetValueAtIndex(groupLists, i);
            
			NSString *groupName = (NSString *)ABRecordCopyCompositeName(currentCheckedGroup);
			
			if ([groupName isEqualToString:@"HiBye"]){
				hiByeGroupId = ABRecordGetRecordID(currentCheckedGroup);
				hasHiByeGroup=YES;
			}
			[groupName release];
		}
		
		if (hasHiByeGroup==NO){
			[self createNewHiByeGroup];
		}
		
	//CFRelease(currentCheckedGroup);

		CFRelease(groupLists);
	
	CFRelease(addressBook);	
    [self updateStore];

}

-(NSString*)firstLetter:(NSString*)str{
	if (!formatter) {
	formatter = [[NSNumberFormatter alloc] init];
	}
	NSString *firstLetter;
	if ([formatter numberFromString:str]||str==@"") {
		firstLetter = @"#";
		
	}else {
		firstLetter = [str capitalizedString];
	}
	return firstLetter;
	
}



-(void)SetDefaultValuesToPesonManagedObject:(Person*)person ref:(ABRecordRef)ref{
    
    NSInteger defaultdaysLeft = [defaults integerForKey:@"daysLeft"];
    NSInteger defaultsdeletionPolicy = [defaults integerForKey:@"deletionPolicy"];
    
    NSDate *deletionDate = [DatesFunctions dateWithIntervalFromNow:defaultdaysLeft factor:D_DAY];
    [person setDdate:deletionDate];
    
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    CFStringRef string = nil;
    
    switch (defaultsdeletionPolicy) {
        case 1:
            string=(CFStringRef)@"Delete/Alert";
            break;
        case 2:
            string=(CFStringRef)@"Delete/Alert";
            break;
        default:
            string=(CFStringRef)@"Delete/NoArchive";
            break;
    }
    
    [person setDeletion_policy:[NSNumber numberWithInteger:defaultsdeletionPolicy]];
    [person setState:[NSNumber numberWithInt:[DatesFunctions returnDateState:deletionDate deletionPolicy:defaultsdeletionPolicy]]];
    ABMultiValueAddValueAndLabel(multi,deletionDate,string, nil);
    ABRecordSetValue(ref, kABPersonDateProperty, multi, nil);
    CFRelease(multi);
    
    [GlobalFunctions setCategoryImageToPerson:@"No Category_B" Ref:ref];
    
    CFErrorRef error = NULL;
    //set default category name;
    ABRecordSetValue(ref, kABPersonJobTitleProperty, CFSTR("No Category"), &error);
    
    person.category=NSLocalizedString(@"No Category",@"");
    person.category_en=@"No Category";
    
    
    CFStringRef categoryRef,nameRef,firstNameRef,lastNameRef,noteRef;
    nameRef = ABRecordCopyCompositeName(ref);
    categoryRef = ABRecordCopyValue(ref, kABPersonJobTitleProperty);
    firstNameRef =  ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    lastNameRef =  ABRecordCopyValue(ref, kABPersonLastNameProperty);
    noteRef =  ABRecordCopyValue(ref, kABPersonNoteProperty);
    
    [person setCompName:(NSString*)nameRef]; 
    [person setFirstName:(NSString*)firstNameRef]; 
    [person setLastName:(NSString*)lastNameRef]; 
    [person setCategory:NSLocalizedString((NSString*)categoryRef,@"")]; 
    [person setCategory_en:(NSString*)categoryRef]; 
    NSString *firstLetter = [(NSString*)nameRef substringToIndex:1];
    [person setFirstLetter:[self firstLetter:firstLetter]]; 
    
    NSInteger RecordId = ABRecordGetRecordID(ref);
    [person setID:[NSNumber numberWithInt:RecordId]];
    
   // CFRelease(nameRef);
   // CFRelease(firstNameRef);
   // CFRelease(lastNameRef);
   // CFRelease(categoryRef);
    //CFRelease(noteRef);

}

-(void)updatePersonManagedObject:(Person*)person ref:(ABRecordRef)ref dateDic:(NSDictionary*)dateDic{
  
    
    CFStringRef categoryRef,nameRef,firstNameRef,lastNameRef,noteRef;
    nameRef = ABRecordCopyCompositeName(ref);
    categoryRef = ABRecordCopyValue(ref, kABPersonJobTitleProperty);
    firstNameRef =  ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    lastNameRef =  ABRecordCopyValue(ref, kABPersonLastNameProperty);
    noteRef =  ABRecordCopyValue(ref, kABPersonNoteProperty);
    
    [person setCompName:(NSString*)nameRef]; 
    [person setFirstName:(NSString*)firstNameRef]; 
    [person setLastName:(NSString*)lastNameRef]; 
    [person setCategory:NSLocalizedString((NSString*)categoryRef,@"")]; 
    [person setCategory_en:(NSString*)categoryRef]; 
 
    
    NSString *firstLetter = [(NSString*)nameRef substringToIndex:1];
    [person setFirstLetter:[self firstLetter:firstLetter]]; 
    
    
    person.deletion_policy = [dateDic objectForKey:@"deletionPolicy"];
    person.ddate = [dateDic objectForKey:@"deletionDate"];
    person.state = [dateDic objectForKey:@"state"];
    
    NSInteger RecordId = ABRecordGetRecordID(ref);
    [person setID:[NSNumber numberWithInt:RecordId]];
    
   // CFRelease(nameRef);
   // CFRelease(firstNameRef);
    //CFRelease(lastNameRef);
   // CFRelease(categoryRef);
    //CFRelease(noteRef);
}
/**
 sets the persons entitys at lunch */

-(void) updateStore {
	
	
	
    NSInteger RecordId;
    NSInteger state;
    BOOL hasDeleteDate = NO;
   

    NSArray *onePersonArray;

    
    //get the persons from the hibye group in the addressbook
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressBook,hiByeGroupId);
    CFArrayRef people;
    people = ABGroupCopyArrayOfAllMembersWithSortOrdering(HiByeGroup, 0);
    

    //GET the persons already in store

    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Person" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
        
    
    NSInteger attributeValue = -1;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state != %i",attributeValue];
   
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"compName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSError *error;
    NSArray *fetchedArray = [moc executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"problem with array");
    }
    
    NSArray *array = [[NSArray alloc] initWithArray:fetchedArray];
    NSArray *personsID = [array valueForKey:@"ID"];
    
    //checks to see if a person had been deleted  from addressbook while app was off.
   for (int i =0; i< [personsID count]; i++) {
        if( ![GlobalFunctions getRefFromId:[[personsID objectAtIndex:i]intValue]]){
            [moc deleteObject:[array objectAtIndex:i]];
        }
    }
    

    if (people){
        BOOL inStore;
        Person *person;
        CFStringRef nameRef;
        //peopleCount = CFArrayGetCount(people);
        CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,CFArrayGetCount(people),people);
        NSInteger numberOfPersonsInGroup=CFArrayGetCount(peopleMutable);

        for (int i =0; i< numberOfPersonsInGroup; i++) {
            inStore = NO;
            ABRecordRef ref = CFArrayGetValueAtIndex(peopleMutable, i);
            RecordId = ABRecordGetRecordID(ref);
            NSLog(@"i = %i",i);
			//NSDate *creationDate  =(NSDate*)ABRecordCopyValue(ref, kABPersonCreationDateProperty);
           // CFRelease(modificationDateRef);
            
            NSDictionary *personDateDic = [NSDictionary dictionaryWithDictionary:[DatesFunctions returnPersonStatusDictionary:RecordId]];
            hasDeleteDate = [[personDateDic objectForKey:@"hasDeleteDate"] boolValue];
            state = [[personDateDic objectForKey:@"state"] intValue];
            nameRef = ABRecordCopyCompositeName(ref);
            
            //check the modification date of the contact
            CFDateRef modificationDateRef  =ABRecordCopyValue(ref, kABPersonModificationDateProperty);
            NSDate *modificationDate = (NSDate*)modificationDateRef;
           
            NSDate *lastUseDate =(NSDate*) [defaults objectForKey:@"lastUseDate"];
            NSComparisonResult result = [modificationDate compare:lastUseDate];
             CFRelease(modificationDateRef);
            
            NSString *attributeNameValue = (NSString*)nameRef;
            NSNumber *attributeIDValue = [NSNumber numberWithInteger:RecordId];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@ AND compName == %@",attributeIDValue,attributeNameValue];
            CFRelease(nameRef);
            onePersonArray = [array filteredArrayUsingPredicate:predicate];
            
            if([onePersonArray count]>0){
                person =(Person*)[onePersonArray objectAtIndex:0];
                inStore=YES;
            }
            
            switch(result){
                case   NSOrderedAscending:  
                    //The modificationDate is earlier then lastUseDate;
                
                    //2. manageDeletionPolicy
                    switch (state){
                        case -2:
                            [GlobalFunctions deletePersonFromAB:RecordId]; 
                            if(inStore){
                            [moc deleteObject:person];
                            }
                            break;
                            //delete  archive
                        case -1:
                            [GlobalFunctions deletePersonFromAB:RecordId];
                             if(inStore){
                            [person setState:[NSNumber numberWithInteger:state]]; 
                             }
                            break;
                    }
                    
                    if(!inStore){
                        person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" 
                                                                        inManagedObjectContext:moc]; 
                        [self SetDefaultValuesToPesonManagedObject:person ref:ref];
                    } 
                    break;
                    
                 
                
                //The modificationDate is later then lastUseDate;
                case  NSOrderedDescending:  
                    
                    if(hasDeleteDate){
                        
                        switch (state){
                                //delete dont archive
                            case -2:
                                [GlobalFunctions deletePersonFromAB:RecordId]; 
                                [moc deleteObject:person];
                                
                                break;
                                //delete and archive
                            case -1:
                                [GlobalFunctions deletePersonFromAB:RecordId]; 
                                [person setState:[NSNumber numberWithInteger:state]]; 
                                break;
                        }  
                        
                        if(inStore){
                            [self updatePersonManagedObject:person ref:ref dateDic:personDateDic];
                            
                        }else if(!inStore){
                            person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" 
                                                                            inManagedObjectContext:moc]; 
                            [self SetDefaultValuesToPesonManagedObject:person ref:ref];
                        }     
                    }else if(!hasDeleteDate){
                       if(!inStore){
                         person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" 
																					inManagedObjectContext:moc]; 
                           [self SetDefaultValuesToPesonManagedObject:person ref:ref];

                       }else if(inStore){
                        [self updatePersonManagedObject:person ref:ref dateDic:personDateDic];
                       }
                        
                     
                        }   
                     break; 
                    } 
            
                  
                     
            
            }
           
            CFRelease(peopleMutable);
            CFRelease(people);
        }
   
    [array release];
    [moc save:nil];
    ABAddressBookSave(addressBook,nil);
    CFRelease(addressBook);

    }

            
			
            
            /*
			NSComparisonResult result = [creationDate compare:lastUseDate];
            
            switch(result){
                  case  NSOrderedDescending:  
                        	NSLog(@"creationDate =  %@ is later then lastUseDate = %@",creationDate,lastUseDate);
                    break;
                    
                case   NSOrderedAscending:  
                            NSLog(@"creationDate =  %@ is earlier then lastUseDate = %@",creationDate,lastUseDate);
                    break;
                    
                    
            }
            */
     


@end

/*
@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
	UIColor *color = [UIColor colorWithRed:137.0/255.0 green:147.0/255.0 blue:166.0/255.0 alpha:1];
	UIImage *img	= [UIImage imageNamed: @"navBg.png"];
	[img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	self.tintColor = color;
}


@end
 */
