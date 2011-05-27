//
//  DictionaryEditorViewController.h
//  Samples App
//
//  Copyright 2010 Sensible Cocoa. All rights reserved.
//

#import "DictionaryEditorViewController.h"


@implementation DictionaryEditorViewController


#pragma mark -
#pragma mark View lifecycle
- (void)loadView {
    self.tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
    self.title=NSLocalizedString(@"Add Categories",@"");
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem  *addButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:nil action:nil];
	self.navigationItem.leftBarButtonItem = addButton;
	[addButton release];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	

	SCDictionaryDefinition *dictionaryDef = 
		[SCDictionaryDefinition definitionWithDictionaryKeyNames:
			[NSArray arrayWithObjects:@"key1", @"key2", @"key3", nil]];
	[dictionaryDef propertyDefinitionWithName:@"key2"].type = SCPropertyTypeSwitch;
	[dictionaryDef propertyDefinitionWithName:@"key3"].type = SCPropertyTypeTextView;
	
	arrayOfDictionaries = [[NSMutableArray alloc] init];
	// Add some dictionaries to the array
	[arrayOfDictionaries addObject:[NSMutableDictionary dictionary]];
	[arrayOfDictionaries addObject:[NSMutableDictionary dictionary]];
	[arrayOfDictionaries addObject:[NSMutableDictionary dictionary]];
	
	
	tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
	
	SCArrayOfObjectsSection *objectsSection =
		[SCArrayOfObjectsSection sectionWithHeaderTitle:nil
											  withItems:arrayOfDictionaries
									withClassDefinition:dictionaryDef];
	objectsSection.addButtonItem = self.navigationItem.leftBarButtonItem;
	[tableModel addSection:objectsSection];
}

- (void)dealloc {
	[tableModel release];
	[arrayOfDictionaries release];
    [super dealloc];
}

#pragma mark -
#pragma mark SCTableViewModelDataSource methods

- (NSObject *)tableViewModel:(SCTableViewModel *)tableViewModel 
	newItemForArrayOfItemsSectionAtIndex:(NSUInteger)index
{
	// When objectsSection requests a new item, return a new mutable dictionary (make sure it's autorelease)
	NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
	[dictionary setValue:@"Test value!" forKey:@"key3"];
	
	return dictionary;
}

#pragma mark -
#pragma mark SCTableViewModelDataSource methods

- (void)tableViewModel:(SCTableViewModel *)tableViewModel willDisplayCell:(SCTableViewCell *)cell 
	 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.textLabel.text = [NSString stringWithFormat:@"Dictionary %i", indexPath.row+1];
}


@end

