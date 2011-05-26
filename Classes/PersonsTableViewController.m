//
//  PersonsTableViewController.m
//  HiBye
//
//  Created by shani hajbi on 9/20/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "PersonsTableViewController.h"
#import "PersonsDataSourceProtocol.h"
#import "Person.h"
#import "PersonViewController.h"
#import "GlobalFunctions.h"
#import "Settings.h"
#import "DatesFunctions.h"
#import "HiByeAppDelegate.h"
#import "ArchivedPersonView.h"
#import "ArchivedPersonDeatails.h"
#import "AddViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SectionHeaderView.h"
#import <dispatch/dispatch.h>
#import "TISwipeableTableView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PersonCell.h"
@implementation PersonsTableViewController
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize pickPersonPicker;
@synthesize theTableView;
@synthesize dataSource;
@synthesize fetchedResultsController;
@synthesize addingManagedObjectContext;
@synthesize segmentedControl;
@synthesize myToolbar;
@synthesize banner;
@synthesize contentView;
@synthesize activeIndexPaths;

dispatch_queue_t myQueue;

#define D_DAY	86400
#define kCustom_Timer 0
#define kDefault_Timer 1
#define kNew_Existing_AS 0
#define kCustum_Default_AS 1
#define kNew_Person 0
#define kExist_Person 1
	

// this is the custom initialization method for the ElementsTableViewController
// it expects an object that conforms to both the UITableViewDataSource protocol
// which provides data to the tableview, and the ElementDataSource protocol which
// provides information about the elements data that is displayed,

- (id)initWithDataSource:(id<PersonsDataSource>)theDataSource {
	if ([self init]) {
		theTableView = nil;
		theTableView.backgroundColor = [UIColor lightGrayColor];
		self.dataSource = theDataSource;
		self.title = [dataSource name];
		self.navigationItem.title=[dataSource navigationBarName];
		UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title=@"Back";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[self.navigationItem setTitle:@"Hi-Bye"];
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(lunchAddPersonActionSheet)];
		UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(enterSettings)];

		[self.navigationItem setRightBarButtonItem:addButton];
		[self.navigationItem setLeftBarButtonItem:settingsButton];
		[addButton release];
		[settingsButton release];
		[temporaryBarButtonItem release];
		
		//**create defaults instance**//	
		defaults = [NSUserDefaults standardUserDefaults];
		isIpad = [defaults boolForKey:@"isIpad"];
		hibyeGroupId = [dataSource hibyeGroupId];
		isArchive=NO;
		transitioning=NO;
		activeIndexPaths = [[NSMutableArray alloc] init];
		
		
	}
	return self;
}




#pragma mark -
#pragma mark load views Method

