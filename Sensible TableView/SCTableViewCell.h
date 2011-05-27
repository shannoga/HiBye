/*
 *  SCTableViewCell.h
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
#import "SCViewController.h"
#import "SCTableViewController.h"
#import "SCBadgeView.h"

@class SCTableViewModel;



/****************************************************************************************/
/*	class SCTableViewCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell for SCTableViewSection. %SCTableViewCell is extensively
 *	subclassed to create cells with special controls such as UITextField and UISlider.
 *
 *	%SCTableViewCell provides the user with the infrastructure to access the cell's value
 *	using two main methods: Bound Object and Bound Key.
 *	- Bound Object method: This works by binding the cell to an object, called the bound object, and
 *	to a property of this object, called the bound property. The cell initializes its value
 *	from the value of the bound property, and when its values changes, it sets the property
 *	back automatically.
 *	- Bound Key method: This works by binding the cell to a key, called the bound key. The
 *	cell initializes its value from the value associated with this key, found in ownerTableViewModel
 *	modelKeyValues dictionary. When the cell's value change, the value of the bound key set
 *	set back in the same modelKeyValues dictionary.
 *
 *	Please note that even though a cell value is not applicable to %SCTableViewCell itself, %SCTableViewCell still
 *	provides the bound object / bound key functionality as a framework to all its subclasses to use.
 *
 */
@interface SCTableViewCell : UITableViewCell
{
	id ownerViewControllerDelegate;	//used internally
	SCTableViewModel *tempDetailModel; //used internally
	
	SCTableViewModel *ownerTableViewModel;
	id delegate;
	NSObject *boundObject;
	NSString *boundPropertyName;
	NSString *boundKey;
	NSObject *initialValue;
	BOOL coreDataBound;  //internal
	
	CGFloat height;
	BOOL editable;
	BOOL movable;
	BOOL selectable;
	BOOL autoResignFirstResponder;
	UITableViewCellEditingStyle cellEditingStyle;
	SCBadgeView *badgeView;
	NSString *detailViewTitle;
#ifdef __IPHONE_3_2	
	UIModalPresentationStyle detailViewModalPresentationStyle;
#endif
	NSArray *detailCellsImageViews;
	BOOL detailViewHidesBottomBar;
		
	BOOL valueRequired;
	BOOL autoValidateValue;
	
	BOOL commitChangesLive;
	BOOL needsCommit;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCTableViewCell. */
+ (id)cell;

/*! Allocates and returns an initialized %SCTableViewCell given cell text.
 *	@param cellText The text that will appear in the cell's textLabel.
 */
+ (id)cellWithText:(NSString *)cellText;

/*! Allocates and returns an initialized %SCTableViewCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see class overview).
 *	@param propertyName The cell's bound property name (see class overview).
 */
+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withPropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCTableViewCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see class overview).
 *	@param keyValue An initial value for the bound key.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue;

/*! Returns an initialized %SCTableViewCell given cell text.
 *	@param cellText The text that will appear in the cell's textLabel.
 */
- (id)initWithText:(NSString *)cellText;

/*! Returns an initialized %SCTableViewCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see class overview).
 *	@param propertyName The cell's bound property name (see class overview).
 */
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withPropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCTableViewCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see class overview).
 *	@param keyValue An initial value for the bound key.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The owner table view model of the cell. 
 *
 * Important: This property gets set automatically by the cell's owner, you should never
 * set this property manually */
@property (nonatomic, assign) SCTableViewModel *ownerTableViewModel;

/*! The object that acts as the delegate of %SCTableViewCell. 
 *	The object must adopt the SCTableViewCellDelegate protocol. */
@property (nonatomic, assign) id delegate;

/*! The cell's bound object (see class overview). */
@property (nonatomic, readonly) NSObject *boundObject;

/*! The cell's bound property name (see class overview). */
@property (nonatomic, readonly) NSString *boundPropertyName;

/*! The cell's bound key (see class overview). */
@property (nonatomic, readonly) NSString *boundKey;

/*! The height of the cell. */
@property (nonatomic, readwrite) CGFloat height;

/*! The editable state of the cell. Default: FALSE. */
@property (nonatomic, readwrite) BOOL editable;

/*! The movable state of the cell. Default: FALSE. */
@property (nonatomic, readwrite) BOOL movable;

/*! Determines if the cell can be selected. Default: TRUE. */
@property (nonatomic, readwrite) BOOL selectable;

/*! The cell's badge view. When assigned a text value, the badgeView displays a badge similar
 *	to the badge displayed by the iPhone's mail application for its mail folders. */
@property (nonatomic, readonly) SCBadgeView *badgeView;

/*! The title of the cell's detail view. If not set, the detail view's title defaults to the cell's textLabel.
 *	Note: Only applicable to cells with detail views. */
@property (nonatomic, copy) NSString *detailViewTitle;

/*! The modal presentation style of the cell's detail view. 
 *	Note: Only applicable to cells with detail views. */
#ifdef __IPHONE_3_2	
@property (nonatomic, readwrite) UIModalPresentationStyle detailViewModalPresentationStyle;
#endif

/*! The style of the cell's detail table view. Default: Depends on subclassed cell.
 *	Note: Only applicable to cells with detail table views. */
@property (nonatomic, readwrite) UITableViewStyle detailTableViewStyle;

/*! Set this property to an array of UIImageView objects to be set to each of the cell's detail cells. 
 *	Note: Only applicable to cells with detail views. */
@property (nonatomic, retain) NSArray *detailCellsImageViews;

/*! Indicates whether the bar at the bottom of the screen is hidden when the cell's detail view is pushed. 
 *	Default: TRUE. 
 *	Note: Only applicable to cells with detail views. */
