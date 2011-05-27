/*
 *  SCTableViewSection.m
 *  Sensible TableView
 *
 *
 *	THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY UNITED STATES 
 *	INTELLECTUAL PROPERTY LAW AND INTERNATIONAL TREATIES. UNAUTHORIZED REPRODUCTION OR 
 *	DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES. YOU SHALL NOT DEVELOP NOR
 *	MAKE AVAILABLE ANY WORK THAT COMPETES WITH A SENSIBLE COCOA PRODUCT DERIVED FROM THIS 
 *	SOURCE CODE. THIS SOURCE CODE MAY NOT BE RESOLD OR REDISTRIBUTED ON A STAND ALONE BASIS.
 *
 *	USAGE OF THIS SOURCE CODE IS BOUND BY THE LICENSE AGREEMENT PROVIDED WITH THE 
 *	DOWNLOADED PRODUCT.
 *
 *  Copyright 2010 Sensible Cocoa. All rights reserved.
 *
 *
 *	This notice may not be removed from this file.
 *
 */

#import "SCTableViewSection.h"
#import "SCTableViewModel.h"
#import "SCGlobals.h"
#import <objc/runtime.h>



@interface SCTableViewSection ()

- (void)disableOwnerViewControllerDelegate;
- (void)enableOwnerViewControllerDelegate;

@end



@implementation SCTableViewSection

@synthesize ownerTableViewModel;
@synthesize boundObject;
@synthesize boundPropertyName;
@synthesize boundKey;
@synthesize commitCellChangesLive;
@synthesize headerTitle;
@synthesize headerHeight;
@synthesize headerView;
@synthesize footerTitle;
@synthesize footerHeight;
@synthesize footerView;
@synthesize cellsImageViews;

+ (id)section
{
	return [[[[self class] alloc] init] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle 
			 withFooterTitle:(NSString *)sectionFooterTitle
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withFooterTitle:sectionFooterTitle] autorelease];
}

- (id)init
{
	if( (self=[super init]) )
	{
		ownerViewControllerDelegate = nil;
		ownerTableViewModel = nil;
		boundObject = nil;
		boundPropertyName = nil;
		boundKey = nil;
		initialValue = nil;
		commitCellChangesLive = TRUE;
		coreDataBound = FALSE;
		headerTitle = nil;
		headerHeight = 0;	// This will set the default header height
		headerView = nil;
		footerTitle = nil;
		footerHeight = 0;	// This will set the default footer height
		footerView = nil;
		cellsImageViews = nil;
		
		cells = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
{
	if([self init])
	{
		self.headerTitle = sectionHeaderTitle;
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle 
		  withFooterTitle:(NSString *)sectionFooterTitle
{
	if([self init])
	{
		self.headerTitle = sectionHeaderTitle;
		self.footerTitle = sectionFooterTitle;
	}
	return self;
}

- (void)dealloc
{
	[boundObject release];
	[boundPropertyName release];
	[boundKey release];
	[initialValue release];
	[headerTitle release];
	[headerView release];
	[footerTitle release];
	[footerView release];
	[cellsImageViews release];
	[cells release];
	[super dealloc];
}

- (NSComparisonResult)compare:(SCTableViewSection *)section
{
	if(!self.headerTitle)
		return NSOrderedAscending;
	
	if(!section.headerTitle)
		return NSOrderedDescending;
	
	return [self.headerTitle compare:section.headerTitle];
}

- (void)setBoundValue:(id)value
{
	if(self.boundObject && self.boundPropertyName)
	{
		[self.boundObject setValue:value forKey:self.boundPropertyName];
	}
	else
		if(self.boundKey)
		{
			if(self.ownerTableViewModel)
			{
				[self.ownerTableViewModel.modelKeyValues setValue:value forKey:self.boundKey];
			}
			else
			{
				[initialValue release];
				initialValue = [value retain];
			}
		}
}

- (NSObject *)boundValue
{
	if(self.boundObject && self.boundPropertyName)
	{
		return [self.boundObject valueForKey:self.boundPropertyName];
	}
	//else
	if(self.boundKey)
	{
		if(self.ownerTableViewModel)
		{
			NSObject *val = [self.ownerTableViewModel.modelKeyValues valueForKey:self.boundKey];
			if(!val && initialValue)
			{
				// set cellValue to initialValue
				[self.ownerTableViewModel.modelKeyValues setValue:initialValue forKey:self.boundKey];
				val = initialValue;
				[initialValue release];
				initialValue = nil;
			}
			return val;
		}
		//else
		return initialValue;
	}
	//else
	return nil;
}

- (void)setCommitCellChangesLive:(BOOL)commit
{
	commitCellChangesLive = commit;
	
	for(SCTableViewCell *cell in cells)
		cell.commitChangesLive = commit;
}

- (NSUInteger)cellCount
{
	return cells.count;
}

- (void)addCell:(SCTableViewCell *)cell
{
	cell.ownerTableViewModel = self.ownerTableViewModel;
	cell.commitChangesLive = self.commitCellChangesLive;
	[cells addObject:cell];
}

- (void)insertCell:(SCTableViewCell *)cell atIndex:(NSUInteger)index
{
	cell.ownerTableViewModel = self.ownerTableViewModel;
	cell.commitChangesLive = self.commitCellChangesLive;
	[cells insertObject:cell atIndex:index];
}

- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	if(index < self.cellCount)
		return [cells objectAtIndex:index];
	//else
	return nil;
}

- (void)removeCellAtIndex:(NSUInteger)index
{
	// Check if the cell to be removed is the current active cell
	SCTableViewCell *cell = [cells objectAtIndex:index];
    if (self.ownerTableViewModel.activeCell == cell)
	{
        self.ownerTableViewModel.activeCell = nil;
    }
	
	[cells removeObjectAtIndex:index];
}

- (NSUInteger)indexForCell:(SCTableViewCell *)cell
{
	return [cells indexOfObjectIdenticalTo:cell];
}

- (BOOL)valuesAreValid
{
	for(SCTableViewCell *cell in cells)
		if(!cell.valueIsValid)
			return FALSE;
	
	return TRUE;
}

- (void)commitCellChanges
{
	for(SCTableViewCell *cell in cells)
		[cell commitChanges];
}

- (void)reloadBoundValues
{
	for(SCTableViewCell *cell in cells)
		[cell reloadBoundValue];
}

- (void)disableOwnerViewControllerDelegate
{
	if([self.ownerTableViewModel.viewController isKindOfClass:[SCTableViewController class]])
	{
		SCTableViewController *tableViewController = 
		(SCTableViewController *)self.ownerTableViewModel.viewController;
		ownerViewControllerDelegate = tableViewController.delegate;
		tableViewController.delegate = nil;
	}
	else
		if([self.ownerTableViewModel.viewController isKindOfClass:[SCViewController class]])
		{
			SCViewController *viewController = 
			(SCViewController *)self.ownerTableViewModel.viewController;
			ownerViewControllerDelegate = viewController.delegate;
			viewController.delegate = nil;
		}
}

- (void)enableOwnerViewControllerDelegate
{
	if([self.ownerTableViewModel.viewController isKindOfClass:[SCTableViewController class]])
	{
		SCTableViewController *tableViewController = 
		(SCTableViewController *)self.ownerTableViewModel.viewController;
		tableViewController.delegate = ownerViewControllerDelegate;
	}
	else
		if([self.ownerTableViewModel.viewController isKindOfClass:[SCViewController class]])
		{
			SCViewController *viewController = 
			(SCViewController *)self.ownerTableViewModel.viewController;
			viewController.delegate = ownerViewControllerDelegate;
		}
}


@end





@interface SCObjectSection ()

- (SCTableViewCell *)getCellForPropertyWithDefinition:(SCPropertyDefinition *)propertyDefinition
								withUIElementDelegate:(id)uiElementDelegate;

@end


@implementation SCObjectSection

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withBoundObject:object] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
									  withBoundObject:object
								  withClassDefinition:classDefinition] autorelease];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
{
	return [self initWithHeaderTitle:sectionHeaderTitle withBoundObject:object 
				 withClassDefinition:nil];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
	[self initWithHeaderTitle:sectionHeaderTitle];
	
	if(!object)
		return self;
	
	boundObject = [object retain];
	
#ifdef _COREDATADEFINES_H	
	if([boundObject isKindOfClass:[NSManagedObject class]])
		coreDataBound = TRUE;
#endif	

	if(!classDefinition)
	{
#ifdef _COREDATADEFINES_H	
		if([self.boundObject isKindOfClass:[NSManagedObject class]])
		{
			NSManagedObject *managedObj = (NSManagedObject *)self.boundObject;
			classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
												 withManagedObjectContext:[managedObj managedObjectContext]
										  autoGeneratePropertyDefinitions:YES];
		}
		else
		{
#endif			
			classDefinition = [SCClassDefinition definitionWithClass:[object class] 
									 autoGeneratePropertyDefinitions:YES];
#ifdef _COREDATADEFINES_H				
		}
#endif							   
	}
	boundObjectClassDefinition = [classDefinition retain];
	
	// Generate cells based on classDefinition
	for(int i=0; i<boundObjectClassDefinition.propertyDefinitionCount; i++)
	{
		SCPropertyDefinition *propertyDefinition = [boundObjectClassDefinition propertyDefinitionAtIndex:i];
		SCTableViewCell *cell = [self getCellForPropertyWithDefinition:propertyDefinition
												 withUIElementDelegate:boundObjectClassDefinition.uiElementDelegate];
		if(cell)
		{
			cell.tag = i;
			[self addCell:cell];
		}
		
	}
	
	return self;
}

