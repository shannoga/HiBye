/*
 *  SCTableViewController.h
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

#import <UIKit/UIKit.h>
#import "SCGlobals.h"

@class SCTableViewModel;


/****************************************************************************************/
/*	class SCTableViewController	*/
/****************************************************************************************/ 
/*!
 *	This class simplifies development with SCTableViewModel the same way that 
 *	UITableViewController simplifies development with UITableView.
 *
 *	%SCTableViewController conveniently creates an automatic tableViewModel that is ready
 *	to be populated with sections and cells. It also provides several ready made navigation
 *	bar types based on SCNavigationBarType, provided that it is a subview of a navigation controller. 
 *	Furthermore, it automatically connects its doneButton (if present) to tableViewModel's commitButton.
 *	In addition, %SCTableViewController provides several delegate methods as part of SCTableViewControllerDelegate
 *	that notifies the delegate object of events like the view appearing or disappearing.
 *
 *	Note: You do NOT have to use %SCTableViewController in order to be able to use SCTableViewModel,
 *	it is just provided as an additional convenience to you.
 *
 *	Note: Some Sensible TableView objects use %SCTableViewController to display their own detail views.
 *
 */
@interface SCTableViewController : UITableViewController 
{
	BOOL toolbarAdded;  //internal
	
	SCTableViewModel *tableViewModel;
	UIViewController *ownerViewController;
	id delegate;
	SCNavigationBarType navigationBarType;
	UINavigationBar *navigationBar;
	UIBarButtonItem *addButton;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	BOOL cancelButtonTapped;
	BOOL doneButtonTapped;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Returns an initialized %SCTableViewController given a navigation bar type. 
 *
 *	@param style The style of the table view.
 *	@param type The type of the navigation bar.
 */
- (id)initWithStyle:(UITableViewStyle)style withNavigationBarType:(SCNavigationBarType)type;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The associated table view model. This model is configured and ready to be populated 
 *	with sections and cells. */
@property (nonatomic, readonly) SCTableViewModel *tableViewModel;

/*! The type of the navigation bar. */
@property (nonatomic, readwrite) SCNavigationBarType navigationBarType;

/*! The navigation bar's Add button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem *addButton;

/*! The editButtonItem of %SCTableViewController's superclass. */
@property (nonatomic, readonly) UIBarButtonItem *editButton;

/*! The navigation bar's Cancel button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;

/*! The navigation bar's Done button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem	*doneButton;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Button Events
//////////////////////////////////////////////////////////////////////////////////////////

/*! Property is TRUE if the view controller have been dismissed due to the user tapping the
 *	Cancel button. This property is useful if you do not wish to subclass this view controller. 
 *	See also SCTableViewControllerDelegate to get notified when the view controller is dismissed. */
@property (nonatomic, readonly) BOOL cancelButtonTapped;

/*! Property is TRUE if the view controller have been dismissed due to the user tapping the
 *	Done button. This property is useful if you do not wish to subclass this view controller. 
 *	See also SCTableViewControllerDelegate to get notified when the view controller is dismissed. */
@property (nonatomic, readonly) BOOL doneButtonTapped;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Delegate
//////////////////////////////////////////////////////////////////////////////////////////

/*! The object that acts as the delegate of %SCTableViewController. 
 *	The object must adopt the SCTableViewControllerDelegate protocol. */
@property (nonatomic, assign) id delegate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! The view controller's owner (used internally) */
@property (nonatomic, assign) UIViewController *ownerViewController;

/*! Method gets called when the Cancel button is tapped. If what you want is to get notified
 *	when the Cancel button gets tapped without subclassing %SCTableViewController, consider
 *	using SCTableViewControllerDelegate. */
- (void)cancelButtonAction;

/*! Method gets called when the Done button is tapped. If what you want is to get notified
 *	when the Cancel button gets tapped without subclassing %SCTableViewController, consider
 *	using SCTableViewControllerDelegate. */
- (void)doneButtonAction;

/*! Dismisses the view controller with the specified values for cancel and done. */
- (void)dismissWithCancelValue:(BOOL)cancelValue doneValue:(BOOL)doneValue;

@end



/****************************************************************************************/
/*	protocol SCTableViewControllerDelegate	*/
/****************************************************************************************/ 
/*!
 *	This protocol should be adopted by objects that want to mediate as a delegate for 
 *	SCTableViewController. All methods for this protocol are optional.
 */
@protocol SCTableViewControllerDelegate

@optional

/*! Notifies the delegate that the view controller has appeared.
 *	@param tableViewController The view controller informing the delegate of the event.
 */
- (void)tableViewControllerDidAppear:(SCTableViewController *)tableViewController;

/*! Notifies the delegate that the view controller has disappeared.
 *	@param tableViewController The view controller informing the delegate of the event.
 *	@param cancelTapped TRUE if Cancel button has been tapped to dismiss the view controller.
 *	@param doneTapped TRUE if Done button has been tapped to dismiss the view controller.
 */
- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped;

/*! Notifies the delegate that the view controller will appear.
 *	@param tableViewController The view controller informing the delegate of the event.
 */
- (void)tableViewControllerWillAppear:(SCTableViewController *)tableViewController;

/*! Notifies the delegate that the view controller will disappear.
 *	@param tableViewController The view controller informing the delegate of the event.
 *	@param cancelTapped TRUE if Cancel button has been tapped to dismiss the view controller.
 *	@param doneTapped TRUE if Done button has been tapped to dismiss the view controller.
 */
- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					  cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped;

@end