@property (nonatomic, readwrite) BOOL detailViewHidesBottomBar;

/*! If property is TRUE, the cell automatically dismisses the keyboard (if applicable) when
 *	another cell is selected or when the value of another cell is changed. Default: TRUE. */
@property (nonatomic, readwrite) BOOL autoResignFirstResponder;

/*! The cell's editing style. */
@property (nonatomic, readwrite) UITableViewCellEditingStyle cellEditingStyle;

/*! Determines if the cell's value is required. If TRUE, valueIsValid will only return true if the
 *	cells value is not empty. Default: FALSE. */
@property (nonatomic, readwrite) BOOL valueRequired;

/*! Determines whether to automatically validate the cell's value. Where applicable, each subclass provides
 *	its own rules for validating the cell's value. If the user chooses to provide custom validation
 *	using either the cell's SCTableViewCellDelegate, or the model's SCTableViewModelDelegate, they should
 *	set this property to FALSE. Default: TRUE. */
@property (nonatomic, readwrite) BOOL autoValidateValue;

/*! This property is TRUE if the cell's value is valid. The validity of the cell's value depend
 *	on the valueRequired and the validateValue properties. If valueRequired is TRUE, valueIsValid is
 *	TRUE only if the cell contains a value. If validateValue is TRUE, valueIsValid depends on
 *	each subclass to provide validation of the cell's value. For validation, the user can also provide 
 *	custom validation using either the cell's SCTableViewCellDelegate, or the model's SCTableViewModelDelegate. */
@property (nonatomic, readonly) BOOL valueIsValid;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cell Value
//////////////////////////////////////////////////////////////////////////////////////////

/*! Set this property to TRUE for the cell to commit its value as soon as it is changed.
 *	If this value is FALSE, the user must explicitly call commitChanges
 *	for the cell to commit its value changes. Default: TRUE. */
@property (nonatomic, readwrite) BOOL commitChangesLive;

/*! This propery is TRUE if the cell value has changed and needs to be committed. If commitChangesLive
 *	is TRUE, this property always remains FALSE. */
@property (nonatomic, readonly) BOOL needsCommit;

/*! Commits any changes to the cell's value either to the bound object or the bound key where
 *	applicable (see class overview). */
- (void)commitChanges;

/*! Reload's the cell's bound value in case the associated bound object or key's value has changed
 *	by means other than the cell itself (e.g. external custom code). */
- (void)reloadBoundValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Properties & Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! This property represents the bound value of the cell. If the cell is bound to an object, then
 *	the property represents the value of the bound property. If the cell is bound to a key, then
 *	the property represents the corresponding value for the bound key in the ownerTableViewModel
 *	modelKeyValues dictionary. If the cell isn't bound to an object or a key, the the property
 *	represents the initialValue internal variable. This property is made available to sheild
 *	subclasses from all the details of dealing with the bound object or the bound key directly.
 *	Subclasses should just set boundValue to their value and %SCTableViewCell will take care of the rest. */
@property (nonatomic, retain) NSObject *boundValue;

/*! Property used internally by framework to manage custom detail models. */
@property (nonatomic, retain) SCTableViewModel *tempDetailModel;

/*!	Method gets called internally whenever the cell value changes. This method should only be used
 *	when subclassing %SCTableViewCell. If what you want is to get notified when a cell value changes,
 *	consider using either SCTableViewCellDelegate or SCTableViewModelDelegate methods. */
- (void)cellValueChanged;

/*! Method gets called internally by framework. */
- (void)tempDetailModelModified;

/*! Method gets called internally by framework. */
- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel;

/*!	Method gets called internally whenever the cell is about to be displayed. This method should only be used
 *	when subclassing %SCTableViewCell. If what you want is to get notified when a cell is about to be displayed,
 *	consider using either SCTableViewCellDelegate or SCTableViewModelDelegate methods. */
- (void)willDisplay;

/*!	Method gets called internally whenever the cell gets selected. This method should only be used
 *	when subclassing %SCTableViewCell. If what you want is to get notified when a cell gets selected,
 *	consider using either SCTableViewCellDelegate or SCTableViewModelDelegate methods. */
- (void)didSelectCell;

/*!	Method gets called internally whenever the cell gets deselected. */
- (void)willDeselectCell;

/*! Method should be overridden by subclasses to support property attributes. The method should be 
 *	able to set the subclass' specific attributes to its corresponding SCPropertyAttributes subclass. */
- (void) setAttributesTo:(SCPropertyAttributes *)attributes;

/*! Method should be overridden by subclasses to provide subclass specific validation of the cell's
 *	value. If what you want is to be able to provide custom cell value validation,
 *	consider using either SCTableViewCellDelegate or SCTableViewModelDelegate methods. */
- (BOOL)getValueIsValid;


@end




/****************************************************************************************/
/*	protocol SCTableViewCellDelegate	*/
/****************************************************************************************/ 
/*!
 *	This protocol should be adopted by objects that want to mediate as a delegate for 
 *	SCTableViewCell. All methods for this protocol are optional.
 */
@protocol SCTableViewCellDelegate

@optional

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cells
//////////////////////////////////////////////////////////////////////////////////////////


