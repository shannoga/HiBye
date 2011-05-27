/*
 *  SCTableViewModel.h
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
#import "SCTableViewSection.h"


/****************************************************************************************/
/*	class SCTableViewModel	*/
/****************************************************************************************/ 
/*!
 *	This class is the master mind behind all of Sensible TableView's functionality.
 *
 *	Sensible TableView provides an alternative easy way to create sophisticated table views very quickly. 
 *	The sophistication of these table views can range from simple text cells, to cells with controls, to
 *	cells that get automatically generated from your own classes. %SCTableViewModel also automatically
 *	generates detail views for common tasks such as selecting cell values or creating new objects.
 *	Using %SCTableViewModel, you can simply create full functioning applications in a matter of minutes.
 *
 *	%SCTableViewModel is designed to be loosely coupled with your user interface elements. What this
 *	means is that you can use %SCTableViewModel with Apple's default UITableView or with any of your 
 *	custom UITableView subclasses. Similarly, you can use %SCTableViewModel with any UIViewController, or
 *	any of its subclasses, including UITableViewController or your own subclasses. In addition,
 *	%SCTableViewModel's auto generated detail views will work whether you use a navigation controller or not.
 *
 *	Architecture:
 *
 *	An %SCTableViewModel defines a table view model with several sections, each section being of type 
 *	SCTableViewSection. Each SCTableViewSection can contain several cells, each cell being of type
 *	SCTableViewCell. %SCTableViewModel's functionality can also be extended using 
 *	SCTableViewModelDataSource and SCTableViewModelDelegate
 */

@interface SCTableViewModel : NSObject <UITableViewDataSource, UITableViewDelegate>
{
	//internal
	id target;
	SEL action;
	SCTableViewModel *masterModel;
	
