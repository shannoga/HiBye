//
//  PersonViewController.m
//  HiBye
//
//  Created by shani hajbi on 9/14/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"
#import "DatesFunctions.h"
#import "GlobalFunctions.h"
#import "HiByeAppDelegate.h"
#import "TableViewDesignFunctions.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "TimerHeaderView.h"
@implementation PersonViewController
@synthesize person;
@synthesize delegate;
@synthesize actionSheetTitelsArray;
@synthesize navigationBar;
@synthesize isIpad;
@synthesize myToolbar;
@synthesize theTableView;
@synthesize undoManager;
@synthesize banner;
@synthesize contentView;

#define D_DAY	86400
#define D_WEEK	604800
#define D_MONTH 2419200

#pragma mark -
#pragma mark init


- (id)init {
	if (self = [super init]) {
		didSaveChanges = NO;
		justShowed=YES;
		
		//**stes a dictionery of titels for the toolbar buttons**//
		self.actionSheetTitelsArray = [NSArray arrayWithObjects:
									   [NSDictionary dictionaryWithObjectsAndKeys:
										NSLocalizedString(@"Delete Selected Contact",@""), @"asTitle",
										NSLocalizedString(@"Delete",@""), @"asDestructive",
										[NSNumber numberWithInt:0],@"asTag",
										nil],
									   [NSDictionary dictionaryWithObjectsAndKeys:
										NSLocalizedString(@"Send contact to Archive",@""), @"asTitle",
										NSLocalizedString(@"Send To Archive",@""), @"asDestructive",
										[NSNumber numberWithInt:1],@"asTag",
										nil],
									   [NSDictionary dictionaryWithObjectsAndKeys:
										NSLocalizedString(@"Save Contact Permanently",@""), @"asTitle",
										NSLocalizedString(@"Save permanently",@""), @"asDestructive",
										[NSNumber numberWithInt:2],@"asTag",
										nil],
									   nil];
		
	}
	return self;
}