- (void)dealloc
{
	[boundObjectClassDefinition release];
	
	[super dealloc];
}

- (SCTableViewCell *)getCellForPropertyWithDefinition:(SCPropertyDefinition *)propertyDefinition
								withUIElementDelegate:(id)uiElementDelegate
{
	SCTableViewCell *cell = nil;
	
	SCPropertyDataType propertyDataType = propertyDefinition.dataType;
	BOOL readOnlyProperty = propertyDefinition.dataReadOnly;
	NSString *propertyName = propertyDefinition.name;
	NSString *propertyTitle = propertyDefinition.title;
	SCPropertyType propertyType = propertyDefinition.type;
	
	if(propertyType == SCPropertyTypeAutoDetect)
	{
		// Auto detect property type
		if(propertyDataType == SCPropertyDataTypeNSString)
		{
			if(readOnlyProperty)
				propertyType = SCPropertyTypeLabel;
			else
				propertyType = SCPropertyTypeTextField;
		}
		else
			if(propertyDataType == SCPropertyDataTypeNSNumber)
			{
				if(readOnlyProperty)
					propertyType = SCPropertyTypeLabel;
				else
					propertyType = SCPropertyTypeNumericTextField;
			}
			else
				if(propertyDataType == SCPropertyDataTypeNSDate)
				{
					if(readOnlyProperty)
						propertyType = SCPropertyTypeLabel;
					else
						propertyType = SCPropertyTypeDate;
				}
				else
				{
					// Can't auto detect
					return nil;
				}
	}
	
	switch (propertyType)
	{
		case SCPropertyTypeLabel:
			if(propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeNSNumber
			   || propertyDataType==SCPropertyDataTypeDictionaryItem)
			{
				cell = [SCLabelCell cellWithText:propertyTitle 
						withBoundObject:boundObject withLabelTextPropertyName:propertyName];
			}
			break;
		case SCPropertyTypeTextView:
			if(propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem)
			{
				cell = [SCTextViewCell cellWithText:propertyTitle
						withBoundObject:boundObject withTextViewTextPropertyName:propertyName];
				if(readOnlyProperty)
				{
					// Override attributes (if exist)
					if([propertyDefinition.attributes isKindOfClass:[SCTextViewAttributes class]])
					{
						((SCTextViewAttributes *)propertyDefinition.attributes).editable = FALSE;
					}
					else
						((SCTextViewCell *)cell).textView.editable = FALSE;
				}
			}
			break;
		case SCPropertyTypeTextField:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCTextFieldCell cellWithText:propertyTitle withPlaceholder:nil
						withBoundObject:boundObject withTextFieldTextPropertyName:propertyName];
			}
			break;
		case SCPropertyTypeNumericTextField:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCNumericTextFieldCell cellWithText:propertyTitle withPlaceholder:nil
											withBoundObject:boundObject withTextFieldTextPropertyName:propertyName];
			}
			break;
		case SCPropertyTypeSlider:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCSliderCell cellWithText:propertyTitle
						withBoundObject:boundObject withSliderValuePropertyName:propertyName];
			}
			break;
		case SCPropertyTypeSegmented:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCSegmentedCell cellWithText:propertyTitle 
									 withBoundObject:boundObject 
				withSelectedSegmentIndexPropertyName:propertyName
							  withSegmentTitlesArray:nil];
			}
			break;
		case SCPropertyTypeSwitch:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSNumber || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCSwitchCell cellWithText:propertyTitle 
						withBoundObject:boundObject withSwitchOnPropertyName:propertyName];
			}
			break;
		case SCPropertyTypeDate:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSDate || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCDateCell cellWithText:propertyTitle 
								withBoundObject:boundObject withDatePropertyName:propertyName];
			}
			break;
		case SCPropertyTypeImagePicker:
			if(!readOnlyProperty && 
			   (propertyDataType==SCPropertyDataTypeNSString || propertyDataType==SCPropertyDataTypeDictionaryItem))
			{
				cell = [SCImagePickerCell cellWithText:propertyTitle 
						withBoundObject:boundObject withImageNamePropertyName:propertyName];
			}
			break;
		case SCPropertyTypeSelection:
			if(!readOnlyProperty && propertyDataType==SCPropertyDataTypeNSNumber)
			{
				cell = [SCSelectionCell cellWithText:propertyTitle 
									 withBoundObject:boundObject withSelectedIndexPropertyName:propertyName
										   withItems:nil];
			}
			else
			if(!readOnlyProperty && propertyDataType==SCPropertyDataTypeNSString)
			{
				cell = [SCSelectionCell cellWithText:propertyTitle 
									 withBoundObject:boundObject withSelectionStringPropertyName:propertyName
										   withItems:nil];
			}
			else
			if(propertyDataType==SCPropertyDataTypeNSMutableSet)
			{
				cell = [SCSelectionCell cellWithText:propertyTitle 
						withBoundObject:boundObject withSelectedIndexesPropertyName:propertyName
						withItems:nil allowMultipleSelection:FALSE];
			}
			break;
		case SCPropertyTypeObjectSelection:
			cell = [SCObjectSelectionCell cellWithText:propertyTitle
									   withBoundObject:boundObject
						withSelectedObjectPropertyName:propertyName
											 withItems:nil
							 withItemTitlePropertyName:nil];
			break;
		case SCPropertyTypeObject:
		{
			NSObject *object = [self.boundObject valueForKey:propertyName];
			
#ifdef _COREDATADEFINES_H			
			if(!object && coreDataBound)
			{
				// create a new object
				NSManagedObject *managedObj = (NSManagedObject *)self.boundObject;
				NSRelationshipDescription *objReleationship = 
					[[[managedObj entity] relationshipsByName] valueForKey:propertyName];
				if(objReleationship)
				{
					object = [NSEntityDescription 
							  insertNewObjectForEntityForName:[[objReleationship destinationEntity] name]
							  inManagedObjectContext:boundObjectClassDefinition.managedObjectContext];
					[self.boundObject setValue:object forKey:propertyName];
				}
			}
#endif			
			
			if(!object)
				break;
			
			SCClassDefinition *objClassDef = nil;
			
#ifdef _COREDATADEFINES_H			
			if([object isKindOfClass:[NSManagedObject class]])
			{
				if([propertyDefinition.attributes isKindOfClass:[SCObjectAttributes class]])
				{
					NSArray *classDefinitions = [[(SCObjectAttributes *)propertyDefinition.attributes 
												  classDefinitions] allValues];
					if(classDefinitions.count)
						objClassDef = [classDefinitions objectAtIndex:0];
				}
			}
#endif			
			
			cell = [SCObjectCell cellWithBoundObject:object withClassDefinition:objClassDef];
			if(propertyDefinition.title)
				((SCObjectCell *)cell).boundObjectTitleText = propertyDefinition.title;
			
			// Technically, boundPropertyName is not applicable to SCObjectCell, however
			// it is set here so that [self cellForPropertyName] would work 
			[(SCObjectCell *)cell setBoundPropertyName:propertyName];
		}
			break;
			
		case SCPropertyTypeArrayOfObjects:
		{
			NSMutableArray *objectsArray = [boundObject valueForKey:propertyName];
			if(!objectsArray)
				break;
			
			if(coreDataBound)
			{
				SCClassDefinition *entityClassDef = nil;
				if([propertyDefinition.attributes isKindOfClass:[SCArrayOfObjectsAttributes class]])
				{
					NSArray *classDefinitions = [[(SCArrayOfObjectsAttributes *)propertyDefinition.attributes 
												 classDefinitions] allValues];
					if(classDefinitions.count)
						entityClassDef = [classDefinitions objectAtIndex:0];
				}
			
				if([[boundObject valueForKey:propertyName] isKindOfClass:[NSMutableSet class]])
				{
					cell = [SCArrayOfObjectsCell cellWithItemsSet:[boundObject mutableSetValueForKey:propertyName]
											  withClassDefinition:entityClassDef];
				}
				else
				if([[boundObject valueForKey:propertyName] isKindOfClass:[NSArray class]])
				{
					cell = [SCArrayOfObjectsCell cellWithItems:[boundObject valueForKey:propertyName]
										   withClassDefinition:entityClassDef];
				}
			}
			else
			{
				cell = [SCArrayOfObjectsCell cellWithItems:objectsArray
								   withClassDefinition:nil];
			}
			
			if(propertyDefinition.title)
				((SCArrayOfObjectsCell *)cell).boundObjectTitleText = propertyDefinition.title;
			
			// Technically, boundPropertyName is not applicable to SCArrayOfObjectsCell, however
			// it is set here so that [self cellForPropertyName] would work 
			[(SCArrayOfObjectsCell *)cell setBoundPropertyName:propertyName];
		}
			break;
		
		default:
			cell = nil;
			break;
	}
	
	if(cell)
	{
		cell.delegate = uiElementDelegate;
		cell.valueRequired = propertyDefinition.required;
		cell.autoValidateValue = propertyDefinition.autoValidate;
		[cell setAttributesTo:propertyDefinition.attributes];
	}
		
	return cell;
}

