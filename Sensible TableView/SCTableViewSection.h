/*
 *  SCTableViewSection.h
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

#import <Foundation/Foundation.h>
#import "SCClassDefinition.h"
#import "SCTableViewCell.h"
#import "SCTableViewController.h"


/****************************************************************************************/
/*	class SCTableViewSection	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a section for SCTableViewModel. Every %SCTableViewSection can contain
 *	any number of SCTableViewCell(s).
 */
@interface SCTableViewSection : NSObject
{
	id ownerViewControllerDelegate;		//internal
	
	SCTableViewModel *ownerTableViewModel;
	NSObject *boundObject;
	NSString *boundPropertyName;
	NSString *boundKey;
	NSObject *initialValue;
	BOOL commitCellChangesLive;
	BOOL coreDataBound;		// internal
	
	NSString *headerTitle;
	CGFloat headerHeight;
	UIView *headerView;
	NSString *footerTitle;
	CGFloat footerHeight;
	UIView *footerView;
	
	NSMutableArray *cells;
	NSArray *cellsImageViews;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCTableViewSection. */
+ (id)section;

/*! Allocates and returns an initialized %SCTableViewSection given a header title.
 *
 *	@param sectionHeaderTitle A header title for the section.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle;

/*! Allocates and returns an initialized %SCTableViewSection given a header and a footer title.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionFooterTitle A footer title for the section.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle 
			 withFooterTitle:(NSString *)sectionFooterTitle;

/*! Returns an initialized %SCTableViewSection given a header title.
 *
 *	@param sectionHeaderTitle A header title for the section.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle;

/*! Returns an initialized %SCTableViewSection given a header and a footer title.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionFooterTitle A footer title for the section.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle 
		  withFooterTitle:(NSString *)sectionFooterTitle;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The owner table view model of the section. 
 *
 * Important: This property gets set automatically by the section's owner, you should never
 * set this property manually */
@property (nonatomic, assign) SCTableViewModel *ownerTableViewModel;

/*! The section header title. */
@property (nonatomic, copy) NSString *headerTitle;

/*! The section header height. */
@property (nonatomic) CGFloat headerHeight;

/*! The section header view. This can be any subclass of UIView (e.g. UILabel or UIImageView).
 *	The section automatically adjusts the height of its header to accommodate this view. */
@property (nonatomic, retain) UIView *headerView;

/*! The section footer title. */
@property (nonatomic, copy) NSString *footerTitle;

/*! The section footer height. */
@property (nonatomic) CGFloat footerHeight;

/*! The section footer view. This can be any subclass of UIView (e.g. UILabel or UIImageView).
 *	The section automatically adjusts the height of its footer to accommodate this view. */
@property (nonatomic, retain) UIView *footerView;

/*! Set this property to an array of UIImageView objects to be set to each of the section's cells. */
@property (nonatomic, retain) NSArray *cellsImageViews;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cells
//////////////////////////////////////////////////////////////////////////////////////////

/*! The number of cells in the section. */
@property (nonatomic, readonly) NSUInteger cellCount;

/*! Adds a new cell to the section.
 *	@param cell Must be a valid non nil SCTableViewCell. */
- (void)addCell:(SCTableViewCell *)cell;

/*! Inserts a new cell into the section at the specified index.
 *	@param cell Must be a valid non nil SCTableViewCell.
 * @param index Must be less than the total number of cells. */
- (void)insertCell:(SCTableViewCell *)cell atIndex:(NSUInteger)index;

/*! Returns the cell at the specified index.
 * @param index Must be less than the total number of cells. */
- (SCTableViewCell *)cellAtIndex:(NSUInteger)index;

/*! Removes the cell at the specified index.
 * @param index Must be less than the total number of cells. */
- (void)removeCellAtIndex:(NSUInteger)index;

/*! Returns the index of the specified cell.
 *	@param cell Must be a valid non nil SCTableViewCell.
 *	@return If cell is not found, method returns NSNotFound. */
- (NSUInteger)indexForCell:(SCTableViewCell *)cell;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cell Values
//////////////////////////////////////////////////////////////////////////////////////////

/*!	This property is TRUE if all the section cells' values are valid, otherwise it's FALSE. */
@property (nonatomic, readonly) BOOL valuesAreValid;

/*! Set this property to TRUE for the section cells to commit their values as soon as they
 *	are changed. If this value is FALSE, the user must explicitly call commitCellChanges
 *	for the cells to commit their value changes. Default: TRUE. */
@property (nonatomic, readwrite) BOOL commitCellChangesLive;

/*! Commits value changes for all cells in section. This method needs to be called only
 *	if the commitCellChangesLive property is FALSE. */
- (void)commitCellChanges;

/*! Reload's the section's bound values in case the associated bound objects or keys valuea has changed
 *	by means other than the cells themselves (e.g. external custom code). */
- (void)reloadBoundValues;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties for Subclassing
//////////////////////////////////////////////////////////////////////////////////////////

/*! Provides subclasses with the framework to bind an SCTableViewSection to an NSObject */
@property (nonatomic, readonly) NSObject *boundObject;

/*! Provides subclasses with the framework to bind an SCTableViewSection to an NSObject */
@property (nonatomic, readonly) NSString *boundPropertyName;

/*! Provides subclasses with the framework to bind an SCTableViewSection to a key */
@property (nonatomic, readonly) NSString *boundKey;

/*! Provides subclasses with the framework to bind an SCTableViewSection to a value */
@property (nonatomic, retain) NSObject *boundValue;


@end






/****************************************************************************************/
/*	class SCObjectSection	*/
 /****************************************************************************************/ 
/*!
 *	This class functions as an SCTableViewModel section that is able to automatically generate
 *	its cells from a given bound object's properties. If the bound object is given without an extended
 *	class definition (SCClassDefinition), then cells will only be generated for properties of type 
 *	NSString and NSNumber, and will be either of type SCTextFieldCell or SCNumericTextFieldCell,
 *	respectively. If an SCClassDefinition is provided for the bound object, a full fledged
 *	section of cells will be generated.
 *
 *	Note: For your convenience, the tag property of each generated cell will have a number corresponding
 *	to the index of it's corresponding property in bound object.
 *
 *	See also: SCArrayOfObjectsSection, SCObjectCell.
 */
@interface SCObjectSection : SCTableViewSection
{
	SCClassDefinition *boundObjectClassDefinition;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCObjectSection given a header title and a bound object.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object that %SCObjectSection will use to generate its cells.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object;

/*! Allocates and returns an initialized %SCObjectSection given a header title, a bound object
 *	and its extended class definition.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object that %SCObjectSection will use to generate its cells.
 *	@param classDefinition The extended class definition for the object.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object
		 withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCObjectSection given a header title and a bound object.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object that %SCObjectSection will use to generate its cells.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object;

/*! Returns an initialized %SCObjectSection given a header title, a bound object
 *	and its extended class definition.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object that %SCObjectSection will use to generate its cells.
 *	@param classDefinition The extended class definition for the object.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object
	  withClassDefinition:(SCClassDefinition *)classDefinition;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Cell Management
//////////////////////////////////////////////////////////////////////////////////////////

/*!	Returns the cell associated with the given bound object's property name.
 *	@param propertyName The bound object's property name.
 *	@return Returns nil if no cell have been generated for the given property name, or
 *	if the property name does not exist within the bound object. */
- (SCTableViewCell *)cellForPropertyName:(NSString *)propertyName;

@end





/****************************************************************************************/
/*	class SCArrayOfItemsSection	*/
 /****************************************************************************************/ 
/*!
 *	This class functions as an SCTableViewModel section that is able to represent an array
 *	of any kind of items and automatically generate its cells from these items. The section
 *	is also able to handle all end-user interaction with the generated cells, including adding,
 *	editing, deleting, and moving the cells. When cells are added or edited, detail views are
 *	automatically generated for this purpose. To enable adding cells, the class' user should
 *	set the addButtonItem property of the section to a valid UIBarButtonItem, the section then
 *	will automatically add new items when the button is tapped. 
 *
 *	When adding new items to the array, the section starts by first asking the model's data source
 *	to provide a new item using its tableViewModel:newItemForArrayOfItemsSectionAtIndex: 
 *	SCTableViewModelDataSource protocol	method.
 *
 *	This class is an abstract base class. Subclasses of this class must override the
 *	buildDetailTableModel method. This method should return a model for the detail view to display.
 *
 *	Important: This is an abstract base class,  you should never make any direct instances of it.
 *
 *	See also: SCArrayOfStringsSection, SCArrayOfObjectsSection.
 *
 */
@interface SCArrayOfItemsSection : SCTableViewSection <SCTableViewControllerDelegate>
{
	//internal
	SCTableViewModel *tempDetailModel;
	
