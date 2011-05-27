/*
 *  SCClassDefinition.h
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
#import "SCPropertyAttributes.h"


@class SCTableViewCell;


typedef enum
{
	SCPropertyDataTypeNSString,
	SCPropertyDataTypeNSNumber,
	SCPropertyDataTypeNSDate,
	SCPropertyDataTypeNSMutableSet,
	SCPropertyDataTypeNSMutableArray,
	SCPropertyDataTypeNSObject,
	SCPropertyDataTypeDictionaryItem,
	SCPropertyDataTypeOther
} SCPropertyDataType;


/*! The types of an SCPropertyDefinition */
typedef enum
{
	/*! The object bound to the property will detect the best user interface element to generate. */
	SCPropertyTypeAutoDetect,
	/*!	The object bound to the property will generate an SCLabelCell interface element */
	SCPropertyTypeLabel,
	/*!	The object bound to the property will generate an SCTextViewCell interface element */
	SCPropertyTypeTextView,
	/*!	The object bound to the property will generate an SCTextFieldCell interface element */
	SCPropertyTypeTextField,
	/*!	The object bound to the property will generate an SCNumericTextFieldCell interface element */
	SCPropertyTypeNumericTextField,
	/*!	The object bound to the property will generate an SCSliderCell interface element */
	SCPropertyTypeSlider,
	/*!	The object bound to the property will generate an SCSegmentedCell interface element */
	SCPropertyTypeSegmented,
	/*!	The object bound to the property will generate an SCSwitchCell interface element */
	SCPropertyTypeSwitch,
	/*!	The object bound to the property will generate an SCDateCell interface element */
	SCPropertyTypeDate,
	/*!	The object bound to the property will generate an SCImagePickerCell interface element */
	SCPropertyTypeImagePicker,
	/*!	The object bound to the property will generate an SCSelectionCell interface element */
	SCPropertyTypeSelection,
	/*!	The object bound to the property will generate an SCObjectSelectionCell interface element */
	SCPropertyTypeObjectSelection,
	/*!	The object bound to the property will generate an SCObjectCell interface element */
	SCPropertyTypeObject,
	/*!	The object bound to the property will generate an SCArrayOfObjectsCell interface element */
	SCPropertyTypeArrayOfObjects,
	/*!	The object bound to the property will not generate an interface element */
	SCPropertyTypeNone
	
} SCPropertyType;


/****************************************************************************************/
/*	class SCPropertyDefinition	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a property definition for SCClassDefinition. Every property
 *	definition should set a property type that determines which user interface element
 *	should be generated for the property. In addition, the generated user interface element
 *	can be further customized using the property's attributes.
 *
 *	See also: SCPropertyType, SCPropertyAttributes, SCClassDefinition.
 *
 */
