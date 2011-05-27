//
//  Settings.m
//  HiBye
//
//  Created by shani hajbi on 9/13/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "DatesFunctions.h"
#import <CoreData/CoreData.h>
#import "HiByeAppDelegate.h"
#import "CustumeCategories.h"
#import "GlobalFunctions.h"
#import "SCBadgeView.h"

@implementation Settings
@synthesize activeCategories;
@synthesize custumeCategories;
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize isIpad;


- (id)init {
	if (self = [super init]) {
	
		
	}
	return self;
}


- (void)loadView {
	self.tableView =  [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
												   style:UITableViewStyleGrouped];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
     self.title=NSLocalizedString(@"Settings",@"");
	defaults = [NSUserDefaults standardUserDefaults];
}




#pragma  -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
	
  
	NSUInteger dummis  = [defaults integerForKey:@"dummisCount"];
    NSNumber *DummisCount =[NSNumber numberWithInt:dummis];
    BOOL enableDummy = [defaults boolForKey:@"dummisEnabeld"];
    NSNumber *daysLeft = [defaults objectForKey:@"daysLeft"];
	NSNumber *maxDaysLeft =[NSNumber numberWithFloat:[defaults integerForKey:@"maxDaysLeft"]];
	NSNumber *minDaysLeft = [NSNumber numberWithFloat:[defaults integerForKey:@"minDaysLeft"]];
	
   // NSIndexSet *selectedIndexesSet = [NSIndexSet indexSetWithIndexesInRange:range];
	NSString *indexes = [defaults objectForKey:@"selectendIndexes"];
	NSArray *arr = [indexes componentsSeparatedByString:@","];
	selectedIndexes = [[NSMutableSet alloc] init];
	for (int i=0; i<[arr count]; i++) {
		[selectedIndexes addObject:[NSNumber numberWithInt:[[arr objectAtIndex:i]intValue]]];
	}
	
	
	categories = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"allCategories"]];
	NSLog(@"categories = %@",categories);
    activeCategories =  [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"activeCategories"]];
    custumeCategories =[[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"customCategories"]];
    NSNumber *sortBy = [NSNumber numberWithBool:[defaults boolForKey:@"sortBy"]];
    
    UIBarButtonItem  *doneButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(done:)];
    
	self.navigationItem.leftBarButtonItem = doneButton;
    [doneButton release];
	

    numbers = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",nil];
   
	tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
	
	SCTableViewSection *timerSection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Timer Settings",@"")];
	
	TimerHeaderView *localTimerHeaderView  = [[TimerHeaderView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
	
	[localTimerHeaderView setTime:[NSNumber numberWithInt:14]];
	timerHeaderView = localTimerHeaderView;
	timerSection.headerView = timerHeaderView;
	[localTimerHeaderView release];

	
	sliderCell = [SCSliderCell cellWithText:nil withBoundKey:@"daysLeft" withSliderValue:daysLeft];
	sliderCell.slider.maximumValue = [maxDaysLeft floatValue];
	sliderCell.slider.minimumValue = [minDaysLeft floatValue];
	sliderCell.slider.continuous=YES;
	sliderCell.slider.minimumValueImage = [UIImage imageNamed:@"emptyTimer.png"];
	sliderCell.slider.maximumValueImage = [UIImage imageNamed:@"fullTimer.png"];
	[timerSection addCell:sliderCell];
	
	SCNumericTextFieldCell *maxCell= [SCNumericTextFieldCell cellWithText:NSLocalizedString(@"Max",@"") withBoundKey:@"maxDaysLeft" withValue:maxDaysLeft];
	
	[timerSection addCell:maxCell];
	
	SCNumericTextFieldCell *minCell= [SCNumericTextFieldCell cellWithText:NSLocalizedString(@"Min",@"") withBoundKey:@"minDaysLeft" withValue:minDaysLeft];
	
 	[timerSection addCell:minCell];
        
	[tableModel addSection:timerSection];
	SCTableViewSection *deletePolicy = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Deletion Policy",@"")];
	[tableModel addSection:deletePolicy];
	
	SCSegmentedCell *deletePolicyCell = [SCSegmentedCell cellWithText:nil withBoundKey:@"deletionPolicy" withSelectedSegmentIndexValue:[defaults objectForKey:@"deletionPolicy"] withSegmentTitlesArray:[NSArray arrayWithObjects:@"Alert",@"Archive",@"Delete",nil]];
	
    [deletePolicy addCell:deletePolicyCell];
    //categories settings cells
    SCTableViewSection *categoriesSection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Categories Settings",@"")];
	[tableModel addSection:categoriesSection];
    
    SCSelectionCell *presetCategoriesCell = [SCSelectionCell cellWithText:NSLocalizedString(@"Preset categories",@"") withBoundKey:@"selectedIndexes" withSelectedIndexesValue:selectedIndexes withItems:categories allowMultipleSelection:YES];
    
    
   
    //presetCategoriesCell.detailTableViewStyle = UITableViewStyleGrouped;
    [categoriesSection addCell:presetCategoriesCell];
    
    
    NSMutableArray * images = [[NSMutableArray alloc] init];

    for(int i=0;i<[categories count];i++){
        //UIImage  *img = [UIImage imageNamed:@"Work_l.png"]
        imageView=nil;
        imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[categories objectAtIndex:i]]];
        [images addObject:imageView];
        [imageView release];
    }
    
    
    presetCategoriesCell.detailCellsImageViews =images;

    
    presetCategoriesCell.displaySelection=NO;
    
    SCTableViewCell *CategoriesCell = [SCTableViewCell cellWithText:NSLocalizedString(@"Add custum categories",@"") withBoundKey:@"presetCategories" withValue:nil];
    CategoriesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
	[categoriesSection addCell:CategoriesCell];
    
    
    //Dummy categories cell
    
    SCTableViewSection *dummySection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"HiBye Dummy Settings",@"")];
	[tableModel addSection:dummySection];
    
    [dummySection addCell:[SCSwitchCell cellWithText:NSLocalizedString(@"HiBye Dummy",@"") withBoundKey:@"enableDummy" withSwitchOnValue:[NSNumber numberWithBool:enableDummy]]];
	
    SCSelectionCell *numberOfDummisCell =[SCSelectionCell cellWithText:NSLocalizedString(@"Dummis Count",@"")  withBoundKey:@"DummisCount" withSelectedIndexValue:DummisCount withItems:numbers];
    //numberOfDummisCell.detailTableViewStyle = UITableViewStyleGrouped;

    [dummySection addCell:numberOfDummisCell];
 
    //view settings
    
    SCTableViewSection *displaySection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Display Settings",@"")];
	[tableModel addSection:displaySection];
    
        
    SCSelectionCell *sortNameByCell = [SCSelectionCell cellWithText:NSLocalizedString(@"Sort contacts by",@"") withBoundKey:@"sortByFirstName" withSelectedIndexValue:sortBy withItems:[NSArray arrayWithObjects:NSLocalizedString(@"first,last",@""),NSLocalizedString(@"last,first",@""),nil]];
   // sortNameByCell.detailTableViewStyle = UITableViewStyleGrouped;
   
    [displaySection addCell:sortNameByCell];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside down
	if (!isIpad) {
		return (interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown);
	}
    return YES;
}