	UITableView *modeledTableView;
	UIViewController *viewController;
	id dataSource;
	id delegate;
	UIBarButtonItem *editButtonItem;
	BOOL autoResizeForKeyboard;
	BOOL autoResizeStatus;
	BOOL keyboardShown;
	CGFloat keyboardOverlap;
	NSMutableArray *sections;
	NSArray *sectionIndexTitles;
	BOOL autoGenerateSectionIndexTitles;
	BOOL autoSortSections;
	BOOL hideSectionHeaderTitles;
	BOOL lockCellSelection;
	NSInteger tag;
	SCTableViewCell *previousActiveCell;
	SCTableViewCell *activeCell;
	NSMutableDictionary *modelKeyValues;
	UIBarButtonItem *commitButton;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCTableViewModel bound to a UITableView and a UIViewController. 
 *
 *	Upon the model's initialization, the model sets itself as the modeledTableView's dataSource and 
 *	delegate, and starts providing it with its sections and cells.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 */
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController;

/*! Returns an initialized %SCTableViewModel bound to a UITableView and a UIViewController.  
 *
 *	Upon the model's initialization, the model sets itself as the modeledTableView's dataSource and 
 *	delegate, and starts providing it with its sections and cells.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*!	When set to a valid UIBarButtonItem, SCTableViewModel automatically puts its table view
 *	in edit mode when the button is tapped. Note: Not required if your view controller is a UITableViewController 
 *	subclass, or if you do not wish to implement editing specific SCTableViewModelDelegate methods. */
@property (nonatomic, retain) UIBarButtonItem *editButtonItem;

/*! If TRUE, %SCTableViewModel will automatically resize the modeledTableView when the
 *	keyboard appears. Property has no effect if viewController is a UITableViewController,
 *	as the UITableViewController will handle the resizing itself. Default: TRUE.*/
@property (nonatomic, readwrite) BOOL autoResizeForKeyboard;

/*! An array of strings that serve as the title of sections in the modeledTableView and 
 * appear in the index list on the right side of the modeledTableView. modeledTableView
 * must be in plain style for the index to appear. */
@property (nonatomic, retain) NSArray *sectionIndexTitles;

/*! If TRUE, %SCTableViewModel will automatically generate the sectionIndexTitles array from
 *	the first letter of each section's header title. Default: FALSE. */
@property (nonatomic, readwrite) BOOL autoGenerateSectionIndexTitles;

/*! If TRUE, %SCTableViewModel will automatically sort its sections according to their header
 *	title value. Default: FALSE. */
@property (nonatomic, readwrite) BOOL autoSortSections;

/*! If TRUE, all section header titles will be hidden. Default: FALSE. */
@property (nonatomic, readwrite) BOOL hideSectionHeaderTitles;

/*! If TRUE, %SCTableViewModel will prevent any cell from being selected. Default: FALSE. 
 *	Note: for preventing individual cells from being selected, use SCTableViewCell "selectable" property. */
@property (nonatomic, readwrite) BOOL lockCellSelection;

/*! An integer that you can use to identify different table view models in your application. */
@property (nonatomic, readwrite) NSInteger tag;

/*! Pauses auto resizing when keyboard appears. This method should be called before displaying
 *	any of your own detail view controllers on top of the model's view controller. This is to disable
 *	the model from processing and acting to keyboard notifications. */
- (void)pauseAutoResizeForKeyboard;

/*! Resumes auto resizing if autoResizeForKeyboard was TRUE at the time pauseAutoResizeForKeyboard
 *	was called, otherwise it does nothing. Method should be called after your own detail controller
 *	disappears. This method should only be called if pauseAutoResizeForKeyboard was called first. */
 - (void)resumeAutoResizeForKeyboard;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Sections
//////////////////////////////////////////////////////////////////////////////////////////

/*! The number of sections in the model. */
@property (nonatomic, readonly) NSUInteger sectionCount;

/*! Adds a new section to the model. 
 *	@param section Must be a valid non nil SCTableViewSection. */
- (void)addSection:(SCTableViewSection *)section;

/*! Inserts a new section at the specified index. 
 *	@param section Must be a valid non nil SCTableViewSection.
 *	@param index Must be less than the total number of sections. */
- (void)insertSection:(SCTableViewSection *)section atIndex:(NSUInteger)index;

/*! Returns the section at the specified index.
 *	@param index Must be less than the total number of sections. */
- (SCTableViewSection *)sectionAtIndex:(NSUInteger)index;

/*! Returns the first section with the specified header title.
 *	@param title The header title. */
- (SCTableViewSection *)sectionWithHeaderTitle:(NSString *)title;

/*! Returns the index of the specified section. 
 *	@param section Must be a valid non nil SCTableViewSection.
 *	@return If section is not found, method returns NSNotFound. */
- (NSUInteger)indexForSection:(SCTableViewSection *)section;

/*! Removes the section at the specified index from the model.
 *	@param index Must be less than the total number of section. */
- (void)removeSectionAtIndex:(NSUInteger)index;

/* Removes all sections from the model. */
- (void)removeAllSections;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cells
//////////////////////////////////////////////////////////////////////////////////////////

/*! The cell that was active previous to the current activeCell. */
@property (nonatomic, readonly) SCTableViewCell *previousActiveCell;

/*! The current active cell. A cell becomes active if it is selected or if its value changes. */
@property (nonatomic, assign) SCTableViewCell *activeCell;

/*! The indexPath of the activeCell. */
@property (nonatomic, readonly) NSIndexPath *activeCellIndexPath;

/*! Returns the cell at the specified indexPath.
 *	@param indexPath Must be a valid non nil NSIndexPath. */
- (SCTableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

/*! Returns the index path for the specified cell.
 *	@param cell Must be a valid non nil SCTableViewCell.
 *	@return If cell is not found, method returns NSNotFound. */
- (NSIndexPath *)indexPathForCell:(SCTableViewCell *)cell;
 
/*! Returns the cell that comes after the specified cell in the model.
 *	@param cell Must be a valid non nil SCTableViewCell.
 *	@param rewind If TRUE and cell is the very last cell in the model, method returns
 *			the cell at the very top.
 *	@return Returns nil if cell is the last cell in the model and rewind is FALSE, or if
 *			cell does not exist in the model. */
- (SCTableViewCell *)cellAfterCell:(SCTableViewCell *)cell rewindIfLastCell:(BOOL)rewind;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Model Values
//////////////////////////////////////////////////////////////////////////////////////////

/*! An NSMutableDictionary of all the model's key/value pairs. The keys and their respective
 *	values are present only if the model's cells and sections are bound to these keys. */
@property (nonatomic, readonly) NSMutableDictionary *modelKeyValues;

/*! TRUE if all the model's section and cell values are valid. */
@property (nonatomic, readonly) BOOL valuesAreValid;

/*! %SCTableViewModel will automatically enable/disable the commitButton based on the
 *	valuesAreValid property, where commitButton is enabled if valuesAreValid is TRUE. */
@property (nonatomic, retain) UIBarButtonItem *commitButton;

/*! Reload's the model's bound values in case the associated bound objects or keys valuea has changed
 *	by means other than the cells themselves (e.g. external custom code). */
- (void)reloadBoundValues;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing the Data Source and Delegate
//////////////////////////////////////////////////////////////////////////////////////////

/*! The object that acts as the data source of %SCTableViewModel. 
 *	The object must adopt the SCTableViewModelDataSource protocol. */
@property (nonatomic, assign) id dataSource;

/*! The object that acts as the delegate of %SCTableViewModel. 
 *	The object must adopt the SCTableViewModelDelegate protocol. */
@property (nonatomic, assign) id delegate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Miscellaneous
//////////////////////////////////////////////////////////////////////////////////////////

/*!	The UITableView bound to %SCTableViewModel. This property is readonly, to set modeledTableView, 
 *	use the class initilizers. */
@property (nonatomic, readonly) UITableView *modeledTableView;

/*!	The UIViewController bound to %SCTableViewModel. This property is readonly, to set viewController, 
 *	use the class initilizers. */
@property (nonatomic, readonly) UIViewController *viewController;

/*! Clears all contents of the model. */
- (void)clear;
 
//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties & Methods (should only be used internally by the framework)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Property is used internally by the framework to set the master model in a master-detail 
	relationship. */
@property (nonatomic, assign) SCTableViewModel *masterModel;

/*! Method gets called internally whenever the value of a section changes. This method 
 *	should only be used when subclassing %SCTableViewModel. If what you want is to get notified
 *	when a section value changes, consider using SCTableViewModelDelegate methods.
 *
 *	When subclassing %SCTableViewModel, you can override this method to define custom behaviour when a 
 *	section value changes. However, you should always call [super valueChangedForSectionAtIndex:]
 *	somewhere in your subclassed method.
 *
 *	@param index Index of the section changed.
 */
- (void)valueChangedForSectionAtIndex:(NSUInteger)index;

/*! Method gets called internally whenever the value of a cell changes. This method 
 *	should only be used when subclassing %SCTableViewModel. If what you want is to get notified
 *	when a cell value changes, consider using either SCTableViewModelDelegate or 
 *	SCTableViewCellDelegate methods.
 *
 *	When subclassing %SCTableViewModel, you can override this method to define custom behaviour when a 
 *	cell value changes. However, you should always call [super valueChangedForRowAtIndexPath:]
 *	somewhere in your subclassed method.
 *
 *	@param indexPath Index path of the cell changed.
 */
- (void)valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Method used internally by the framework to monitor model modification events. */
- (void)setTargetForModelModifiedEvent:(id)_target action:(SEL)_action;

/*! Subclasses should override this method to handle when editButtonItem is tapped. */
- (void)didTapEditButtonItem;

/*! Method used internally to replace the modeled tableview. */
- (void)replaceModeledTableViewWith:(UITableView *)tableView;


@end




@class SCArrayOfItemsModel;
/****************************************************************************************/
/*	protocol SCTableViewModelDataSource	*/
/****************************************************************************************/ 
/*!
 *	This protocol should be adopted by objects that want to mediate as a data source for 
 *	SCTableViewModel. All methods for this protocol are optional.
 */
@protocol SCTableViewModelDataSource

@optional

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Custom detail views
//////////////////////////////////////////////////////////////////////////////////////////

/*! Asks the dataSource to provide a custom detail table view model for the specified cell. 
 *	This custom table view model will be used to render the cell's details instead of the default 
 *	automatically generated detail model. The returned model is typically a blank model with no 
 *	sections (all content will be generated by the requesting cell).
 *	Important: This method should only be implemented for cells that require a detail
 *	UITableView to display their contents. For cells that do not require a detail UITableView
 *	(e.g.: SCImagePickerCell), you should implement the tableViewModel:customDetailViewForRowAtIndexPath:
 *	method instead.
 *	Note: This method is typically used to display the cell's details in the detail view of an
 *	iPad's UISplitViewController.
 *
 *	@param tableViewModel The model requesting the custom detail table view model.
 *	@param indexPath The index path of the cell whose detail table view model is requested. 
 *	@return The custom detail table view model. This model should be autoreleased and is typically
 *	a blank model that the requesting cell will generate the content for.
 */
- (SCTableViewModel *)tableViewModel:(SCTableViewModel *)tableViewModel
   customDetailTableViewModelForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Asks the dataSource to provide a custom detail view controller for the specified cell. 
 *	This custom detail view will be used to render the cell's details instead of the default 
 *	automatically generated detail view controller.
 *	Important: This method should only be implemented for cells that do not require a detail
 *	UITableView to display their contents (e.g.: SCImagePickerCell). For all other cells that do require a detail 
 *	UITableView, you should implement the tableViewModel:customTableViewModelForRowAtIndexPath:
 *	method instead.
 *	Note: This method is typically used to display the cell's details in the detail view of an
 *	iPad's UISplitViewController.
 *
 *	@param tableViewModel The model requesting the custom detail view controller.
 *	@param indexPath The index path of the cell whose detail view controller is requested. 
 *	@return The custom detail view controller. This view controller is typically
 *	a blank view controller that the requesting cell will generate the content for.
 */
- (UIViewController *)tableViewModel:(SCTableViewModel *)tableViewModel
	customDetailViewForRowAtIndexPath:(NSIndexPath *)indexPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Inserting, Deleting, or Moving Model Rows
//////////////////////////////////////////////////////////////////////////////////////////

/*!	Asks the dataSource to handle to the insertion or deletion of the specified row in the 
 *	model. 
 *
 *	Important: It is very rare when you'll need to define this method. If you are using
 *	an SCArrayOfItemsSection or any of its subclasses, the insertion and deletion of rows
 *	will be handeled for you automatically.
 *
 *	@param tableViewModel The model requesting the insertion or deletion.
 *	@param editingStyle The cell editing style corresponding to a insertion or deletion requested 
 *	for the row specified by indexPath. Possible editing styles are UITableViewCellEditingStyleInsert 
 *	or UITableViewCellEditingStyleDelete.
 *	@param indexPath The index path locating the row in the model.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	 forRowAtIndexPath:(NSIndexPath *)indexPath;

/*!	Asks the dataSource to handle to the movement of the specified row in the 
 *	model from a specified location to another. 
 *
 *	Important: It is very rare when you'll need to define this method. If you are using
 *	an SCArrayOfItemsSection or any of its subclasses, the movement of rows
 *	will be handeled for you automatically.
 *
 *	@param tableViewModel The model requesting the row movement.
 *	@param fromIndexPath The starting index path of the row to be moved.
 *	@param toIndexPath The destination index path of the move.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
		   toIndexPath:(NSIndexPath *)toIndexPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name SCArrayOfItemsModel methods
//////////////////////////////////////////////////////////////////////////////////////////

/*! Asks the dataSource to return the section header title for the given item index.
 *
 *	@param tableViewModel The model requesting the section header title.
 *	@param item The item whose setion header title is requested.
 *	@param index The index of item in SCArrayOfItemsModel.
 *	@return The method should return an autoreleased NSString header title.
 */
- (NSString *)tableViewModel:(SCArrayOfItemsModel *)tableViewModel
   sectionHeaderTitleForItem:(NSObject *)item AtIndex:(NSUInteger)index;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name New Object Creation
//////////////////////////////////////////////////////////////////////////////////////////

/*! Asks the dataSource to handle the creation of a new item in an SCArrayOfItemsSection.
 *
 *	When there is an attempt to create a new array item in an SCArrayOfItemsSection, the
 *	dataSource is asked to provide this new item. If the dataSource does not define this method,
 *	SCArrayOfItemsSection creates an item of the same class as the first item in the array.
 *	If no items are in the array, and this method is not defined, no new objects can be created.
 *
 *	@param tableViewModel The model requesting owning the array of objects section.
 *	@param index The index of the array of items section requesting the new item.
 *	@return The method should return an autoreleased new item that is a subclass of NSObject.
 */
- (NSObject *)tableViewModel:(SCTableViewModel *)tableViewModel
	newItemForArrayOfItemsSectionAtIndex:(NSUInteger)index;

@end





/****************************************************************************************/
/*	protocol SCTableViewModelDelegate	*/
/****************************************************************************************/ 
/*!
 *	This protocol should be adopted by objects that want to mediate as a delegate for 
 *	SCTableViewModel. All methods for this protocol are optional.
 */
@protocol SCTableViewModelDelegate

@optional

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing TableView Model
//////////////////////////////////////////////////////////////////////////////////////////

/*! Notifies the delegate that the table view will enter editing mode. Note: For this method
 *	to get fired, the SCTableViewModel editButtonItem property must be set. */
- (void)tableViewModelWillBeginEditing:(SCTableViewModel *)tableViewModel;

/*! Notifies the delegate that the table view did enter editing mode. Note: For this method
 *	to get fired, the SCTableViewModel editButtonItem property must be set. */
- (void)tableViewModelDidBeginEditing:(SCTableViewModel *)tableViewModel;

/*! Notifies the delegate that the table view will exit editing mode. Note: For this method
 *	to get fired, the SCTableViewModel editButtonItem property must be set. */
- (void)tableViewModelWillEndEditing:(SCTableViewModel *)tableViewModel;

/*! Notifies the delegate that the table view did exit editing mode. Note: For this method
 *	to get fired, the SCTableViewModel editButtonItem property must be set. */
- (void)tableViewModelDidEndEditing:(SCTableViewModel *)tableViewModel;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Sections
//////////////////////////////////////////////////////////////////////////////////////////

/*! Notifies the delegate that the value for the section at the specified index has changed.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param index The index of the section who's value has changed.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	valueChangedForSectionAtIndex:(NSUInteger)index;	

/*! Notifies the delegate that the detail view for the section at the specified index will appear.
 *	This is the perfect time to do any customizations to the section's detail view model.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param index The index of the section who's detail view will appear.
 *	@param detailTableViewModel The model for the section's detail view.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewWillAppearForSectionAtIndex:(NSUInteger)index
	withDetailTableViewModel:(SCTableViewModel *)detailTableViewModel;

/*! Notifies the delegate that the detail view for the section at the specified index will disappear.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param index The index of the section who's detail view will disappear.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewWillDisappearForSectionAtIndex:(NSUInteger)index;

/*! Notifies the delegate that the detail view for the section at the specified index has disappeared.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param index The index of the section who's detail view has disappeared.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewDidDisappearForSectionAtIndex:(NSUInteger)index;

/*! Notifies the delegate that a new item bound cell has been created for the section at the specified index.
 *	Note: Method usually called for SCArrayOfItemsSection's subclasses. 
 *	Important: Although item has been created, it's still not added to the section and can be deallocated
 *	if the user cancels the item's detail view.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param index The index of the section who's a new item has been created for.
 *	@param item The item that has been created.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	itemCreatedForSectionAtIndex:(NSUInteger)index item:(NSObject *)item;

/*! Notifies the delegate that a new item bound cell has been added to a section at the specified indexPath.
 *	Note: Method usually called for SCArrayOfItemsSection's subclasses.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path the new item bound cell has been added to.
 *	@param item The item that has been added.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	itemAddedForSectionAtIndexPath:(NSIndexPath *)indexPath item:(NSObject *)item;

/*! Notifies the delegate that an item bound cell has been edited for a section at the specified indexPath.
 *	Note: Method usually called for SCArrayOfItemsSection's subclasses.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path the new item bound cell has been added to.
 *	@param item The item that has been edited.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	itemEditedForSectionAtIndexPath:(NSIndexPath *)indexPath item:(NSObject *)item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cells
//////////////////////////////////////////////////////////////////////////////////////////

/*! Notifies the delegate that the cell at the specified indexPath is about to be configured in its owner UITableView. 
 *	This is the perfect time to do any customization to the cell's height, editable, and movable properties.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param cell The cell that is about to layout controls.
 *	@param indexPath The index path of the cell.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	   willConfigureCell:(SCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the cell at the specified indexPath will be displayed. This is 
 *	the perfect place to do any customization to the cell's appearance.
 *
 *	Note: To change cell properties like the height, editable, or movable states, 
 *	use the willConfigureCell delegate method instead.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param cell The cell that will be displayed.
 *	@param indexPath The index path of the cell that will be displayed.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	   willDisplayCell:(SCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the cell at the specified indexPath will be selected.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell that will be selected.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the cell at the specified indexPath has been selected.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell that has been selected.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the cell at the specified indexPath has been deselected.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell that has been deselected.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the accessory button for the cell at the 
 *	specified indexPath has been selected.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell with the accessory button.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the value of the cell at the specified indexPath has changed.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell who's value has changed.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Asks the delegate if the value is valid for the cell at the specified indexPath.
 *	Define this method if you want to override the cells' default value validation and provide 
 *	your own custom validation.
 *	
 *	@param tableViewModel The model asking the delegate for validation.
 *	@param indexPath The index path of the cell who's value needs validation.
 */
- (BOOL)tableViewModel:(SCTableViewModel *)tableViewModel 
	valueIsValidForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the return keyboard button has been tapped for the cell
 *	at the specified indexPath. Define this method if you want to override the cells'
 *	default behaviour for tapping the return button.
 *	
 *	@param tableViewModel The model asking the delegate for validation.
 *	@param indexPath The index path of the cell who's keyboard return key has been tapped.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	returnButtonTappedForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that cell at the specified indexPath has been newly inserted.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell who has been newly inserted.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel 
	didInsertRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that cell at the specified indexPath will be removed.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell who will be removed.
 *	@return Return TRUE to proceed with the remove operation, otherwise return FALSE.
 */
- (BOOL)tableViewModel:(SCTableViewModel *)tableViewModel 
	willRemoveRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the detail view for the cell at the specified indexPath will appear.
 *	This is the perfect time to do any customizations to the cell's detail view model.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index path of the cell who's detail view will appear.
 *	@param detailTableViewModel The model for the cell's detail view.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewWillAppearForRowAtIndexPath:(NSIndexPath *)indexPath
		withDetailTableViewModel:(SCTableViewModel *)detailTableViewModel;

/*! Notifies the delegate that the detail view for the cell at the specified indexPath will disappear.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index of the cell who's detail view will disappear.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewWillDisappearForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Notifies the delegate that the detail view for the cell at the specified indexPath has disappeared.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param indexPath The index of the cell who's detail view has disappeared.
 */
- (void)tableViewModel:(SCTableViewModel *)tableViewModel
	detailViewDidDisappearForRowAtIndexPath:(NSIndexPath *)indexPath;

/*! Asks the delegate for a new image name for the SCImagePickerCell at the specified indexPath.
 *	Define this method to provide a new name for the selected image, instead of using the auto generated one.
 *	
 *	@param tableViewModel The model asking the delegate for validation.
 *	@param indexPath The index path of the SCImagePickerCell who needs a new image name.
 */
- (NSString *)tableViewModel:(SCTableViewModel *)tableViewModel 
	newImageNameForRowAtIndexPath:(NSIndexPath *)indexPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name SCArrayOfItemsModel methods
//////////////////////////////////////////////////////////////////////////////////////////

/*! Notifies the delegate that the search bar scope button selection changed.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 *	@param selectedScope The index of the selected scope button.
 */
- (void)tableViewModel:(SCArrayOfItemsModel *)tableViewModel
	searchBarSelectedScopeButtonIndexDidChange:(NSInteger)selectedScope;

/*! Notifies the delegate that the search bar bookmark button was tapped.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 */
- (void)tableViewModelSearchBarBookmarkButtonClicked:(SCArrayOfItemsModel *)tableViewModel;

/*! Notifies the delegate that the search bar cancel button was tapped.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 */
- (void)tableViewModelSearchBarCancelButtonClicked:(SCArrayOfItemsModel *)tableViewModel;

/*! Notifies the delegate that the search bar results list button was tapped.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 */
- (void)tableViewModelSearchBarResultsListButtonClicked:(SCArrayOfItemsModel *)tableViewModel;

/*! Notifies the delegate that the search bar search button was tapped.
 *	
 *	@param tableViewModel The model informing the delegate of the event.
 */
- (void)tableViewModelSearchBarSearchButtonClicked:(SCArrayOfItemsModel *)tableViewModel;


@end






/****************************************************************************************/
/*	class SCArrayOfItemsModel	*/
/****************************************************************************************/ 
/*!
 *	This class subclasses SCTableViewModel to represent an array
 *	of any kind of items and will automatically generate its cells from these items. %SCArrayOfItemsModel 
 *	will automatically generate a set of SCArrayOfItemsSection(s) if the SCTableViewModelDataSource method 
 *	tableViewModel:sectionHeaderTitleForItem:AtIndex: is implemented, otherwise it will only generate a single 
 *	SCArrayOfItemsSection.
 *
 *	Important: This is an abstract base class, you should never make any direct instances of it.
 *
 *	See also: SCArrayOfStringsModel, SCArrayOfObjectsModel, SCArrayOfStringsSection, SCArrayOfObjectsSection.
 *
 */
@interface SCArrayOfItemsModel : SCTableViewModel <SCTableViewControllerDelegate, UISearchBarDelegate>
{
	SCArrayOfItemsSection *tempSection;		//internal
	NSArray *filteredArray;					//internal
	
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
	
	UISearchBar *searchBar;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Returns an initialized %SCArrayOfItemsModel given a UITableView, UIViewController, 
 *	and an array of items.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param _items An array of items that the model will use to generate its cells.
 *	This array must be of type NSMutableArray, as it must support the model's add, delete, and
 *	move operations. If you do not with to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, 
 *	and allowMovingItems properties.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
	withViewController:(UIViewController *)_viewController
				withItems:(NSMutableArray *)_items;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The array of items that the model uses to generate its cells from.
 *
 *	This array must be of type NSMutableArray, as it must support the model's add, delete, and
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

/*! Allows/disables moving cells/items from one row to another. Default: FALSE. */
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

/*! The search bar associated with the model. Once set to a valid UISearchBar, the model will
 *	automatically filter its items based on the user's typed search term. */
@property (nonatomic, retain) UISearchBar *searchBar;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties & Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Subclasses should override this method to handle section creation. */
- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title;

/*! Subclasses should override this method to set additional section properties after creation. */
- (void)setPropertiesForSection:(SCArrayOfItemsSection *)section;

/*! Subclasses should override this method to handle when addButtonItem is tapped. */
- (void)didTapAddButtonItem;

/*! Method called internally by framework when the model should add a new item. */
- (void)addNewItem:(NSObject *)newItem;

@end







/****************************************************************************************/
/*	class SCArrayOfStringsModel	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a table view model that is able to represent an array
 *	of string items and automatically generate its cells from these items. The class inherits
 *	all its funtionality from its superclass: SCArrayOfItemsModel, except that its items
 *	array can only contain items of type NSString. %SCArrayOfStringsModel 
 *	will automatically generate a set of SCArrayOfStringsSection(s) if the SCTableViewModelDataSource method 
 *	tableViewModel:sectionHeaderTitleForItem:AtIndex: is implemented, otherwise it will only generate a single 
 *	SCArrayOfStringsSection.
 */

@interface SCArrayOfStringsModel : SCArrayOfItemsModel
{
}

@end






/****************************************************************************************/
/*	class SCArrayOfObjectsModel	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a table view model that is able to represent an array
 *	of any kind of objects and automatically generate its cells from these objects. In addition,
 *	%SCArrayOfObjectsModel generates its detail views from the properties of the corresponding
 *	object in its items array. Objects in the items array need not all be of the same object type, but
 *	they must all decend from NSObject. If more than one type of object is present in the items
 *	array, then their respective class definitions should be added to the itemsClassDefinitions
 *	set.
 *
 *	%SCArrayOfItemsModel 
 *	will automatically generate a set of SCArrayOfObjectsSection(s) if the SCTableViewModelDataSource method 
 *	tableViewModel:sectionHeaderTitleForItem:AtIndex: is implemented, otherwise it will only generate a single 
 *	SCArrayOfObjectsSection.
 */
@interface SCArrayOfObjectsModel : SCArrayOfItemsModel
{
	NSMutableDictionary *itemsClassDefinitions;
	
	NSMutableSet *itemsSet;
	BOOL sortItemsSetAscending;
	NSString *searchPropertyName;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and an array of objects.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param _items An array of objects that the model will use to generate its cells.
 *	This array must be of type NSMutableArray, as it must support the model's add, delete, and
 *	move operations. If you do not with to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, 
 *	and allowMovingItems properties.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withItems:(NSMutableArray *)_items
   withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Allocates and returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and a mutable set of objects. This method should only be used to create a model with the contents
 *	of a Core Data relationship.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param _itemsSet A mutable set of objects that the model will use to generate its cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects set.
 */
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withItemsSet:(NSMutableSet *)_itemsSet
   withClassDefinition:(SCClassDefinition *)classDefinition;
   
#ifdef _COREDATADEFINES_H
/*! Allocates and returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and an entity class definition. Note: This method creates a model with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a model with only a subset
 *	of these objects, consider using the other %SCArrayOfObjectsModel initializers.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param classDefinition The class definition of the entity of the objects.
 */
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withEntityClassDefinition:(SCClassDefinition *)classDefinition;

/*! Allocates and returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	an entity class definition and an NSPredicate.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param classDefinition The class definition of the entity of the objects.
 *	@param perdicate The predicate that will be used to fetch the objects.
 */
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
				   usingPredicate:(NSPredicate *)predicate;
#endif

/*! Returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and an array of objects.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param _items An array of objects that the model will use to generate its cells.
 *	This array must be of type NSMutableArray, as it must support the model's add, delete, and
 *	move operations. If you do not with to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, 
 *	and allowMovingItems properties.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withItems:(NSMutableArray *)_items
   withClassDefinition:(SCClassDefinition *)classDefinition;
   
/*! Returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and a mutable set of objects. This method should only be used to create a model with the contents
 *	of a Core Data relationship.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param _itemsSet A mutable set of objects that the model will use to generate its cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects set.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withItemsSet:(NSMutableSet *)_itemsSet
   withClassDefinition:(SCClassDefinition *)classDefinition;
   
#ifdef _COREDATADEFINES_H
/*! Returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	and an entity class definition. Note: This method creates a model with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a model with only a subset
 *	of these objects, consider using the other %SCArrayOfObjectsModel initializers.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param classDefinition The class definition of the entity of the objects.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
   withViewController:(UIViewController *)_viewController
   withEntityClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCArrayOfObjectsModel given a UITableView, UIViewController, 
 *	an entity class definition and an NSPredicate.
 *
 *	@param _modeledTableView The UITableView to be bound to the model. 
 *	@param _viewController The UIViewController to be bound to the model. _viewController must be
 *	the view controller that contains the modeledTableView.
 *	@param classDefinition The class definition of the entity of the objects.
 *	@param perdicate The predicate that will be used to fetch the objects.
 */
- (id)initWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
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

/*! The mutable set of objects that the model will use to generate its cells. Note: 
 This property should only be set when representing a Core Data relationship. */
@property (nonatomic, retain) NSMutableSet *itemsSet;

/*! If TRUE,  objects in itemsSet are sorted ascendingly, otherwise they're sorted descendingly.
 *	Note: Only applicable if itemsSet has been assigned. */
@property (nonatomic) BOOL sortItemsSetAscending;

/*! The name of the object's property that the value of which will be used to search the items array 
 *	when the user types a search term inside the model's associated search bar. To search more than one property 
 *	value, separate the property names by a semi-colon (e.g.: @"firstName;lastName"). To search all 
 *	properties in the object's class definition, set the property to an astrisk (e.g.: @"*").
 *	If the property is not set, it defaults to the value of the object's class definition titlePropertyName property. */
@property (nonatomic, copy) NSString *searchPropertyName;

@end





