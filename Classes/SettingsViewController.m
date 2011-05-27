//
//  SettingsViewController.m
//  HiBye
//
//  Created by shani hajbi on 10/25/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//

#import "SettingsViewController.h"
#import "HiByeAppDelegate.h"

@implementation SettingsViewController


#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
    self.tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	// Get managedObjectContext from application delegate
	NSManagedObjectContext *managedObjectContext = [( HiByeAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
	

	
	// Create a class definition for TaskStepEntity
	SCClassDefinition *taskStepDef =
    [SCClassDefinition definitionWithEntityName:@"CategoryEntity" withManagedObjectContext:managedObjectContext
                              withPropertyNames: [NSArray arrayWithObjects:@"name", nil]];
	// Do some property definition customization
	SCPropertyDefinition *tsdescPropertyDef = [taskStepDef propertyDefinitionWithName:@"desc"];
	tsdescPropertyDef.title = @"Description";
	tsdescPropertyDef.type = SCPropertyTypeTextView;
	
	
	// Create a class definition for TaskEntity
	SCClassDefinition *taskDef = 
    [SCClassDefinition definitionWithEntityName:@"TaskEntity" withManagedObjectContext:managedObjectContext
                              withPropertyNames: [NSArray arrayWithObjects:@"name", @"desc", @"dueDate", @"active", @"priority", 
                                                  @"category", @"assignedTo", @"taskSteps", nil]];
	// Do some property definition customization
	SCPropertyDefinition *descPropertyDef = [taskDef propertyDefinitionWithName:@"desc"];
	descPropertyDef.title = @"Description";
	descPropertyDef.type = SCPropertyTypeTextView;
	SCPropertyDefinition *priorityPropertyDef = [taskDef propertyDefinitionWithName:@"priority"];
	priorityPropertyDef.type = SCPropertyTypeSegmented;
	priorityPropertyDef.attributes = [SCSegmentedAttributes 
									  attributesWithSegmentTitlesArray:[NSArray arrayWithObjects:@"Low", @"Medium", @"High", nil]];
	SCPropertyDefinition *categoryPropertyDef = [taskDef propertyDefinitionWithName:@"category"];
	categoryPropertyDef.type = SCPropertyTypeSelection;
	categoryPropertyDef.attributes = [SCSelectionAttributes attributesWithItems:[NSArray arrayWithObjects:@"Home", @"Work", @"Other", nil]
														 allowMultipleSelection:NO
															   allowNoSelection:NO];
	SCPropertyDefinition *assignedToPropertyDef = [taskDef propertyDefinitionWithName:@"assignedTo"];
	assignedToPropertyDef.type = SCPropertyTypeObjectSelection;
	assignedToPropertyDef.attributes = [SCObjectSelectionAttributes attributesWithItemsEntityClassDefinition:personDef
																				  withItemsTitlePropertyName:@"name"
																					  allowMultipleSelection:NO
																							allowNoSelection:NO];
	SCPropertyDefinition *taskStepsPropertyDef = [taskDef propertyDefinitionWithName:@"taskSteps"];
	taskStepsPropertyDef.attributes = [SCArrayOfObjectsAttributes attributesWithObjectClassDefinition:taskStepDef
																					 allowAddingItems:TRUE
																				   allowDeletingItems:TRUE
																					 allowMovingItems:FALSE];
	
	// Instantiate the tabel model
	tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
	
	// Create and add the objects section
	SCArrayOfObjectsSection *objectsSection = [SCArrayOfObjectsSection sectionWithHeaderTitle:nil
																	withEntityClassDefinition:taskDef];
	objectsSection.addButtonItem = self.navigationItem.rightBarButtonItem;
	[tableModel addSection:objectsSection];
}


- (void)dealloc {
	
    [tableModel release];
	
    [super dealloc];
}



@end