#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
	
	//**create defaults instance**//	
	defaults = [NSUserDefaults standardUserDefaults];
	
	//**prevent animating the table view as it loads**//	
	
	
	//**get the categories list from the user preferences**//
	categories = [[NSMutableArray alloc] initWithArray:[defaults  arrayForKey:@"activeCategories"]];
	//**adde the custum categories list from the user preferences**//
	//[categories addObjectsFromArray:[defaults arrayForKey:@"customCategories"]];
	//[categories removeLastObject];
	
	
	
	
	//**stes the save button**//
	UIBarButtonItem  *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.rightBarButtonItem.enabled=NO;
	
	///////////*init the main view*//////////
	UIView *viewController = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	viewController.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin);
	viewController.autoresizesSubviews =YES;
	viewController.backgroundColor = [UIColor whiteColor];
	self.view = viewController;
	[viewController release];
	
	///////*init the content view that holds the tool bar and the table view*///////
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 425)];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	contentView.autoresizesSubviews =YES;
	contentView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.contentView];
	
	
    self.theTableView =  [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.contentView.frame.size.width,self.contentView.frame.size.height-49)
												   style:UITableViewStyleGrouped];
    [self.theTableView setBackgroundColor:[UIColor lightGrayColor]];
	   self.theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin);

	[self.contentView addSubview:self.theTableView ];
	
	///////////////////////////////////////////////
	//*********TABLE VIEW MODEL*****************//
	//////////////////////////////////////////////
	
	//**init the Table view model**//	
	tableModel = [[SCTableViewModel alloc] initWithTableView:self.theTableView withViewController:self];
	
	//**sets the header section of the table view**//
	SCTableViewSection *HedearSection = [SCTableViewSection section];
	HedearCell = [SCTableViewCell cell];
	HedearCell.textLabel.text = person.compName;
	HedearCell.detailTextLabel.text = NSLocalizedString(person.category,@"");
	HedearCell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_l.png",person.category_en]];
	[TableViewDesignFunctions setTransparentBgToCell:HedearCell];
	[tableModel addSection:HedearSection];
	[HedearSection addCell:HedearCell];
	

		
	//**sets the timer section of the table view**//
	SCTableViewSection *timerSection = [SCTableViewSection section];
	
	//**create the timer header view with the "DaysLeft" Label**//
	TimerHeaderView *localTimerHeaderView  = [[TimerHeaderView alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
	[localTimerHeaderView setTime:[defaults objectForKey:@"daysLeft"]];
	timerHeaderView = localTimerHeaderView;
	timerSection.headerView = timerHeaderView;
	[localTimerHeaderView release];
	
	//**create the Slider cell for setting the timer**//
	NSDictionary *personStatus =[NSDictionary dictionaryWithDictionary:[DatesFunctions returnPersonStatusDictionary:[person.ID intValue]]]; 
	
	SCSliderCell *sliderCell = [SCSliderCell cellWithText:nil withBoundKey:@"sl" withSliderValue:[personStatus objectForKey:@"daysLeft"]];
	sliderCell.slider.maximumValue=[defaults floatForKey:@"maxDaysLeft"];
	sliderCell.slider.minimumValue=[defaults floatForKey:@"minDaysLeft"];
	sliderCell.slider.continuous=YES;
	sliderCell.slider.minimumValueImage = [UIImage imageNamed:@"emptyTimer.png"];
	sliderCell.slider.maximumValueImage = [UIImage imageNamed:@"fullTimer.png"];
	
	[tableModel addSection:timerSection];
	[timerSection addCell:sliderCell];
    
	
	//**create the SCSegmentedCell cell for setting the delition policy**//
	NSNumber *deletionPolicy = person.deletion_policy;
	SCSegmentedCell *deletePolicyCell = [SCSegmentedCell cellWithText:nil withBoundKey:@"deletionPolicy" withSelectedSegmentIndexValue:deletionPolicy withSegmentTitlesArray:[NSArray arrayWithObjects:@"Alert",@"Archive",@"Delete",nil]];
	[timerSection addCell:deletePolicyCell];
	
	
	//**only is the person is active create the SCTableViewSection to change the category**//
    if(person.state!=0){
		//categories & note settings cells
		SCTableViewSection *categoriesSection = [SCTableViewSection sectionWithHeaderTitle:nil];		
		NSString *categoryCellTitle;
		NSString *preCategory;
		NSNumber *preSelectedIndex;
        categoryCellTitle=  NSLocalizedString(@"Change category",@"");
        preCategory = NSLocalizedString(person.category_en,@"");
        preSelectedIndex = [NSNumber numberWithUnsignedInteger:[categories indexOfObject:preCategory]];
		
		SCSelectionCell *presetCategoriesCell = [SCSelectionCell cellWithText:categoryCellTitle withBoundKey:@"category" withSelectedIndexValue:preSelectedIndex withItems:categories];
		presetCategoriesCell.detailTableViewStyle = UITableViewStyleGrouped;
		presetCategoriesCell.label.text = preCategory;
		NSMutableArray * images = [[NSMutableArray alloc] init];
		
		for(int i=0;i<[categories count];i++){
			imageView=nil;
			imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[categories objectAtIndex:i]]];
			[images addObject:imageView];
			[imageView release];
		}
		presetCategoriesCell.detailCellsImageViews =images;
		presetCategoriesCell.tag=0;
		[tableModel addSection:categoriesSection];
		[categoriesSection addCell:presetCategoriesCell];

		//**only is the person is active create the SCTableViewSection to change the category**//
		SCTextViewCell *restCell = [SCTextViewCell  cellWithText:nil withBoundKey:@"rest" withTextViewTextValue:nil];
		///restCell.textView.inputAccessoryView =toolbar;
		restCell.textView.keyboardType = UIKeyboardTypePhonePad;
		restCell.detailTextLabel.numberOfLines=2;
		restCell.detailTextLabel.font=[UIFont systemFontOfSize:16];
		restCell.detailTextLabel.textColor=[UIColor lightGrayColor];
		restCell.detailTextLabel.text =@"Phone Numbers, Email Adressed and URL's";
		
		[categoriesSection addCell:restCell];
		
		//**only is the person is active create the SCSwitchCell to change the public/private attribute**//

		SCTableViewSection *privateSection = [SCTableViewSection sectionWithHeaderTitle:@"Set contact as private"];		

		[privateSection addCell:[SCSwitchCell cellWithText:@"Make Private" withBoundKey:@"private" withSwitchOnValue:person.isPrivate]];
		[tableModel addSection:privateSection];
	}
    
	
	///////*init the  tollBar*///////	
	
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,378, self.contentView.frame.size.width,49)];
	[toolBar sizeToFit];
	self.myToolbar = toolBar;
	[toolBar release];
	
	///////*init the  toolbat buttons*///////	
	myToolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight);
	
	
	CGRect rect = CGRectMake(0, 0, 85, 33); 
	 UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage  *btnImage = [UIImage imageNamed:@"Button-(Red).png"];
	[button setImage:btnImage forState:UIControlStateNormal];
	button.frame = rect;
	button.titleLabel.text = NSLocalizedString(@"Delete\nPermanently",@"");
	[button addTarget:self action:@selector(setActionSheet:) forControlEvents:(UIControlEventTouchUpInside)];
	button.tag = 0;
	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	btnImage = [UIImage imageNamed:@"Button-(Orange).png"];
	[button setImage:btnImage forState:UIControlStateNormal];
	button.frame = rect;
	button.titleLabel.text = NSLocalizedString(@"Save\nPermanently",@""); 
	[button addTarget:self action:@selector(setActionSheet:) forControlEvents:(UIControlEventTouchUpInside)];
	button.tag = 1;
	UIBarButtonItem *archiveButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	btnImage = [UIImage imageNamed:@"Button-(Green).png"];
	[button setImage:btnImage forState:UIControlStateNormal];
	button.frame = rect;
	button.titleLabel.text = NSLocalizedString(@"Send to\n Archive",@""); 
	[button addTarget:self action:@selector(setActionSheet:) forControlEvents:(UIControlEventTouchUpInside)];
	button.tag = 2;
	saveButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//Add buttons to the array
	NSMutableArray *items = [NSMutableArray arrayWithObjects:deleteButton,flexItem,saveButton ,flexItem,archiveButton, nil];
	
	//release buttons
	[archiveButton release];
	[saveButton release];
	[deleteButton release];
	[flexItem release];
	
	//add array of buttons to toolbar
	[myToolbar setItems:items animated:NO];
	[self.contentView addSubview:myToolbar];
	
	///////*create the banner for ads if supported*///////	
	
	if(banner == nil)
    {
        [self createADBannerView];
    }
    [self layoutForCurrentOrientation:NO];
	
	
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutForCurrentOrientation:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableViewModel:(SCTableViewModel *) tableViewModel willConfigureCell:(SCTableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {

  
}  

- (void)tableViewModel:(SCTableViewModel *) tableViewModel willDisplayCell:(SCTableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Futura" size:14];
    cell.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]];
    //cell.imageView.image = [UIImage imageNamed:[categories objectAtIndex:indexPath.row]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor =[UIColor clearColor];
}