	NSMutableArray *items;
	UITableViewCellAccessoryType itemsAccessoryType;
	BOOL allowAddingItems;
	BOOL allowDeletingItems;
	BOOL allowMovingItems;
	BOOL allowEditDetailView;
	BOOL allowRowSelection;
	BOOL detailViewModal;
#ifdef __IPHONE_3_2	
	UIModalPresentationStyle detailViewModalPresentationStyle;
#endif
	UITableViewStyle detailTableViewStyle;
	BOOL detailViewHidesBottomBar;
	NSString *cellIdentifier;
	NSIndexPath *selectedCellIndexPath;
	UIBarButtonItem *addButtonItem;
	NSObject *tempItem;		//used for temporarily storing newly added items
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCArrayOfItemsSection given a header title and an array of items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItems An array of items that the section will use to generate its cells.
 *	This array must be of type NSMutableArray, as it must support the section's add, delete, and
 *	move operations. If you do not with to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, 
 *	and allowMovingItems properties.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems;

/*! Returns an initialized %SCArrayOfItemsSection given a header title and an array of items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItems An array of items that the section will use to generate its cells.
 *	This array must be of type NSMutableArray, as it must support the section's add, delete, and
 *	move operations. If you do not wish to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, 
 *	and allowMovingItems properties.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The array of items that the section uses to generate its cells from.
 *
 *	This array must be of type NSMutableArray, as it must support the section's add, delete, and
 *	move operations. If you do not wish to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, allowMovingItems,
 *	and allowEditDetailView properties. */
@property (nonatomic, retain) NSMutableArray *items;

/*! The accessory type of the generated cells. */
@property (nonatomic, readwrite) UITableViewCellAccessoryType itemsAccessoryType;

/*!	Allows/disables adding new cells/items to the items array. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowAddingItems;

/*! Allows/disables deleting new cells/items from the items array. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowDeletingItems;

/*! Allows/disables moving cells/items from one row to another. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowMovingItems;

/*! Allows/disables a detail view for editing items' values. Default: TRUE. 
 *
 *	Detail views are automatically generated for editing new items. You can control wether the
 *	view appears as a modal view or gets pushed to the navigation stack using the detailViewModal
 *	property. Modal views have the added feature of giving the end user a Cancel and Done buttons.
 *	The Cancel button cancels all user's actions, while the Done button commits them. Also, if the
 *	cell's validation is enabled, the Done button will remain disabled until all cells' values
 *	are valid.
 */
@property (nonatomic, readwrite) BOOL allowEditDetailView;

/*! Allows/disables row selection. */
@property (nonatomic, readwrite) BOOL allowRowSelection;

/*!	If TRUE, the detail view always appears as a modal view. If FALSE and a navigation controller
 *	exists, the detail view is pushed to the navigation controller's stack, otherwise the view
 *	appears modally. Default: FALSE.
 *
 *	Note: This value has no effect on the detail view generated to add new items, as it
 *	always appears modally.
 */
@property (nonatomic, readwrite) BOOL detailViewModal;

/*! The modal presentation style of the section's detail view. */
#ifdef __IPHONE_3_2	
@property (nonatomic, readwrite) UIModalPresentationStyle detailViewModalPresentationStyle;
#endif

/*!	The view style of the detail view's table. Default: UITableViewStyleGrouped. */
@property (nonatomic, readwrite) UITableViewStyle detailTableViewStyle;

/*! Indicates whether the bar at the bottom of the screen is hidden when the section's detail view is pushed. 
 *	Default: TRUE. 
 *	Note: Only applicable to cells with detail views. */
@property (nonatomic, readwrite) BOOL detailViewHidesBottomBar;

/*!	Set this property to a valid UIBarButtonItem. When addButtonItem is tapped and allowAddingItems
 *	is TRUE, a detail view is automatically generated for the user to enter the new items
 *	properties. If the properties are commited, a new item is added to the array */
@property (nonatomic, retain) UIBarButtonItem *addButtonItem;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Manual Event Control
//////////////////////////////////////////////////////////////////////////////////////////

/*! User can call this method to dispatch an AddNewItem event, the same event dispached
 *	when the end-user taps addButtonItem. */
- (void)dispatchAddNewItemEvent;

/*! User can call this method to dispatch a SelectRow event, the same event dispached
 *	when the end-user selects a cell. */
- (void)dispatchSelectRowAtIndexPathEvent:(NSIndexPath *)indexPath;

/*! User can call this method to dispatch a RemoveRow event, the same event dispached
 *	when the end-user taps the delete button on a cell. */
- (void)dispatchRemoveRowAtIndexPathEvent:(NSIndexPath *)indexPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties & Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*!	Subclasses should use this property when creating new dequeable cells */
@property (nonatomic, readonly) NSString *cellIdentifier;

/*!	Subclasses should override this method to handle the creation of section cells */
- (SCTableViewCell *)createCellAtIndex:(NSUInteger)index;

/*!	Subclasses should override this method to manage setting the properties cells after being dequed
 *	from the table view */
- (void)setPropertiesForCell:(SCTableViewCell *)cell withIndex:(NSUInteger)index;

/*! Subclasses should override this method to set the text for each generated cell */
- (NSString *)textForCellAtIndex:(NSUInteger)index;

/*! Subclasses should override this method to set the detail text for each generated cell */
- (NSString *)detailTextForCellAtIndex:(NSUInteger)index;

/*! Subclasses should override this method to handle when generated cells are selected */
- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

/*! Subclasses should override this method to handle when generated cells are deleted */
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forCellAtIndexPath:(NSIndexPath *)indexPath;

/*! Subclasses should override this method to handle when generated cells are moved */
- (void)moveCellAtIndexPath:(NSIndexPath *)fromIndexPath 
			   toIndexPath:(NSIndexPath *)toIndexPath;

/*! Subclasses should override this method to handle when addButtonItem is tapped */
- (void)didTapAddButtonItem;

/*! Subclasses should override this method to handle creating a new item */
- (NSObject *)createNewItem;

/*!	Subclasses must override this method to build a model for the generated detail view.
 *	@param detailTableModel This is an empty model. Method should add sections and cells to this model.
 *	@param item The item that the model should be built for. If item is nil, a model should be buil
 *	for a new item. */
- (void)buildDetailTableModel:(SCTableViewModel *)detailTableModel forItem:(NSObject *)item;

/*! Subclasses should override this method to handle adding a new item
 *	(method called internally by framework) */
- (void)addNewItem:(NSObject *)newItem;

/*! Method gets called internally by framework. */
- (void)tempDetailModelModified;

/*! Method gets called internally by framework. */
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel;

@end







/****************************************************************************************/
/*	class SCArrayOfStringsSection	*/
 /****************************************************************************************/ 
/*!
 *	This class functions as an SCTableViewModel section that is able to represent an array
 *	of string items and automatically generate its cells from these items. The class inherits
 *	all its funtionality from its superclass: SCArrayOfItemsSection, except that its items
 *	array can only contain items of type NSString.
 */
 
@interface SCArrayOfStringsSection : SCArrayOfItemsSection
{
}

@end






/****************************************************************************************/
/*	class SCArrayOfObjectsSection	*/
/****************************************************************************************/ 
/*!
 *	This class functions as an SCTableViewModel section that is able to represent an array
 *	of any kind of objects and automatically generate its cells from these objects. In addition,
 *	%SCArrayOfObjectsSection generates its detail views from the properties of the corresponding
 *	object in its items array. Objects in the items array need not all be of the same object type, but
 *	they must all decend from NSObject. If more than one type of object is present in the items
 *	array, then their respective class definitions should be added to the itemsClassDefinitions
 *	set.
 *
 *	See also: SCObjectSection, SCObjectCell.
 */
@interface SCArrayOfObjectsSection : SCArrayOfItemsSection
{
	NSMutableDictionary *itemsClassDefinitions;
	