/*! Notifies the delegate that the specified cell is about to be configured in its owner UITableView. 
 *	This is the perfect time to do any customization to the cell's height, editable, and movable properties.
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)willConfigureCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the specified cell is about to be displayed. This is the perfect
 *	time to do any customization to the cell's appearance. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate.
 *	Note: To change cell properties like the height, editable, or movable states, use the willConfigureCell delegate
 *	method instead. 
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)willDisplayCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the specified cell will be selected. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)willSelectCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the specified cell has been selected. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)didSelectCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the specified cell has been deselected. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)didDeselectCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the specified cell's accessory button have been tapped. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)accessoryButtonTappedForCell:(SCTableViewCell *)cell;

/*! Asks the delegate if the value is valid for the specified cell.
 *	Define this method if you want to override the cells' default value validation and provide 
 *	your own custom validation. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (BOOL)valueIsValidForCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the return keyboard button has been tapped for the specified cell
 *	Define this method if you want to override the cells'
 *	default behaviour for tapping the return button. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)returnButtonTappedForCell:(SCTableViewCell *)cell;

/*! Asks the delegate for a new image name for the specified SCImagePickerCell.
 *	Define this method to provide a new name for the selected image, instead of using the auto generated one. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (NSString *)newImageNameForCell:(SCTableViewCell *)cell;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Cell's detail view
//////////////////////////////////////////////////////////////////////////////////////////

/*! Notifies the delegate that the cell's detail view will appear. 
 *	This is the perfect time to do any customizations to the cell's detail view model.
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)detailViewWillAppearForCell:(SCTableViewCell *)cell
		   withDetailTableViewModel:(SCTableViewModel *)detailTableViewModel;

/*! Notifies the delegate that the cell's detail view will disappear. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)detailViewWillDisappearForCell:(SCTableViewCell *)cell;

/*! Notifies the delegate that the cell's detail view has disappeared. 
 *
 *	Note: This method overrides its counterpart in SCTableViewModelDelegate. */
- (void)detailViewDidDisappearForCell:(SCTableViewCell *)cell;

@end







/****************************************************************************************/
/*	class SCControlCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as an abstract base class for all cells that require user controls to be
 *	present inside their content view.
 *
 *	Note: This is an abstract base class, you should never make any direct instances of it.
 */
 
@interface SCControlCell : SCTableViewCell
{
	BOOL pauseControlEvents; //internal
	
	UIView *control;
	
	CGFloat maxTextLabelWidth;
	CGFloat controlIndentation;
	CGFloat controlMargin;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The control associated with the cell. Even though this property is readonly, feel free
 *	to customize any of the control's properties.
 *
 *	Note: The type of the control has been choosen to be of type UIView instead of UIControl
 *	as not all user controls decend from UIControl (e.g. UITextView). */
@property (nonatomic, readonly) UIView *control;

/*!	The maximum with of the cell's textLabel */
@property (nonatomic, readwrite) CGFloat maxTextLabelWidth;

/*!	The indentation of the control from the cell's left border. This indentation keeps the 
 *	control at a specific distance from the cell's border unless the textLabel's text 
 *	exceeds this distance, in which case the control is moved accordingly to the right. */
@property (nonatomic, readwrite) CGFloat controlIndentation;

/*! The margin between the control and the cell's textLabel. */
@property (nonatomic, readwrite) CGFloat controlMargin;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*!	Method should be overridden by subclasses to load the cell's bound value into their controls */
- (void)loadBoundValueIntoControl;

@end



/****************************************************************************************/
/*	class SCLabelCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UILabel control. The bound property name or bound
 *	key value of this cell must be of type NSString.
 */

@interface SCLabelCell : SCControlCell
{
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCLabelCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UILabel's text. 
 *	Property must be of type NSString and can be a readonly property.
 */
+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withLabelTextPropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCLabelCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param labelTextValue An initial value for UILabel's text.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withLabelTextValue:(NSString *)labelTextValue;

/*! Returns an initialized %SCLabelCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UILabel's text. 
 *	Property must be of type NSString and can be a readonly property.
 */
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withLabelTextPropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCLabelCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param labelTextValue An initial value for the Label's text.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withLabelTextValue:(NSString *)labelTextValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UILabel control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UILabel *label;

@end



/****************************************************************************************/
/*	class SCTextViewCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UITextView control. The bound property name or bound
 *	key value of this cell must be of type NSString.
 */

@interface SCTextViewCell : SCControlCell <UITextViewDelegate>
{
	BOOL autoResize;
	CGFloat minimumHeight;
	CGFloat maximumHeight;
	