-(void)tableViewModel:(SCTableViewModel *)tableViewModel didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

}



#pragma mark -
#pragma mark action sheets


-(void)setActionSheet:(id)sender {
	UIButton *btnSender=(UIButton*) sender;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[actionSheetTitelsArray objectAtIndex:btnSender.tag]objectForKey:@"AStitle"]
														delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
														destructiveButtonTitle:[[actionSheetTitelsArray objectAtIndex:btnSender.tag]objectForKey:@"asDestructive"] otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet setTag:btnSender.tag];
	
	
	[actionSheet showFromToolbar:self.myToolbar];
		 
		 
	[actionSheet release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(buttonIndex==0){ 
		[delegate personViewController:self didFinishWithChange:YES person:person withAction:actionSheet.tag];
	}    
}



#pragma mark -
#pragma mark Undo support

- (void)setUpUndoManager {
	/*
	 If the book's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
	 The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
	 */
	if (person.managedObjectContext.undoManager == nil) {
		
		NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
		[anUndoManager setLevelsOfUndo:3];
		self.undoManager = anUndoManager;
		[anUndoManager release];
		
		person.managedObjectContext.undoManager = undoManager;
	}
	
	// Register as an observer of the book's context's undo manager.
	NSUndoManager *personUndoManager = person.managedObjectContext.undoManager;
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:personUndoManager];
	[dnc addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:personUndoManager];
}


- (void)cleanUpUndoManager {
	
	// Remove self as an observer.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (person.managedObjectContext.undoManager == undoManager) {
		person.managedObjectContext.undoManager = nil;
		self.undoManager = nil;
	}		
}


- (NSUndoManager *)undoManager {
	return person.managedObjectContext.undoManager;
}


- (void)undoManagerDidUndo:(NSNotification *)notification {
	[self.theTableView reloadData];
	[self updateRightBarButtonItemState];
}


- (void)undoManagerDidRedo:(NSNotification *)notification {
	[self.theTableView reloadData];
	[self updateRightBarButtonItemState];
}

- (void)updateRightBarButtonItemState {
	// Conditionally enable the right bar button item -- it should only be enabled if the book is in a valid state for saving.
    self.navigationItem.rightBarButtonItem.enabled = [person validateForUpdate:NULL];
}

/*
 The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
 */
- (BOOL)canBecomeFirstResponder {
	return YES;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
	[person.managedObjectContext rollback];
	[super viewWillDisappear:animated];
	[self resignFirstResponder];
}



#pragma mark -
#pragma mark SCTableViewModelDelegate methods