@interface SCPropertyDefinition : NSObject
{
	SCPropertyDataType dataType;
	BOOL dataReadOnly;
	NSString *name;
	NSString *title;
	SCPropertyType type;
	BOOL required;
	BOOL autoValidate;
	SCPropertyAttributes *attributes;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCPropertyDefinition given a property name.
 *
 *	@param propertyName The name of the property.
 */
+ (id)definitionWithName:(NSString *)propertyName;

/*! Allocates and returns an initialized %SCPropertyDefinition given a property name,
 *	title, and type.
 *
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. Property titles are used by user
 *	interface elements to generate labels associated with the generated controls.
 *	@param propertyType The property type determines which user interface element will
 *	be generated for the property.
 */
+ (id)definitionWithName:(NSString *)propertyName 
				   title:(NSString *)propertyTitle
					type:(SCPropertyType)propertyType;

/*! Returns an initialized %SCPropertyDefinition given a property name.
 *
 *	@param propertyName The name of the property.
 */
- (id)initWithName:(NSString *)propertyName;

/*! Returns an initialized %SCPropertyDefinition given a property name,
 *	title, and type.
 *
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. Property titles are used by user
 *	interface elements to generate labels associated with the generated controls.
 *	@param propertyType The property type determines which user interface element will
 *	be generated for the property.
 */
- (id)initWithName:(NSString *)propertyName 
			 title:(NSString *)propertyTitle
			  type:(SCPropertyType)propertyType;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The name of the property associated with the property definition. */
@property (nonatomic, readonly) NSString *name;

/*! The title of the property. Property titles are used by user
 *	interface elements to generate labels associated with the generated controls.*/
@property (nonatomic, copy) NSString *title;

/*! The type of the property. Property types determines which user interface element will
 *	be generated for the property. */
@property (nonatomic, readwrite) SCPropertyType type;

/*! The attibutes set of the property. Property attributes gives the user the ability
 *	to further customize the user interface element that will be generated for the property. */
@property (nonatomic, retain) SCPropertyAttributes *attributes;

/*! Set to TRUE if property is a required property. Default: FALSE. */
@property (nonatomic, readwrite) BOOL required;

/*! Set to TRUE if the property value should be automatically validated by the user interface element
 *	before commiting it to the property. If the user chooses to provide custom validation
 *	using either the cell's SCTableViewCellDelegate, or the model's SCTableViewModelDelegate, they should
 *	set this property to FALSE. Default: TRUE. */
@property (nonatomic, readwrite) BOOL autoValidate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Internal
//////////////////////////////////////////////////////////////////////////////////////////

/*! This property is automatically set by the framework and should never be assigned a
 *	value directly. */
@property (nonatomic, readwrite) SCPropertyDataType dataType;

/*! This property is automatically set by the framework and should never be assigned a
 *	value directly. */
@property (nonatomic, readwrite) BOOL dataReadOnly;

@end






/****************************************************************************************/
/*	class SCClassDefinition	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a means to further extend the definition of user-defined classes.
 *	Using class definitions, classes like SCObjectCell and SCObjectSection 
 *	will be able to better generate user interface elements that truly represent the 
 *	properties of their bound objects. 
 *
 *	%SCClassDefinition mainly consists of one or more property definitions of type SCPropertyDefinition.
 *	Upon creation, %SCClassDefinition will (optionally) automatically generate all the
 *	property definitions for the given class. From there, the user will be able to customize
 *	the generated property definitions, add new definitions, or remove generated definitions.
 *
 *	See also: SCPropertyDefinition.
 */
@interface SCClassDefinition : NSObject 
{
	Class cls;
	
#ifdef _COREDATADEFINES_H
	NSEntityDescription *entity;
	NSManagedObjectContext *managedObjectContext;
#endif
	