-(void)tableViewModel:(SCTableViewModel *)tableViewModel didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch(indexPath.section){
            case 0:
            if(indexPath.row ==0 && tableViewModel == tableModel){
                
            }
            break;
        case 1:
            if(indexPath.row ==1 && tableViewModel == tableModel){
                
                
                CustumeCategories *detailViewController = [[CustumeCategories alloc] init];
                detailViewController.delegate=self;
                detailViewController.categories = custumeCategories;

                [self.navigationController pushViewController:detailViewController animated:YES];
                [detailViewController release];
          
            }
            break;
    }
}



#pragma mark -
#pragma mark SCTableViewModelDelegate methods

- (void)tableViewModel:(SCTableViewModel *) tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *) indexPath
{
	

	NSNumber *newMax;
	NSNumber *newMin;
	NSNumber *currentSliderVal;
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
			
				case 0:
					[defaults setObject:[tableModel.modelKeyValues valueForKey:@"daysLeft"] forKey:@"daysLeft"];
					[timerHeaderView setTime:[tableModel.modelKeyValues valueForKey:@"daysLeft"]];
					[defaults synchronize];
					
					break;
				case 1:
					newMax = [tableModel.modelKeyValues valueForKey:@"maxDaysLeft"];
					currentSliderVal = [tableModel.modelKeyValues valueForKey:@"daysLeft"];
					
					if ([newMax intValue]<[currentSliderVal intValue]) {
						[defaults setObject:newMax forKey:@"daysLeft"];
						[timerHeaderView setTime:newMax];
						[sliderCell.slider setValue:[newMax floatValue] animated:YES];

					}else {
						[sliderCell.slider setValue:[currentSliderVal floatValue] animated:YES];
						
					}

					[defaults setObject:newMax forKey:@"maxDaysLeft"];
					[defaults synchronize];
					break;
				case 2:
					
					newMin = [tableModel.modelKeyValues valueForKey:@"minDaysLeft"];
					currentSliderVal = [tableModel.modelKeyValues valueForKey:@"daysLeft"];
					
					if ([newMin intValue]<[currentSliderVal intValue]) {
						[defaults setObject:newMin forKey:@"daysLeft"];
						[timerHeaderView setTime:newMin];
						[sliderCell.slider setValue:[newMin floatValue] animated:YES];
						
					}else {
						[sliderCell.slider setValue:[currentSliderVal floatValue] animated:YES];
						
					}
					[defaults setObject:newMin forKey:@"minDaysLeft"];
					[defaults synchronize];
					break;
		
			}
			break;
		case 1:
				[defaults setObject:[tableModel.modelKeyValues valueForKey:@"deletionPolicy"] forKey:@"deletionPolicy"];
				[defaults synchronize];
			break;
			
		case 2:
			switch (indexPath.row) {
				case 0:
					selectedIndexes = [tableModel.modelKeyValues valueForKey:@"selectedIndexes"];
					NSLog(@"selectedIndexes %@",selectedIndexes);
					NSEnumerator *enumerator = [selectedIndexes objectEnumerator];
					id value;
					[activeCategories removeAllObjects];
					
					while ((value = [enumerator nextObject])) {
						
						[activeCategories addObject:[categories objectAtIndex:[value  intValue]]];
						
					}
					[defaults setObject:activeCategories forKey:@"activeCategories"];
					
					//appSettings.selectedIndexes = selectedIndexes;
					[self.managedObjectContext save:nil];
					break;
			}
			break;
			
		case 3:
			switch (indexPath.row) {
				case 0:
					[defaults setBool:[[tableModel.modelKeyValues valueForKey:@"enableDummy"]boolValue] forKey:@"enableDummy"];
					[defaults synchronize];
					break;
				case 1:
					[defaults setInteger:[[tableModel.modelKeyValues valueForKey:@"DummisCount"]intValue]+1 forKey:@"DummisCount"];
					[defaults synchronize];
					break;
				
			}
			break;
			
		case 4:
			switch (indexPath.row) {
				case 0:
					[defaults setBool:[[tableModel.modelKeyValues valueForKey:@"sortByFirstName"]boolValue] forKey:@"sortByFirstName"];
					[defaults synchronize];
					break;
				
			}
			break;
		
		}

    }