- (SCTableViewCell *)cellForPropertyName:(NSString *)propertyName
{
	for(SCTableViewCell *cell in cells)
	{
		if([cell.boundPropertyName isEqualToString:propertyName])
			return cell;
	}
	return nil;
}

@end







@interface SCArrayOfItemsSection ()

- (SCTableViewModel *)getCustomDetailModelForRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@implementation SCArrayOfItemsSection

@synthesize items;
@synthesize itemsAccessoryType;
@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditDetailView;
@synthesize allowRowSelection;
@synthesize detailViewModal;
#ifdef __IPHONE_3_2
@synthesize detailViewModalPresentationStyle;
#endif
@synthesize detailTableViewStyle;
@synthesize detailViewHidesBottomBar;
@synthesize cellIdentifier;
@synthesize addButtonItem;

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
											withItems:sectionItems]	autorelease];
}


- (id)init
{
	if( (self=[super init]) )
	{
		tempDetailModel = nil;
		items = nil;
		itemsAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = TRUE;
		allowEditDetailView = TRUE;
		allowRowSelection = TRUE;
		detailViewModal = FALSE;
#ifdef __IPHONE_3_2
		detailViewModalPresentationStyle = UIModalPresentationFullScreen;
#endif
		
		detailTableViewStyle = UITableViewStyleGrouped;
		detailViewHidesBottomBar = TRUE;
		cellIdentifier = @"ItemCellId";
		selectedCellIndexPath = nil;
		addButtonItem = nil;
		tempItem = nil;
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle])
	{
		self.items = sectionItems;
	}
	return self;
}

- (void)dealloc
{
	[tempDetailModel release];
	[items release];
	[selectedCellIndexPath release];
	[addButtonItem release];
	[tempItem release];
	[super dealloc];
}

- (void)setAddButtonItem:(UIBarButtonItem *)barButtonItem
{
	[addButtonItem release];
	addButtonItem = [barButtonItem retain];
	
	addButtonItem.target = self;
	addButtonItem.action = @selector(didTapAddButtonItem);
}

// override superclass method
- (NSUInteger)cellCount
{
	return items.count;
}

// override superclass method
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	if(!self.items)
		return nil;
	
	SCTableViewCell *cell = (SCTableViewCell *)[self.ownerTableViewModel.modeledTableView 
							 dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (cell == nil) 
	{
        cell = [self createCellAtIndex:index];
    }
	[self setPropertiesForCell:cell withIndex:index];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willConfigureCell:)])
	{
		[cell.delegate willConfigureCell:cell];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:willConfigureCell:forRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index 
														inSection:[self.ownerTableViewModel indexForSection:self]];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel willConfigureCell:cell 
											forRowAtIndexPath:indexPath];
		}
	
    return cell;
}