	@private
	BOOL initializing;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCTextViewCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UITextView's text. 
 *	Property must be a readwrite property of type NSString.
 */
+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withTextViewTextPropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCTextViewCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param textViewTextValue An initial value for UITextView's text.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withTextViewTextValue:(NSString *)textViewTextValue;

/*! Returns an initialized %SCTextViewCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UITextView's text. 
 *	Property must be a readwrite property of type NSString.
 */
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withTextViewTextPropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCTextViewCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param textViewTextValue An initial value for UITextView's text.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withTextViewTextValue:(NSString *)textViewTextValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UITextView control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UITextView *textView;

/*!	Determines if textView should automatically resize to fit its contents. Default: TRUE. */
@property (nonatomic, readwrite) BOOL autoResize;

/*! The minimum height for textView. */
@property (nonatomic, readwrite) CGFloat minimumHeight;

/*! The maximum height for textView. */
@property (nonatomic, readwrite) CGFloat maximumHeight;


@end




/****************************************************************************************/
/*	class SCTextFieldCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UITextField control. The bound property name or bound
 *	key value of this cell must be of type NSString.
 */

@interface SCTextFieldCell : SCControlCell <UITextFieldDelegate>
{
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCTextFieldCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param placeholder The placeholder string for UITextField.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UITextField's text. 
 *	Property must be a readwrite property of type NSString.
 */
+ (id)cellWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
   withBoundObject:(NSObject *)object withTextFieldTextPropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCTextFieldCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param placeholder The placeholder string for UITextField.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param textFieldTextValue An initial value for UITextField's text.
 */
+ (id)cellWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
	  withBoundKey:(NSString *)key withTextFieldTextValue:(NSString *)textFieldTextValue;

/*! Returns an initialized %SCTextFieldCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param placeholder The placeholder string for UITextField.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UITextField's text. 
 *	Property must be a readwrite property of type NSString.
 */
- (id)initWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
   withBoundObject:(NSObject *)object withTextFieldTextPropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCTextFieldCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param placeholder The placeholder string for UITextField.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param textFieldTextValue An initial value for UITextField's text.
 */
- (id)initWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
	  withBoundKey:(NSString *)key withTextFieldTextValue:(NSString *)textFieldTextValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UITextField control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UITextField *textField;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Method gets called internally whenever the value of textField is changed. */
- (void)textFieldEditingChanged;

@end




/****************************************************************************************/
/*	class SCNumericTextFieldCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UITextField control with numeric values. The bound property name or bound
 *	key value of this cell must be of type NSNumber.
 *	%SCNumericTextFieldCell defines its own validation rules according to the following criteria:
 *	- Value is valid only if it's a numeric value.
 *	- If minimumValue is not nil, then value is only valid if it's greater than or equal to this value.
 *	- If maximumValue is not nil, then value is only valid if it's less than or equal to this value.
 *	- If allowFloatValue is FALSE, then value is only valid if it's an integer value.
 */

@interface SCNumericTextFieldCell : SCTextFieldCell
{
	NSNumber *minimumValue;
	NSNumber *maximumValue;
	BOOL allowFloatValue;
	BOOL displayZeroAsBlank;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The minimum valid cell value. */
@property (nonatomic, copy) NSNumber *minimumValue;

/*! The maximum valid cell value. */
@property (nonatomic, copy) NSNumber *maximumValue;

/*! If FALSE, only integer cell values are valid. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowFloatValue;

/*! If TRUE, an empty space is displayed if the bound value equals zero. Default: FALSE. */
@property (nonatomic, readwrite) BOOL displayZeroAsBlank;

@end





/****************************************************************************************/
/*	class SCSliderCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UISlider control. The bound property name or bound
 *	key value of this cell must be of type NSNumber.
 */

@interface SCSliderCell : SCControlCell
{
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCSliderCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UISlider's value.
 *	Property must be a readwrite property of type NSNumber.
 */
+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSliderValuePropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCSliderCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param sliderValue An initial value for UISlider value.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSliderValue:(NSNumber *)sliderValue;

/*! Returns an initialized %SCSliderCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UISlider's value.
 *	Property must be a readwrite property of type NSNumber.
 */
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSliderValuePropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCSliderCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param sliderValue An initial value for UISlider value.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSliderValue:(NSNumber *)sliderValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UISlider control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UISlider *slider;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Method gets called internally whenever the value of slider control is changed. */
- (void)sliderValueChanged;

@end




/****************************************************************************************/
/*	class SCSegmentedCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UISegmentedControl. The bound property name or bound
 *	key value of this cell must be of type NSNumber.
 */
@interface SCSegmentedCell : SCControlCell
{
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCSegmentedCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the 
 *	UISegmentedControl's selectedSegmentIndex value.
 *	Property must be a readwrite property of type NSNumber.
 *	@param cellSegmentTitlesArray An array containing title strings for UISegmentedControl's segments.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedSegmentIndexPropertyName:(NSString *)propertyName
	withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray;

/*! Allocates and returns an initialized %SCSegmentedCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedSegmentIndexValue An initial value for UISegmentedControl's selectedSegmentIndex value.
 *	@param cellSegmentTitlesArray An array containing title strings for UISegmentedControl's segments.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedSegmentIndexValue:(NSNumber *)selectedSegmentIndexValue
			withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray;

/*! Returns an initialized %SCSegmentedCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the 
 *	UISegmentedControl's selectedSegmentIndex value.
 *	Property must be a readwrite property of type NSNumber.
 *	@param cellSegmentTitlesArray An array containing title strings for UISegmentedControl's segments.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedSegmentIndexPropertyName:(NSString *)propertyName
	withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray;

/*! Returns an initialized %SCSegmentedCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedSegmentIndexValue An initial value for UISegmentedControl's selectedSegmentIndex value.
 *	@param cellSegmentTitlesArray An array containing title strings for UISegmentedControl's segments.
 */
- (id)initWithText:(NSString *)cellText
		withBoundKey:(NSString *)key withSelectedSegmentIndexValue:(NSNumber *)selectedSegmentIndexValue
			withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UISegmentedControl associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;

/*!	Method creates segmented control segments based on the content of the segmentTitlesArray.
 *	@param segmentTitlesArray Must be an array of NSString objects. */
- (void)createSegmentsUsingArray:(NSArray *)segmentTitlesArray;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Method gets called internally whenever the value of segmented control is changed. */
- (void)segmentedControlValueChanged;

@end



/****************************************************************************************/
/*	class SCSwitchCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell with a UISwitch control. The bound property name or bound
 *	key value of this cell must be of type NSNumber.
 */
@interface SCSwitchCell : SCControlCell
{
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCSwitchCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UISwitch's on value.
 *	Property must be a readwrite property of type NSNumber.
 */
+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSwitchOnPropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCSwitchCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param switchOnValue An initial value for UISwitch's on value.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSwitchOnValue:(NSNumber *)switchOnValue;

/*! Returns an initialized %SCSwitchCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the UISwitch's on value.
 *	Property must be a readwrite property of type NSNumber.
 */
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSwitchOnPropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCSwitchCell given cell text, bound key, and an
 *	initial key value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param switchOnValue An initial value for UISwitch's on value.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSwitchOnValue:(NSNumber *)switchOnValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UISwitch control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UISwitch *switchControl;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (should only be used when subclassing)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Method gets called internally whenever the value of switch control is changed. */
- (void)switchControlChanged;

@end





/****************************************************************************************/
/*	class SCDateCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that provides the end-user with an automatically generated
 *	detail view of a UIDatePicker to choose a date from. The bound property name or bound
 *	key value of this cell must be of type NSDate.
 */
@interface SCDateCell : SCLabelCell <SCViewControllerDelegate>
{
	UIDatePicker *datePicker;
	NSDateFormatter *dateFormatter;
	BOOL displaySelectedDate;
	BOOL allowDetailView;
	BOOL detailViewModal;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCDateCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the cell's date selection.
 *	Property must be a readwrite property of type NSDate.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withDatePropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCDateCell given cell text, bound key, and initial
 *	date value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param dateValue An initial value to the cell's date selection.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withDateValue:(NSDate *)dateValue;

/*! Returns an initialized %SCDateCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the cell's date selection.
 *	Property must be a readwrite property of type NSDate.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withDatePropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCDateCell given cell text, bound key, and initial
 *	date value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param dateValue An initial value to the cell's date selection.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withDateValue:(NSDate *)dateValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UIDatePicker control associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the control's properties. */
@property (nonatomic, readonly) UIDatePicker *datePicker;

/*! Set to customize how the cell display's the selected date. */
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

/*! If TRUE, the cell displays the selected date in a left aligned label. Default: TRUE. */
@property (nonatomic, readwrite) BOOL displaySelectedDate;

/*! Allows/disables a detail view for editing the cell's date. Default: TRUE. 
 *
 *	A detail view is automatically generated for editing the cell's date. You can control wether the
 *	view appears as a modal view or gets pushed to the navigation stack using the detailViewModal
 *	property. Modal views have the added feature of giving the end user a Cancel and Done buttons.
 *	The Cancel button cancels all user's actions, while the Done button commits them. Also, if the
 *	cell's validation is enabled, the Done button will remain disabled until all cells' values
 *	are valid.
 */
@property (nonatomic, readwrite) BOOL allowDetailView;

/*!	If TRUE, the detail view always appears as a modal view. If FALSE and a navigation controller
 *	exists, the detail view is pushed to the navigation controller's stack, otherwise the view
 *	appears modally. Default: FALSE. */
@property (nonatomic, readwrite) BOOL detailViewModal;

@end





/****************************************************************************************/
/*	class SCImagePickerCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that provides the end-user with an automatically generated
 *	detail view of type UIImagePickerController to pick an image with. As soon as the image is picked,
 *	it will be saved to the Documents folder using either an auto generated name from the current time stamp,
 *	or a name provided through SCTableViewModelDelegate or SCTableViewCellDelegate. 
 *	The bound property name or bound key value of this cell must be of type NSString, and will be 
 *	bound to the name of the selected image. Once an image is selected, tapping an SCImagePickerCell
 *	will display the image in a detail view. To select a different image, the table view must be put in edit
 *	mode (make sure UITableView's allowsSelectionDuringEditing property is TRUE). Alternatively, make
 *	sure that displayClearImageButtonInDetailView property is TRUE, and the user will be able to
 *	tap a "Clear Image" button to clear the selected image.
 */
@interface SCImagePickerCell : SCTableViewCell <UINavigationControllerDelegate,
												UIImagePickerControllerDelegate,
												UIActionSheetDelegate,
												SCViewControllerDelegate>
{
	UIImage *cachedImage;  // Internal
	UIImageView *detailImageView; // Internal
	
	UIImagePickerController *imagePickerController;
	NSString *placeholderImageName;
	BOOL displayImageNameAsCellText;
	BOOL askForSourceType;
	UIButton *clearImageButton;
	BOOL displayClearImageButtonInDetailView;
	BOOL autoPositionClearImageButton;
	BOOL autoPositionImageView;
	
	CGRect textLabelFrame;
	CGRect imageViewFrame;
	
	NSString *selectedImageName;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCImagePickerCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the cell's selected image name.
 *	Property must be a readwrite property of type NSString.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withImageNamePropertyName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCImagePickerCell given cell text, bound key, and initial
 *	image name value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param imageNameValue An initial value to the cell's selected image name.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withImageNameValue:(NSString *)imageNameValue;

/*! Returns an initialized %SCImagePickerCell given cell text, bound object, and a bound
 *	property name. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the cell's selected image name.
 *	Property must be a readwrite property of type NSString.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withImageNamePropertyName:(NSString *)propertyName;

/*! Returns an initialized %SCImagePickerCell given cell text, bound key, and initial
 *	image name value. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param imageNameValue An initial value to the cell's selected image name.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withImageNameValue:(NSString *)imageNameValue;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The UIImagePickerController associated with the cell. Even though this property is readonly,
 *	feel free to customize any of the controller's relevant properties. */
@property (nonatomic, readonly) UIImagePickerController *imagePickerController;

/*! The selected image. Returns nil if no image is selected. */
@property (nonatomic, readonly) UIImage *selectedImage;

/*! The name for an image in the documents folder that will be used as a placeholder if
 *	no image is selected. */
@property (nonatomic, retain) NSString *placeholderImageName;

/*! If TRUE, the selected image name will be displayed in the cell's textLabel. Default: TRUE. */
@property (nonatomic) BOOL displayImageNameAsCellText;

/*! If TRUE, the user will be asked for the source type, otherwise, the source type will be
 *	determined from imagePickerController's sourceType property. Default: TRUE.
 *	Note: If the device has no camera, setting this to TRUE automatically sets the sourceType 
 *	to UIImagePickerControllerSourceTypePhotoLibrary. */
@property (nonatomic) BOOL askForSourceType;

/*! A button that clears the currently selected image when tapped. Feel free to customize the 
 *	default look and feel of this button. */
@property (nonatomic, readonly) UIButton *clearImageButton;

/*! If TRUE, clearImageButton will be displayed in the cell's detail view. Default: TRUE. */
@property (nonatomic) BOOL displayClearImageButtonInDetailView;

/*! If TRUE, clearImageButton will be automatically positioned in the cell's detail view. Default: TRUE. */
@property (nonatomic) BOOL autoPositionClearImageButton;

/*! Set this property to customize the placement of the cell's textLabel. */
@property (nonatomic, readwrite) CGRect textLabelFrame;

/*! Set this property to customize the placement of the cell's imageView. */
@property (nonatomic, readwrite) CGRect imageViewFrame;


/*! The name of the selected image. */
@property (nonatomic, retain) NSString *selectedImageName;


/*! Resets the clearImageButton default layer styles such as corneRadius and borderWidth. */
- (void)resetClearImageButtonStyles;

@end







/****************************************************************************************/
/*	class SCSelectionCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that provides the end-user with an automatically generated
 *	detail view of options to choose from, much like the Ringtone selection cell in the 
 *	iPhone's sound settings. The selection items are provided in the form of an array of
 *	NSStrings, called the items array. %SCSelection cell can be configured to allow multiple
 *	selection and to allow no selection at all. If allow multiple selection is disabled, then
 *	the bound property name or bound key value of this cell must be of type NSNumber, otherwise
 *	it must be of type NSMutableSet.
 *
 *	See also: SCSelectionSection.
 */
@interface SCSelectionCell : SCLabelCell <SCTableViewControllerDelegate>
{
	BOOL boundToNSNumber;	//internal
	BOOL boundToNSString;	//internal
	
	NSArray *items;
	BOOL allowMultipleSelection;
	BOOL allowNoSelection;
	BOOL autoDismissDetailView;
	BOOL hideDetailViewNavigationBar;
	
	BOOL displaySelection;
	NSString *delimeter;
	
	NSMutableSet *selectedItemsIndexes;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound object, an NSNumber bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected item index.
 *	Property must be of an NSNumber type and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems;

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound object, a bound
 *	property name, an array of selection items, and whether to allow multiple selection. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected items indexes set.
 *	Property must be of an NSMutableSet type and can be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection;

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound object, an NSString bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected item string.
 *	Property must be of an NSString type and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object 
	withSelectionStringPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems;

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound key, an initial selected
 *	index value, and an array of selection items. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedIndexValue An NSNumber with the initially selected item index.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexValue:(NSNumber *)selectedIndexValue
		 withItems:(NSArray *)cellItems;

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound key, an initial selected
 *	indexes value, an array of selection items, and whether to allow multiple selection. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedIndexesValue A set with all the initially selected items' indexes.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection;

/*! Returns an initialized %SCSelectionCell given cell text, bound object, an NSNumber bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected item index.
 *	Property must be of an NSNumber type and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems;

/*! Returns an initialized %SCSelectionCell given cell text, bound object, a bound
 *	property name, an array of selection items, and whether to allow multiple selection. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected items indexes set.
 *	Property must be of an NSMutableSet type and can be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection;

/*! Returns an initialized %SCSelectionCell given cell text, bound object, an NSString bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the selected item string.
 *	Property must be of an NSString type and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object 
		withSelectionStringPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems;

/*! Returns an initialized %SCSelectionCell given cell text, bound key, an initial selected
 *	index value, and an array of selection items. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedIndexValue An NSNumber with the initially selected item index.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexValue:(NSNumber *)selectedIndexValue
		 withItems:(NSArray *)cellItems;

/*! Allocates and returns an initialized %SCSelectionCell given cell text, bound key, an initial selected
 *	indexes value, an array of selection items, and whether to allow multiple selection. 
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param key	The cell's bound key (see SCTableViewCell class overview).
 *	@param selectedIndexesValue A set will all the initially selected items' indexes.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSString type.
 *	@param multipleSelection Determines if multiple selection is allowed.
 */
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The selection items array. All array elements must be of NSString type. */
@property (nonatomic, retain) NSArray *items;

/*! This property reflects the current cell's selection. You can set this property
 *	to define the cell's selection.
 *
 *	Note: If you have bound this cell to an object or a key, you can define the cell's selection
 *	using either the bound property value or the key value, respectively. */
@property (nonatomic, copy) NSNumber *selectedItemIndex;

/*! This property reflects the current cell's selection(s). You can add index(es) to the set
 *	to define the cell's selection.
 *
 *	Note: If you have bound this cell to an object or a key, you can define the cell's selection
 *	using either the bound property value or the key value, respectively. */
@property (nonatomic, readonly) NSMutableSet *selectedItemsIndexes;

/*! If TRUE, the cell allows multiple selection. Default: FALSE. */
@property (nonatomic, readwrite) BOOL allowMultipleSelection;

/*! If TRUE, the cell allows no selection at all. Default: FALSE. */
@property (nonatomic, readwrite) BOOL allowNoSelection;

/*! If TRUE, the detail view is automatically dismissed when an item is selected. Default: FALSE. */
@property (nonatomic, readwrite) BOOL autoDismissDetailView;

/*! If TRUE, the detail view's navigation bar is hidder. Default: FALSE. 
 *	Note: Only applicable when autoDismissDetailView is TRUE. */
@property (nonatomic, readwrite) BOOL hideDetailViewNavigationBar;

/*! If TRUE, the cell displays the selected items' titles inside the cell in a left aligned label. Default: TRUE. */
@property (nonatomic, readwrite) BOOL displaySelection;

/*! The delimeter that separates the titles of the selected items. Default: @" ,".
 *	
 *	Note: This property is applicable only if displaySelection is TRUE. */
@property (nonatomic, copy) NSString *delimeter;



@end





/****************************************************************************************/
/*	class SCObjectSelectionCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that provides the end-user with an automatically generated
 *	detail view of objects to choose from. The selection items are provided in the form of an array of
 *	NSObjects, called the items array. %SCSelection cell can be configured to allow multiple
 *	selection and to allow no selection at all. If allow multiple selection is disabled, then
 *	the bound property name of this cell must be of type NSObject, otherwise
 *	it must be of type NSMutableSet. 
 *	Note: This class is usually used to represent a selection relationship between
 *	a Core Data object and other object(s).
 *
 */
@interface SCObjectSelectionCell : SCSelectionCell
{
	NSString *titlePropertyName;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCObjectSelectionCell given cell text, bound object, a bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the object selection.
 *	If multiple selection is allowed, then property must be of an NSMutableSet type, otherwise,
 *	property must be of type NSObject and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSObject type and all items must be instances of the same class.
 *	@param itemTitlePropertyName The property name of the objects in cellItems, the value of which will 
 *	be used as the objects' titles when they are displayed for selection.
 */
+(id)cellWithText:(NSString *)cellText
  withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
		withItems:(NSArray *)cellItems withItemTitlePropertyName:(NSString *)itemTitlePropertyName;

/*! Returns an initialized %SCObjectSelectionCell given cell text, bound object, a bound
 *	property name, and an array of selection items.
 *	@param cellText The text that will appear in the cell's textLabel.
 *	@param object	The cell's bound object (see SCTableViewCell class overview).
 *	@param propertyName The cell's bound property name corresponding to the object selection.
 *	If multiple selection is allowed, then property must be of an NSMutableSet type, otherwise,
 *	property must be of type NSObject and cannot be a readonly property.
 *	@param cellItems An array of the items that the user will choose from. All items must be of
 *	an NSObject type and all items must be instances of the same class.
 *	@param itemTitlePropertyName The property name of the objects in cellItems, the value of which will 
 *	be used as the objects' titles when they are displayed for selection.
 */
-(id)initWithText:(NSString *)cellText
  withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
		withItems:(NSArray *)cellItems withItemTitlePropertyName:(NSString *)itemTitlePropertyName;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The property name of the objects in cellItems, the value of which will 
 *	be used as the objects' titles when they are displayed for selection. */
@property (nonatomic, retain) NSString *titlePropertyName;


@end





/****************************************************************************************/
/*	class SCObjectCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that is able to automatically generate a detail view with cells generated
 *	from a given bound object's properties. If the bound object is given without an extended
 *	class definition (SCClassDefinition), then the cells will only be generated for properties of type 
 *	NSString and NSNumber, and will be either of type SCTextFieldCell or SCNumericTextFieldCell,
 *	respectively. If an SCClassDefinition is provided for the bound object, a full fledged
 *	detail view of cells will be generated.
 *
 *	When %SCObjectCell is selected by the end-user, a detail view optionally fires up to to give
 *	the user the ability to edit the object's properties.
 *
 *	See also: SCObjectSection, SCArrayOfObjectsSection.
 */
@interface SCObjectCell : SCTableViewCell <SCTableViewControllerDelegate>
{
	SCClassDefinition *objectClassDefinition;
	NSString *boundObjectTitleText;
	BOOL allowDetailView;
	BOOL detailViewModal;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCObjectCell given a bound object.
 *
 *	@param object The object that %SCObjectCell will use to generate its detail view cells.
 */
+ (id)cellWithBoundObject:(NSObject *)object;

/*! Allocates and returns an initialized %SCObjectCell given a bound object and a class definition.
 *
 *	@param object The object that %SCObjectCell will use to generate its detail view cells.
 *	@param classDefinition The extended class definition for the object.
 */
+ (id)cellWithBoundObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCObjectCell given a bound object.
 *
 *	@param object The object that %SCObjectCell will use to generate its detail view cells.
 */
- (id)initWithBoundObject:(NSObject *)object;

/*! Returns an initialized %SCObjectCell given a bound object and a class definition.
 *
 *	@param object The object that %SCObjectCell will use to generate its detail view cells.
 *	@param classDefinition The extended class definition for the object.
 */
- (id)initWithBoundObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDefinition;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The extended class definition of the bound object. */
@property (nonatomic, retain) SCClassDefinition *objectClassDefinition;

/*! The bound object title that will appear in the cell's textLabel.
 *
 *	If this value is nil, %SCObjectCell uses the value of the title property found
 *	in objectClassDefinition. Set this value to override the default behaviour and
 *	provide your own title text for the object.
 */
@property (nonatomic, copy) NSString *boundObjectTitleText; 

/*! Allows/disables a detail view for editing the bound object's properties. Default: TRUE. 
 *
 *	A detail view is automatically generated for editing the bound object's properties. You can control wether the
 *	view appears as a modal view or gets pushed to the navigation stack using the detailViewModal
 *	property. Modal views have the added feature of giving the end user a Cancel and Done buttons.
 *	The Cancel button cancels all user's actions, while the Done button commits them. Also, if the
 *	cell's validation is enabled, the Done button will remain disabled until all cells' values
 *	are valid.
 */
@property (nonatomic, readwrite) BOOL allowDetailView;

/*!	If TRUE, the detail view always appears as a modal view. If FALSE and a navigation controller
 *	exists, the detail view is pushed to the navigation controller's stack, otherwise the view
 *	appears modally. Default: FALSE. */
@property (nonatomic, readwrite) BOOL detailViewModal;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal Methods (do not use)
//////////////////////////////////////////////////////////////////////////////////////////

/*! Method is for internal use only, never call this method directly. */
- (void)setBoundPropertyName:(NSString *)propertyName;

@end





/****************************************************************************************/
/*	class SCArrayOfObjectsCell	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a cell that, given an array of objects, will generate 
 *	an SCArrayOfObjectsSection detail view that's displayed when the cell is tapped. The cell can 
 *	also be optionally bound to an object and generate an additional SCObjectSection detail view
 *	when the cell is tapped while the table is in edit mode.
 *
 *	See also: SCObjectCell, SCObjectSection, SCArrayOfObjectsSection.
 */
@interface SCArrayOfObjectsCell : SCObjectCell
{
	NSMutableArray *items;
	NSMutableSet *itemsSet;
	BOOL sortItemsSetAscending;
	NSMutableDictionary *itemsClassDefinitions;
	
	BOOL allowAddingItems;
	BOOL allowDeletingItems;
	BOOL allowMovingItems;
	BOOL allowEditDetailView;
	BOOL allowRowSelection;
	BOOL displayItemsCountInBadgeView;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCArrayOfObjectsCell given an array of objects and
 *	their class definition.
 *
 *	@param cellItems An array of objects that the cell will use to generate its detail cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
+ (id)cellWithItems:(NSMutableArray *)cellItems
		withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Allocates and returns an initialized %SCArrayOfObjectsCell given 
 *	a mutable set of objects. This method should only be used to create a cell with the contents
 *	of a Core Data relationship.
 *
 *	@param cellItemsSet A mutable set of objects that the cell will use to generate its cells.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
+ (id)cellWithItemsSet:(NSMutableSet *)cellItemsSet
		withClassDefinition:(SCClassDefinition *)classDefinition;

#ifdef _COREDATADEFINES_H
/*! Allocates and returns an initialized %SCArrayOfObjectsCell given a header title and 
 *	an entity class definition. Note: This method creates a cell with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a cell with only a subset
 *	of these objects, consider using the other section initializers.
 *
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
+ (id)cellWithEntityClassDefinition:(SCClassDefinition *)classDefinition;
#endif

/*! Returns an initialized %SCArrayOfObjectsCell given an array of objects and
 *	their class definition.
 *
 *	@param cellItems An array of objects that the cell will use to generate its detail cells.
 *	@param classDefinition The class definition of the class or entity of the objects in the objects array.
 *	If the array contains more than one type of object, then their respective class definitions
 *	must be added to the itemsClassDefinitions dictionary after initialization.
 */
- (id)initWithItems:(NSMutableArray *)cellItems
		withClassDefinition:(SCClassDefinition *)classDefinition;

/*! Returns an initialized %SCArrayOfObjectsCell given 
 *	a mutable set of objects. This method should only be used to create a cell with the contents
 *	of a Core Data relationship.
 *
 *	@param cellItemsSet A mutable set of objects that the cell will use to generate its cells.
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
- (id)initWithItemsSet:(NSMutableSet *)cellItemsSet
   withClassDefinition:(SCClassDefinition *)classDefinition;

#ifdef _COREDATADEFINES_H
/*! Returns an initialized %SCArrayOfObjectsCell given a header title and 
 *	an entity class definition. Note: This method creates a cell with all the objects that
 *	exist in classDefinition's entity's managedObjectContext. To create a cell with only a subset
 *	of these objects, consider using the other section initializers.
 *
 *	@param classDefinition The class definition of the entity of the objects in the objects set.
 */
- (id)initWithEntityClassDefinition:(SCClassDefinition *)classDefinition;
#endif


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The array of objects that the cell uses to generate its detail view.
 *
 *	This array must be of type NSMutableArray, as it must support add, delete, and
 *	move operations. If you do not wish to allow these operations on your array, you can either pass
 *	an array using [NSMutableArray arrayWithArray:myArray], or you can disable the functionality
 *	from the user interface by setting the allowAddingItems, allowDeletingItems, allowMovingItems,
 *	and allowEditDetailView properties. */
@property (nonatomic, retain) NSMutableArray *items;

/*! The mutable set of objects that the cell will use to generate its detail view. Note: 
	This property should only be set when representing a Core Data relationship. */
@property (nonatomic, retain) NSMutableSet *itemsSet;

/*! If TRUE,  objects in itemsSet are sorted ascendingly, otherwise they're sorted descendingly.
 *	Note: Only applicable if itemsSet has been assigned. */
@property (nonatomic) BOOL sortItemsSetAscending;

/*!	Contains all the different class definitions of all the objects in the items array. Each
 *	dictionary entry should contain a key with the SCClassDefinition class name, and a value 
 *	with the actual SCClassDefinition.
 *
 *	Tip: The class name of the SCClassDefinition can be easily determined using the
 *	SClassDefinition.className property.
 */
@property (nonatomic, readonly) NSMutableDictionary *itemsClassDefinitions;

/*!	Allows/disables adding new objects to the items array. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowAddingItems;

/*! Allows/disables deleting new objects from the items array. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowDeletingItems;

/*! Allows/disables moving objects from one row to another. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowMovingItems;

/*! Allows/disables editing detail views for objects. Default: TRUE. */
@property (nonatomic, readwrite) BOOL allowEditDetailView;

/*! Allows/disables row selection. */
@property (nonatomic, readwrite) BOOL allowRowSelection;

/*! Allows/disables displaying the number of objects in the cell's badgeView. Default: TRUE. */
@property (nonatomic, readwrite) BOOL displayItemsCountInBadgeView;


@end