	NSMutableSet *itemsSet;
	BOOL sortItemsSetAscending;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCArrayOfObjectsSection given a header title and an array of objects.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItems A mutable array of objects that the section will use to generate its cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				   withItems:(NSMutableArray *)sectionItems
		 withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Allocates and returns an initialized %SCArrayOfObjectsSection given a header title and 
 *	a mutable set of objects. This method should only be used to create a section with the contents
 *	of a Core Data relationship.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItemsSet A mutable set of objects that the section will use to generate its cells.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItemsSet:(NSMutableSet *)sectionItemsSet
		 withClassDefinition:(SCClassDefinition *)classDefinition;

#ifdef _COREDATADEFINES_H
/*! Allocates and returns an initialized %SCArrayOfObjectsSection given a header title and 
 *	an entity class definition. Note: This method creates a section with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a section with only a subset
 *	of these objects, consider using the other section initializers.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition;

/*! Allocates and returns an initialized %SCArrayOfObjectsSection given a header title, 
 *	an entity class definition, and an NSPredicate. 
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 *	@param perdicate The predicate that will be used to fetch the objects.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
			  usingPredicate:(NSPredicate *)predicate;
#endif

/*! Returns an initialized %SCArrayOfObjectsSection given a header title and an array of objects.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItems An array of objects that the section will use to generate its cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
				withItems:(NSMutableArray *)sectionItems
	  withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCArrayOfObjectsSection given a header title and 
 *	a mutable set of objects. This method should only be used to create a section with the contents
 *	of a Core Data relationship.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param sectionItemsSet A mutable set of objects that the section will use to generate its cells.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withItemsSet:(NSMutableSet *)sectionItemsSet
	  withClassDefinition:(SCClassDefinition *)classDefinition;

#ifdef _COREDATADEFINES_H
/*! Returns an initialized %SCArrayOfObjectsSection given a header title and 
 *	an entity class definition. Note: This method creates a section with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a section with only a subset
 *	of these objects, consider using the other section initializers.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
	withEntityClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCArrayOfObjectsSection given a header title, 
 *	an entity class definition, and an NSPredicate. 
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 *	@param perdicate The predicate that will be used to fetch the objects.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
   withEntityClassDefinition:(SCClassDefinition *)classDefinition
			  usingPredicate:(NSPredicate *)predicate;
#endif

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*!	Contains all the different class definitions of all the objects in the items array. Each
 *	dictionary entry should contain a key with the SCClassDefinition class name, and a value 
 *	with the actual SCClassDefinition.
 *
 *	Tip: The class name of the SCClassDefinition can be easily determined using the
 *	SClassDefinition.className property.
 */
@property (nonatomic, readonly) NSMutableDictionary *itemsClassDefinitions;

/*! The mutable set of objects that the section will use to generate its cells. Note: 
 This property should only be set when representing a Core Data relationship. */
@property (nonatomic, retain) NSMutableSet *itemsSet;

/*! If TRUE,  objects in itemsSet are sorted ascendingly, otherwise they're sorted descendingly.
 *	Note: Only applicable if itemsSet has been assigned. */
@property (nonatomic) BOOL sortItemsSetAscending;


@end







/****************************************************************************************/
/*	class SCSelectionSection	*/
/****************************************************************************************/ 
/*!
 *	This class functions as an SCTableViewModel section that is able to provide selection functionality. 
 *	The cells in this section represent different items	that the end-user can select from, and they
 *	are generated from NSStrings in its items array. Once a cell is selected, a checkmark appears next
 *	to it, similar to Apple's Settings application where a user selects a Ringtone for their
 *	iPhone. The section can be configured to allow multiple selection and to allow no selection
 *	at all.
 *	
 *	There are three ways to set/retrieve the section's selection:
 *	- Through binding an object to the section, and specifying a property name to bind the selection index
 *	result to. The bound property must be of type NSMutableSet if multiple selection is allowed, otherwise
 *	it must be of type NSNumber or NSString.
 *	- Through binding a key to the section and setting/retrieving through the ownerTableViewModel modelKeyValues property.
 *	- Through the selectedItemsIndexes or selectedItemIndex properties.
 *
 *	See also: SCSelectionCell.
 */ 
@interface SCSelectionSection : SCArrayOfItemsSection
{	
	BOOL boundToNSNumber;	//internal
	BOOL boundToNSString;	//internal
	NSIndexPath *lastSelectedRowIndexPath; //internal
	
