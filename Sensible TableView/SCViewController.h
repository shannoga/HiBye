/*
 *  SCViewController.h
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
/*	class SCViewController	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a means to simplify development with SCTableViewModel.
 *
 *	%SCViewController conveniently provides several ready made navigation
 *	bar types based on SCNavigationBarType, provided that it is a subview of a navigation controller. 
 *	%SCViewController also defines placeholders for a tableView and a tableViewModel that
 *	the user can allocate and assign. If a tableViewModel is defined, %SCViewController also
 *	connects its doneButton (if present) to tableViewModel's commitButton automatically.
 *	In addition, %SCViewController provides several delegate methods as part of SCViewControllerDelegate
 *	that notifies the delegate object of events like the view appearing or disappearing.
 *
 *	Note: You do NOT have to use %SCViewController in order to be able to use SCTableViewModel,
 *	it is just provided as an additional convenience to you.
 *
 *	Note: Some Sensible TableView objects use %SCViewController to display their own detail views.
 *
 */
@interface SCViewController : UIViewController 
{
	BOOL toolbarAdded;  //internal
	
	UIViewController *ownerViewController;
	id delegate;
	UITableView *tableView;
	SCTableViewModel *tableViewModel;
	SCNavigationBarType navigationBarType;
	UINavigationBar *navigationBar;
	UIBarButtonItem *addButton;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	BOOL cancelButtonTapped;
	BOOL doneButtonTapped;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! This can optionally be set if the user wishes to display a table view in the view controller. 
 *	Note: If the table view is added programmatically, then the user also needs to add it to
 *	the view controller's view. */
@property (nonatomic, retain) IBOutlet UITableView *tableView;

/*! This can optionally be set if the user wishes to associate a table view model to tableView. */
@property (nonatomic, retain) SCTableViewModel *tableViewModel;

/*! The type of the navigation bar. */
@property (nonatomic, readwrite) SCNavigationBarType navigationBarType;

/*! The navigation bar's Add button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem *addButton;

/*! The editButtonItem of %SCViewController's superclass. */
@property (nonatomic, readonly) UIBarButtonItem *editButton;

/*! The navigation bar's Cancel button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;

/*! The navigation bar's Done button. Only contains a value if the button exists on the bar. */
@property (nonatomic, readonly) UIBarButtonItem	*doneButton;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Button Events
//////////////////////////////////////////////////////////////////////////////////////////

/*! Property is TRUE if the view controller have been dismissed due to the user tapping the
 *	Cancel button. This property is useful if you do not with to subclass this view controller. 
 *	See also SCViewControllerDelegate to get notified when the view controller is dismissed. */
@property (nonatomic, readonly) BOOL cancelButtonTapped;

/*! Property is TRUE if the view controller have been dismissed due to the user tapping the
 *	Done button. This property is useful if you do not with to subclass this view controller. 
 *	See also SCViewControllerDelegate to get notified when the view controller is dismissed. */
@property (nonatomic, readonly) BOOL doneButtonTapped;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Delegate
//////////////////////////////////////////////////////////////////////////////////////////

/*! The object that acts as the delegate of %SCViewController. 
 *	The object must adopt the SCViewControllerDelegate protocol. */
@property (nonatomic, assign) id delegate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties and Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! The view controller's owner (used internally) */
@property (nonatomic, assign) UIViewController *ownerViewController;

/*! Method gets called when the Cancel button is tapped. If what you want is to get notified
 *	when the Cancel button gets tapped without subclassing %SCViewController, consider
 *	using SCViewControllerDelegate. */
- (void)cancelButtonAction;

/*! Method gets called when the Done button is tapped. If what you want is to get notified
 *	when the Cancel button gets tapped without subclassing %SCViewController, consider
 *	using SCViewControllerDelegate. */
- (void)doneButtonAction;

/*! Dismisses the view controller with the specified values for cancel and done. */
- (void)dismissWithCancelValue:(BOOL)cancelValue doneValue:(BOOL)doneValue;

@end



/****************************************************************************************/
/*	protocol SCViewControllerDelegate	*/
/****************************************************************************************/ 
/*!
 *	This protocol should be adopted by objects that want to mediate as a delegate for 
 *	SCViewController. All methods for this protocol are optional.
 */
@protocol SCViewControllerDelegate

@optional

/*! Notifies the delegate that the view controller has appeared.
 *	@param viewController The view controller informing the delegate of the event.
 */
- (void)viewControllerDidAppear:(SCViewController *)viewController;

/*! Notifies the delegate that the view controller has disappeared.
 *	@param viewController The view controller informing the delegate of the event.
 *	@param cancelTapped TRUE if Cancel button has been tapped to dismiss the view controller.
 *	@param doneTapped TRUE if Done button has been tapped to dismiss the view controller.
 */
- (void)viewControllerDidDisappear:(SCViewController *)viewController
				cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped;

/*! Notifies the delegate that the view controller will appear.
 *	@param viewController The view controller informing the delegate of the event.
 */
- (void)viewControllerWillAppear:(SCViewController *)viewController;

/*! Notifies the delegate that the view controller will disappear.
 *	@param viewController The view controller informing the delegate of the event.
 *	@param cancelTapped TRUE if Cancel button has been tapped to dismiss the view controller.
 *	@param doneTapped TRUE if Done button has been tapped to dismiss the view controller.
 */
- (void)viewControllerWillDisappear:(SCViewController *)viewController
					  cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped;

@end
