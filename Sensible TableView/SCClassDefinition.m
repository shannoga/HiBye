/*
 *  SCClassDefinition.m
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

#import "SCClassDefinition.h"
#import <objc/runtime.h>

@implementation SCPropertyDefinition

@synthesize dataType;
@synthesize dataReadOnly;
@synthesize name;
@synthesize title;
@synthesize type;
@synthesize required;
@synthesize autoValidate;
@synthesize attributes;

+ (id)definitionWithName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithName:propertyName] autorelease];
}

+ (id)definitionWithName:(NSString *)propertyName 
				   title:(NSString *)propertyTitle
					type:(SCPropertyType)propertyType
{
	return [[[[self class] alloc] initWithName:propertyName
										 title:propertyTitle
										  type:propertyType] autorelease];
}

- (id)initWithName:(NSString *)propertyName
{
	return [self initWithName:propertyName title:nil type:SCPropertyTypeAutoDetect];
}

- (id)initWithName:(NSString *)propertyName 
			 title:(NSString *)propertyTitle
			  type:(SCPropertyType)propertyType
{
	if( (self=[super init]) )
	{
		dataType = SCPropertyDataTypeOther;
		dataReadOnly = FALSE;
		
		name = [propertyName copy];
		self.title = propertyTitle;
		self.type = propertyType;
		self.required = FALSE;
		self.autoValidate = TRUE;
		self.attributes = nil;
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[title release];
	[attributes release];
	
	[super dealloc];
}

@end







@interface SCClassDefinition ()

- (NSString *)getUserFriendlyPropertyTitleFromName:(NSString *)propertyName;

@end


@implementation SCClassDefinition

@synthesize cls;

#ifdef _COREDATADEFINES_H
@synthesize entity;
@synthesize managedObjectContext;
#endif

@synthesize keyPropertyName;
@synthesize titlePropertyName;
@synthesize titlePropertyNameDelimiter;
@synthesize descriptionPropertyName;
@synthesize uiElementDelegate;


+ (id) definitionWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	return [[[[self class] alloc] initWithClass:_cls 
				 autoGeneratePropertyDefinitions:autoGenerate] autorelease];
}

+ (id) definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
{
	return [[[[self class] alloc] initWithClass:_cls 
							   withPropertyNames:propertyNames] autorelease];
}

+ (id) definitionWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
		 withPropertyTitles:(NSArray *)propertyTitles
{
	return [[[[self class] alloc] initWithClass:_cls 
							   withPropertyNames:propertyNames
							  withPropertyTitles:propertyTitles] autorelease];
}


#ifdef _COREDATADEFINES_H
+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
		autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	return [[[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
					 autoGeneratePropertyDefinitions:autoGenerate] autorelease];
}

+ (id)definitionWithEntityName:(NSString *)entityName 
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
{
	return [[[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
								   withPropertyNames:propertyNames] autorelease];
}

+ (id)definitionWithEntityName:(NSString *)entityName
	  withManagedObjectContext:(NSManagedObjectContext *)context
			 withPropertyNames:(NSArray *)propertyNames
			withPropertyTitles:(NSArray *)propertyTitles
{
	return [[[[self class] alloc] initWithEntityName:entityName
							withManagedObjectContext:context
								   withPropertyNames:propertyNames
								  withPropertyTitles:propertyTitles] autorelease];
}
#endif


- (id) init
{
	if( (self = [super init]) )
	{
#ifdef _COREDATADEFINES_H		
		entity = nil;
		managedObjectContext = nil;
#endif		
		
		propertyDefinitions = [[NSMutableArray alloc] init];
		keyPropertyName = nil;
		titlePropertyName = nil;
		titlePropertyNameDelimiter = @" ";
		descriptionPropertyName = nil;
		uiElementDelegate = nil;
	}
	return self;
}

- (id) initWithClass:(Class)_cls autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	if([self init])
	{
		cls = _cls;
		
		if(autoGenerate)
		{
			unsigned int count = 0;
			objc_property_t *properties = class_copyPropertyList(self.cls, &count);
			for (unsigned int i = 0; i < count; i++ )
			{	
				NSString *propertyName = [NSString stringWithUTF8String: property_getName(properties[i])];
				[self addPropertyDefinitionWithName:propertyName 
											  title:[self getUserFriendlyPropertyTitleFromName:propertyName] 
											   type:SCPropertyTypeAutoDetect];
			}
			free(properties);
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
	}
	
	return self;
}

- (id) initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
{
	return [self initWithClass:_cls withPropertyNames:propertyNames withPropertyTitles:nil];
}

- (id) initWithClass:(Class)_cls withPropertyNames:(NSArray *)propertyNames
   withPropertyTitles:(NSArray *)propertyTitles
{
	if([self initWithClass:_cls autoGeneratePropertyDefinitions:NO])
	{
		for(int i=0; i<propertyNames.count; i++)
		{
			NSString *propertyName = [propertyNames objectAtIndex:i];
			NSString *propertyTitle;
			if(i < propertyTitles.count)
				propertyTitle = [propertyTitles objectAtIndex:i];
			else
				propertyTitle = [self getUserFriendlyPropertyTitleFromName:propertyName];
			[self addPropertyDefinitionWithName:propertyName
										  title:propertyTitle
										   type:SCPropertyTypeAutoDetect];
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
		
		self.descriptionPropertyName = nil;
	}
	
	return self;
}


#ifdef _COREDATADEFINES_H
- (id)initWithEntityName:(NSString *)entityName 
	withManagedObjectContext:(NSManagedObjectContext *)context
		autoGeneratePropertyDefinitions:(BOOL)autoGenerate
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
														 inManagedObjectContext:context];
	
	if(!autoGenerate)
	{
		[self init];
		managedObjectContext = [context retain];
		entity = [entityDescription retain];
		return self;
	}
	//else
	
	NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:entityDescription.properties.count];
	for(NSPropertyDescription *propertyDescription in entityDescription.properties)
	{
		[propertyNames addObject:[propertyDescription name]];
	}
	return [self initWithEntityName:entityName withManagedObjectContext:context
				  withPropertyNames:propertyNames];
}

- (id)initWithEntityName:(NSString *)entityName 
withManagedObjectContext:(NSManagedObjectContext *)context
	   withPropertyNames:(NSArray *)propertyNames
{
	return [self initWithEntityName:entityName withManagedObjectContext:context
				  withPropertyNames:propertyNames withPropertyTitles:nil];
}

- (id)initWithEntityName:(NSString *)entityName
withManagedObjectContext:(NSManagedObjectContext *)context
	   withPropertyNames:(NSArray *)propertyNames
	  withPropertyTitles:(NSArray *)propertyTitles
{
	if( (self = [self init]) )
	{
		managedObjectContext = [context retain];
		entity = [[NSEntityDescription entityForName:entityName
							  inManagedObjectContext:self.managedObjectContext] retain];
		
		for(int i=0; i<propertyNames.count; i++)
		{
			NSString *propertyName = [propertyNames objectAtIndex:i];
			NSString *propertyTitle;
			if(i < propertyTitles.count)
				propertyTitle = [propertyTitles objectAtIndex:i];
			else
				propertyTitle = [self getUserFriendlyPropertyTitleFromName:propertyName];
			NSPropertyDescription *propertyDescription = 
				[[self.entity propertiesByName] valueForKey:propertyName];
			
			if(propertyDescription)
			{
				SCPropertyDefinition *propertyDef = [SCPropertyDefinition 
													 definitionWithName:propertyName
													 title:propertyTitle
													 type:SCPropertyTypeNone];
				propertyDef.required = ![propertyDescription isOptional];
				
				if([propertyDescription isKindOfClass:[NSAttributeDescription class]])
				{
					NSAttributeDescription *attribute = (NSAttributeDescription *)propertyDescription;
					switch ([attribute attributeType]) 
					{
						case NSInteger16AttributeType:
						case NSInteger32AttributeType:
						case NSInteger64AttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeNumericTextField;
							propertyDef.attributes = [SCNumericTextFieldAttributes 
													  attributesWithMinimumValue:nil 
													  maximumValue:nil 
													  allowFloatValue:FALSE];
							break;

						case NSDecimalAttributeType:
						case NSDoubleAttributeType:
						case NSFloatAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeNumericTextField;
							break;
							
						case NSStringAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSString;
							propertyDef.type = SCPropertyTypeTextField;
							break;
							
						case NSBooleanAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSNumber;
							propertyDef.type = SCPropertyTypeSwitch;
							break;

						case NSDateAttributeType:
							propertyDef.dataType = SCPropertyDataTypeNSDate;
							propertyDef.type = SCPropertyTypeDate;
							break;
							
					
						default:
							propertyDef.type = SCPropertyTypeNone;
							break;
					}
				}
				else
					if([propertyDescription isKindOfClass:[NSRelationshipDescription class]])
					{
						NSRelationshipDescription *relationship = (NSRelationshipDescription *)propertyDescription;
						
						if([relationship isToMany])
						{
							propertyDef.dataType = SCPropertyDataTypeNSMutableSet;
							propertyDef.type = SCPropertyTypeArrayOfObjects;
						}
						else
						{
							propertyDef.dataType = SCPropertyDataTypeNSObject;
							propertyDef.type = SCPropertyTypeObject;
						}
					}
				else
					if([propertyDescription isKindOfClass:[NSFetchedPropertyDescription class]])
					{
						propertyDef.dataType = SCPropertyDataTypeNSMutableSet;
						propertyDef.type = SCPropertyTypeArrayOfObjects;
						propertyDef.attributes = [SCArrayOfObjectsAttributes 
												  attributesWithObjectClassDefinition:nil
												  allowAddingItems:NO
												  allowDeletingItems:NO
												  allowMovingItems:NO];
					}
				
				[self addPropertyDefinition:propertyDef];
			}
		}
		
		// Set self.keyPropertyName & self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
		{
			self.keyPropertyName = [self propertyDefinitionAtIndex:0].name;
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
		}
	}
	
	return self;
}
#endif


- (void)dealloc
{
#ifdef _COREDATADEFINES_H	
	[managedObjectContext release];
	[entity release];
#endif
	
	[propertyDefinitions release];
	[keyPropertyName release];
	[titlePropertyName release];
	[titlePropertyNameDelimiter release];
	[descriptionPropertyName release];
	
	[super dealloc];
}

- (NSString *)getUserFriendlyPropertyTitleFromName:(NSString *)propertyName
{
	NSMutableString *UFName = [[[NSMutableString string] retain] autorelease];
	
	if(![propertyName length])
		return UFName;
	
	// Capitalize & append the 1st character
	[UFName appendString:[[propertyName substringToIndex:1] uppercaseString]];
	
	// Leave a space for every capital letter
	NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
	for(int i=1; i<[propertyName length]; i++)
	{
		unichar chr = [propertyName characterAtIndex:i];
		if([uppercaseSet characterIsMember:chr])
			[UFName appendString:[NSString stringWithFormat:@" %c", chr]];
		else
			[UFName appendString:[NSString stringWithFormat:@"%c", chr]];
	}
	
	return UFName;
}

- (NSString *)className
{
#ifdef _COREDATADEFINES_H	
	if(self.entity)
		return [self.entity name];
#endif
	//else
	return [NSString stringWithFormat:@"%s", class_getName(self.cls)];
}

- (void)setKeyPropertyName:(NSString *)propertyName
{
	if([self isValidPropertyName:propertyName])
	{
		[keyPropertyName release];
		keyPropertyName = [propertyName copy];
	}
}

- (NSUInteger)propertyDefinitionCount
{
	return propertyDefinitions.count;
}

- (BOOL)addPropertyDefinitionWithName:(NSString *)propertyName 
								title:(NSString *)propertyTitle
								 type:(SCPropertyType)propertyType
{
	SCPropertyDefinition *propertyDefinition = 
	[[SCPropertyDefinition alloc] initWithName:propertyName 
										 title:propertyTitle 
										  type:propertyType];
	BOOL success = [self addPropertyDefinition:propertyDefinition];
	[propertyDefinition release];
	
	return success;
}

- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
{
	if([self isValidPropertyName:propertyDefinition.name])
	{
		BOOL coreDataDefinition = FALSE;
#ifdef _COREDATADEFINES_H
		if(self.entity)
			coreDataDefinition = TRUE;
#endif
		if(!coreDataDefinition)
		{
			// Set property's dataType & dataReadOnly properties
			objc_property_t property = class_getProperty(self.cls, [propertyDefinition.name UTF8String]);
			if(!property)
				return FALSE;
			NSArray *attributesArray = [[NSString stringWithUTF8String: property_getAttributes(property)] 
										componentsSeparatedByString:@","];
			NSSet *attributesSet = [NSSet setWithArray:attributesArray];
			
			propertyDefinition.dataReadOnly = [attributesSet containsObject:@"R"];
			
			if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
											  [NSString stringWithUTF8String:class_getName([NSString class])]]])
				propertyDefinition.dataType = SCPropertyDataTypeNSString;
			else
				if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
												  [NSString stringWithUTF8String:class_getName([NSNumber class])]]])
					propertyDefinition.dataType = SCPropertyDataTypeNSNumber;
				else
					if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
													  [NSString stringWithUTF8String:class_getName([NSDate class])]]])
						propertyDefinition.dataType = SCPropertyDataTypeNSDate;
					else
						if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
														  [NSString stringWithUTF8String:class_getName([NSMutableSet class])]]])
							propertyDefinition.dataType = SCPropertyDataTypeNSMutableSet;
						else
							if([attributesSet containsObject:[NSString stringWithFormat:@"T@\"%@\"", 
															  [NSString stringWithUTF8String:class_getName([NSMutableArray class])]]])
								propertyDefinition.dataType = SCPropertyDataTypeNSMutableArray;
		}
		
		[propertyDefinitions addObject:propertyDefinition];
		return TRUE;
	}
	//else
	return FALSE;
}

- (void)removePropertyDefinitionAtIndex:(NSUInteger)index
{
	[propertyDefinitions removeObjectAtIndex:index];
}

- (void)removePropertyDefinitionWithName:(NSString *)propertyName
{
	NSUInteger index = [self indexOfPropertyDefinitionWithName:propertyName];
	if(index != -1)
		[propertyDefinitions removeObjectAtIndex:index];
}

- (SCPropertyDefinition *)propertyDefinitionAtIndex:(NSUInteger)index
{
	return [propertyDefinitions objectAtIndex:index];
}

- (SCPropertyDefinition *)propertyDefinitionWithName:(NSString *)propertyName
{
	NSUInteger index = [self indexOfPropertyDefinitionWithName:propertyName];
	if(index != -1)
		return [propertyDefinitions objectAtIndex:index];
	//else
	return nil;
}

- (NSUInteger)indexOfPropertyDefinitionWithName:(NSString *)propertyName
{
	for(NSUInteger i=0; i<propertyDefinitions.count; i++)
	{
		SCPropertyDefinition *propertyDefinition = [propertyDefinitions objectAtIndex:i];
		if([propertyDefinition.name isEqualToString:propertyName])
			return i;
	}
	return -1;
}

- (BOOL)isValidPropertyName:(NSString *)propertyName
{
	BOOL propertyValid = FALSE;

#ifdef _COREDATADEFINES_H	
	if(self.entity)
	{
		propertyValid = ([[self.entity propertiesByName] valueForKey:propertyName] != nil);
	}
	else
	{
#endif		
		objc_property_t property = class_getProperty(self.cls, [propertyName UTF8String]);
		
		if(property)
		{
			// Property must be an NSObject decendant to be allowed
			NSArray *attributesArray = [[NSString stringWithUTF8String: property_getAttributes(property)] 
										componentsSeparatedByString:@","];
			NSString *classAttribute = [attributesArray objectAtIndex:0];
			NSRange classStringRange = [classAttribute rangeOfString:@"T@\""];
			if(classStringRange.location != NSNotFound)
			{
				propertyValid = TRUE;
			}
		}
#ifdef _COREDATADEFINES_H		
	}
#endif	
	
	return propertyValid;
}

- (NSString *)titleValueForObject:(NSObject *)object
{
	if(!self.titlePropertyName)
		return nil;

	NSMutableString *titleValue = [NSMutableString string];
	
	NSArray *titleNames = [self.titlePropertyName componentsSeparatedByString:@";"];
#ifdef _COREDATADEFINES_H
	if([object isKindOfClass:[NSManagedObject class]])
	{
		for(int i=0; i<titleNames.count; i++)
		{
			id value = [(NSManagedObject *)object valueForKeyPath:[titleNames objectAtIndex:i]];
			if(value)
			{
				if(i!=0)
					[titleValue appendString:self.titlePropertyNameDelimiter];
				[titleValue appendString:[NSString stringWithFormat:@"%@", value]];
			}
		}
	}
	else
	{
		for(int i=0; i<titleNames.count; i++)
		{
			id value = [object valueForKey:[titleNames objectAtIndex:i]];
			if(value)
			{
				if(i!=0)
					[titleValue appendString:self.titlePropertyNameDelimiter];
				[titleValue appendString:[NSString stringWithFormat:@"%@", value]];
			}
		}
	}
#else
	for(int i=0; i<titleNames.count; i++)
	{
		id value = [object valueForKey:[titleNames objectAtIndex:i]];
		if(value)
		{
			if(i!=0)
				[titleValue appendString:self.titlePropertyNameDelimiter];
			[titleValue appendString:[NSString stringWithFormat:@"%@", value]];
		}
	}
#endif
	
	return titleValue;
}

@end






@implementation SCDictionaryDefinition

+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
{
	return [[[[self class] alloc] initWithDictionaryKeyNames:keyNames] autorelease];
}

+ (id)definitionWithDictionaryKeyNames:(NSArray *)keyNames
						 withKeyTitles:(NSArray *)keyTitles
{
	return [[[[self class] alloc] initWithDictionaryKeyNames:keyNames
											   withKeyTitles:keyTitles] autorelease];
}

- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
{
	return [self initWithDictionaryKeyNames:keyNames withKeyTitles:nil];
}

- (id)initWithDictionaryKeyNames:(NSArray *)keyNames
				   withKeyTitles:(NSArray *)keyTitles
{
	if([self init])
	{
		for(int i=0; i<keyNames.count; i++)
		{
			NSString *keyName = [keyNames objectAtIndex:i];
			NSString *keyTitle;
			if(i < keyTitles.count)
				keyTitle = [keyTitles objectAtIndex:i];
			else
				keyTitle = [self getUserFriendlyPropertyTitleFromName:keyName];
			[self addPropertyDefinitionWithName:keyName
										  title:keyTitle
										   type:SCPropertyTypeTextField];
		}
		
		// Set self.titlePropertyName to the first property
		if(self.propertyDefinitionCount)
			self.titlePropertyName = [self propertyDefinitionAtIndex:0].name;
	}
	return self;
}

// override superclass
- (BOOL)isValidPropertyName:(NSString *)propertyName
{
	return TRUE;	// Should accept any key name as a valid property name
}

// override superclass
- (BOOL)addPropertyDefinition:(SCPropertyDefinition *)propertyDefinition
{
	propertyDefinition.dataType = SCPropertyDataTypeDictionaryItem;
	[propertyDefinitions addObject:propertyDefinition];
	
	return TRUE;
}

// override superclass
- (NSString *)className
{
	return @"__NSCFDictionary";
}

@end


