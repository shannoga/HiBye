/*
 *  SCPropertyAttributes.m
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

#import "SCPropertyAttributes.h"
#import "SCClassDefinition.h"


@implementation SCPropertyAttributes

@synthesize imageView;
@synthesize imageViewArray;

- (id)init
{
	if( (self = [super init]) )
	{
		imageView = nil;
		imageViewArray = nil;
	}
	return self;
}

- (void)dealloc
{
	[imageView release];
	[imageViewArray release];
	
	[super dealloc];
}

@end







@implementation SCTextViewAttributes

@synthesize minimumHeight;
@synthesize maximumHeight;
@synthesize autoResize;
@synthesize editable;


+ (id)attributesWithMinimumHeight:(CGFloat)minHeight maximumHeight:(CGFloat)maxHeight
					   autoResize:(BOOL)_autoResize editable:(BOOL)_editable
{
	return [[[[self class] alloc] initWithMinimumHeight:minHeight maximumHeight:maxHeight 
											 autoResize:_autoResize editable:_editable] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumHeight = FLT_MIN;		// will be ignored
		maximumHeight = FLT_MIN;		// will be ignored
		autoResize = TRUE;
		editable = TRUE;
	}
	return self;
}

- (id)initWithMinimumHeight:(CGFloat)minHeight maximumHeight:(CGFloat)maxHeight
				 autoResize:(BOOL)_autoResize editable:(BOOL)_editable
{
	if([self init])
	{
		self.minimumHeight = minHeight;
		self.maximumHeight = maxHeight;
		self.autoResize = _autoResize;
		self.editable = _editable;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end







@implementation SCTextFieldAttributes

@synthesize placeholder;

+ (id)attributesWithPlaceholder:(NSString *)_placeholder
{
	return [[[[self class] alloc] initWithPlaceholder:_placeholder] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		placeholder = nil;		// will be ignored
	}
	return self;
}

- (id)initWithPlaceholder:(NSString *)_placeholder
{
	if([self init])
	{
		self.placeholder = _placeholder;
	}
	return self;
}

- (void)dealloc
{
	[placeholder release];
	[super dealloc];
}

@end







@implementation SCNumericTextFieldAttributes

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize allowFloatValue;

+ (id)attributesWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
				 allowFloatValue:(BOOL)allowFloat
{
	return [[[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue 
									   allowFloatValue:allowFloat] autorelease];
}

+ (id)attributesWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
				 allowFloatValue:(BOOL)allowFloat placeholder:(NSString *)_placeholder
{
	return [[[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue 
									   allowFloatValue:allowFloat
										   placeholder:_placeholder] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumValue = nil;		// will be ignored
		maximumValue = nil;		// will be ignored
		allowFloatValue = TRUE;
	}
	return self;
}

- (id)initWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
		   allowFloatValue:(BOOL)allowFloat
{
	if([self init])
	{
		self.maximumValue = maxValue;
		self.minimumValue = minValue;
		self.allowFloatValue = allowFloat;
	}
	return self;
}

- (id)initWithMinimumValue:(NSNumber *)minValue maximumValue:(NSNumber *)maxValue
		   allowFloatValue:(BOOL)allowFloat placeholder:(NSString *)_placeholder
{
	if([self initWithPlaceholder:_placeholder])
	{
		self.maximumValue = maxValue;
		self.minimumValue = minValue;
		self.allowFloatValue = allowFloat;
	}
	return self;
}

- (void)dealloc
{
	[minimumValue release];
	[maximumValue release];
	[super dealloc];
}

@end







@implementation SCSliderAttributes

@synthesize minimumValue;
@synthesize maximumValue;

+ (id)attributesWithMinimumValue:(float)minValue maximumValue:(float)maxValue
{
	return [[[[self class] alloc] initWithMinimumValue:minValue maximumValue:maxValue]
			autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		minimumValue = FLT_MIN;		// will be ignored
		maximumValue = FLT_MIN;		// will be ignored
	}
	return self;
}

- (id)initWithMinimumValue:(float)minValue maximumValue:(float)maxValue
{
	if([self init])
	{
		self.minimumValue = minValue;
		self.maximumValue = maxValue;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end







@implementation SCSegmentedAttributes

@synthesize segmentTitlesArray;

+ (id)attributesWithSegmentTitlesArray:(NSArray *)titles
{
	return [[[[self class] alloc] initWithSegmentTitlesArray:titles] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		segmentTitlesArray = nil;		// will be ignored
	}
	return self;
}

- (id)initWithSegmentTitlesArray:(NSArray *)titles
{
	if([self init])
	{
		self.segmentTitlesArray = titles;
	}
	return self;
}

- (void)dealloc
{
	[segmentTitlesArray release];
	[super dealloc];
}

@end







@implementation SCDateAttributes

@synthesize dateFormatter;

+ (id)attributesWithDateFormatter:(NSDateFormatter *)formatter
{
	return [[[[self class] alloc] initWithDateFormatter:formatter] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		dateFormatter = nil;		// will be ignored
	}
	return self;
}

- (id)initWithDateFormatter:(NSDateFormatter *)formatter
{
	if([self init])
	{
		self.dateFormatter = formatter;
	}
	return self;
}

- (void)dealloc
{
	[dateFormatter release];
	[super dealloc];
}

@end







@implementation SCSelectionAttributes

@synthesize items;
@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize autoDismissDetailView;
@synthesize hideDetailViewNavigationBar;

+ (id)attributesWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
		 allowNoSelection:(BOOL)allowNoSel
{
	return [[[[self class] alloc] initWithItems:_items allowMultipleSelection:allowMultipleSel
							   allowNoSelection:allowNoSel] autorelease];
}

+ (id)attributesWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
		 allowNoSelection:(BOOL)allowNoSel autoDismissDetailView:(BOOL)autoDismiss
			hideDetailViewNavigationBar:(BOOL)hideNavBar
{
	return [[[[self class] alloc] initWithItems:_items allowMultipleSelection:allowMultipleSel
							   allowNoSelection:allowNoSel 
						  autoDismissDetailView:autoDismiss
					hideDetailViewNavigationBar:hideNavBar] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		items = nil;		// will be ignored
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		autoDismissDetailView = FALSE;
		hideDetailViewNavigationBar = FALSE;
	}
	return self;
}

- (id)initWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
   allowNoSelection:(BOOL)allowNoSel
{
	if([self init])
	{
		self.items = _items;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
	}
	return self;
}

- (id)initWithItems:(NSArray *)_items allowMultipleSelection:(BOOL)allowMultipleSel
   allowNoSelection:(BOOL)allowNoSel autoDismissDetailView:(BOOL)autoDismiss
		hideDetailViewNavigationBar:(BOOL)hideNavBar
{
	if([self init])
	{
		self.items = _items;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
		self.autoDismissDetailView = autoDismiss;
		self.hideDetailViewNavigationBar = hideNavBar;
	}
	return self;
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}

@end






@implementation SCObjectSelectionAttributes

@synthesize itemsEntityClassDefinition;
@synthesize itemsTitlePropertyName;
#ifdef _COREDATADEFINES_H
@synthesize fetchRequest;
#endif

+ (id)attributesWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
					withItemsTitlePropertyName:(NSString *)titlePropertyName
						allowMultipleSelection:(BOOL)allowMultipleSel
							  allowNoSelection:(BOOL)allowNoSel
{
	return [[[[self class] alloc] initWithItemsEntityClassDefinition:classDefinition
										  withItemsTitlePropertyName:titlePropertyName
											  allowMultipleSelection:allowMultipleSel
													allowNoSelection:allowNoSel] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		itemsEntityClassDefinition = nil;
		itemsTitlePropertyName = nil;
		
#ifdef _COREDATADEFINES_H
		fetchRequest = nil;
#endif
	}
	return self;
}

- (id)initWithItemsEntityClassDefinition:(SCClassDefinition *)classDefinition 
			  withItemsTitlePropertyName:(NSString *)titlePropertyName
				  allowMultipleSelection:(BOOL)allowMultipleSel
						allowNoSelection:(BOOL)allowNoSel
{
	if([self init])
	{
		self.itemsEntityClassDefinition = classDefinition;
		self.itemsTitlePropertyName = titlePropertyName;
		self.allowMultipleSelection = allowMultipleSel;
		self.allowNoSelection = allowNoSel;
	}
	return self;
}

- (void)dealloc
{
	[itemsEntityClassDefinition release];
	[itemsTitlePropertyName release];
#ifdef _COREDATADEFINES_H	
	[fetchRequest release];
#endif	
	[super dealloc];
}

@end







@implementation SCObjectAttributes

@synthesize classDefinitions;

+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithObjectClassDefinition:classDefinition] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		classDefinitions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self init])
	{
		if(classDefinition)
			[self.classDefinitions setValue:classDefinition forKey:classDefinition.className];
	}
	return self;
}

- (void)dealloc
{
	[classDefinitions release];
	[super dealloc];
}

@end








@implementation SCArrayOfObjectsAttributes

@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditingItems;

+ (id)attributesWithObjectClassDefinition:(SCClassDefinition *)classDefinition
						 allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting
						 allowMovingItems:(BOOL)allowMoving
{
	return [[[[self class] alloc] initWithObjectClassDefinition:classDefinition
											   allowAddingItems:allowAdding
											 allowDeletingItems:allowDeleting
											   allowMovingItems:allowMoving] autorelease];
}

- (id)init
{
	if( (self = [super init]) )
	{
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = TRUE;
		allowEditingItems = TRUE;
	}
	return self;
}

- (id)initWithObjectClassDefinition:(SCClassDefinition *)classDefinition
				   allowAddingItems:(BOOL)allowAdding allowDeletingItems:(BOOL)allowDeleting
				   allowMovingItems:(BOOL)allowMoving
{
	if([super initWithObjectClassDefinition:classDefinition])
	{
		allowAddingItems = allowAdding;
		allowDeletingItems = allowDeleting;
		allowMovingItems = allowMoving;
	}
	return self;
}

@end






