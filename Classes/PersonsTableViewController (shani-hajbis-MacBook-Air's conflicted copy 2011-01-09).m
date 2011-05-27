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
#import "PersonTableViewCell.h"
#import "HiByeAppDelegate.h"
#import "ArchivedPersonView.h"
#import "QuickAddViewController.h"
#import "AppSettings.h"
#import <QuartzCore/QuartzCore.h>
@implementation PersonsTableViewController
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize pickPersonPicker;
@synthesize newPersonPicker;
@synthesize theTableView;
@synthesize dataSource;
@synthesize fetchedResultsController;
@synthesize addingManagedObjectContext;
@synthesize segmentedControl;

@synthesize pop;
@synthesize myToolbar;
@synthesize banner;
@synthesize contentView;

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
		self.dataSource = theDataSource;
		self.title = [dataSource name];
		self.tabBarItem.image = [dataSource tabBarImage];
		self.navigationItem.title=[dataSource navigationBarName];
		UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
		temporaryBarButtonItem.title=@"Back";
		self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		[temporaryBarButtonItem release];
		isIpad = [dataSource isIpad];
		isArchive=NO;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contectsaved)
													 name:NSManagedObjectContextDidSaveNotification
												   object:[dataSource currentManagedObjectContext]];
		
	}
	return self;
}

-(void)contectsaved{
	
	//[self.theTableView reloadData];	
}

- (void)dealloc {
	banner.delegate = nil;
    [banner release]; banner = nil; 
	[searchDisplayController release];
	[searchBar release];
	[theTableView release];
    [addingManagedObjectContext release];
    [fetchedResultsController release];
	[dataSource release];
    [newPersonPicker release];
    [pickPersonPicker release];
	[dataSource release];
	[segmentedControl release];
	[pop release];
	[super dealloc];
}

#pragma mark -
#pragma mark load views Method

- (void)loadView {
	
	///////////*init the main view*//////////
	UIView *viewController = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	viewController.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.view = viewController;
	[viewController release];
	
	///////*init the content view that holds the tool bat and the table view*///////
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	contentView.backgroundColor = [UIColor yellowColor];
	[self.view addSubview:self.contentView];
	

	///////*init the  table view*///////
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 410) style:[dataSource tableViewStyle]];
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	tableView.showsVerticalScrollIndicator =YES;
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.sectionIndexMinimumDisplayRowCount=7;
	self.theTableView = tableView;
	[self.contentView addSubview:self.theTableView];
	[tableView release];
	
	///////*init the  searchBar*///////
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate=self;
    searchBar.delegate =self;
	self.theTableView.tableHeaderView = searchBar;

	if (![dataSource isArchive]) {
	///////*init the  segmentedControl*///////
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"All",@""),NSLocalizedString(@"Expired",@"") , nil]];
	segmentedControl.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	segmentedControl.frame = CGRectMake
	((self.view.bounds.size.width-segmentedControl.frame.size.width)/2 ,
	(self.navigationController.navigationBar.frame.size.height -30)/2 ,segmentedControl.frame.size.width,30);
	[segmentedControl addTarget:self
					action:@selector(ReloadTableViewWithNewPerdicate:)
                   forControlEvents:UIControlEventValueChanged];
	segmentedControl.selectedSegmentIndex=0;
	[self.navigationController.navigationBar addSubview:segmentedControl];
	[segmentedControl release];
	}
		
	///////*init the  tollBar*///////	
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, (self.contentView.frame.origin.y +self.contentView.frame.size.height )-self.myToolbar.frame.size.height, self.contentView.frame.size.width,self.myToolbar.frame.size.height)];
	toolBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight);
	[toolBar sizeToFit];
	self.myToolbar = toolBar;
	[toolBar release];
		
	///////*init the  toolbat buttons*///////	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimerdPersonActionSheet)];
	UIBarButtonItem *fastAddButton = [[UIBarButtonItem alloc] initWithTitle:@"Quick" style:UIBarButtonItemStyleBordered target:self action:@selector(quickAddTimerdPerson)];
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(enterSettings)];
	UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithTitle:@"Archive" style:UIBarButtonItemStyleBordered target:self action:@selector(showArchive)];
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	NSMutableArray *items = [NSMutableArray arrayWithObjects:addButton,flexItem,fastAddButton ,flexItem,settingsButton,flexItem,archiveButton, nil];
		
	[addButton release];
	[fastAddButton release];
	[settingsButton release];
	[flexItem release];
	[self.myToolbar setItems:items animated:NO];
	[self.contentView addSubview:self.myToolbar];
	
	///////*create the banner for ads if supported*///////	
	if(banner == nil)
    {
        [self createADBannerView];
    }
    [self layoutForCurrentOrientation:NO];
		  
}
#pragma mark -
#pragma mark UIView Methods