- (void)loadView {
	
	///////////*init the main view*//////////
	UIView *viewController = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	viewController.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin);
	viewController.autoresizesSubviews =YES;
	viewController.backgroundColor = [UIColor whiteColor];
	self.view = viewController;
	[viewController release];
	
	///////*init the content view that holds the tool bar and the table view*///////
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	contentView.autoresizesSubviews =YES;
	contentView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.contentView];
	
		
	///////*init the  table view*///////
	TISwipeableTableView *tableView = [[TISwipeableTableView alloc] initWithFrame:CGRectZero];
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin);
	tableView.showsVerticalScrollIndicator =YES;
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
	[tableView setSwipeDelegate:self];
	tableView.sectionIndexMinimumDisplayRowCount=100;
	
	self.theTableView = tableView;
	self.theTableView.frame = CGRectMake(0,0, self.contentView.frame.size.width,self.contentView.frame.size.height-49);
	
	[self.contentView addSubview:self.theTableView];
	[tableView release];
	
	
		
	///////*init the  tollBar*///////	
	
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,396, self.contentView.frame.size.width,49)];
	[toolBar sizeToFit];
	self.myToolbar = toolBar;
	[toolBar release];
	
	///////*init the  toolbat buttons*///////	
	myToolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight);
	
	///////*init the  segmentedControl*///////
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"All",@""),NSLocalizedString(@"Expired",@"") , nil]];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	segmentedControl.frame = CGRectMake
	(0 ,0,segmentedControl.frame.size.width,30);
	[segmentedControl addTarget:self action:@selector(ReloadTableViewWithNewPerdicate:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.selectedSegmentIndex=0;
	UIBarButtonItem *segmented = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Archive",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(showArchive)];
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	mainitems = [[NSMutableArray alloc ]initWithObjects:flexItem,flexItem,segmented,flexItem,archiveButton, nil];
	archiveitems =  [[NSMutableArray alloc ]initWithObjects:flexItem,archiveButton,flexItem, nil];
	[archiveButton release];
	[segmented release];
	[flexItem release];
	[segmentedControl release];
	[self.myToolbar setItems:mainitems animated:NO];
	[self.contentView addSubview:self.myToolbar];
	

	
	///////*init the  searchBar*///////
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate=self;
    searchBar.delegate =self;
	self.theTableView.tableHeaderView = searchBar;



	
		
	myQueue = dispatch_queue_create("com.shannoga.archive", NULL);

	
	///////*create the banner for ads if supported*///////	
	if(banner == nil)
    {
        [self createADBannerView];
    }
    [self layoutForCurrentOrientation:NO];
		 

}
#pragma mark -
#pragma mark UIView Methods

- (void)dealloc {
	[activeIndexPaths release];
	activeIndexPaths=nil;
	banner.delegate = nil;
    [banner release]; banner = nil; 
	[searchDisplayController release];
	[searchBar release];
	[theTableView release];
    [addingManagedObjectContext release];
    [fetchedResultsController release];
	[dataSource release];
    [pickPersonPicker release];
	[dataSource release];
	[segmentedControl release];
	[super dealloc];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}
	
-(void)viewWillAppear:(BOOL)animated{
    self.segmentedControl.hidden=NO;
	[self.theTableView reloadData];
	[self layoutForCurrentOrientation:NO];
    [super viewWillAppear:YES];
}



- (void)viewDidUnload {
	[super viewDidUnload];
	self.contentView = nil;
    banner.delegate = nil;
    self.banner = nil;
	pickPersonPicker = nil;
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	fetchedResultsController =nil;
	addingManagedObjectContext = nil;
	segmentedControl = nil;
	dataSource=nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   
    [self layoutForCurrentOrientation:YES];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   NSInteger numberOfRows = 0;
	
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
	
	PersonCell * cell = (PersonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[PersonCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	[self configureCell:cell atIndexPath:indexPath];

	
    return cell;
	
}

- (void)configureCell:(PersonCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    if([fetchedResultsController objectAtIndexPath:indexPath]!=nil){
	Person *person = (Person *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.person = person;
	cell.delegate=self;
		
		if ([person.state intValue]>0) {
			[activeIndexPaths addObject:indexPath];
		}

    }
}


-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
  
	SectionHeaderView *headerView = [[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.theTableView.bounds.size.width, 15) title:[sectionInfo name]] autorelease];
	
	return headerView;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchedResultsController sectionForSectionIndexTitle:[title capitalizedString] atIndex:index];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
		return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
       	}   
}

#pragma mark showing person view controllers


// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    
    if(!isArchive){
		// deselect the new row using animation
		[tableView deselectRowAtIndexPath:newIndexPath animated:YES];
		Person *person = (Person *)[fetchedResultsController objectAtIndexPath:newIndexPath];
		PersonViewController *personController = [[PersonViewController alloc] init];
		personController.person =person;
		personController.delegate=self;
		personController.hidesBottomBarWhenPushed = YES;
		segmentedControl.hidden = YES;
		[self.navigationController pushViewController:personController animated:YES];
		[personController release];
		
    }else{
        
        [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
		ArchivedPersonDeatails *personController = [[ArchivedPersonDeatails alloc] init];
        Person *person = (Person *)[fetchedResultsController objectAtIndexPath:newIndexPath];
		personController.person = person;
        personController.hiByeGroupId = [dataSource hibyeGroupId];
        personController.delegate = self;
        [self.navigationController pushViewController:personController animated:YES];
        [personController release];
    }
}

static void completionCallback(SystemSoundID soundID, void * clientData) {
	AudioServicesRemoveSystemSoundCompletion(soundID);
}
- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString * path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	NSURL * fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
	
	SystemSoundID soundID;
	AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
	AudioServicesPlaySystemSound(soundID);
	AudioServicesAddSystemSoundCompletion (soundID, NULL, NULL, completionCallback, NULL);
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	[(TISwipeableTableView*)self.theTableView hideVisibleBackView:NO];
}
/*
- (void)checkButtonTapped:(id)sender event:(id)event {
    
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.theTableView];
    
	NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
		[self tableView:self.theTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}
 */