- (void)tableViewModel:(SCTableViewModel *) tableViewModel
detailViewWillAppearForRowAtIndexPath:(NSIndexPath *) indexPath
withDetailTableViewModel:(SCTableViewModel *) detailTableViewModel
{
    // Set the detail table view model's delegate to self so that you can handle
    // the willConfigureCell method
    detailTableViewModel.delegate = self;
    detailTableViewModel.viewController.navigationItem.rightBarButtonItem =detailTableViewModel.viewController.editButtonItem;
}

// Now handle the willConfigureCell method
- (void)tableViewModel:(SCTableViewModel *)tableViewModel willConfigureCell:(SCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.height = 44;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17];
   
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(tableViewModel != tableModel) // Make sure it's the detail model not the main model
   {
    cell.movable = TRUE;
    cell.editable=YES;
    }
}



- (void)tableViewModel:(SCTableViewModel *) tableViewModel willDisplayCell:(SCTableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath
{
   cell.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]];
    //cell.imageView.image = [UIImage imageNamed:[categories objectAtIndex:indexPath.row]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor =[UIColor clearColor];
    
}



- (void)custumeCategories:(CustumeCategories *)controller didFinishWithArray:(NSMutableArray*)categoriesArray {
    [defaults setObject:categoriesArray forKey:@"customeCategories"];
   	[defaults synchronize];

}


- (IBAction)done:(id)sender {
	if (isIpad) {
		[delegate settings:self didFinishWithSave:YES];
	}else{
    [self.navigationController dismissModalViewControllerAnimated:YES];
	}
}



- (void)dealloc {
	[selectedIndexes release];
	[categories release];
    [activeCategories release];
	[custumeCategories release];
	[tableModel release];
    [numbers release];
    [super dealloc];
}


@end