	BOOL allowMultipleSelection;
	BOOL allowNoSelection;
	BOOL autoDismissViewController;
	NSMutableSet *_selectedItemsIndexes;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCSelectionSection given a header title, a bound object,
 *	an NSNumber bound property name, and an array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection. This property must
 *	be of type NSNumber and can't be a readonly property. The section will also initialize its selection 
 *	from the value present in this property.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
withSelectedIndexPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems;

/*! Allocates and returns an initialized %SCSelectionSection given a header title, a bound object,
 *	an NSMutableSet bound property name, an array of selection items, and wether to allow multiple selection.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection(s). This property must
 *	be of type NSMutableSet. The section will also initialize its selection(s) from the value present
 *	in this property.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectedIndexesPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems 
	   allowMultipleSelection:(BOOL)multipleSelection;

/*! Allocates and returns an initialized %SCSelectionSection given a header title, a bound object,
 *	an NSString bound property name, and an array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection. This property must
 *	be of type NSString and can't be a readonly property. The section will also initialize its selection 
 *	from the value present in this property.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectionStringPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems;

/*! Allocates and returns an initialized %SCSelectionSection given a header title, a bound key,
 *	an NSNumber bound property name, and array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param key The key the section will bind to and will automatically change its bound value to reflect
 *	the section's current selection. This value can be accessed using the ownerTableViewModel modelKeyValues property.
 *	@param selectedIndexValue A set with all the initially selected items' indexes.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type..
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withBoundKey:(NSString *)key 
	  withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				   withItems:(NSArray *)sectionItems;

/*! Allocates and returns an initialized %SCSelectionSection given a header title, a bound key,
 *	an NSMutableSet bound property name, an array of selection items, and wether to allow multiple selection.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param key The key the section will bind to and will automatically change its bound value to reflect
 *	the section's current selection(s). This value can be accessed using the ownerTableViewModel modelKeyValues property.
 *	@param selectedIndexesValue A set with all the initially selected items' indexes.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
+ (id)sectionWithHeaderTitle:(NSString *)sectionHeaderTitle
				withBoundKey:(NSString *)key 
	withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				   withItems:(NSArray *)sectionItems 
	   allowMultipleSelection:(BOOL)multipleSelection;

/*! Returns an initialized %SCSelectionSection given a header title, a bound object,
 *	an NSNumber bound property name, and an array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection. This property must
 *	be of type NSNumber and can't be a readonly property. The section will also initialize its selection 
 *	from the value present in this property.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectedIndexPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems;

/*! Returns an initialized %SCSelectionSection given a header title, a bound object,
 *	a bound property name, an array of selection items, and wether to allow multiple selection.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection(s). This property must
 *	be of type NSMutableSet. The section will also initialize its selection(s) from the value present
 *	in this property. Every item in this set must be an NSNumber that represent the index of the selected cell(s).
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
		  withBoundObject:(NSObject *)object 
			withSelectedIndexesPropertyName:(NSString *)propertyName 
				withItems:(NSArray *)sectionItems 
	allowMultipleSelection:(BOOL)multipleSelection;

/*! Returns an initialized %SCSelectionSection given a header title, a bound object,
 *	an NSString bound property name, and an array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param object The object the section will bind to.
 *	@param propertyName The property name present in the bound object that the section will bind to and
 *	will automatically change the value of to reflect the section's current selection. This property must
 *	be of type NSString and can't be a readonly property. The section will also initialize its selection 
 *	from the value present in this property.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundObject:(NSObject *)object 
				withSelectionStringPropertyName:(NSString *)propertyName 
				   withItems:(NSArray *)sectionItems;

/*! Returns an initialized %SCSelectionSection given a header title, a bound key,
 *	an NSNumber bound property name, an array of selection items.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param key The key the section will bind to and will automatically change its bound value to reflect
 *	the section's current selection. This value can be accessed using the ownerTableViewModel modelKeyValues property.
 *	@param selectedIndexValue A set with all the initially selected items' indexes.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type..
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key 
   withSelectedIndexValue:(NSNumber *)selectedIndexValue 
				withItems:(NSArray *)sectionItems;

/*! Returns an initialized %SCSelectionSection given a header title, a bound object,
 *	a bound property name, an array of selection items, and wether to allow multiple selection.
 *
 *	@param sectionHeaderTitle A header title for the section.
 *	@param key The key the section will bind to and will automatically change its bound value to reflect
 *	the section's current selection(s). This value can be accessed using the ownerTableViewModel modelKeyValues property.
 *	@param selectedIndexesValue A set with all the initially selected items' indexes.
 *	@param sectionItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
- (id)initWithHeaderTitle:(NSString *)sectionHeaderTitle
			 withBoundKey:(NSString *)key 
					withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue 
				withItems:(NSArray *)sectionItems 
	allowMultipleSelection:(BOOL)multipleSelection;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! This property reflects the current section's selection. You can set this property
 *	to define the section's selection.
 *
 *	Note: If you have bound this section to an object or a key, you can define the section's selection
 *	using either the bound property value or the key value, respectively. Note: In case of no selection,
 *	this property will be set to an NSNumber of value -1. */
@property (nonatomic, copy) NSNumber *selectedItemIndex;

/*! This property reflects the current section's selection(s). You can add index(es) to the set
 *	to define the section's selection.
 *
 *	Note: If you have bound this section to an object or a key, you can define the section's selection
 *	using either the bound property value or the key value, respectively. */
@property (nonatomic, readonly) NSMutableSet *selectedItemsIndexes;

/*! If TRUE, the section allows multiple selection. Default: FALSE. */
@property (nonatomic, readwrite) BOOL allowMultipleSelection;

/*! If TRUE, the section allows no selection at all. Default: FALSE. */
@property (nonatomic, readwrite) BOOL allowNoSelection;

/*! If TRUE, the section allows automatically dismisses the current view controller when a value is
 *	selected. Default: FALSE. */
@property (nonatomic, readwrite) BOOL autoDismissViewController;


@end