-(void)viewWillAppear:(BOOL)animated{
    self.segmentedControl.hidden=NO;
    [super viewWillAppear:YES];
}

- (void)viewWillAppear {
	[super viewWillAppear:YES];
	[self.theTableView reloadData];
	[self layoutForCurrentOrientation:YES];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.contentView = nil;
    banner.delegate = nil;
    self.banner = nil;
	pickPersonPicker = nil;
	newPersonPicker = nil;
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
/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
   
        [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navBg.png"]]];
   
    return headerView;
}
*/
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
    PersonTableViewCell *cell = (PersonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PersonTableViewCell"];
    if (cell == nil) {
        cell = [[[PersonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonTableViewCell"]autorelease];
	
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    
	return cell;
}

- (void)configureCell:(PersonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    if([fetchedResultsController objectAtIndexPath:indexPath]!=nil){
	Person *person = (Person *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.person = person;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchedResultsController sectionForSectionIndexTitle:[title capitalizedString] atIndex:index];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
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
		
		// get the element that is represented by the selected row.
		Person *person = (Person *)[fetchedResultsController objectAtIndexPath:newIndexPath];
		
		// create an AtomicElementViewController. This controller will display the full size tile for the element
		PersonViewController *personController = [[PersonViewController alloc] init];
		
		// set the element for the controller
		personController.newPerson =person;
		personController.delegate=self;
		personController.personIndexPath = newIndexPath;
		personController.isIpad =isIpad;	
		personController.managedObjectContext = [dataSource currentManagedObjectContext];
		personController.hidesBottomBarWhenPushed = YES;
		personController.appSettings = [dataSource appSettings];
		segmentedControl.hidden = YES;
		
		if (person.state==[NSNumber numberWithInt:0]) {
			personController.isShortPersonView = YES;
		}
		
		[self.navigationController pushViewController:personController animated:YES];
		[personController release];
		[person release];
		
    }else{
        
        // deselect the new row using animation
        [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
        
        // get the element that is represented by the selected row.
      //  Person *person = (Person *)[fetchedResultsController objectAtIndexPath:newIndexPath];
        
        // create an AtomicElementViewController. This controller will display the full size tile for the element
        //ArchivedPersonViewController *personController = [[ArchivedPersonViewController alloc] init];
       // personController.person = person;
        personController.delegate = self;
		//personController.isIpad=isIpad;
        personController.managedObjectContext = [dataSource currentManagedObjectContext];
        personController.appSettings = [dataSource appSettings]
        personController.hiByeGroupId=[dataSource hibyeGroupId];
		
		UIViewController *vc = [[UIViewController alloc] init];
		vc.view.backgroundColor = [UIColor redColor];
		ArchivedPersonView *av = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
		[vc setView:av];
		[vc loadView];
        [self.navigationController pushViewController:vc animated:YES];
        [av release];
        [vc release];
		
    }
    
}


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

#pragma mark -
#pragma mark Adding person Methods
#pragma mark add person with build in controller
///////*add person with build in controller*///////
-(void) addTimerdPersonActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add new HiBye contact",@"")
																delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
																destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add New Contact",@""),
																NSLocalizedString(@"Select Existing Contact",@""),nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet setTag:0];
	[actionSheet showFromToolbar:self.myToolbar];
	[actionSheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == kNew_Existing_AS){
		
		if(buttonIndex==kNew_Person){
			[self showNewPersonViewController];
		}
		
		if(buttonIndex==kExist_Person){
			[self showPeoplePickerController];
		}
		
	}
	
	if(actionSheet.tag == kCustum_Default_AS){
		
		if(buttonIndex==kCustom_Timer){
          
				CFErrorRef error = NULL; 

				ABAddressBookRef addressbook = ABAddressBookCreate();
				ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressbook, TempREcordId);
	
				Person *person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" 
																					inManagedObjectContext:[dataSource currentManagedObjectContext]];

				person.ID =[NSNumber numberWithInt:TempREcordId];
				person.category=NSLocalizedString(@"No Category",@"");	
				person.category_en=@"No Category";
				person.note = NSLocalizedString(@"No note",@"");

			
				NSString *name =(NSString*) ABRecordCopyCompositeName(ref);
				NSString *firstName = (NSString*) ABRecordCopyValue(ref, kABPersonFirstNameProperty);
				NSString *lastName =(NSString*) ABRecordCopyValue(ref, kABPersonLastNameProperty);

				person.compName=name;
				person.firstName=firstName;
				person.lastName=lastName;
				person.firstLetter=[firstName substringToIndex:1];
			
				[name release];
				[firstName release];
				[lastName release];
		
			
				[GlobalFunctions setCategoryImageToPerson:@"No Category_B" Ref:ref];
				NSMutableDictionary *dic =  [GlobalFunctions setDefaultTimerSettingsToPerson:ref settings:[dataSource appSettings]];
				person.ddate=[dic objectForKey:@"deletionDate"];
				person.ddate_label =[dic objectForKey:@"dateLabel"];
				person.state =[dic objectForKey:@"state"];
		
				ABAddressBookAddRecord(addressbook, ref, &error);
				ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressbook, [dataSource hibyeGroupId]);
				BOOL didAdd = ABGroupAddMember(HiByeGroup,ref,nil);
				NSLog(@"Did didAdd = %d",didAdd);
				BOOL didSave = ABAddressBookSave(addressbook, &error);
				NSLog(@"Did Save = %d",didSave);
				
				//CFRelease(ref);
				CFRelease(addressbook);

			}
		
		
		if(buttonIndex==kDefault_Timer){
			[self addCustomValuesAfterSelection];
		}
	}
   
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark adding new person or selecting existing person
///////*adding new person or selecting existing person*///////
-(void) ChosseBetweenDefaultOrCutomeTimer {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Set Contact Timer",@"")
															 delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
											   destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Use Default Timer",@""),
								  NSLocalizedString(@"Set Custom Timer",@""),nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet setTag:1];
	[actionSheet showFromToolbar:self.myToolbar];
	[actionSheet release];
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
	[self presentModalViewController:pickerView animated:YES];
	[pickerView release];	
}



#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)personRef {	
	
	TempREcordId = ABRecordGetRecordID(personRef);
    
	BOOL hasDeleteDate = [GlobalFunctions CheckToSeeIfInHiBye:TempREcordId];
    
	if (hasDeleteDate) {
        [GlobalFunctions alert:NSLocalizedString(@"Selected contact allready exist in HiBye", @"") ];
	}else{
        [self dismissModalViewControllerAnimated:YES];
        [self ChosseBetweenDefaultOrCutomeTimer];
        
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

#pragma mark showNewPersonViewController methods
-(void)showNewPersonViewController {
    newPersonPicker = [[ABNewPersonViewController alloc] init];
	newPersonPicker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:newPersonPicker];
	
	[newPersonPicker release];
	
	if (!isIpad) {
		[self presentModalViewController:navigation animated:YES];
	}else {
		UIPopoverController *localPop = [[UIPopoverController alloc] initWithContentViewController:navigation];
	self.pop = localPop;
		[localPop release];
		[pop presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	[navigation release];
}



#pragma mark add person with quick  controller
///////*adding person with quick  controller*///////
-(void) quickAddTimerdPerson {
	QuickAddViewController *controller = [[QuickAddViewController alloc]init];
	controller.delegate=self;	
	controller.isIpad=isIpad;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
	
	if (!isIpad) {
		[self presentModalViewController:navigation animated:YES];
	}else {
		UIPopoverController *localPop = [[UIPopoverController alloc] initWithContentViewController:navigation];
		self.pop =localPop;
		[localPop release];
		[pop presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
	
	[controller release];
	[navigation release];	
}



#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)personRef {
	if(personRef){
		TempREcordId = [GlobalFunctions getIDFromRef:personRef];
		[self ChosseBetweenDefaultOrCutomeTimer];
	}
	
	if(!isIpad){
		[self dismissModalViewControllerAnimated:YES];
	}else{
		//[pop dismissPopoverAnimated:YES];
	}	
}





#pragma mark -
#pragma mark Adding a person

- (void)addCustomValuesAfterSelection {
  
	
	 Person *person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:[dataSource currentManagedObjectContext]];
	
	PersonViewController *controller = [[PersonViewController alloc]init];
	
	controller.delegate=self;
	controller.hidesBottomBarWhenPushed = YES;
	controller.isCostumTimer=YES;
	controller.isShortPersonView = NO;
	controller.title =NSLocalizedString(@"Set new Timer",@"");
	
	
	person.ID = [NSNumber numberWithInt:TempREcordId ];
	controller.newPerson=person;
	controller.appSettings = [dataSource appSettings];
	controller.hiByeGroupId = [dataSource hibyeGroupId];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, TempREcordId);
    NSString *name = (NSString *) ABRecordCopyCompositeName(ref);
	NSString *firstName = (NSString*) ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    NSString *lastName = (NSString*) ABRecordCopyValue(ref, kABPersonFirstNameProperty);

	controller.newPerson.firstName=name;
	controller.newPerson.lastName=firstName;
	controller.newPerson.compName =lastName;
	
	[name release];
	[firstName release];
	[lastName release];

    CFRelease(addressBook);
	
	controller.newPerson.firstLetter = [controller.newPerson.firstName substringToIndex:1];
	controller.newPerson.category=NSLocalizedString(@"No Category",@"");
	controller.newPerson.category_en=@"No Category";
	controller.newPerson.note = NSLocalizedString(@"No note",@"");
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];	
	[controller release];
	


		[self dismissModalViewControllerAnimated:YES];

		[self presentModalViewController:navigation animated:YES];

	[navigation release];
	
}



#pragma mark -
#pragma mark Delegation methods
- (void)personViewController:(PersonViewController *)controller didFinishWithAdd:(BOOL)save person:(Person*)sentPerson; {
	if (save) {
		[[fetchedResultsController managedObjectContext] save:nil];
	}else {
		[GlobalFunctions deletePersonFromAB:[sentPerson.ID intValue]];
		[[fetchedResultsController managedObjectContext] deleteObject:sentPerson];
		[[fetchedResultsController managedObjectContext] save:nil];
	}

	[self dismissModalViewControllerAnimated:YES];


}

//called when an action is done on a person and he should be deleted from addressbook
- (void)personViewController:(PersonViewController *)controller  didFinishWithChange:(BOOL)save person:(Person*)personToDelete withAction:(NSInteger)actionIndex {
    
    if (save) {
        switch(actionIndex){
            case 0:
                [GlobalFunctions deletePersonFromAB:[personToDelete.ID intValue]];
                [[fetchedResultsController managedObjectContext] deleteObject:personToDelete];
				[[fetchedResultsController managedObjectContext] save:nil];
                break;

            case 1:
                [GlobalFunctions sendPersonToArchive:personToDelete inManagedObjectContext:[dataSource currentManagedObjectContext]];
                [GlobalFunctions deletePersonFromAB:[personToDelete.ID intValue]];
			
                break;
                
            case 2:
                [GlobalFunctions removePersonFromHiBye:[personToDelete.ID intValue] HiByeGroupId:[dataSource hibyeGroupId]];
                [[fetchedResultsController managedObjectContext] deleteObject:personToDelete];
				[[fetchedResultsController managedObjectContext] save:nil];
                break;
                
        }
	}
            [self.navigationController popToRootViewControllerAnimated:YES];
}

//called when a person is restored back from time out list
- (void)personViewController:(PersonViewController *)controller didLengthPersonTimer:(BOOL)length person:(Person*)personToRepaste personIndex:(NSIndexPath*)indexPath {
    if (length) {
        [self configureCell:(PersonTableViewCell *)[self.theTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        [dataSource saveContext];
		}
	[self.navigationController popToRootViewControllerAnimated:YES];  
}

- (void)archivedPersonDeatails:(ArchivedPersonDeatails *)controller didFinishWithRestore:(BOOL)restore {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
	   
}

- (void)quickAddViewController:(QuickAddViewController *)controller didFinishWithSave:(BOOL)save withDictionery:(NSDictionary*)dic {
	
	if (save) {
		
		
		CFErrorRef error = NULL; 
		
		
		ABAddressBookRef addressbook = ABAddressBookCreate();
		ABRecordRef ref = ABPersonCreate();
		NSInteger recordID = [GlobalFunctions getIDFromRef:ref];

		
		NSString *name = [dic objectForKey:@"compName"];
		NSString *phoneNumber = [dic objectForKey:@"phoneNumber"];
		NSString *rest = [dic objectForKey:@"rest"];
			
		
		Person *person = (Person*)[NSEntityDescription insertNewObjectForEntityForName:@"Person" 
																			inManagedObjectContext:[dataSource currentManagedObjectContext]];
		person.ID =[NSNumber numberWithInt:recordID];
	
		person.category=NSLocalizedString(@"No Category",@"");
		person.category_en=@"No Category";
		
		if (name!=nil) {
			person.compName=name;
			ABRecordSetValue(ref, kABPersonCompositeNameFormatFirstNameFirst, name, &error);
			person.firstLetter=[name substringToIndex:1];
			
		}else if (phoneNumber!=nil) {
			person.compName = phoneNumber;
			person.firstLetter=@"#";
		}
		
		if (phoneNumber!=nil) {
			ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMultiValueAddValueAndLabel(multiPhone, phoneNumber,kABPersonPhoneMainLabel, NULL);
			ABRecordSetValue(ref, kABPersonPhoneProperty, multiPhone,nil);
			CFRelease(multiPhone);
		}

		 
		
		if (rest!=nil) {
			
			NSRegularExpression *regexMail = [NSRegularExpression regularExpressionWithPattern:@"..*[@]..*[.]..*" options:NSRegularExpressionCaseInsensitive error:nil];
			NSRegularExpression *regexUrl = [NSRegularExpression regularExpressionWithPattern:@"..*[.]..*[.]..*" options:NSRegularExpressionCaseInsensitive error:nil];
			NSTextCheckingResult *match = [regexMail firstMatchInString:rest
															options:NSRegularExpressionCaseInsensitive
															  range:NSMakeRange(0, [rest length])];
			NSTextCheckingResult *match2 = [regexUrl firstMatchInString:rest
																options:NSRegularExpressionCaseInsensitive
																  range:NSMakeRange(0, [rest length])];
			if (match) {
				NSLog(@"is mail");
				ABMutableMultiValueRef multiMail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				ABMultiValueAddValueAndLabel(multiMail, rest,kABWorkLabel, NULL);
				ABRecordSetValue(ref, kABPersonEmailProperty, multiMail,nil);
				CFRelease(multiMail);
			}else if (match2) {
			
				
				if (match2) {
					NSLog(@"is URL");
					ABMutableMultiValueRef multiUrl = ABMultiValueCreateMutable(kABMultiStringPropertyType);
					ABMultiValueAddValueAndLabel(multiUrl, rest,kABPersonHomePageLabel, NULL);
					ABRecordSetValue(ref, kABPersonURLProperty, multiUrl,nil);
					CFRelease(multiUrl);
				}
			}else{
				NSLog(@"is Note");
				ABRecordSetValue(ref, kABPersonNoteProperty, rest, &error);
				person.note = rest;
			}

		
		}else {
			NSLog(@"is Null");
			person.note = NSLocalizedString(@"No note",@"");

		}

		
		//set default image;
		[GlobalFunctions setCategoryImageToPerson:@"No Category_B" Ref:ref];
		NSMutableDictionary *dic =  [GlobalFunctions setDefaultTimerSettingsToPerson:ref settings:[dataSource appSettings]];
		person.ddate=[dic objectForKey:@"deletionDate"];
		person.ddate_label = [dic objectForKey:@"dateLabel"];
		person.state = [dic objectForKey:@"state"];
		
	
		
		ABAddressBookAddRecord(addressbook, ref, &error);
		ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressbook, [dataSource hibyeGroupId]);
		BOOL didAdd = ABGroupAddMember(HiByeGroup,ref,nil);
		NSLog(@"Did didAdd = %d",didAdd);
		CFRelease(ref);
		BOOL didSave = ABAddressBookSave(addressbook, &error);
		NSLog(@"Did Save = %d",didSave);
		CFRelease(addressbook);
		[dataSource saveContext];
	}
	

	if(!isIpad){
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}else{
		[pop dismissPopoverAnimated:YES];
	}

}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:[dataSource currentManagedObjectContext]];
        [fetchRequest setEntity:entity];
  
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"compName" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        // Edit the sort key as appropriate.
	
	
	NSString *perdicateString;
	
	if (!isArchive) {
		
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			 perdicateString = @"state>-1";
			break;
		case 1:
			 perdicateString = @"state==0";
			break;
		case 2:
			 perdicateString = @"state==0";
			break;
		case 3:
			 perdicateString = @"state<0";
			break;
		default:
			break;
	}
	}else {
		perdicateString = @"state<0";
	}

	/*
		if (theTableView == self.searchDisplayController.searchResultsTableView){
			perdicateString = @"state==0";
		
		}else {
			if (segmentedControl.selectedSegmentIndex ==0) {
			perdicateString= [dataSource perdicateForTableView];

		}else {
			 perdicateString = @"state==0";
		}

		}

	*/	
    
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
			[self configureCell:(PersonTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	
	
	if (!isIpad) {
		[self presentModalViewController:navigation animated:YES];
		[navigation release];

	}else {
		UIPopoverController *localPop = [[UIPopoverController alloc] initWithContentViewController:navigation];
		[navigation release];
		self.pop = localPop;
		[localPop release];
		
		//[pop setPopoverContentSize:CGSizeMake(400, 700)];
		[pop presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	}

	//[navigation release];
		
}

//called when a settings are closed

- (void)settings:(Settings *)controller didFinishWithSave:(BOOL)save{
		[pop dismissPopoverAnimated:YES];
   
}

#pragma mark -
#pragma mark Archive 
-(void)showArchive{

/*
		id<PersonsDataSource> archivedataSource = [[ArchivedPersonSortedByFirstNameDataSource alloc] init];
		
		PersonsTableViewController *theViewController;	
		theViewController = [[PersonsTableViewController alloc] initWithDataSource:archivedataSource];
		// create the navigation controller with the view controller
		UINavigationController *theNavigationController;
		theNavigationController = [[UINavigationController alloc] initWithRootViewController:theViewController];
		// before we return we can release the dataSource (it is now managed by the ElementsTableViewController instance
		[archivedataSource release];
		
		// and we can release the viewController because it is managed by the navigation controller
		
	*/
	CATransition *transition = [CATransition animation];
	transition.duration = 1.3;
	[transition setType: @"flip"];
	[transition setSubtype:@"fromRight"];
	
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[transition setFillMode:@"extended"];
	[[self.view layer] addAnimation:transition forKey:nil];
	if (!isArchive) {
		isArchive=YES;
		
		[UIView animateWithDuration:2
						 animations:^{
							 self.segmentedControl.alpha=0;
							 self.navigationController.navigationBar.tintColor = [UIColor brownColor];
						 }];
		
	}else {
		isArchive=NO;
		[UIView animateWithDuration:2
						 animations:^{
							 self.segmentedControl.alpha=1;
							 self.navigationController.navigationBar.tintColor = [UIColor blueColor];
						 }];

	}

	
	[NSFetchedResultsController deleteCacheWithName:@"Root"];

	[self.fetchedResultsController performFetch:nil];
	[self.theTableView reloadData];
	//[self.view addSubview: theViewController.view];
	[CATransaction commit];
	
		//[theViewController release];
		//[theNavigationController release];
		
	
	
	
}

#pragma mark -
#pragma mark Content Filtering
/*
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSLog(@"sfdhgsdfh");
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state==2"];
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
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state!=%i",sc.selectedSegmentIndex];
	[fetchedResultsController.fetchRequest setPredicate:predicate];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }  
	[self.theTableView reloadData];
}



#pragma mark -
#pragma mark ADBannerView Methods

-(void)createADBannerView
{

    NSString *contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
    
    // Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
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
    bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierLandscape, ADBannerContentSizeIdentifierPortrait, nil];
    
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
	CGFloat toolBarHeight = 0.0;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        bannerHeight = 32.0;
		toolBarHeight = 30.0;
    }
    else
    {
        banner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        bannerHeight = 50.0;
		toolBarHeight = 44.0;
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
						 self.myToolbar.frame = CGRectMake(0, (self.contentView.frame.origin.y +self.contentView.frame.size.height )-self.myToolbar.frame.size.height, self.contentView.frame.size.width,self.myToolbar.frame.size.height);
						 self.theTableView.frame = CGRectMake(0,0, self.contentView.frame.size.width,
															  self.contentView.frame.size.height-self.myToolbar.frame.size.height);
                     }];
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