	NSMutableArray *propertyDefinitions;
	NSString *keyPropertyName;
	NSString *titlePropertyName;
	NSString *titlePropertyNameDelimiter;
	NSString *descriptionPropertyName;
	id uiElementDelegate;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Creation and Initialization
//////////////////////////////////////////////////////////////////////////////////////////

/*! Allocates and returns an initialized %SCClassDefinition given a class and the option to
 *	auto generate property definitions for the given class.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the generated properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param autoGenerate If TRUE, %SCClassDefinition will automatically 
 *	generate all the property definitions for the given class. 
 */
+ (id)definitionWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/*! Allocates and returns an initialized %SCClassDefinition given a class and an array of
 *	the property names to generate property definitions from.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the given properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 */
+ (id)definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames;

/*! Allocates and returns an initialized %SCClassDefinition given a class, an array of
 *	the property names to generate property definitions from, and array of titles
 *	for these properties.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array
 *	elements must be of type NSString.
 */
+ (id)definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
		withPropertyTitles:(NSArray *)propertyTitles;

/*! Allocates and returns an initialized %SCClassDefinition given a class and the option to
 *	auto generate property definitions for the given class.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the generated properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param autoGenerate If TRUE, %SCClassDefinition will automatically 
 *	generate all the property definitions for the given class. 
 */
- (id)initWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/*! Allocates and returns an initialized %SCClassDefinition given a class and an array of
 *	the property names to generate property definitions from.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the given properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 */
- (id)initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames;

/*! Allocates and returns an initialized %SCClassDefinition given a class, an array of
 *	the property names to generate property definitions from, and array of titles
 *	for these properties.
 *
 *	@param _cls A class for which the definition will be extended.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array
 *	elements must be of type NSString.
 */
- (id)initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
  withPropertyTitles:(NSArray *)propertyTitles;


#ifdef _COREDATADEFINES_H

/*! Allocates and returns an initialized %SCClassDefinition given a Core Data entity name and the option to
 *	auto generate property definitions for the given entity's properties.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the generated properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param autoGenerate If TRUE, %SCClassDefinition will automatically 
 *	generate all the property definitions for the given entity's attributes. 
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
	autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/*! Allocates and returns an initialized %SCClassDefinition given a Core Data entity name and an array of
 *	the property names to generate property definitions for.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the given properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName 
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames;

/*! Allocates and returns an initialized %SCClassDefinition given a Core Data entity name, an array of
 *	the property names to generate property definitions for, and array of titles
 *	for these properties.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array
 *	elements must be of type NSString.
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
+ (id)definitionWithEntityName:(NSString *)entityName
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
			withPropertyTitles:(NSArray *)propertyTitles;

/*! Returns an initialized %SCClassDefinition given a Core Data entity name and the option to
 *	auto generate property definitions for the given entity's properties.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the generated properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param autoGenerate If TRUE, %SCClassDefinition will automatically 
 *	generate all the property definitions for the given entity's attributes. 
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName 
	withManagedObjectContext:(NSManagedObjectContext *)context
	autoGeneratePropertyDefinitions:(BOOL)autoGenerate;

/*! Returns an initialized %SCClassDefinition given a Core Data entity name and an array of
 *	the property names to generate property definitions for.
 *
 *	The method will also generate user friendly property titles from the names of 
 *	the given properties. These titles can be modified by the user later as part of
 *	the property definition customization.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName 
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames;

/*! Returns an initialized %SCClassDefinition given a Core Data entity name, an array of
 *	the property names to generate property definitions for, and array of titles
 *	for these properties.
 *
 *	@param entityName The name of the entity for which the definition will be extended.
 *	@param context The managed object context of the entity.
 *	@param propertyNames An array of the names of properties to be generated. All array
 *	elements must be of type NSString.
 *	@param propertyTitles An array of titles to the properties in propertyNames. All array
 *	elements must be of type NSString.
 *
 *	Note: This method is used when creating an extended class definition for Core Data's managed object.
 */
- (id)initWithEntityName:(NSString *)entityName
  withManagedObjectContext:(NSManagedObjectContext *)context
		 withPropertyNames:(NSArray *)propertyNames
		withPropertyTitles:(NSArray *)propertyTitles;

#endif


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Configuration
//////////////////////////////////////////////////////////////////////////////////////////

/*! The class associated with the definition. Note: Only applicable with class definition is 
 *	initialized with a class. */
@property (nonatomic, readonly) Class cls;

#ifdef _COREDATADEFINES_H
/*! The entity associated with the definition. Note: Only applicable when class definition is 
 *	initialized with an entity name. */
@property (nonatomic, readonly, retain) NSEntityDescription *entity;

/*! The managed object context of the entity associated with the definition. Note: Only  
 *	applicable when class definition is initialized with an entity name. */
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;
#endif

/*!	The string name of cls or entity */
@property (nonatomic, readonly) NSString *className;

/*! The key of the entity associated with the definition. The key is usually used when
 *	a set of entities is sorted. By default, %SCClassDefinition sets this property to the name of the 
 *	first property in the entity. Note: Only applicable when class definition is 
 *	initialized with an entity name. */
@property (nonatomic, copy) NSString *keyPropertyName;

/*!	The name of the title property for the class or entity. Title properties are used in user
 *	interface elements to display title information based on the value of the property
 *	named here. By default, %SCClassDefinition sets this property to the name of the 
 *	first property in cls or entity. Note: To have the title set to more than one property value,
 *	separate the property names by a semi-colon (e.g.: @"firstName;lastName"). When displayed, the
 *	titles will be separated by the value of the titlePropertyNameDelimiter property. */
@property (nonatomic, copy) NSString *titlePropertyName;

/*! The delimiter used to separate the titles specified in titlePropertyName. Default: @" ". */
@property (nonatomic, copy) NSString *titlePropertyNameDelimiter;

/*!	The name of the description property for the class or entity. Description properties are used in user
 *	interface elements to display description information based on the value of the property
 *	named here. */
@property (nonatomic, copy) NSString *descriptionPropertyName;

/*! The delegate for the user interface elements that will be generated for the property definitions. */
@property (nonatomic, assign) id uiElementDelegate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Managing Property Definitions
//////////////////////////////////////////////////////////////////////////////////////////

/*! The number of property definitions. */
@property (nonatomic, readonly) NSUInteger propertyDefinitionCount;

/*! Methods adds a new property definition.
 *	@param propertyName The name of the property.
 *	@param propertyTitle The title of the property. If no value is provided, 
 *	the method automatically generates a user friendly name for the property.
 *	@param propertyType The property type.
 *	@return Returns TRUE if adding the definition was successful. The main reason for
 *	addition failure is if the property name does not match an existing property in cls.
 */
- (BOOL)addPropertyDefinitionWithName:(NSString *)propertyName 
								title:(NSString *)propertyTitle
								 type:(SCPropertyType)propertyType;

/*! Methods adds a new property definition.
 *	@param propertyDefinition The property definition to be added.
 *	@return Returns TRUE if adding the definition was successful. The main reason for
 *	addition failure is if the property name does not match an existing property in cls.
 */
- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition;

/*! Removes the property definition at the given index.
 *	@param index Must be less than the total number of property definitions. */
- (void)removePropertyDefinitionAtIndex:(NSUInteger)index;

/*! Removes the property definition with the given name. 
 *	@param propertyName The name of the property to be removed. */
- (void)removePropertyDefinitionWithName:(NSString *)propertyName;

/*! Returns the property definition at the given index.
 *	@param index Must be less than the total number of property definitions. */
- (SCPropertyDefinition *)propertyDefinitionAtIndex:(NSUInteger)index;

/*! Returns the property definition with the given name. 
 *	@param propertyName The name of the property who's definition to be returned. */
- (SCPropertyDefinition *)propertyDefinitionWithName:(NSString *)propertyName;

/*! Returns the index for the property definition with the given name. 
 *	@param propertyName The name of the property who's index to be returned. */
- (NSUInteger)indexOfPropertyDefinitionWithName:(NSString *)propertyName;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Other
//////////////////////////////////////////////////////////////////////////////////////////

/*! Returns TRUE if propertyName is valid.  A propertyName is valid if it exists within the associated
 *	class or entity. 
 *	@param propertyName The name of the property who's validity is to be checked. */
- (BOOL)isValidPropertyName:(NSString *)propertyName;

/*! Returns the title string value for the given object. The title value is determined
 *	based on the value of the titlePropertyName property. Note: object must be an instance
 *	of the same class or entity defined in the class definition. */
- (NSString *)titleValueForObject:(NSObject *)object;

@end








/****************************************************************************************/
/*	class SCDictionaryDefinition	*/
/****************************************************************************************/ 
/*!
 *	This class functions as a means to further extend the key definitions of an NSMutableDictionary.
 *	Using dictionary definitions, classes like SCObjectCell and SCObjectSection 
 *	will be able to better generate user interface elements that truly represent the 
 *	keys of their bound mutable dictionaries. 
 *
 *	%SCDictionaryDefinition directly decends from SCClassDefinition.
 *
 *	See also: SCPropertyDefinition.
 */
@interface SCDictionaryDefinition : SCClassDefinition
{
}

/*! Allocates and returns an initialized %SCDictionaryDefinition given the key names
 *	of the mutable dictionary to be defined. By default, all property definitions generated
 *	for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 *	after initialization.
 *
 *	@param keyNames An array of the dictionary key names. All array
 *	elements must be of type NSString.
 */
+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames;

/*! Allocates and returns an initialized %SCDictionaryDefinition given the key names
 *	and titles of the mutable dictionary to be defined. By default, all property definitions generated
 *	for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 *	after initialization.
 *
 *	@param keyNames An array of the dictionary key names. All array
 *	elements must be of type NSString.
 *	@param keyTitles An array of titles to the keys in keyNames. All array
 *	elements must be of type NSString.
 */
+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
	   withKeyTitles:(NSArray *)keyTitles;

/*! Returns an initialized %SCDictionaryDefinition given the key names
 *	of the mutable dictionary to be defined. By default, all property definitions generated
 *	for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 *	after initialization.
 *
 *	@param keyNames An array of the dictionary key names. All array
 *	elements must be of type NSString.
 */
- (id)initWithDictionaryKeyNames:(NSArray *)keyNames;

/*! Returns an initialized %SCDictionaryDefinition given the key names
 *	and titles of the mutable dictionary to be defined. By default, all property definitions generated
 *	for the given keyNames will have a type of SCPropertyTypeTextField. This can be fully customized
 *	after initialization.
 *
 *	@param keyNames An array of the dictionary key names. All array
 *	elements must be of type NSString.
 *	@param keyTitles An array of titles to the keys in keyNames. All array
 *	elements must be of type NSString.
 */
- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
				   withKeyTitles:(NSArray *)keyTitles;

@end