#pragma mark -
#pragma mark Adding person Methods
#pragma mark add person with build in controller
///////*add person with build in controller*///////
-(void) lunchAddPersonActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add new contact",@"")
																delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
																destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add New Contact",@""),
																NSLocalizedString(@"Select Existing Contact",@""),nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet setTag:0];
	[actionSheet showFromToolbar:self.myToolbar];
	[actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

		
		if(buttonIndex==kNew_Person){
			[self addPerson:0 name:nil existing:NO];
		}
		
		if(buttonIndex==kExist_Person){
			[self showPeoplePickerController];
		}
		
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate methods
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return YES;
}

#pragma mark showPeoplePickerController
-(void)showPeoplePickerController {
	ABPeoplePickerNavigationController *pickerView = [[ABPeoplePickerNavigationController alloc] init];
    pickerView.peoplePickerDelegate = self;
	[self.navigationController presentModalViewController:pickerView animated:YES];
	[pickerView release];	
}



#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)personRef {	
	
	NSInteger TempREcordId = ABRecordGetRecordID(personRef);
    
	BOOL hasDeleteDate = [GlobalFunctions CheckToSeeIfInHiBye:TempREcordId];
    
	if (hasDeleteDate) {
        [GlobalFunctions alert:NSLocalizedString(@"Selected contact allready exist in HiBye", @"") ];
	}else{
		[self dismissModalViewControllerAnimated:NO];

		//[NSThread sleepForTimeInterval:1];
		CFStringRef name = ABRecordCopyCompositeName(personRef);
		NSString *compName = (NSString*)name;
		[self addPerson:TempREcordId name:compName existing:YES];
		CFRelease(name);

    }
    

	return NO;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}




#pragma mark -
#pragma mark Delegation methods
- (void)personViewController:(PersonViewController *)controller didFinishWithSave:(BOOL)save {
	[dataSource saveContext];
	[self.navigationController popToRootViewControllerAnimated:YES];

}

//called when an action is done on a person and he should be deleted from addressbook
- (void)personViewController:(PersonViewController *)controller  didFinishWithChange:(BOOL)save person:(Person*)person withAction:(NSInteger)actionIndex {
    
    if (save) {
        switch(actionIndex){
            case 0:
				dispatch_async(myQueue, ^{[GlobalFunctions deletePersonFromAB:[person.ID intValue]]; });  
                
                [[fetchedResultsController managedObjectContext] deleteObject:person];
				[[fetchedResultsController managedObjectContext] save:nil];
                break;

            case 1:
				dispatch_async(myQueue, ^{[GlobalFunctions sendPersonToArchive:person]; });    
                break;
                
            case 2:
				dispatch_async(myQueue, ^{[GlobalFunctions removePersonFromHiBye:[person.ID intValue] HiByeGroupId:hibyeGroupId]; }); 
                
                [[fetchedResultsController managedObjectContext] deleteObject:person];
				[[fetchedResultsController managedObjectContext] save:nil];
                break;
                
        }
	}
            [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)archivedPersonDeatails:(ArchivedPersonDeatails *)controller didFinishWithRestore:(BOOL)restore withPerson:(NSManagedObject*)person {
    	[[fetchedResultsController managedObjectContext] save:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
	   
}



- (void)addPerson:(NSInteger)recoreId name:(NSString*)compName existing:(BOOL)existing {
	
	// Create a new managed object context for the new person -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingContext release];
	
	[addingManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
	
	
	Person *person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:addingContext];

	if (existing) {
		
		//ABRecordRef ref = [GlobalFunctions getRefFromId:recoreId];
		//NSString *compName = [GlobalFunctions GetCompNameFromRef:ref];
		person.compName = compName;
		person.ID =[NSNumber numberWithInt:recoreId];
		
	}
    AddViewController *addViewController = [[AddViewController alloc] initWithPerson:person];
	addViewController.delegate = self;
	
	
	//addViewController.person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:addingContext];
	
	addViewController.hiByeGroupId = [dataSource hibyeGroupId];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
	
    [self presentModalViewController:navController animated:YES];
	
	[addViewController release];
	[navController release];
}

/**
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new book.
 */
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		/*
		 The new book is associated with the add controller's managed object context.
		 This is good because it means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad -- but it does make it more difficult to get the new book registered with the fetched results controller.
		 First, you have to save the new book.  This means it will be added to the persistent store.  Then you can retrieve a corresponding managed object into the application delegate's context.  Normally you might do this using a fetch or using objectWithID: -- for example
		 
		 NSManagedObjectID *newBookID = [controller.book objectID];
		 NSManagedObject *newBook = [applicationContext objectWithID:newBookID];
		 
		 These techniques, though, won't update the fetch results controller, which only observes change notifications in its context.
		 You don't want to tell the fetch result controller to perform its fetch again because this is an expensive operation.
		 You can, though, update the main context using mergeChangesFromContextDidSaveNotification: which will emit change notifications that the fetch results controller will observe.
		 To do this:
		 1	Register as an observer of the add controller's change notifications
		 2	Perform the save
		 3	In the notification method (addControllerContextDidSave:), merge the changes
		 4	Unregister as an observer
		 */
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;
    [self dismissModalViewControllerAnimated:YES];

}


/**
 Notification from the add controller's context's save operation. This is used to update the fetched results controller's managed object context with the new book instead of performing a fetch (which would be a much more computationally expensive operation).
 */
- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
    [context save:nil];
     }

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:[dataSource currentManagedObjectContext]];
        [fetchRequest setEntity:entity];
  
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[dataSource keyName] ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        // Edit the sort key as appropriate.
	
	
	NSString *perdicateString;
	
	if (!isArchive) {
		perdicateString = @"state>-1";
	
	}else {
		perdicateString = @"state<0";
	}
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:perdicateString];
      
       
	
        [fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setPredicate:predicate];

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[dataSource currentManagedObjectContext] sectionNameKeyPath:@"firstLetter" cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
		[aFetchedResultsController release];
        [fetchRequest release];
		[sortDescriptor release];
        [sortDescriptors release];
	
    
	return fetchedResultsController;
     
}    


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.theTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.theTableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(PersonCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.theTableView endUpdates];
}