- (void)tableViewModel:(SCTableViewModel *) tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *) indexPath
{
	
		NSString *newCategory;	
		NSNumber *deletionPolicy;
		
		// Set the action name for the undo operation.
		//[self setUpUndoManager];
		//undoManager = [[person managedObjectContext] undoManager];
		//[undoManager setActionName:person.compName];
		
		
	switch (indexPath.section) {
			NSDate *newDate;
		case 1:
			switch (indexPath.row) {
				case 0:
					[timerHeaderView setTime:[tableModel.modelKeyValues valueForKey:@"sl"]];
					//**save the date changes to the person**//
					 newDate = [DatesFunctions dateWithIntervalFromNow:[[tableModel.modelKeyValues valueForKey:@"sl"]intValue] factor:D_DAY];
					person.ddate = newDate;
					break;
			
				case 1:
					newDate = [DatesFunctions dateWithIntervalFromNow:[[tableModel.modelKeyValues valueForKey:@"sl"]intValue] factor:D_DAY];
					deletionPolicy = [tableModel.modelKeyValues valueForKey:@"deletionPolicy"];
					//**save the delitionpolicy changes to the person**//
					person.deletion_policy = deletionPolicy;
					person.state = [NSNumber numberWithInteger:[DatesFunctions returnDateState:newDate deletionPolicy:[deletionPolicy intValue]]];
					if ([deletionPolicy intValue]==2) {
						[GlobalFunctions alert:@"Contact will be deleted with out any alert and wont be archived"];
					}
				break;
	
				}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					newCategory= [categories objectAtIndex:[[tableModel.modelKeyValues valueForKey:@"category"]intValue]];
					NSString *nc=@"CustomCategory_l";
					HedearCell.detailTextLabel.text = NSLocalizedString(newCategory,@"");
					if ([categories containsObject:newCategory]) {
						nc=[NSString stringWithFormat:@"%@_l", newCategory];
					}
					NSString *imagefile = [[NSBundle mainBundle] pathForResource:nc ofType:@"png"];
					UIImage *ui = [[UIImage alloc] initWithContentsOfFile:imagefile];
					HedearCell.imageView.image = ui;
					[ui release];
					
					person.category = NSLocalizedString(newCategory,@"");
					person.category_en=newCategory;
					break;
			}		
			break;
		case 3:
			switch (indexPath.row) {
				case 0:
					person.isPrivate = [tableModel.modelKeyValues valueForKey:@"isPrivate"];
					break;
			}
			break;
	}
	

    self.navigationItem.rightBarButtonItem.enabled=YES;
	
}

#pragma mark -
#pragma mark Save and cancel operations

- (void)save:(id)sender {
	
	
	didSaveChanges = YES;
	//**If the person is not private write it to the addressBook**//
	if (![tableModel.modelKeyValues valueForKey:@"isPrivate"]) {
		
		ABAddressBookRef addressBook = ABAddressBookCreate();
		CFErrorRef error = NULL;
		ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook,[person.ID intValue]);
		
		
		if(person.state!=0){
			//set default image;
			NSString *img=[NSString stringWithFormat:@"%@%@", person.category_en,@"_B"];
			[GlobalFunctions setCategoryImageToPerson:img Ref:ref];
		
			
			//set default category name;
			ABRecordSetValue(ref, kABPersonJobTitleProperty, NSLocalizedString(person.category,@""), &error);
			//set notes to person
			ABRecordSetValue(ref, kABPersonNoteProperty,person.note, &error);
		}
		
		//set new date
		ABMutableMultiValueRef multi =
		ABMultiValueCreateMutable(kABMultiStringPropertyType);
		CFErrorRef anError = NULL;
		
		CFStringRef string =[GlobalFunctions getLabelForDeletionPolicy:[person.deletion_policy intValue]] ;
		
		BOOL didAdd = ABMultiValueAddValueAndLabel(multi,person.ddate,string, NULL);
		if (didAdd != YES) {NSLog(@"didAdd = ");}
		ABRecordSetValue(ref, kABPersonDateProperty, multi, &anError);
		if (anError != NULL) { /* ... handle error ... */}
		
		CFRelease(multi);
		
		
		if (ABAddressBookSave(addressBook, nil)) {
        	NSLog(@"%s saved successfuly", _cmd);
		} else {
        	NSLog(@"%s something bad happen while saving", _cmd);
		}
		CFRelease(addressBook);   
	}
	
	[self.delegate personViewController:self didFinishWithSave:YES];
	
}


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
	
#if __IPHONE_4_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
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



/////////********/////////////********/////////********/////////////********/////////********/////////////********



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.contentView = nil;
    banner.delegate = nil;
    self.banner = nil;
    person=nil;
    tableModel=nil;
    categories=nil;
	myToolbar=nil;
	theTableView=nil;
}

- (void)dealloc {
	[myToolbar release];
	[actionSheetTitelsArray release];
	[categories release];
    [person release];
    [tableModel release];
	[theTableView release];
	self.contentView = nil;
    banner.delegate = nil;
    self.banner = nil;
    [super dealloc];
}





@end