// override superclass method
- (NSUInteger)indexForCell:(SCTableViewCell *)cell
{
	NSIndexPath *indexPath = [self.ownerTableViewModel.modeledTableView indexPathForCell:cell];
	if(indexPath.section == [self.ownerTableViewModel indexForSection:self])
		return indexPath.row;
	return NSNotFound;
}

- (SCTableViewCell *)createCellAtIndex:(NSUInteger)index
{
	SCTableViewCell *cell = [[[SCTableViewCell alloc] initWithStyle:SC_DefaultCellStyle 
										  reuseIdentifier:self.cellIdentifier] autorelease];
	cell.ownerTableViewModel = self.ownerTableViewModel;
	
	return cell;
}

- (void)setPropertiesForCell:(SCTableViewCell *)cell withIndex:(NSUInteger)index
{
	cell.textLabel.text = [self textForCellAtIndex:index];
	cell.detailTextLabel.text = [self detailTextForCellAtIndex:index];
	cell.editable = self.allowDeletingItems;
	cell.movable = self.allowMovingItems;
	if(self.allowRowSelection)
	{
		cell.accessoryType = self.itemsAccessoryType;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	return [NSString stringWithFormat:@"Item: %i", index];
}

- (NSString *)detailTextForCellAtIndex:(NSUInteger)index
{
	return nil;
}

- (void)tempDetailModelModified
{
	[self commitDetailModelChanges:tempDetailModel];
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	//will be overridden in subclasses
}

- (SCTableViewModel *)getCustomDetailModelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewModel *detailModel = nil;
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailTableViewModelForRowAtIndexPath:)])
	{
		detailModel = [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
							  customDetailTableViewModelForRowAtIndexPath:indexPath];
	}
	return detailModel;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
	[selectedCellIndexPath release];
	selectedCellIndexPath = [indexPath retain];
	
	if(!self.allowEditDetailView)
		return;
	
	[self dispatchSelectRowAtIndexPathEvent:indexPath];
}

- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
	[selectedCellIndexPath release];
	selectedCellIndexPath = [indexPath retain];
	
	// Check for custom detail table view model
	SCTableViewModel *detailTableViewModel = [self getCustomDetailModelForRowAtIndexPath:indexPath];
	if(detailTableViewModel)
	{
		[tempDetailModel release];
		tempDetailModel = [[SCTableViewModel alloc] initWithTableView:detailTableViewModel.modeledTableView
												   withViewController:detailTableViewModel.viewController];
		tempDetailModel.masterModel = self.ownerTableViewModel;
		[tempDetailModel setTargetForModelModifiedEvent:self action:@selector(tempDetailModelModified)];
		[self buildDetailTableModel:tempDetailModel	
							forItem:[self.items objectAtIndex:indexPath.row]];
		[tempDetailModel sectionAtIndex:0].commitCellChangesLive = TRUE;
		[detailTableViewModel.modeledTableView reloadData];
		
		return;
	}
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	
	SCNavigationBarType navBarType;
	if(navController && !self.detailViewModal)
		navBarType = SCNavigationBarTypeNone;
	else
		navBarType = SCNavigationBarTypeDoneRightCancelLeft;
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:navBarType];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
	detailViewController.title = 
	[self.ownerTableViewModel.modeledTableView cellForRowAtIndexPath:indexPath].textLabel.text;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
		self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	[self buildDetailTableModel:detailViewController.tableViewModel	
						forItem:[self.items objectAtIndex:indexPath.row]];
	
	SCTableViewCell *cell = [self.ownerTableViewModel cellAtIndexPath:indexPath];
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[cell.delegate detailViewWillAppearForCell:cell withDetailTableViewModel:detailViewController.tableViewModel];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
						detailViewWillAppearForRowAtIndexPath:indexPath 
									 withDetailTableViewModel:detailViewController.tableViewModel];
		}
	
	[self.ownerTableViewModel pauseAutoResizeForKeyboard];
	[self disableOwnerViewControllerDelegate];
	if(navController && !self.detailViewModal)
	{
		[navController pushViewController:detailViewController animated:TRUE];
	}
	else
	{
		UINavigationController *detailNavController = [[UINavigationController alloc] 
													   initWithRootViewController:detailViewController];
		if(navController)
			detailNavController.navigationBar.barStyle = navController.navigationBar.barStyle;
#ifdef __IPHONE_3_2
		if([SCHelper is_iPad])
		{
			detailNavController.contentSizeForViewInPopover = detailViewController.contentSizeForViewInPopover;
			detailNavController.modalPresentationStyle = self.detailViewModalPresentationStyle;
		}
#endif
		[self.ownerTableViewModel.viewController presentModalViewController:detailNavController
																   animated:TRUE];
		[detailNavController release];
	}
	
	[detailViewController release];
}

- (void)didTapAddButtonItem
{
	if(!self.allowAddingItems)
		return;
	
	[self dispatchAddNewItemEvent];
}

- (void)dispatchAddNewItemEvent
{
	selectedCellIndexPath = nil;
	
	[tempItem release];
	tempItem = [[self createNewItem] retain];
	if(!tempItem)
		return;
	
	NSUInteger index = [ownerTableViewModel indexForSection:self];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemCreatedForSectionAtIndex:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
							 itemCreatedForSectionAtIndex:index
													 item:tempItem];
	}
	
	if(self.ownerTableViewModel.activeCell.autoResignFirstResponder)
		[self.ownerTableViewModel.activeCell resignFirstResponder];
	
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:SCNavigationBarTypeDoneRightCancelLeft];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
		self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	[self buildDetailTableModel:detailViewController.tableViewModel
						forItem:tempItem];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForSectionAtIndex:withDetailTableViewModel:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					detailViewWillAppearForSectionAtIndex:index
								 withDetailTableViewModel:detailViewController.tableViewModel];
	}
	
	UINavigationController *detailNavController = [[UINavigationController alloc] 
												   initWithRootViewController:detailViewController];
	if(self.ownerTableViewModel.viewController.navigationController)
		detailNavController.navigationBar.barStyle = 
		self.ownerTableViewModel.viewController.navigationController.navigationBar.barStyle;
#ifdef __IPHONE_3_2
	if([SCHelper is_iPad])
	{
		detailNavController.contentSizeForViewInPopover = detailViewController.contentSizeForViewInPopover;
		detailNavController.modalPresentationStyle = self.detailViewModalPresentationStyle;
	}
#endif
	[self.ownerTableViewModel pauseAutoResizeForKeyboard];
	[self disableOwnerViewControllerDelegate];
	[self.ownerTableViewModel.viewController presentModalViewController:detailNavController
															   animated:TRUE];
	[detailNavController release];
	
	[detailViewController release];
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forCellAtIndexPath:(NSIndexPath *)indexPath
{
	[self dispatchRemoveRowAtIndexPathEvent:indexPath];
}

- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
	BOOL shouldRemove = TRUE;
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:willRemoveRowAtIndexPath:)])
	{
		shouldRemove = [self.ownerTableViewModel.delegate 
						tableViewModel:self.ownerTableViewModel willRemoveRowAtIndexPath:indexPath];
	}
	
	if(!shouldRemove)
		return;
	
	if( (selectedCellIndexPath.section==indexPath.section &&  selectedCellIndexPath.row==indexPath.row) && tempDetailModel)
	{
		UITableView *detailTableView = tempDetailModel.modeledTableView;
		[tempDetailModel release];
		tempDetailModel = nil;
		detailTableView.dataSource = nil;
		detailTableView.delegate = nil;
		[detailTableView reloadData];
	}
	
	[self.items removeObjectAtIndex:indexPath.row];
	NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
	[self.ownerTableViewModel.modeledTableView deleteRowsAtIndexPaths:indexPaths 
													 withRowAnimation:UITableViewRowAnimationRight];
	[indexPaths release];
}

- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
				toIndexPath:(NSIndexPath *)toIndexPath
{
	id item = [[self.items objectAtIndex:fromIndexPath.row] retain];
	[self.items removeObjectAtIndex:fromIndexPath.row];
	
	if(fromIndexPath.section == toIndexPath.section)
	{
		[self.items insertObject:item atIndex:toIndexPath.row];
	}
	else
	{
		SCTableViewSection *toSection = [self.ownerTableViewModel sectionAtIndex:toIndexPath.section];
		if([toSection isKindOfClass:[SCArrayOfItemsSection class]])
			[[(SCArrayOfItemsSection *)toSection items] insertObject:item atIndex:toIndexPath.row];
	}
	
	[item release];
}

- (NSObject *)createNewItem
{
	// If supported, have datasource create the new item
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:newItemForArrayOfItemsSectionAtIndex:)])
	{
		return [self.ownerTableViewModel.dataSource tableViewModel:self.ownerTableViewModel
							  newItemForArrayOfItemsSectionAtIndex:[self.ownerTableViewModel indexForSection:self]];
	}
	
	// Else use a class from the first item in items
	if(!self.items.count)
		return nil;
	
	return [[[[[self.items objectAtIndex:0] class] alloc] init] autorelease];
}

- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
	// Does nothing, override in subclasses
}

- (void)addNewItem:(NSObject *)newItem
{
	// Does nothing, override in subclasses
}


#pragma mark -
#pragma mark SCTableViewControllerDelegate methods

// Should be overridden by subclasses
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForSectionAtIndex:)])
	{
		NSUInteger index = [ownerTableViewModel indexForSection:self];
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
				  detailViewWillDisappearForSectionAtIndex:index];
	}
}

- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForSectionAtIndex:)])
	{
		NSUInteger index = [ownerTableViewModel indexForSection:self];
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					detailViewDidDisappearForSectionAtIndex:index];
	}
}


@end







@implementation SCArrayOfStringsSection


// override superclass method
- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	id item = [self.items objectAtIndex:index];
	if([item isKindOfClass:[NSString class]])
		return (NSString *)item;
	//else
	return [super textForCellAtIndex:index];
}

// override superclass method
- (NSObject *)createNewItem
{
	return [NSString string];
}

// override superclass method
- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
	SCTableViewSection *section = [[SCTableViewSection alloc] init];
	SCTextFieldCell *textFieldCell = [[SCTextFieldCell alloc] initWithText:nil];
	textFieldCell.textField.text = (NSString *)item;
	[section addCell:textFieldCell];
	[textFieldCell release];
	[detailTableModel addSection:section];
	[section release];
}

// override superclass method
- (void)addNewItem:(NSObject *)newItem
{
	[items addObject:newItem];
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	NSIndexPath *newRowIndexPath = [NSIndexPath indexPathForRow:items.count-1 inSection:sectionIndex];
	NSArray *indexPaths = [NSArray arrayWithObject:newRowIndexPath];
	[self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:indexPaths
													 withRowAnimation:UITableViewRowAnimationBottom];
	[self.ownerTableViewModel.modeledTableView scrollToRowAtIndexPath:newRowIndexPath 
													 atScrollPosition:UITableViewScrollPositionNone
															 animated:YES];
	[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:newRowIndexPath animated:TRUE 
													 scrollPosition:UITableViewScrollPositionNone];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemAddedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						   itemAddedForSectionAtIndexPath:newRowIndexPath
													 item:newItem];
	}
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:didInsertRowAtIndexPath:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel didInsertRowAtIndexPath:newRowIndexPath];
	}
}

// override superclass method
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	NSIndexPath *textFieldCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	SCTextFieldCell *textFieldCell = (SCTextFieldCell *)[detailModel
														 cellAtIndexPath:textFieldCellIndexPath];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemEditedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						  itemEditedForSectionAtIndexPath:textFieldCellIndexPath
													 item:[self.items objectAtIndex:textFieldCellIndexPath.row]];
	}
	
	NSString *oldString = [items objectAtIndex:selectedCellIndexPath.row];
	NSString *newString = textFieldCell.textField.text;
	if(![oldString isEqualToString:newString])
	{
		[items replaceObjectAtIndex:selectedCellIndexPath.row withObject:newString];
	}
	
	if(tempDetailModel) // a custom detail view is defined
	{
		NSArray *indexPaths = [NSArray arrayWithObject:selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
	}
}

// override superclass method
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	// (!selectedCellIndexPath && !doneTapped)==TRUE means that the user terminated the application before
	//	tapping any buttons.
	if(cancelTapped || (!selectedCellIndexPath && !doneTapped))
	{
		[tempItem release];
		tempItem = nil;
		return;
	}
	
	NSIndexPath *textFieldCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	SCTextFieldCell *textFieldCell = (SCTextFieldCell *)[tableViewController.tableViewModel
														 cellAtIndexPath:textFieldCellIndexPath];
	
	if(selectedCellIndexPath)
	{
		[self commitDetailModelChanges:tableViewController.tableViewModel];
	}
	else
	{
		// New item added
		if([self.ownerTableViewModel isKindOfClass:[SCArrayOfItemsModel class]])
		{
			// Have model handle the item addition
			[(SCArrayOfItemsModel *)self.ownerTableViewModel addNewItem:textFieldCell.textField.text];
		}
		else
		{
			[self addNewItem:textFieldCell.textField.text];
		}
	}
	
	[tempItem release];
	tempItem = nil;	
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	[self.ownerTableViewModel valueChangedForSectionAtIndex:sectionIndex];
}

//override superclass
- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped
						  doneButtonTapped:doneTapped];
	
	if(selectedCellIndexPath)
	{
		NSArray *indexPaths = [NSArray arrayWithObject:selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
	}
}

@end









@interface SCArrayOfObjectsSection ()

- (SCClassDefinition *)getClassDefinitionForObject:(NSObject *)object;

- (void)generateItemsArrayFromItemsSet;
- (SCClassDefinition *)firstClassDefinition;  // Returns the 1st classdef in classDefinitions

#ifdef _COREDATADEFINES_H
- (void)registerWithManagedObjectContextNotifications;
- (void)deleteCoreDataTempObject;
#endif

@end


@implementation SCArrayOfObjectsSection

@synthesize itemsClassDefinitions;
@synthesize itemsSet;
@synthesize sortItemsSetAscending;


+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
											withItems:sectionItems
								  withClassDefinition:classDefinition] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItemsSet:(NSMutableSet *)sectionItemsSet
		 withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
										 withItemsSet:sectionItemsSet
								  withClassDefinition:classDefinition] autorelease];
}