#pragma mark -
#pragma mark Setting controller

-(void)enterSettings {
    
    
    Settings *controller = [[Settings alloc]init];
    [controller setManagedObjectContext:(NSManagedObjectContext *)[dataSource currentManagedObjectContext]];            
	controller.delegate=self;	
	controller.isIpad=isIpad;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
	[controller release];
	[self presentModalViewController:navigation animated:YES];
	[navigation release];
		
}

//called when a settings are closed

- (void)settings:(Settings *)controller didFinishWithSave:(BOOL)save{
   
}

#pragma mark -
#pragma mark Archive 
-(void)showArchive{


	CATransition *transition = [CATransition animation];
	transition.duration = 1;
	[transition setType: @"flip"];
	if (!isArchive) {
	[transition setSubtype:@"fromRight"];
	}else {
	[transition setSubtype:@"fromLeft"];
	}
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[transition setFillMode:@"extended"];
	//[[self.navigationController.navigationBar layer] addAnimation:transition forKey:nil];
	[[self.theTableView layer] addAnimation:transition forKey:nil];
	
	
	[self performSelector:@selector(changeLabel) withObject:nil afterDelay:transition.duration/2];
	if (!isArchive) {
		isArchive=YES;
		[self.myToolbar setItems:archiveitems animated:YES];
		
	}else {
		isArchive=NO;
		[self.myToolbar setItems:mainitems animated:YES];
	}

	
	[NSFetchedResultsController deleteCacheWithName:@"Root"];
	[self.fetchedResultsController performFetch:nil];
	[self.theTableView reloadData];
	[CATransaction commit];

	
}

-(void)changeLabel{
	NSString *barTitle = isArchive ? @"Archive":@"Hi-Bye";
	[self.navigationItem setTitle:barTitle];
	UIColor *barColor = isArchive ? [UIColor brownColor]:nil;
	self.navigationController.navigationBar.tintColor = barColor;
	self.navigationItem.rightBarButtonItem.enabled=!isArchive;
	self.navigationItem.leftBarButtonItem.enabled=!isArchive;


}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSLog(@"searching");
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compName=8"];
	[fetchedResultsController.fetchRequest setPredicate:predicate];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }  
	
	 
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