#ifdef _COREDATADEFINES_H
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
							withEntityClassDefinition:classDefinition] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
			  usingPredicate:(NSPredicate *)predicate
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle
							withEntityClassDefinition:classDefinition
									   usingPredicate:predicate] autorelease];
}
#endif

- (id)init
{
	if( (self=[super init]) )
	{
		itemsClassDefinitions = [[NSMutableDictionary alloc] init];
		
		itemsSet = nil;
		sortItemsSetAscending = TRUE;
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([super initWithHeaderTitle:sectionHeaderTitle withItems:sectionItems])
	{
#ifdef _COREDATADEFINES_H
		if(!classDefinition && [sectionItems count])
		{
			if([[sectionItems objectAtIndex:0] isKindOfClass:[NSManagedObject class]])
			{
				NSManagedObject *managedObj = (NSManagedObject *)[sectionItems objectAtIndex:0];
				classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
													 withManagedObjectContext:[managedObj managedObjectContext]
											  autoGeneratePropertyDefinitions:YES];
			}
		}
#endif
		
		if(classDefinition)
		{
#ifdef _COREDATADEFINES_H			
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				[self registerWithManagedObjectContextNotifications];
				
				allowMovingItems = FALSE;  // not applicable to core data
			}
#endif			
			
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
		}
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withItemsSet:(NSMutableSet *)sectionItemsSet
	  withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([super initWithHeaderTitle:sectionHeaderTitle withItems:nil])
	{
#ifdef _COREDATADEFINES_H
		if(!classDefinition && [sectionItemsSet count])
		{
			if([[sectionItemsSet anyObject] isKindOfClass:[NSManagedObject class]])
			{
				NSManagedObject *managedObj = (NSManagedObject *)[sectionItemsSet anyObject];
				classDefinition = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
													 withManagedObjectContext:[managedObj managedObjectContext]
											  autoGeneratePropertyDefinitions:YES];
			}
		}
#endif		
		
		if(classDefinition)
		{
#ifdef _COREDATADEFINES_H			
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				[self registerWithManagedObjectContextNotifications];
				
				allowMovingItems = FALSE;  // not applicable to core data
			}
#endif			
			
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			
			self.itemsSet = sectionItemsSet;	// setter also generates items array
		}
	}
	return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
	withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [self initWithHeaderTitle:sectionHeaderTitle withEntityClassDefinition:classDefinition
					  usingPredicate:nil];
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
withEntityClassDefinition:(SCClassDefinition *)classDefinition
		   usingPredicate:(NSPredicate *)predicate
{
	// Create the sectionItems array
	NSMutableArray *sectionItems = nil;
	
	if(classDefinition.entity)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:classDefinition.entity];
		if(predicate)
			[fetchRequest setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
											initWithKey:classDefinition.keyPropertyName 
											ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		sectionItems = [NSMutableArray arrayWithArray:[classDefinition.managedObjectContext 
													   executeFetchRequest:fetchRequest
													   error:NULL]];
		
		[sortDescriptor release];
		[sortDescriptors release];
		[fetchRequest release];
	}
	
	return [self initWithHeaderTitle:sectionHeaderTitle withItems:sectionItems
				 withClassDefinition:classDefinition];
}
#endif

- (void)dealloc
{
	[itemsClassDefinitions release];
	[itemsSet release];
	
	if(coreDataBound)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	
	[super dealloc];
}

// override superclass method
- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	id object = [self.items objectAtIndex:index];
	SCClassDefinition *objectClassDef = [self getClassDefinitionForObject:object];
	
	if(objectClassDef.titlePropertyName)
	{
		return [objectClassDef titleValueForObject:object];
	}
	
	//else
	return nil;
}

// override superclass method
- (NSString *)detailTextForCellAtIndex:(NSUInteger)index
{
	id object = [self.items objectAtIndex:index];
	SCClassDefinition *objectClassDef = [self getClassDefinitionForObject:object];
	
	if(objectClassDef.descriptionPropertyName)
	{
#ifdef _COREDATADEFINES_H
		if([object isKindOfClass:[NSManagedObject class]])
			return [NSString stringWithFormat:@"%@", [(NSManagedObject *)object valueForKeyPath:objectClassDef.descriptionPropertyName]];
#endif		
		//else
		return [NSString stringWithFormat:@"%@", [object valueForKey:objectClassDef.descriptionPropertyName]];
	}
	
	//else
	return nil;
}

// override superclass method
- (NSObject *)createNewItem
{
	NSObject *obj = nil;
	
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H
		SCClassDefinition *classDef = [self firstClassDefinition];
		NSEntityDescription *entity = [classDef entity];
		if(entity)
		{
			obj = [[NSEntityDescription 
					insertNewObjectForEntityForName:[entity name]
					inManagedObjectContext:classDef.managedObjectContext] 
				   autorelease];
			
			if(self.itemsSet)
				[self.itemsSet addObject:obj];
		}
#endif
	}
	else
	{
		obj = [super createNewItem];
		if(!obj)
		{
			// Use a class from itemsClassDefinitions
			SCClassDefinition *classDef = [self firstClassDefinition];
			if(classDef)
				obj = [[[classDef.cls alloc] init] autorelease];
		}
	}
	
	return obj;
}

// override superclass method
- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item
{
	SCObjectSection *objectSection = [[SCObjectSection alloc]
									  initWithHeaderTitle:nil 
									  withBoundObject:item 
									  withClassDefinition:[self getClassDefinitionForObject:item]];
	objectSection.commitCellChangesLive = FALSE;
	[detailTableModel addSection:objectSection];
	[objectSection release];
}

// override superclass method
- (void)addNewItem:(NSObject *)newItem
{
	[items addObject:newItem];
	
	if(coreDataBound)
	{
		// Sort the items array (if key is sortable)
		NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
										initWithKey:[self firstClassDefinition].keyPropertyName
										ascending:self.sortItemsSetAscending];
		@try 
		{
			[items sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
		}
		@catch (NSException * e) 
		{
			// do nothing (do not sort)
		}
		@finally 
		{
			[descriptor release];
		}
	}
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	NSUInteger newItemIndex = [items indexOfObjectIdenticalTo:newItem];
	
	NSIndexPath *newRowIndexPath = [NSIndexPath indexPathForRow:newItemIndex inSection:sectionIndex];
	NSArray *indexPaths = [NSArray arrayWithObject:newRowIndexPath];
	[self.ownerTableViewModel.modeledTableView insertRowsAtIndexPaths:indexPaths
													 withRowAnimation:UITableViewRowAnimationBottom];
	[self.ownerTableViewModel.modeledTableView scrollToRowAtIndexPath:newRowIndexPath 
													 atScrollPosition:UITableViewScrollPositionNone
															 animated:YES];
	[self.ownerTableViewModel.modeledTableView selectRowAtIndexPath:newRowIndexPath animated:TRUE 
													 scrollPosition:UITableViewScrollPositionNone];
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemAddedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						   itemAddedForSectionAtIndexPath:newRowIndexPath
													 item:newItem];
	}
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:didInsertRowAtIndexPath:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
								  didInsertRowAtIndexPath:newRowIndexPath];
	}
	
	// Check for custom detail table view model for the newly added item
	SCTableViewModel *detailTableViewModel = [self getCustomDetailModelForRowAtIndexPath:newRowIndexPath];
	if(detailTableViewModel)
	{
		[self didSelectCellAtIndexPath:newRowIndexPath];
	}
}