*/
-(void)ReloadTableViewWithNewPerdicate:(id)sender{
	
	UISegmentedControl *sc = (UISegmentedControl*)sender;
	//[theTableView beginUpdates];
	Person *person;
	switch (sc.selectedSegmentIndex) {
		case 1:
			for (int i=0; i<[activeIndexPaths count]; i++) {
				person=(Person*)[fetchedResultsController objectAtIndexPath:[activeIndexPaths objectAtIndex:i]];
				[fetchedResultsController.managedObjectContext deleteObject:person];
			}
			
			//[theTableView insertRowsAtIndexPaths:activeIndexPaths withRowAnimation:UITableViewRowAnimationRight];
			break;
		case 0:
			[fetchedResultsController.managedObjectContext rollback];
			break;

	}
	
	
	//[theTableView endUpdates];

	
	/*
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state!=%i",sc.selectedSegmentIndex];
	[fetchedResultsController.fetchRequest setPredicate:predicate];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    } 
*/
	//[self.theTableView reloadData];
}


///////////////////////////////////////////////
//*********calling/masaging*****************//
//////////////////////////////////////////////

#pragma mark -
#pragma mark Compose Mail


	
	

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)personCell:(PersonCell *)controller displayMailComposerSheet:(NSString*)recipient
{
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	//[picker setSubject:@"Hello from California!"];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:recipient]; 
	[picker setToRecipients:toRecipients];
	
	// Attach an image to the email
	NSString *path = [[NSBundle mainBundle] pathForResource:@"No Category" ofType:@"png"];
	NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"Hi-Bye"];
	
	NSString *emailBody = @"Sent from Hi-Bye";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
	
}


- (void)personCell:(PersonCell *)controller displaySMSComposerSheet:(NSString*)recipient
	
{
	MFMessageComposeViewController	*sms = [[MFMessageComposeViewController alloc] init];
	sms.messageComposeDelegate=self;
	
	NSArray *Recipients = [NSArray arrayWithObject:@"first@example.com"]; 
	[sms setRecipients:Recipients];
	
	[self presentModalViewController:sms animated:YES];
	[sms release];	
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}





///////////////////////////////////////////////
//*********ADBannerView*****************//
//////////////////////////////////////////////

#pragma mark -
#pragma mark ADBannerView Methods

-(void)createADBannerView
{
	NSString *contentSize;
#if __IPHONE_4_0 == __IPHONE_OS_VERSION_MAX_ALLOWED
	contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?ADBannerContentSizeIdentifier480x32: ADBannerContentSizeIdentifier320x50;
	
#endif
	
#if __IPHONE_4_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
	contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait:  ADBannerContentSizeIdentifierLandscape;

#endif
	

    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0, CGRectGetMaxY(self.view.bounds));
    
    // Now to create and configure the banner view
    ADBannerView *bannerView = [[ADBannerView alloc] initWithFrame:frame];
    // Set the delegate to self, so that we are notified of ad responses.
    bannerView.delegate = self;
    // Set the autoresizing mask so that the banner is pinned to the bottom
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    // Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set.
	
	
#if __IPHONE_4_0 == __IPHONE_OS_VERSION_MAX_ALLOWED
	bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier480x32, ADBannerContentSizeIdentifier320x50, nil];
	
#endif
	
#if __IPHONE_4_0  <= __IPHONE_OS_VERSION_MAX_ALLOWED
	bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
	
#endif
	

	
    
    // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:bannerView];
    self.banner = bannerView;
    [bannerView release];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{

    CGFloat animationDuration = animated ? 0.2 : 0.0;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
		
		#if __IPHONE_4_0 == __IPHONE_OS_VERSION_MAX_ALLOWED
			banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
		#endif
		
		#if __IPHONE_4_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
			banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		#endif
		
        bannerHeight = 50.0;
    }
    else
    {
		
		#if __IPHONE_4_0 == __IPHONE_OS_VERSION_MAX_ALLOWED
			banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		#endif
		
		#if __IPHONE_4_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
			banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		#endif
		
		
		bannerHeight = 32.0;
    }
    
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(banner.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
		bannerOrigin.y -= bannerHeight;
    }
    else
    {
		bannerOrigin.y += bannerHeight;
    }
    

	
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.contentView.frame = contentFrame;
                         [self.contentView layoutIfNeeded];
						 banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, banner.frame.size.width, banner.frame.size.height);

                     }];
    TISwipeableTableView *tv = (TISwipeableTableView*)self.theTableView;
    [tv hideVisibleBackView:YES];
    [tv reloadData];
}



#pragma mark ADBannerViewDelegate methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

@end

/////////********/////////////********/////////********/////////////********/////////********/////////////********