// override superclass method
- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath
{
	BOOL shouldRemove = TRUE;
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:willRemoveRowAtIndexPath:)])
	{
		shouldRemove = [self.ownerTableViewModel.delegate 
						tableViewModel:self.ownerTableViewModel willRemoveRowAtIndexPath:indexPath];
	}
	
	if(!shouldRemove)
		return;
	
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H
		SCClassDefinition *classDef = [self firstClassDefinition];
		NSObject *obj = [[self.items objectAtIndex:indexPath.row] retain];
		
		[super dispatchRemoveRowAtIndexPathEvent:indexPath];
		
		if(self.itemsSet)
			[self.itemsSet removeObject:obj];
		else
			[classDef.managedObjectContext deleteObject:(NSManagedObject *)obj];
#endif		
	}
	else
		[super dispatchRemoveRowAtIndexPathEvent:indexPath];
}

// override superclass method
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:itemEditedForSectionAtIndexPath:item:)])
	{
		[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						  itemEditedForSectionAtIndexPath:selectedCellIndexPath
													 item:[self.items objectAtIndex:selectedCellIndexPath.row]];
	}
	
	if(tempDetailModel) // a custom detail view is defined
	{
		NSArray *indexPaths = [NSArray arrayWithObject:selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
	}
}

// override superclass method
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	// (!selectedCellIndexPath && !doneTapped)==TRUE means that the user terminated the application before
	//	tapping any buttons.
	if(cancelTapped || (!selectedCellIndexPath && !doneTapped))
	{
		if(coreDataBound)
		{
#ifdef _COREDATADEFINES_H			
			if([tempItem isKindOfClass:[NSManagedObject class]])
				[self deleteCoreDataTempObject];
#endif			
		}
		else
			[tempItem release];
		tempItem = nil;
		return;
	}

	//looping to include any custom user added sections too
	for(int i=0; i<tableViewController.tableViewModel.sectionCount; i++)
	{
		SCTableViewSection *section = [tableViewController.tableViewModel sectionAtIndex:i];
		if([section isKindOfClass:[SCObjectSection class]])
			[(SCObjectSection *)section commitCellChanges];
	}
	
	NSUInteger sectionIndex = [self.ownerTableViewModel indexForSection:self];
	if(selectedCellIndexPath)
	{
		[self commitDetailModelChanges:tableViewController.tableViewModel];
	}
	else	// newly added item
	{
		// Must release tempItem here in case user needs to do a [managedObjectContext save:] operation
		// in itemAddedForSectionAtIndexPath or didInsertRowAtIndexPath (see registerWithManagedObjectContextNotifications)
		NSObject *newItem = tempItem;
		tempItem = nil;
		
		if([self.ownerTableViewModel isKindOfClass:[SCArrayOfItemsModel class]])
		{
			// Have model handle the item addition
			[(SCArrayOfItemsModel *)self.ownerTableViewModel addNewItem:newItem];
		}
		else
		{
			[self addNewItem:newItem];
		}
		
		[newItem release];
	}
	
	[tempItem release];
	tempItem = nil;
	
	[self.ownerTableViewModel valueChangedForSectionAtIndex:sectionIndex];
}

//override superclass
- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[super tableViewControllerDidDisappear:tableViewController cancelButtonTapped:cancelTapped
						  doneButtonTapped:doneTapped];
	
	if(selectedCellIndexPath)
	{
		NSArray *indexPaths = [NSArray arrayWithObject:selectedCellIndexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
	}
}

-(void)setItemsSet:(NSMutableSet *)set
{
	[itemsSet release];
	itemsSet = [set retain];
	
	[self generateItemsArrayFromItemsSet];
}

-(void)setSortItemsSetAscending:(BOOL)ascending
{
	sortItemsSetAscending = ascending;
	[self generateItemsArrayFromItemsSet];
}

- (SCClassDefinition *)getClassDefinitionForObject:(NSObject *)object
{
	SCClassDefinition *objectClassDef = nil;
	
	if(coreDataBound)
	{
#ifdef _COREDATADEFINES_H		
		NSManagedObject *managedObj = (NSManagedObject *)object;
		objectClassDef = [self.itemsClassDefinitions 
						  valueForKey:[[managedObj entity] name]];
		if(!objectClassDef)
			objectClassDef = [SCClassDefinition definitionWithEntityName:[[managedObj entity] name]
												withManagedObjectContext:[managedObj managedObjectContext]
										 autoGeneratePropertyDefinitions:YES];
#endif		
	}
	else
	{
		objectClassDef = [self.itemsClassDefinitions valueForKey:[NSString stringWithFormat:@"%s",
												 class_getName([object class])]];
		if(!objectClassDef)
			objectClassDef = [SCClassDefinition definitionWithClass:[object class]
									autoGeneratePropertyDefinitions:YES];
	}
	
	return objectClassDef;
}

- (void)generateItemsArrayFromItemsSet
{
	if(!self.itemsSet)
	{
		self.items = nil;
		return;
	}
	
	NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.itemsSet allObjects]]; 
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] 
									initWithKey:[self firstClassDefinition].keyPropertyName
									ascending:self.sortItemsSetAscending];
	[sortedArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release];
	
	self.items = sortedArray;
}

- (SCClassDefinition *)firstClassDefinition
{
	SCClassDefinition *classDef = nil;
	if([self.itemsClassDefinitions count])
	{
		classDef = [self.itemsClassDefinitions 
							valueForKey:[[self.itemsClassDefinitions allKeys] objectAtIndex:0]];
	}
	
	return classDef;
}


#ifdef _COREDATADEFINES_H
- (void)registerWithManagedObjectContextNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(deleteCoreDataTempObject) 
												 name:NSManagedObjectContextWillSaveNotification 
											   object:nil];
}

- (void)deleteCoreDataTempObject
{
	if([tempItem isKindOfClass:[NSManagedObject class]])
	{
		[[self firstClassDefinition].managedObjectContext deleteObject:(NSManagedObject *)tempItem];
		
		tempItem = nil;
	}
}
#endif

@end








@interface SCSelectionSection ()

- (void)buildSelectedItemsIndexesFromString:(NSString *)string;
- (NSString *)buildStringFromSelectedItemsIndexes;

- (void)deselectLastSelectedRow;
- (void)dismissViewController;

@end



@implementation SCSelectionSection

@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize autoDismissViewController;

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectedIndexPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object withSelectedIndexPropertyName:propertyName 
											withItems:sectionItems] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object withSelectedIndexesPropertyName:propertyName 
											withItems:sectionItems 
								allowMultipleSelection:multipleSelection] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectionStringPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
									  withBoundObject:object 
					  withSelectionStringPropertyName:propertyName 
											withItems:sectionItems] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withBoundKey:(NSString *)key 
	  withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				   withItems:(NSArray *)sectionItems
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
										 withBoundKey:key withSelectedIndexValue:selectedIndexValue 
											withItems:sectionItems] autorelease];
}

+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
					 withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				   withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	return [[[[self class] alloc] initWithHeaderTitle:sectionHeaderTitle 
											  withBoundKey:key withSelectedIndexesValue:selectedIndexesValue 
											withItems:sectionItems 
								allowMultipleSelection:multipleSelection] autorelease];
}

- (id)init
{
	if( (self=[super init]) )
	{
		boundToNSNumber = FALSE;
		boundToNSString = FALSE;
		lastSelectedRowIndexPath = nil;
		itemsAccessoryType = UITableViewCellAccessoryCheckmark;
		allowAddingItems = FALSE;
		allowDeletingItems = FALSE;
		allowMovingItems = FALSE;
		allowEditDetailView = FALSE;
		
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		autoDismissViewController = FALSE;
		_selectedItemsIndexes = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectedIndexPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = [object retain];
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [self.boundObject valueForKey:propertyName]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		boundToNSNumber = TRUE;
		allowMultipleSelection = FALSE;
		
		if(self.boundValue)
			[self.selectedItemsIndexes addObject:self.boundValue];
		
		if(self.boundObject && !self.boundValue)
			self.boundValue = [NSNumber numberWithInt:-1];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = [object retain];
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [self.boundObject valueForKey:propertyName]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		allowMultipleSelection = multipleSelection;
		
		if(self.boundObject && !self.boundValue)
			self.boundValue = [NSMutableSet set];   //Empty set
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectionStringPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundObject = [object retain];
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [self.boundObject valueForKey:propertyName]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
		
		boundToNSString = TRUE;
		allowMultipleSelection = FALSE;
		
		if([self.boundValue isKindOfClass:[NSString class]] && self.items)
		{
			[self buildSelectedItemsIndexesFromString:(NSString *)self.boundValue];
		}
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key 
   withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				withItems:(NSArray *)sectionItems
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexValue;
		boundToNSNumber = TRUE;
		allowMultipleSelection = FALSE;
		
		if(self.boundValue)
			[self.selectedItemsIndexes addObject:self.boundValue];
		
		if(self.boundKey && !self.boundValue)
			self.boundValue = [NSNumber numberWithInt:-1];
	}
	return self;
}

- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				withItems:(NSArray *)sectionItems allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithHeaderTitle:sectionHeaderTitle withItems:[NSMutableArray arrayWithArray:sectionItems]])
	{
		boundKey = [key copy];
		self.boundValue = selectedIndexesValue;
		allowMultipleSelection = multipleSelection;
		
		if(self.boundKey && !self.boundValue)
			self.boundValue = [NSMutableSet set];   //Empty set
	}
	return self;
}

- (void)dealloc
{
	[_selectedItemsIndexes release];
	[lastSelectedRowIndexPath release];
	[super dealloc];
}

- (void)buildSelectedItemsIndexesFromString:(NSString *)string
{
	NSArray *selectionStrings = [string componentsSeparatedByString:@";"];
	
	[self.selectedItemsIndexes removeAllObjects];
	for(NSString *selectionString in selectionStrings)
	{
		int index = [self.items indexOfObject:selectionString];
		if(index != NSNotFound)
			[self.selectedItemsIndexes addObject:[NSNumber numberWithInt:index]];
	}
}

- (NSString *)buildStringFromSelectedItemsIndexes
{
	NSMutableArray *selectionStrings = [NSMutableArray arrayWithCapacity:[self.selectedItemsIndexes count]];
	for(NSNumber *index in self.selectedItemsIndexes)
	{
		[selectionStrings addObject:[self.items objectAtIndex:[index intValue]]];
	}
	
	return [selectionStrings componentsJoinedByString:@";"];
}

// override superclass method
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index
{
	SCTableViewCell *cell = [super cellAtIndex:index];
	
	if([self.selectedItemsIndexes containsObject:[NSNumber numberWithInt:index]])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.editable = FALSE;
	cell.movable = FALSE;
	
	return cell;
}

// override superclass method
- (NSString *)textForCellAtIndex:(NSUInteger)index
{
	id item = [self.items objectAtIndex:index];
	if([item isKindOfClass:[NSString class]])
		return (NSString *)item;
	//else
	return [super textForCellAtIndex:index];
}

- (void)deselectLastSelectedRow
{
	[self.ownerTableViewModel.modeledTableView deselectRowAtIndexPath:lastSelectedRowIndexPath
															 animated:YES];
}

// override superclass method
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableView *tableView = self.ownerTableViewModel.modeledTableView;
	NSNumber *itemIndex = [NSNumber numberWithInt:indexPath.row];
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	[lastSelectedRowIndexPath release];
	lastSelectedRowIndexPath = [indexPath retain];
	
	if([self.selectedItemsIndexes containsObject:itemIndex])
	{
		if(!self.allowNoSelection && self.selectedItemsIndexes.count==1)
		{
			[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.05];
			
			if(self.autoDismissViewController)
				[self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.4];
			return;
		}
		
		//uncheck cell and exit method
		[self.selectedItemsIndexes removeObject:itemIndex];
		selectedCell.accessoryType = UITableViewCellAccessoryNone;
		selectedCell.textLabel.textColor = [UIColor blackColor];
		[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
		[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.05];
		return;
	}
	
	if(!self.allowMultipleSelection && self.selectedItemsIndexes.count)
	{
		//uncheck old cell
		NSUInteger oldRowIndex =  [(NSNumber *)[self.selectedItemsIndexes anyObject] intValue];
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldRowIndex inSection:indexPath.section];
		[self.selectedItemsIndexes removeAllObjects];
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		oldCell.textLabel.textColor = [UIColor blackColor];
	}
	
	//check selected cell
	[self.selectedItemsIndexes addObject:itemIndex];
	if(boundToNSNumber)
		self.boundValue = self.selectedItemIndex;
	else
		if(boundToNSString)
			self.boundValue = [self buildStringFromSelectedItemsIndexes];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedCell.textLabel.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
	
	[self.ownerTableViewModel valueChangedForSectionAtIndex:indexPath.section];
	
	[self performSelector:@selector(deselectLastSelectedRow) withObject:nil afterDelay:0.1];
	
	if(self.autoDismissViewController)
		[self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.4];
}

- (void)dismissViewController
{
	if([self.ownerTableViewModel.viewController isKindOfClass:[SCTableViewController class]])
	{
		[(SCTableViewController *)self.ownerTableViewModel.viewController 
		 dismissWithCancelValue:FALSE doneValue:TRUE];
	}
}

- (NSMutableSet *)selectedItemsIndexes
{
	if(self.boundObject && !(boundToNSNumber || boundToNSString))
		return (NSMutableSet *)self.boundValue;
	//else
	return _selectedItemsIndexes;
}

- (void)setSelectedItemIndex:(NSNumber *)number
{
	NSNumber *num = [number copy];
	
	if(boundToNSNumber)
		self.boundValue = num;
	
	[self.selectedItemsIndexes removeAllObjects];
	if([number intValue] >= 0)
		[self.selectedItemsIndexes addObject:num];
	
	[num release];
}

- (NSNumber *)selectedItemIndex
{
	NSNumber *index = [self.selectedItemsIndexes anyObject];
	
	if(index)
		return index;
	//else
	return [NSNumber numberWithInt:-1];
}

@end








