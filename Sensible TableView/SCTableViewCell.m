/*
 *  SCTableViewCell.m
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

#import "SCTableViewCell.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "SCGlobals.h"
#import "SCTableViewModel.h"


@interface SCTableViewCell ()

- (void)disableOwnerViewControllerDelegate;
- (void)enableOwnerViewControllerDelegate;

@end





@implementation SCTableViewCell

@synthesize tempDetailModel;
@synthesize ownerTableViewModel;
@synthesize boundObject;
@synthesize boundPropertyName;
@synthesize boundKey;
@synthesize height;
@synthesize editable;
@synthesize movable;
@synthesize selectable;
@synthesize detailViewTitle;
#ifdef __IPHONE_3_2
@synthesize detailViewModalPresentationStyle;
#endif
@synthesize detailTableViewStyle;
@synthesize detailCellsImageViews;
@synthesize detailViewHidesBottomBar;
@synthesize badgeView;
@synthesize autoResignFirstResponder;
@synthesize cellEditingStyle;
@synthesize valueRequired;
@synthesize autoValidateValue;
@synthesize delegate;
@synthesize commitChangesLive;
@synthesize needsCommit;

+ (id)cell
{
	return [[[[self class] alloc] initWithStyle:SC_DefaultCellStyle
								reuseIdentifier:nil] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
{
	return [[[[self class] alloc] initWithText:cellText] autorelease];
}

+ (id)cellWithText:(NSString *)cellText withBoundObject:(NSObject *)object 
  withPropertyName:(NSString *)propertyName;
{
	return [[[[self class] alloc] initWithText:cellText withBoundObject:object
							  withPropertyName:propertyName] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue
{
	return [[[[self class] alloc] initWithText:cellText
								  withBoundKey:key withValue:keyValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.shouldIndentWhileEditing = TRUE;
		
		ownerViewControllerDelegate = nil;
		tempDetailModel = nil;
		
		ownerTableViewModel = nil;
		boundObject = nil;
		boundPropertyName = nil;
		boundKey = nil;
		initialValue = nil;
		coreDataBound = FALSE;
		height = 44;
		editable = FALSE;
		movable = FALSE;
		selectable = TRUE;
		detailViewTitle = nil;
#ifdef __IPHONE_3_2
		detailViewModalPresentationStyle = UIModalPresentationFullScreen;
#endif
		detailTableViewStyle = UITableViewStyleGrouped;
		detailCellsImageViews = nil;
		detailViewHidesBottomBar = TRUE;
		autoResignFirstResponder = TRUE;
		cellEditingStyle = UITableViewCellEditingStyleDelete;
		valueRequired = FALSE;
		autoValidateValue = TRUE;
		delegate = nil;
		commitChangesLive = TRUE;
		needsCommit = FALSE;
		
		// Setup the badgeView
		badgeView = [[SCBadgeView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
		[self.contentView addSubview:badgeView];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		self.textLabel.text = cellText;
	}
	return self;
}

- (id)initWithText:(NSString *)cellText withBoundObject:(NSObject *)object 
  withPropertyName:(NSString *)propertyName
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		self.textLabel.text = cellText;
		boundObject = [object retain];
		
#ifdef _COREDATADEFINES_H
		if([boundObject isKindOfClass:[NSManagedObject class]])
			coreDataBound = TRUE;
#endif		
		
		// Only bind property name if property exists
		BOOL propertyExists;
		@try { [self.boundObject valueForKey:propertyName]; propertyExists = TRUE; }
		@catch (NSException *exception) { propertyExists = FALSE; }
		if(propertyExists)
			boundPropertyName = [propertyName copy];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		self.textLabel.text = cellText;
		boundKey = [key copy];
		if(keyValue)
			self.boundValue = keyValue;
	}
	return self;
}

- (void)dealloc
{
	[tempDetailModel release];
	[boundObject release];
	[boundPropertyName release];
	[boundKey release];
	[initialValue release];
	[badgeView release];
	[detailViewTitle release];
	[detailCellsImageViews release];
	
	[super dealloc];
}

//overrides superclass
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[self.badgeView setNeedsDisplay];
}

//overrides superclass
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[self.badgeView setNeedsDisplay];
}

//overrides superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if(self.badgeView.text)
	{
		// Set the badgeView frame
		CGFloat margin = 10;
		CGSize badgeTextSize = [self.badgeView.text sizeWithFont:self.badgeView.font];
		CGFloat badgeHeight = badgeTextSize.height - 2;
		CGRect badgeFrame = CGRectMake(self.contentView.frame.size.width - (badgeTextSize.width+16) - margin, 
									   round((self.contentView.frame.size.height - badgeHeight)/2), 
									   badgeTextSize.width+16, badgeHeight); // must use "round" for badge to get correctly rendered
		self.badgeView.frame = badgeFrame;
		[self.badgeView setNeedsDisplay];
		
		// Resize textLabel
		if((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeFrame.origin.x)
		{
			CGFloat badgeWidth = self.textLabel.frame.size.width - badgeFrame.size.width - margin;
			
			self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, 
											  badgeWidth, self.textLabel.frame.size.height);
		}
		
		// Resize detailTextLabel
		if((self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width) >= badgeFrame.origin.x)
		{
			CGFloat badgeWidth = self.detailTextLabel.frame.size.width - badgeFrame.size.width - margin;
			
			self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, 
													badgeWidth, self.detailTextLabel.frame.size.height);
		}
	}
}

//overrides superclass
- (void)setBackgroundColor:(UIColor *)color
{
	[super setBackgroundColor:color];
	
	if(self.selectionStyle == UITableViewCellSelectionStyleNone)
	{
		// This is much more optimized than [UIColor clearColor]
		self.textLabel.backgroundColor = color;
		self.detailTextLabel.backgroundColor = color;
	}
	else
	{
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
}

- (void)setBoundValue:(NSObject *)value
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

- (BOOL)valueIsValid
{
	if(self.autoValidateValue)
		return [self getValueIsValid];
	
	BOOL valid = TRUE;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(valueIsValidForCell:)])
	{
		valid = [delegate valueIsValidForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:valueIsValidForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [ownerTableViewModel indexPathForCell:self];
			valid = [self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
								valueIsValidForRowAtIndexPath:indexPath];
		}
	
	return valid;
}

- (BOOL)getValueIsValid
{
	// Should be overridden by subclasses
	return TRUE;
}

- (void)cellValueChanged
{
	needsCommit = TRUE;
	
	if(self.commitChangesLive)
		[self commitChanges];
	
	NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
	if(tempDetailModel) // a custom detail view is defined
	{
		NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths
														 withRowAnimation:UITableViewRowAnimationNone];
	}
	
	[self.ownerTableViewModel valueChangedForRowAtIndexPath:indexPath];
}

- (void)tempDetailModelModified
{
	[self commitDetailModelChanges:tempDetailModel];
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	// Does nothing, should be overridden by subclasses
}

- (void)willDisplay
{
	// Does nothing, should be overridden by subclasses
}

- (void)didSelectCell
{
	// Does nothing, should be overridden by subclasses
}

- (void)willDeselectCell
{
	if(tempDetailModel)
	{
		UITableView *detailTableView = tempDetailModel.modeledTableView;
		self.tempDetailModel = nil;
		detailTableView.dataSource = nil;
		detailTableView.delegate = nil;
		[detailTableView reloadData];
	}
}

- (void)commitChanges
{
	needsCommit = FALSE;
}

- (void)reloadBoundValue
{
	// Does nothing, should be overridden by subclasses
}

- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	self.imageView.image = attributes.imageView.image;
	self.detailCellsImageViews = attributes.imageViewArray;
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
	
	// also lock master cell selection (in case a custom detail view is provided)
	if(self.ownerTableViewModel.masterModel)
		self.ownerTableViewModel.masterModel.lockCellSelection = TRUE;
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
	
	// resume cell selection
	if(self.ownerTableViewModel.masterModel)
		self.ownerTableViewModel.masterModel.lockCellSelection = FALSE;
}

@end





@implementation SCControlCell

@synthesize control;
@synthesize maxTextLabelWidth;
@synthesize controlIndentation;
@synthesize controlMargin;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		pauseControlEvents = FALSE;
		control = nil;
		maxTextLabelWidth = SC_DefaultMaxTextLabelWidth;
		controlIndentation = SC_DefaultControlIndentation;
		controlMargin = SC_DefaultControlMargin;
	}
	return self;
}

- (void)dealloc
{
	[control release];
	[super dealloc];
}

//overrides superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect textLabelFrame;
	if([self.textLabel.text length])
		textLabelFrame = self.textLabel.frame;
	else
		textLabelFrame = CGRectMake(0, SC_DefaultControlMargin, 0, SC_DefaultControlHeight);
	
	// Modify the textLabel frame to take only it's text width instead of the full cell width
	CGSize constraintSize = CGSizeMake(self.maxTextLabelWidth, MAXFLOAT);
	textLabelFrame.size.width = [self.textLabel.text sizeWithFont:self.textLabel.font 
												constrainedToSize:constraintSize 
													lineBreakMode:self.textLabel.lineBreakMode].width;
	self.textLabel.frame = textLabelFrame;
	
	// Layout the control next to self.textLabel, with it's same yCoord & height
	CGFloat indentation = self.controlIndentation;
	if(textLabelFrame.size.width == 0)
		indentation = 0;
	CGSize contentViewSize = self.contentView.bounds.size;
	CGFloat controlXCoord = textLabelFrame.origin.x+textLabelFrame.size.width+self.controlMargin;
	if(controlXCoord < indentation)
		controlXCoord = indentation;
	CGRect controlFrame = CGRectMake(controlXCoord, 
									 textLabelFrame.origin.y, 
									 contentViewSize.width - controlXCoord - self.controlMargin, 
									 textLabelFrame.size.height);
	self.control.frame = controlFrame;
}

//override superclass
- (void)willDisplay
{
	[super willDisplay];
	
	if(!self.needsCommit)
		[self loadBoundValueIntoControl];
}

//override superclass
- (void)reloadBoundValue
{
	[self loadBoundValueIntoControl];
}

- (void)loadBoundValueIntoControl
{
	// Does nothing, should be overridden by subclasses
}

@end






@implementation SCLabelCell


+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withLabelTextPropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText withBoundObject:object
							  withLabelTextPropertyName:propertyName] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withLabelTextValue:(NSString *)labelTextValue
{
	return [[[[self class] alloc] initWithText:cellText
								  withBoundKey:key 
							withLabelTextValue:labelTextValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		control = [[UILabel alloc] init];
		self.label.textAlignment = UITextAlignmentRight;
		self.label.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
		self.label.highlightedTextColor = self.textLabel.highlightedTextColor;
#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		self.label.backgroundColor = [UIColor clearColor];
#else
		self.label.backgroundColor = self.backgroundColor;
#endif
		[self.contentView addSubview:self.label];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withLabelTextPropertyName:(NSString *)propertyName
{
	return [self initWithText:cellText withBoundObject:object withPropertyName:propertyName];
}
- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withLabelTextValue:(NSString *)labelTextValue
{
	return [self initWithText:cellText withBoundKey:key withValue:labelTextValue];
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setBackgroundColor:(UIColor *)color
{
	[super setBackgroundColor:color];
	
	if(self.selectionStyle == UITableViewCellSelectionStyleNone)
	{
		// This is much more optimized than [UIColor clearColor]
		self.label.backgroundColor = color;
	}
	else
	{
		self.label.backgroundColor = [UIColor clearColor];
	}
}

//overrides superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Adjust label position
	CGRect labelFrame = self.label.frame;
	labelFrame.origin.y -= 1;
	self.label.frame = labelFrame;
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if(self.boundPropertyName || self.boundKey)
	{
		NSObject *val = self.boundValue;
		if([val isKindOfClass:[NSString class]])
			self.label.text = (NSString *)self.boundValue;
		else
			if([val isKindOfClass:[NSNumber class]])
				self.label.text = [NSString stringWithFormat:@"%@", (NSNumber *)self.boundValue];
			else
				self.label.text = nil;
	}
}

- (UILabel *)label
{
	return (UILabel *)control;
}

@end






// Must subclass UITextView to modify contentOffset & contentInset. Setting these properties
// directly on the original UITextView class has unpredictable results.
@interface SCTextView : UITextView
{	float maxHeight;} @property (nonatomic, readwrite) float maxHeight;
@end
@implementation SCTextView
@synthesize maxHeight;
//Only need to override setContentOffset for SDKs prior to 4.1
#ifndef __IPHONE_4_1
-(void)setContentOffset:(CGPoint)point
{
	if(self.contentSize.height <= self.maxHeight+10)
		[super setContentOffset:CGPointMake(0, 2)];
	else
		[super setContentOffset:point];
}
#endif
-(void)setContentInset:(UIEdgeInsets)edgeInsets
{
	edgeInsets.top = 0;
	edgeInsets.bottom = 2;
	
	[super setContentInset:edgeInsets];
}
@end



@interface SCTextViewCell ()

- (void)layoutTextView;

@end



@implementation SCTextViewCell

@synthesize autoResize;
@synthesize minimumHeight;
@synthesize maximumHeight;


+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withTextViewTextPropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText withBoundObject:object
				  withTextViewTextPropertyName:propertyName] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withTextViewTextValue:(NSString *)textViewTextValue
{
	return [[[[self class] alloc] initWithText:cellText
								  withBoundKey:key 
						 withTextViewTextValue:textViewTextValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		initializing = TRUE;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		autoResize = TRUE;
		height = 87;
		minimumHeight = 87;		// 3 lines with default font
		maximumHeight = 149;
		
		control = [[SCTextView alloc] init];
		((SCTextView *)self.textView).maxHeight = maximumHeight;
		self.textView.delegate = self; 
		
		self.textView.font = [UIFont fontWithName:self.textView.font.fontName size:SC_DefaultTextViewFontSize];
		self.textView.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
		[self.contentView addSubview:self.textView];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withTextViewTextPropertyName:(NSString *)propertyName
{
	return [self initWithText:cellText withBoundObject:object withPropertyName:propertyName];
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withTextViewTextValue:(NSString *)textViewTextValue
{
	return [self initWithText:cellText withBoundKey:key withValue:textViewTextValue];
}

- (void)dealloc
{
	[super dealloc];
}

//overrides superclass
- (CGFloat)height
{
	if(self.autoResize)
	{
		if(initializing)
		{
			[self layoutSubviews];
			if((self.boundPropertyName || self.boundKey) && [self.boundValue isKindOfClass:[NSString class]])
			{
				pauseControlEvents = TRUE;
				self.textView.text = (NSString *)self.boundValue;
				pauseControlEvents = FALSE;
			}
			initializing = FALSE;
		}
		else
			[self layoutTextView];
		
		CGFloat _height;
		if([self.textView.text length] > 1)
		{
			_height = self.textView.contentSize.height;
			if(_height < self.minimumHeight)
				_height = self.minimumHeight;
			if(_height > self.maximumHeight)
				_height = self.maximumHeight;
		}
		else
			_height = self.minimumHeight;
		
		return _height;
	}
	// else
	return height;
}

//overrides superclass
- (BOOL)becomeFirstResponder
{
	return [self.textView becomeFirstResponder];
}

//overrides superclass
- (BOOL)resignFirstResponder
{
	return [self.textView resignFirstResponder];
}

//overrides superclass
- (void)setBackgroundColor:(UIColor *)color
{
	[super setBackgroundColor:color];
	
	self.textView.backgroundColor = color;
}

//overrides superclass
- (void)layoutSubviews
{	
	[super layoutSubviews];
	
	[self layoutTextView];
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && (!self.boundValue || [self.boundValue isKindOfClass:[NSString class]]) )
	{
		pauseControlEvents = TRUE;
		self.textView.text = (NSString *)self.boundValue;
		pauseControlEvents = FALSE;
	}
}

//overrides superclass
- (void)commitChanges
{
	self.boundValue = self.textView.text;
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCTextViewAttributes class]])
		return;
	
	SCTextViewAttributes *textViewAttributes = (SCTextViewAttributes *)attributes;
	if(textViewAttributes.minimumHeight > 0)
		self.minimumHeight = textViewAttributes.minimumHeight;
	if(textViewAttributes.maximumHeight > 0)
		self.maximumHeight = textViewAttributes.maximumHeight;
	self.textView.editable = textViewAttributes.editable;
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if(![self.textView.text length] && self.valueRequired)
		return FALSE;
	//else
	return TRUE;
}

- (UITextView *)textView
{
	return (UITextView *)control;
}

- (void)setMaximumHeight:(CGFloat)maxHeight
{
	maximumHeight = maxHeight;
	((SCTextView *)self.textView).maxHeight = maximumHeight;
}

- (void)layoutTextView
{	
	CGSize contentViewSize = self.contentView.bounds.size;
	CGRect textLabelFrame = self.textLabel.frame;
	CGFloat textViewXCoord = textLabelFrame.origin.x+textLabelFrame.size.width+self.controlMargin;
	CGFloat indentation = self.controlIndentation;
	if(textLabelFrame.size.width == 0)
		indentation = 13;	
	if(textViewXCoord < indentation)
		textViewXCoord = indentation;
	textViewXCoord -= 8; // to account for UITextView padding
	CGRect textViewFrame = CGRectMake(textViewXCoord,
									  2, 
									  contentViewSize.width - textViewXCoord - self.controlMargin, 
									  contentViewSize.height-3);
	self.textView.frame = textViewFrame;
}

- (void)textViewDidBeginEditing:(UITextView *)_textView
{
	self.ownerTableViewModel.activeCell = self;
}

- (void)textViewDidChange:(UITextView *)_textView
{		
	if(pauseControlEvents)
		return;
	
	[self cellValueChanged];
	
	// resize cell if needed by reloading it
	static float prevContentHeight = 0;
	if(self.autoResize && prevContentHeight!=self.textView.contentSize.height)
	{
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
		// reloadRowAtIndex is called twice to solve a resizing glitch relating to UITextView & UITableViewCell
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths 
														 withRowAnimation:UITableViewRowAnimationNone];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths 
														 withRowAnimation:UITableViewRowAnimationNone];
		[self.textView becomeFirstResponder];
		[self.ownerTableViewModel.modeledTableView scrollToRowAtIndexPath:indexPath 
														 atScrollPosition:UITableViewScrollPositionNone 
																 animated:YES];
		prevContentHeight = self.textView.contentSize.height;
	}
}

@end






@implementation SCTextFieldCell


+ (id)cellWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
   withBoundObject:(NSObject *)object withTextFieldTextPropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText withPlaceholder:placeholder
							   withBoundObject:object withTextFieldTextPropertyName:propertyName] 
			autorelease];
}

+ (id)cellWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
	  withBoundKey:(NSString *)key withTextFieldTextValue:(NSString *)textFieldTextValue
{
	return [[[[self class] alloc] initWithText:cellText withPlaceholder:placeholder
								  withBoundKey:key withTextFieldTextValue:textFieldTextValue] 
			autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		control = [[UITextField alloc] init];
		self.textField.delegate = self;
		[self.textField addTarget:self action:@selector(textFieldEditingChanged) 
										forControlEvents:UIControlEventEditingChanged];
		self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.textField.textColor = [UIColor colorWithRed:50.0f/255 green:79.0f/255 blue:133.0f/255 alpha:1];
		self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		[self.contentView addSubview:self.textField];
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
   withBoundObject:(NSObject *)object withTextFieldTextPropertyName:(NSString *)propertyName
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		self.textField.placeholder = placeholder;
	}
	return self;
}

- (id)initWithText:(NSString *)cellText withPlaceholder:(NSString *)placeholder
	  withBoundKey:(NSString *)key withTextFieldTextValue:(NSString *)textFieldTextValue
{
	if([self initWithText:cellText withBoundKey:key withValue:textFieldTextValue])
	{
		self.textField.placeholder = placeholder;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

//overrides superclass
- (BOOL)becomeFirstResponder
{
	return [self.textField becomeFirstResponder];
}

//overrides superclass
- (BOOL)resignFirstResponder
{
	return [self.textField resignFirstResponder];
}

//overrides superclass
- (void)setBackgroundColor:(UIColor *)color
{
	[super setBackgroundColor:color];
	
	self.textField.backgroundColor = color;
}

//override's superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Adjust height & yCoord
	CGRect textFieldFrame = self.textField.frame;
	textFieldFrame.origin.y = (self.contentView.frame.size.height - SC_DefaultTextFieldHeight)/2;
	textFieldFrame.size.height = SC_DefaultTextFieldHeight;
	self.textField.frame = textFieldFrame;
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && (!self.boundValue || [self.boundValue isKindOfClass:[NSString class]]) )
	{
		pauseControlEvents = TRUE;
		self.textField.text = (NSString *)self.boundValue;
		pauseControlEvents = FALSE;
	}
}

//overrides superclass
- (void)commitChanges
{
	self.boundValue = self.textField.text;
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCTextFieldAttributes class]])
		return;
	
	SCTextFieldAttributes *textFieldAttributes = (SCTextFieldAttributes *)attributes;
	if(textFieldAttributes.placeholder)
		self.textField.placeholder = textFieldAttributes.placeholder;
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if(![self.textField.text length] && self.valueRequired)
		return FALSE;
	//else
	return TRUE;
}

- (UITextField *)textField
{
	return (UITextField *)control;
}

- (void)textFieldEditingChanged
{
	if(pauseControlEvents)
		return;
	
	[self cellValueChanged];
}


- (void)textFieldDidBeginEditing:(UITextField *)_textField
{
	self.ownerTableViewModel.activeCell = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(returnButtonTappedForCell:)])
	{
		[delegate returnButtonTappedForCell:self];
		return TRUE;
	}
	
	if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.ownerTableViewModel.delegate 
		   respondsToSelector:@selector(tableViewModel:returnButtonTappedForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel 
										   returnButtonTappedForRowAtIndexPath:indexPath];
			return TRUE;
		}
	
	BOOL handeledReturn;
	switch (self.textField.returnKeyType)
	{
		case UIReturnKeyDefault:
		case UIReturnKeyNext:
		{
			// get next cell
			SCTableViewCell *currentCell = self;
			SCTableViewCell *nextCell;
			while( (nextCell = [self.ownerTableViewModel cellAfterCell:currentCell rewindIfLastCell:YES]) ) 
			{
				if([nextCell isKindOfClass:[SCTextFieldCell class]])
				{
					if([(SCTextFieldCell *)nextCell textField].enabled)
						break;
					//else
					//loop to the next cell
					currentCell = nextCell;
				}
				else
					if([nextCell isKindOfClass:[SCTextViewCell class]])
					{
						if([(SCTextViewCell *)nextCell textView].editable)
							break;
						//else
						//loop to the next cell
						currentCell = nextCell;
					}
					else
					{
						nextCell = nil;
						break;
					}
			}
			
			if(nextCell)
			{
				NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:nextCell];
				[self.ownerTableViewModel.modeledTableView
				 scrollToRowAtIndexPath:indexPath 
				 atScrollPosition:UITableViewScrollPositionNone
				 animated:YES];
				[nextCell becomeFirstResponder];
			}
			else
				[self resignFirstResponder];
		}
			handeledReturn = TRUE;
			break;
			
		case UIReturnKeyDone: 
			[self.textField resignFirstResponder];
			handeledReturn = TRUE;
			break;
			
		default:
			handeledReturn = FALSE;
			break;
	}
	
	return handeledReturn;
}

@end





@implementation SCNumericTextFieldCell

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize allowFloatValue;
@synthesize displayZeroAsBlank;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		
		minimumValue = nil;
		maximumValue = nil;
		allowFloatValue = TRUE;
		displayZeroAsBlank = FALSE;
	}
	
	return self;
}

- (void)dealloc
{
	[minimumValue release];
	[maximumValue release];
	[super dealloc];
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && (!self.boundValue || [self.boundValue isKindOfClass:[NSNumber class]]))
	{
		pauseControlEvents = TRUE;
		
		NSNumber *numericValue = (NSNumber *)self.boundValue;
		if(numericValue)
		{
			if([numericValue intValue]==0 && self.displayZeroAsBlank)
				self.textField.text = nil;
			else
				self.textField.text = [NSString stringWithFormat:@"%@", numericValue];
		}
		else
		{
			self.textField.text = nil;
		}
		
		pauseControlEvents = FALSE;
	}
}

//overrides superclass
- (void)commitChanges
{
	if([self.textField.text length])
		self.boundValue = [NSNumber numberWithDouble:[self.textField.text doubleValue]];
	else
		self.boundValue = nil;
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCNumericTextFieldAttributes class]])
		return;
	
	SCNumericTextFieldAttributes *numericTextFieldAttributes = 
											(SCNumericTextFieldAttributes *)attributes;
	if(numericTextFieldAttributes.minimumValue)
		self.minimumValue = numericTextFieldAttributes.minimumValue;
	if(numericTextFieldAttributes.maximumValue)
		self.maximumValue = numericTextFieldAttributes.maximumValue;
	self.allowFloatValue = numericTextFieldAttributes.allowFloatValue;
}

//overrides superclass
- (BOOL)getValueIsValid
{	
	if(![self.textField.text length])
	{
		if(self.valueRequired)
			return FALSE;
		//else
		return TRUE;
	}
		
	NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
	[numFormatter setMinimum:self.minimumValue];
	[numFormatter setMaximum:self.maximumValue];
	[numFormatter setAllowsFloats:self.allowFloatValue];
	BOOL valid;
	if([numFormatter numberFromString:self.textField.text])
		valid = TRUE;
	else
		valid = FALSE;
	[numFormatter release];
	
	return valid;
}


@end







@implementation SCSliderCell


+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSliderValuePropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText withBoundObject:object
					 withSliderValuePropertyName:propertyName] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSliderValue:(NSNumber *)sliderValue
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key
							   withSliderValue:sliderValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		control = [[UISlider alloc] init];
		[self.slider addTarget:self action:@selector(sliderValueChanged) 
								forControlEvents:UIControlEventValueChanged];
		self.slider.continuous = FALSE;
		[self.contentView addSubview:self.slider];
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSliderValuePropertyName:(NSString *)propertyName
{
	return [self initWithText:cellText withBoundObject:object withPropertyName:propertyName];
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSliderValue:(NSNumber *)sliderValue
{
	return [self initWithText:cellText withBoundKey:key withValue:sliderValue];
}

- (void)dealloc
{
	[super dealloc];
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withPropertyName:(NSString *)propertyName
{
	[super initWithText:cellText withBoundObject:object withPropertyName:propertyName];
	
	if(self.boundObject && !self.boundValue && self.commitChangesLive)
		self.boundValue = [NSNumber numberWithFloat:self.slider.value];
	
	return self;
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue
{
	[super initWithText:cellText withBoundKey:key withValue:keyValue];
	
	if(self.boundKey && !self.boundValue && self.commitChangesLive)
		self.boundValue = [NSNumber numberWithFloat:self.slider.value];
	
	return self;
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && [self.boundValue isKindOfClass:[NSNumber class]])
	{
		pauseControlEvents = TRUE;
		self.slider.value = [(NSNumber *)self.boundValue floatValue];
		pauseControlEvents = FALSE;
	}
}

//overrides superclass
- (void)commitChanges
{
	self.boundValue = [NSNumber numberWithFloat:self.slider.value];
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCSliderAttributes class]])
		return;
	
	SCSliderAttributes *sliderAttributes = (SCSliderAttributes *)attributes;
	if(sliderAttributes.minimumValue >= 0)
		self.slider.minimumValue = sliderAttributes.minimumValue;
	if(sliderAttributes.maximumValue >= 0)
		self.slider.maximumValue = sliderAttributes.maximumValue;
}

- (UISlider *)slider
{
	return (UISlider *)control;
}

- (void)sliderValueChanged
{	
	if(pauseControlEvents)
		return;
	
	if(self.ownerTableViewModel.activeCell != self)
		self.ownerTableViewModel.activeCell = self;
	
	[self cellValueChanged];
}

@end






@implementation SCSegmentedCell


+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedSegmentIndexPropertyName:(NSString *)propertyName
	withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray
{
	return [[[[self class] alloc] initWithText:cellText  
							   withBoundObject:object 
		  withSelectedSegmentIndexPropertyName:propertyName
						withSegmentTitlesArray:cellSegmentTitlesArray] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedSegmentIndexValue:(NSNumber *)selectedSegmentIndexValue
		withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray
{
	return [[[[self class] alloc] initWithText:cellText  
									   withBoundKey:key 
				 withSelectedSegmentIndexValue:selectedSegmentIndexValue
						withSegmentTitlesArray:cellSegmentTitlesArray] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		control = [[UISegmentedControl alloc] init];
		[self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) 
											forControlEvents:UIControlEventValueChanged];
		self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		[self.contentView addSubview:self.segmentedControl];
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedSegmentIndexPropertyName:(NSString *)propertyName
	withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		[self createSegmentsUsingArray:cellSegmentTitlesArray];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedSegmentIndexValue:(NSNumber *)selectedSegmentIndexValue
		withSegmentTitlesArray:(NSArray *)cellSegmentTitlesArray
{
	if([self initWithText:cellText withBoundKey:key withValue:selectedSegmentIndexValue])
	{
		if(cellSegmentTitlesArray)
		{
			for(int i=0; i<cellSegmentTitlesArray.count; i++)
			{
				NSString *segmentTitle = (NSString *)[cellSegmentTitlesArray objectAtIndex:i];
				[self.segmentedControl insertSegmentWithTitle:segmentTitle atIndex:i 
													 animated:FALSE];
			}
		}
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withPropertyName:(NSString *)propertyName
{
	[super initWithText:cellText withBoundObject:object withPropertyName:propertyName];
	
	if(self.boundObject && !self.boundValue)
		self.boundValue = [NSNumber numberWithInt:-1];
	
	return self;
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
   withBoundKey:(NSString *)cellKey withValue:(NSObject *)cellKeyValue
{
	[super initWithText:cellText withBoundKey:cellKey withValue:cellKeyValue];
	
	if(self.boundKey && !self.boundValue)
		self.boundValue = [NSNumber numberWithInt:-1];
	
	return self;
}

//override's superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Adjust height & yCoord
	CGRect segmentedFrame = self.segmentedControl.frame;
	segmentedFrame.origin.y = (self.contentView.frame.size.height - SC_DefaultSegmentedControlHeight)/2;
	segmentedFrame.size.height = SC_DefaultSegmentedControlHeight;
	self.segmentedControl.frame = segmentedFrame;
}

//override's superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && [self.boundValue isKindOfClass:[NSNumber class]])
	{
		pauseControlEvents = TRUE;
		self.segmentedControl.selectedSegmentIndex = [(NSNumber *)self.boundValue intValue];
		pauseControlEvents = FALSE;
	}
}

//override's superclass
- (void)commitChanges
{
	self.boundValue = [NSNumber numberWithInt:self.segmentedControl.selectedSegmentIndex];
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCSegmentedAttributes class]])
		return;
	
	SCSegmentedAttributes *segmentedAttributes = (SCSegmentedAttributes *)attributes;
	if(segmentedAttributes.segmentTitlesArray)
		[self createSegmentsUsingArray:segmentedAttributes.segmentTitlesArray];
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if( (self.segmentedControl.selectedSegmentIndex==-1) && self.valueRequired )
		return FALSE;
	//else
	return TRUE;
}

- (UISegmentedControl *)segmentedControl
{
	return (UISegmentedControl *)control;
}

- (void)createSegmentsUsingArray:(NSArray *)segmentTitlesArray
{
	[self.segmentedControl removeAllSegments];
	if(segmentTitlesArray)
	{
		for(int i=0; i<segmentTitlesArray.count; i++)
		{
			NSString *segmentTitle = (NSString *)[segmentTitlesArray objectAtIndex:i];
			[self.segmentedControl insertSegmentWithTitle:segmentTitle atIndex:i 
												 animated:FALSE];
		}
	}
}

- (void)segmentedControlValueChanged
{
	if(pauseControlEvents)
		return;
	
	if(self.ownerTableViewModel.activeCell != self)
		self.ownerTableViewModel.activeCell = self;
	
	[self cellValueChanged];
}

@end






@implementation SCSwitchCell


+ (id)cellWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSwitchOnPropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText withBoundObject:object
					  withSwitchOnPropertyName:propertyName] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSwitchOnValue:(NSNumber *)switchOnValue
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key
							 withSwitchOnValue:switchOnValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		control = [[UISwitch alloc] init];
		[self.switchControl addTarget:self action:@selector(switchControlChanged) 
										forControlEvents:UIControlEventValueChanged];
		[self.contentView addSubview:self.switchControl];
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withSwitchOnPropertyName:(NSString *)propertyName
{
	return [self initWithText:cellText withBoundObject:object withPropertyName:propertyName];
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSwitchOnValue:(NSNumber *)switchOnValue
{
	return [self initWithText:cellText withBoundKey:key withValue:switchOnValue];
}

- (void)dealloc
{
	[super dealloc];
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
   withBoundObject:(NSObject *)object withPropertyName:(NSString *)propertyName
{
	[super initWithText:cellText withBoundObject:object withPropertyName:propertyName];
	
	if(self.boundObject && !self.boundValue && self.commitChangesLive)
		self.boundValue = [NSNumber numberWithBool:self.switchControl.on];
	
	return self;
}

//overrides superclass
- (id)initWithText:(NSString *)cellText 
	  withBoundKey:(NSString *)key withValue:(NSObject *)keyValue
{
	[super initWithText:cellText withBoundKey:key withValue:keyValue];
	
	if(self.boundKey && !self.boundValue && self.commitChangesLive)
		self.boundValue = [NSNumber numberWithFloat:self.switchControl.on];
	
	return self;
}

//overrides superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize contentViewSize = self.contentView.bounds.size;
	CGRect switchFrame = self.switchControl.frame;
	switchFrame.origin.x = contentViewSize.width - switchFrame.size.width - 10;
	switchFrame.origin.y = (contentViewSize.height-switchFrame.size.height)/2;
	self.switchControl.frame = switchFrame;
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	if( (self.boundPropertyName || self.boundKey) && [self.boundValue isKindOfClass:[NSNumber class]])
	{
		pauseControlEvents = TRUE;
		self.switchControl.on = [(NSNumber *)self.boundValue boolValue];
		pauseControlEvents = FALSE;
	}
}

//overrides superclass
- (void)commitChanges
{
	self.boundValue = [NSNumber numberWithBool:self.switchControl.on];
	needsCommit = FALSE;
}

- (UISwitch *)switchControl
{
	return (UISwitch *)control;
}

- (void)switchControlChanged
{
	if(pauseControlEvents)
		return;
	
	if(self.ownerTableViewModel.activeCell != self)
		self.ownerTableViewModel.activeCell = self;
	
	[self cellValueChanged];
}

@end







@interface SCDateCell ()

- (UIViewController *)getCustomDetailViewForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)commitDetailViewChanges;

@end



@implementation SCDateCell

@synthesize datePicker;
@synthesize dateFormatter;
@synthesize displaySelectedDate;
@synthesize allowDetailView;
@synthesize detailViewModal;


+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withDatePropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withDatePropertyName:propertyName] 
			autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withDateValue:(NSDate *)dateValue
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key withDateValue:dateValue] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		datePicker = [[UIDatePicker alloc] init];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM d  hh:mm a"];
		displaySelectedDate = TRUE;
		allowDetailView = TRUE;
		detailViewModal = FALSE;
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withDatePropertyName:(NSString *)propertyName
{
	return [self initWithText:cellText withBoundObject:object withPropertyName:propertyName];
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withDateValue:(NSDate *)dateValue
{
	return [self initWithText:cellText withBoundKey:key withValue:dateValue];
}

- (void)dealloc
{
	[datePicker release];
	[dateFormatter release];
	[super dealloc];
}

//overrides superclass
- (void)loadBoundValueIntoControl
{
	// Set the picker's frame before setting its value (required for iPad compatability)
	CGRect pickerFrame = CGRectZero;
#ifdef __IPHONE_3_2
	if([SCHelper is_iPad])
		pickerFrame.size.width = self.ownerTableViewModel.viewController.contentSizeForViewInPopover.width;
	else
#endif			
		pickerFrame.size.width = self.ownerTableViewModel.viewController.view.frame.size.width;
	pickerFrame.size.height = 216;
	self.datePicker.frame = pickerFrame;
	
	NSDate *date = nil;
	if( (self.boundPropertyName || self.boundKey) && [self.boundValue isKindOfClass:[NSDate class]])
	{
		date = (NSDate *)self.boundValue;
		self.datePicker.date = date;
	}
	
	self.label.text = [dateFormatter stringFromDate:date];
	self.label.hidden = !self.displaySelectedDate;
}

//override superclass
- (void)cellValueChanged
{	
	self.label.text = [dateFormatter stringFromDate:self.datePicker.date];
	
	[super cellValueChanged];
}

//overrides superclass
- (void)commitDetailViewChanges
{
	[self cellValueChanged];
}

//overrides superclass
- (void)commitChanges
{
	if(self.label.text)	// if a date value have been selected
		self.boundValue = self.datePicker.date;
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCDateAttributes class]])
		return;
	
	SCDateAttributes *dateAttributes = (SCDateAttributes *)attributes;
	if(dateAttributes.dateFormatter)
		self.dateFormatter = dateAttributes.dateFormatter;
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if(!self.label.text && self.valueRequired)
		return FALSE;
	//else
	return TRUE;
}

- (UIViewController *)getCustomDetailViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController *detailViewController = nil;
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailViewForRowAtIndexPath:)])
	{
		detailViewController = [self.ownerTableViewModel.dataSource 
								tableViewModel:self.ownerTableViewModel
								customDetailViewForRowAtIndexPath:indexPath];
	}
	return detailViewController;
}

//override parent's
- (void)didSelectCell
{
	self.ownerTableViewModel.activeCell = self;
	
	if(!self.allowDetailView)
		return;
	
	// Check for custom detail view controller
	NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
	UIViewController *customDetailView = [self getCustomDetailViewForRowAtIndexPath:indexPath];
	if(customDetailView)
	{
		[customDetailView.view addSubview:self.datePicker];
		
		// Center the picker in the detailViewController
		CGRect pickerFrame = self.datePicker.frame;
		pickerFrame.origin.x = (customDetailView.view.frame.size.width - pickerFrame.size.width)/2;
		self.datePicker.frame = pickerFrame;
		[self.datePicker addTarget:self action:@selector(commitDetailViewChanges) 
				  forControlEvents:UIControlEventValueChanged];
		
		return;
	}
	
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	
	SCNavigationBarType navBarType;
	if(navController && !self.detailViewModal)
		navBarType = SCNavigationBarTypeNone;
	else
		navBarType = SCNavigationBarTypeDoneRightCancelLeft;
	SCViewController *detailViewController = [[SCViewController alloc] init];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.navigationBarType = navBarType;
	detailViewController.delegate = self;
	if(self.detailViewTitle)
		detailViewController.title = self.detailViewTitle;
	else
		detailViewController.title = self.textLabel.text;
	if([SCHelper is_iPad])
		detailViewController.view.backgroundColor = [UIColor colorWithRed:32.0f/255 green:35.0f/255 blue:42.0f/255 alpha:1];
	else
		detailViewController.view.backgroundColor = [UIColor colorWithRed:41.0f/255 green:42.0f/255 blue:57.0f/255 alpha:1];
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	[detailViewController.view addSubview:self.datePicker];
	
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

- (void)willDeselectCell
{
	// Check if a custom detail view controller exists
	NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
	UIViewController *detailViewController = [self getCustomDetailViewForRowAtIndexPath:indexPath];
	if(detailViewController)
	{
		// Remove datePicker
		[self.datePicker removeFromSuperview];
	}
}

#pragma mark -
#pragma mark SCViewControllerDelegate methods

- (void)viewControllerWillAppear:(SCViewController *)viewController
{
	// Center the picker in the detailViewController
	CGRect pickerFrame = self.datePicker.frame;
	pickerFrame.origin.x = (viewController.view.frame.size.width - pickerFrame.size.width)/2;
	self.datePicker.frame = pickerFrame;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[self.delegate detailViewWillAppearForCell:self withDetailTableViewModel:nil];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						detailViewWillAppearForRowAtIndexPath:indexPath
									 withDetailTableViewModel:nil];
		}
}

- (void)viewControllerWillDisappear:(SCViewController *)viewController
					  cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	if(cancelTapped)
		return;
	
	[self commitDetailViewChanges];
	
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillDisappearForCell:)])
	{
		[self.delegate detailViewWillDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailViewWillDisappearForRowAtIndexPath:indexPath];
		}
}

- (void)viewControllerDidDisappear:(SCViewController *)viewController 
				cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewDidDisappearForCell:)])
	{
		[self.delegate detailViewDidDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailViewDidDisappearForRowAtIndexPath:indexPath];
		}
}


@end






@interface SCImagePickerCell ()

- (NSString *)selectedImagePath;
- (void)setCachedImage;
- (void)displayImagePicker;
- (void)displayImageInDetailView;
- (void)addImageViewToDetailView:(UIViewController *)detailView;
- (void)didTapClearImageButton;

@end



@implementation SCImagePickerCell

@synthesize imagePickerController;
@synthesize placeholderImageName;
@synthesize displayImageNameAsCellText;
@synthesize askForSourceType;
@synthesize selectedImageName;
@synthesize clearImageButton;
@synthesize displayClearImageButtonInDetailView;
@synthesize autoPositionClearImageButton;
@synthesize textLabelFrame;
@synthesize imageViewFrame;

+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withImageNamePropertyName:(NSString *)propertyName
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withImageNamePropertyName:propertyName] 
			autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withImageNameValue:(NSString *)imageNameValue
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key withImageNameValue:imageNameValue] 
			autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		cachedImage = nil;
		detailImageView = nil;
		
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		
		placeholderImageName = nil;
		displayImageNameAsCellText = TRUE;
		askForSourceType = TRUE;
		selectedImageName = nil;
		autoPositionImageView = TRUE;
		
		clearImageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		clearImageButton.frame = CGRectMake(0, 0, 120, 25);
		[clearImageButton setTitle:@"Clear Image" forState:UIControlStateNormal];
		[clearImageButton addTarget:self action:@selector(didTapClearImageButton) 
				   forControlEvents:UIControlEventTouchUpInside];
		clearImageButton.backgroundColor = [UIColor grayColor];
		clearImageButton.layer.cornerRadius = 8.0f;
		clearImageButton.layer.masksToBounds = YES;
		clearImageButton.layer.borderWidth = 1.0f;
		displayClearImageButtonInDetailView = TRUE;
		autoPositionClearImageButton = TRUE;
		
		textLabelFrame = CGRectMake(0, 0, 0, 0);
		imageViewFrame = CGRectMake(0, 0, 0, 0);
		
		// Add rounded corners to the image view
		self.imageView.layer.masksToBounds = YES;
		self.imageView.layer.cornerRadius = 8.0f;
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withImageNamePropertyName:(NSString *)propertyName
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		self.selectedImageName = (NSString *)self.boundValue;
		[self setCachedImage];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withImageNameValue:(NSString *)imageNameValue
{
	if([self initWithText:cellText withBoundKey:key withValue:imageNameValue])
	{
		self.selectedImageName = (NSString *)self.boundValue;
		[self setCachedImage];
	}
	return self;
}

- (void)dealloc
{
	[cachedImage release];
	[detailImageView release];
	[imagePickerController release];
	[placeholderImageName release];
	[selectedImageName release];
	[clearImageButton release];
	
	[super dealloc];
}

- (void)resetClearImageButtonStyles
{
	clearImageButton.backgroundColor = [UIColor clearColor];
	clearImageButton.layer.cornerRadius = 0.0f;
	clearImageButton.layer.masksToBounds = NO;
	clearImageButton.layer.borderWidth = 0.0f;
}

- (UIImage *)selectedImage
{
	if(self.selectedImageName && !cachedImage)
		[self setCachedImage];
	
	return cachedImage;
}

- (void)setCachedImage
{
	[cachedImage release];
	cachedImage = nil;
	
	UIImage *image = [UIImage imageWithContentsOfFile:[self selectedImagePath]];
	if(image)
	{
		cachedImage = [image retain];
	}
}

- (NSString *)selectedImagePath
{
	if(!self.selectedImageName)
		return nil;
	
	NSString *fullName = [NSString stringWithFormat:@"Documents/%@", self.selectedImageName];
	
	return [NSHomeDirectory() stringByAppendingPathComponent:fullName];
}

//overrides superclass
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if(self.selectedImageName)
	{
		if(self.displayImageNameAsCellText)
			self.textLabel.text = self.selectedImageName;
		
		if(!cachedImage)
			[self setCachedImage];
		
		self.imageView.image = cachedImage;
		
		if(cachedImage)
		{
			// Set the correct frame for imageView
			CGRect imgframe = self.imageView.frame;
			imgframe.origin.x = 2;
			imgframe.origin.y = 3;
			imgframe.size.height -= 4;
			self.imageView.frame = imgframe;
		}
	}
	else
	{
		if(self.displayImageNameAsCellText)
			self.textLabel.text = @"";
		
		if(self.placeholderImageName)
			self.imageView.image = [UIImage imageNamed:self.placeholderImageName];
	}
	
	if(self.textLabelFrame.size.height)
	{
		self.textLabel.frame = self.textLabelFrame;
	}
	if(self.imageViewFrame.size.height)
	{
		self.imageView.frame = self.imageViewFrame;
	}
}

//overrides superclass
- (void)commitChanges
{
	self.boundValue = self.selectedImageName;
	
	needsCommit = FALSE;
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if(!self.selectedImageName && self.valueRequired)
		return FALSE;
	//else
	return TRUE;
}

//override parent's
- (void)didSelectCell
{
	self.ownerTableViewModel.activeCell = self;

	if(!self.ownerTableViewModel.modeledTableView.editing && self.selectedImageName)
	{
		[self displayImageInDetailView];
		return;
	}
	
	BOOL actionSheetDisplayed = FALSE;
	
	if(self.askForSourceType)
	{
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		{
			UIActionSheet *actionSheet = [[UIActionSheet alloc]
										 initWithTitle:nil
										 delegate:self
										 cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:nil
										 otherButtonTitles:@"Take Photo",@"Choose Photo",nil];
			[actionSheet showInView:self.ownerTableViewModel.viewController.view];
			[actionSheet release];
			
			actionSheetDisplayed = TRUE;
		}
		else
		{
			self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		}
	}
	
	if(!actionSheetDisplayed)
		[self displayImagePicker];
}	

- (void)displayImageInDetailView
{
	// Check for custom detail view controller
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailViewForRowAtIndexPath:)])
	{
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		UIViewController *detailViewController = [self.ownerTableViewModel.dataSource 
												  tableViewModel:self.ownerTableViewModel
												  customDetailViewForRowAtIndexPath:indexPath];
		if(detailViewController)
		{
			[self addImageViewToDetailView:detailViewController];
			
			return;
		}
	}
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	
	SCNavigationBarType navBarType;
	if(navController)
		navBarType = SCNavigationBarTypeNone;
	else
		navBarType = SCNavigationBarTypeDoneRight;
	SCViewController *detailViewController = [[SCViewController alloc] init];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.navigationBarType = navBarType;
	detailViewController.delegate = self;
	if(self.detailViewTitle)
		detailViewController.title = self.detailViewTitle;
	else
		detailViewController.title = self.textLabel.text;
	if([SCHelper is_iPad])
		detailViewController.view.backgroundColor = [UIColor colorWithRed:32.0f/255 green:35.0f/255 blue:42.0f/255 alpha:1];
	else
		detailViewController.view.backgroundColor = [UIColor colorWithRed:41.0f/255 green:42.0f/255 blue:57.0f/255 alpha:1];
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif	
	
	[self.ownerTableViewModel pauseAutoResizeForKeyboard];
	[self disableOwnerViewControllerDelegate];
	if(navController)
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

- (void)addImageViewToDetailView:(UIViewController *)detailView
{
	// Add an image view with the correct image size to the detail view
	CGSize detailViewSize = detailView.view.frame.size;
	[detailImageView release];
	detailImageView = [[UIImageView alloc] initWithImage:cachedImage];
	detailImageView.frame = CGRectMake(0, 0, detailViewSize.width, detailViewSize.height);
	detailImageView.contentMode = UIViewContentModeScaleAspectFit;
	[detailView.view addSubview:detailImageView];
	
	//Add clearImageButton
	if(self.displayClearImageButtonInDetailView)
	{
		if(self.autoPositionClearImageButton)
		{
			CGRect btnFrame = self.clearImageButton.frame;
			self.clearImageButton.frame = CGRectMake(detailViewSize.width - btnFrame.size.width - 10,
													 detailViewSize.height - btnFrame.size.height - 10,
													 btnFrame.size.width, btnFrame.size.height);
		}
		[detailView.view addSubview:self.clearImageButton];
	}
}

- (void)didTapClearImageButton
{
	self.selectedImageName = nil;
	[cachedImage release];
	cachedImage = nil;
	
	detailImageView.image = nil;
}

- (void)displayImagePicker
{	
#ifdef __IPHONE_3_2
	if([SCHelper is_iPad])
	{
		UIPopoverController *popover = [[UIPopoverController alloc] 
										initWithContentViewController:self.imagePickerController];
		[popover presentPopoverFromRect:self.frame inView:self.ownerTableViewModel.viewController.view
			   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
#endif
		[self.ownerTableViewModel pauseAutoResizeForKeyboard];
		[self disableOwnerViewControllerDelegate];
		[self.ownerTableViewModel.viewController presentModalViewController:self.imagePickerController
																   animated:TRUE];
#ifdef __IPHONE_3_2
	}
#endif
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet
	clickedButtonAtIndex:(NSInteger)buttonIndex
{
	BOOL cancelTapped = FALSE;
	switch (buttonIndex)
	{
		case 0:  // Take Photo
			self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
		case 1:  // Choose Photo
			self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;	
		default:
			cancelTapped = TRUE;
			break;
	}
	
	if(!cancelTapped)
		[self displayImagePicker];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePickerController dismissModalViewControllerAnimated:TRUE];
	
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
	didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self.imagePickerController dismissModalViewControllerAnimated:TRUE];
	
#ifdef __IPHONE_3_2
	if([SCHelper is_iPad])
	{
		//no need to resume anything as the picker was displayed in a popover
	}
	else
	{
#endif
		[self.ownerTableViewModel resumeAutoResizeForKeyboard];
		[self enableOwnerViewControllerDelegate];
#ifdef __IPHONE_3_2
	}
#endif
	
	[cachedImage release];
	cachedImage = nil;

	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	if(image)
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
		   && [self.delegate respondsToSelector:@selector(newImageNameForCell:)])
		{
			self.selectedImageName = [self.delegate newImageNameForCell:self];
		}
		else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
			&& [self.ownerTableViewModel.delegate respondsToSelector:@selector(tableViewModel:newImageNameForRowAtIndexPath:)])
		{
			self.selectedImageName = 
				[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						newImageNameForRowAtIndexPath:[self.ownerTableViewModel indexPathForCell:self]];
		}
		else
			self.selectedImageName = [NSString stringWithFormat:@"%@", [NSDate date]];
			
		[UIImageJPEGRepresentation(image, 80) writeToFile:[self selectedImagePath] atomically:YES];
		
		[self layoutSubviews];
		
		
		// reload cell
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
		[self.ownerTableViewModel.modeledTableView reloadRowsAtIndexPaths:indexPaths 
														 withRowAnimation:UITableViewRowAnimationNone];
		
		[self cellValueChanged];
	}
}

#pragma mark -
#pragma mark SCViewControllerDelegate methods

- (void)viewControllerWillAppear:(SCViewController *)viewController
{
	[self addImageViewToDetailView:viewController];
	
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[self.delegate detailViewWillAppearForCell:self withDetailTableViewModel:nil];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						detailViewWillAppearForRowAtIndexPath:indexPath
									 withDetailTableViewModel:nil];
		}
}

- (void)viewControllerWillDisappear:(SCViewController *)viewController 
				 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
}

@end







@interface SCSelectionCell ()

- (void)buildSelectedItemsIndexesFromBoundValue;
- (void)buildSelectedItemsIndexesFromString:(NSString *)string;
- (NSString *)buildStringFromSelectedItemsIndexes;

- (SCSelectionSection *)createSelectionSection;
- (void)addSelectionSectionToModel:(SCTableViewModel *)model;
- (NSString *)getTitleForItemAtIndex:(NSUInteger)index;

@end

@implementation SCSelectionCell

@synthesize items;
@synthesize allowMultipleSelection;
@synthesize allowNoSelection;
@synthesize autoDismissDetailView;
@synthesize hideDetailViewNavigationBar;
@synthesize displaySelection;
@synthesize delimeter;
@synthesize selectedItemsIndexes;


+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withSelectedIndexPropertyName:propertyName 
									 withItems:cellItems] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection;
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withSelectedIndexesPropertyName:propertyName 
									 withItems:cellItems 
						 allowMultipleSelection:multipleSelection] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectionStringPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withSelectionStringPropertyName:propertyName 
									 withItems:cellItems] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexValue:(NSNumber *)selectedIndexValue
		 withItems:(NSArray *)cellItems
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key withSelectedIndexValue:selectedIndexValue 
									 withItems:cellItems ] autorelease];
}

+ (id)cellWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection
{
	return [[[[self class] alloc] initWithText:cellText 
								  withBoundKey:key withSelectedIndexesValue:selectedIndexesValue 
									 withItems:cellItems 
						 allowMultipleSelection:multipleSelection] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		boundToNSNumber = FALSE;
		boundToNSString = FALSE;
		items = nil;
		allowMultipleSelection = FALSE;
		allowNoSelection = FALSE;
		autoDismissDetailView = FALSE;
		hideDetailViewNavigationBar = FALSE;
		displaySelection = TRUE;
		delimeter = @", ";
		selectedItemsIndexes = [[NSMutableSet alloc] init];
		
		self.detailTableViewStyle = UITableViewStylePlain;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems
{	
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		boundToNSNumber = TRUE;
		self.items = cellItems;
		self.allowMultipleSelection = FALSE;
		
		[self buildSelectedItemsIndexesFromBoundValue];
		
		if(self.boundObject && !self.boundValue && self.commitChangesLive)
			self.boundValue = [NSNumber numberWithInt:-1];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectedIndexesPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		self.items = cellItems;
		self.allowMultipleSelection = multipleSelection;
		
		[self buildSelectedItemsIndexesFromBoundValue];
		
		if(self.boundObject && !self.boundValue && self.commitChangesLive)
			self.boundValue = [NSMutableSet set];   //Empty set
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
   withBoundObject:(NSObject *)object withSelectionStringPropertyName:(NSString *)propertyName 
		 withItems:(NSArray *)cellItems
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		boundToNSString = TRUE;
		self.items = cellItems;
		self.allowMultipleSelection = FALSE;
		
		[self buildSelectedItemsIndexesFromBoundValue];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexValue:(NSNumber *)selectedIndexValue
		 withItems:(NSArray *)cellItems
{	
	if([self initWithText:cellText withBoundKey:key withValue:selectedIndexValue])
	{
		boundToNSNumber = TRUE;
		self.items = cellItems;
		self.allowMultipleSelection = FALSE;
		
		[self buildSelectedItemsIndexesFromBoundValue];
		
		if(self.boundKey && !self.boundValue && self.commitChangesLive)
			self.boundValue = [NSNumber numberWithInt:-1];
	}
	return self;
}

- (id)initWithText:(NSString *)cellText
	  withBoundKey:(NSString *)key withSelectedIndexesValue:(NSMutableSet *)selectedIndexesValue
		 withItems:(NSArray *)cellItems allowMultipleSelection:(BOOL)multipleSelection
{
	if([self initWithText:cellText withBoundKey:key withValue:selectedIndexesValue])
	{
		self.items = cellItems;
		self.allowMultipleSelection = multipleSelection;
		
		[self buildSelectedItemsIndexesFromBoundValue];
		
		if(self.boundKey && !self.boundValue && self.commitChangesLive)
			self.boundValue = [NSMutableSet set];   //Empty set
	}
	return self;
}

- (void)dealloc
{
	[items release];
	[delimeter release];
	[selectedItemsIndexes release];
	[super dealloc];
}

- (void)buildSelectedItemsIndexesFromBoundValue
{
	[self.selectedItemsIndexes removeAllObjects];
	
	if([self.boundValue isKindOfClass:[NSNumber class]])
	{
		[self.selectedItemsIndexes addObject:self.boundValue];
	}
	else
		if([self.boundValue isKindOfClass:[NSMutableSet class]])
		{
			NSMutableSet *boundSet = (NSMutableSet *)self.boundValue;
			for(NSNumber *index in boundSet)
				[self.selectedItemsIndexes addObject:index];
		}
		else
			if([self.boundValue isKindOfClass:[NSString class]] && self.items)
			{
				[self buildSelectedItemsIndexesFromString:(NSString *)self.boundValue];
			}
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

//override superclass
- (void)cellValueChanged
{
	[self willDisplay];		// call to redraw label values
	
	[super cellValueChanged];
}

- (NSString *)getTitleForItemAtIndex:(NSUInteger)index
{
	return [self.items objectAtIndex:index];
}

//override superclass
- (void)willDisplay
{
	// don't call superclass willDisplay, as the "label"'s text will be set manually
	//[super willDisplay];
	
	NSArray *indexesArray = [[self.selectedItemsIndexes allObjects] 
							 sortedArrayUsingSelector:@selector(compare:)];
	if(self.items && self.displaySelection && indexesArray.count)
	{
		NSMutableString *selectionString = [[NSMutableString alloc] init];
		for(int i=0; i<indexesArray.count; i++)
		{
			NSUInteger index = [(NSNumber *)[indexesArray objectAtIndex:i] intValue];
			if(index > (self.items.count-1))
				continue;
			
			if(i==0)
				[selectionString appendString:[self getTitleForItemAtIndex:index]];
			else
				[selectionString appendFormat:@"%@%@", self.delimeter,
											(NSString *)[self getTitleForItemAtIndex:index]];
		}
		self.label.text = selectionString;
		[selectionString release];
	}
	else
		self.label.text = nil;
}

- (void)reloadBoundValue
{
	[self buildSelectedItemsIndexesFromBoundValue];
	[self willDisplay];
}

- (SCSelectionSection *)createSelectionSection
{
	return [SCSelectionSection sectionWithHeaderTitle:nil
											withItems:[NSMutableArray arrayWithArray:self.items]];
}
			 
- (void)addSelectionSectionToModel:(SCTableViewModel *)model
{
	SCSelectionSection *selectionSection = [self createSelectionSection];
	
	if(boundToNSNumber)
	{
		selectionSection.selectedItemIndex = self.selectedItemIndex;
	}
	else
	{
		for(NSNumber *index in self.selectedItemsIndexes)
			[selectionSection.selectedItemsIndexes addObject:index];
	}
	
	selectionSection.allowNoSelection = self.allowNoSelection;
	selectionSection.allowMultipleSelection = self.allowMultipleSelection;
	selectionSection.autoDismissViewController = self.autoDismissDetailView;
	selectionSection.cellsImageViews = self.detailCellsImageViews;
	
	[model addSection:selectionSection];
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	[self.selectedItemsIndexes removeAllObjects];
	SCSelectionSection *selectionSection = 
	(SCSelectionSection *)[detailModel sectionAtIndex:0];
	for(NSNumber *index in selectionSection.selectedItemsIndexes)
		[self.selectedItemsIndexes addObject:index];
	
	[self cellValueChanged];
}

//override superclass
- (void)didSelectCell
{	
	self.ownerTableViewModel.activeCell = self;

	if(!self.items)
		return;
	
	// Check for custom detail table view model
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailTableViewModelForRowAtIndexPath:)])
	{
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		SCTableViewModel *detailTableViewModel = [self.ownerTableViewModel.dataSource 
												  tableViewModel:self.ownerTableViewModel
												  customDetailTableViewModelForRowAtIndexPath:indexPath];
		if(detailTableViewModel)
		{
			self.tempDetailModel = [[SCTableViewModel alloc] initWithTableView:detailTableViewModel.modeledTableView
													   withViewController:detailTableViewModel.viewController];
			self.tempDetailModel.masterModel = self.ownerTableViewModel;
			[self.tempDetailModel setTargetForModelModifiedEvent:self action:@selector(tempDetailModelModified)];
			[self addSelectionSectionToModel:self.tempDetailModel];
			[detailTableViewModel.modeledTableView reloadData];
			
			return;
		}
	}
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	SCNavigationBarType navBarType;
	if(navController)
		navBarType = SCNavigationBarTypeNone;
	else
		navBarType = SCNavigationBarTypeDoneRight;
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:navBarType];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
	if(self.detailViewTitle)
		detailViewController.title = self.detailViewTitle;
	else
		detailViewController.title = self.textLabel.text;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif
	
	[self addSelectionSectionToModel:detailViewController.tableViewModel];
	
	[self.ownerTableViewModel pauseAutoResizeForKeyboard];
	[self disableOwnerViewControllerDelegate];
	if(navController)
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

// overrides superclass
- (void)commitChanges
{
	if(boundToNSNumber)
	{
		self.boundValue = self.selectedItemIndex;
	}
	else
	if(boundToNSString)
	{
		self.boundValue = [self buildStringFromSelectedItemsIndexes];
	}
	else
	{
		if([self.boundValue isKindOfClass:[NSMutableSet class]])
		{
			NSMutableSet *boundValueSet = (NSMutableSet *)self.boundValue;
			[boundValueSet removeAllObjects];
			for(NSNumber *index in self.selectedItemsIndexes)
				[boundValueSet addObject:index];
		}
	}
	
	needsCommit = FALSE;
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCSelectionAttributes class]])
		return;
	
	SCSelectionAttributes *selectionAttributes = (SCSelectionAttributes *)attributes;
	if(selectionAttributes.items)
		self.items = selectionAttributes.items;
	self.allowMultipleSelection = selectionAttributes.allowMultipleSelection;
	self.allowNoSelection = selectionAttributes.allowNoSelection;
	self.autoDismissDetailView = selectionAttributes.autoDismissDetailView;
	self.hideDetailViewNavigationBar = selectionAttributes.hideDetailViewNavigationBar;
}

//overrides superclass
- (BOOL)getValueIsValid
{
	if(![self.selectedItemsIndexes count] && !self.allowNoSelection && self.valueRequired)
		return FALSE;
	//else
	return TRUE;
}

- (void)setItems:(NSArray *)array
{
	[items release];
	items = [array retain];
	
	if(boundToNSString)
	{
		[self buildSelectedItemsIndexesFromString:(NSString *)self.boundValue];
	}
}

- (void)setSelectedItemIndex:(NSNumber *)number
{
	[self.selectedItemsIndexes removeAllObjects];
	if([number intValue] >= 0)
	{
		NSNumber *num = [number copy];
		[self.selectedItemsIndexes addObject:num];
		[num release];
	}
}

- (NSNumber *)selectedItemIndex
{
	NSNumber *index = [self.selectedItemsIndexes anyObject];
	
	if(index)
		return index;
	//else
	return [NSNumber numberWithInt:-1];
}

#pragma mark -
#pragma mark SCTableViewControllerDelegate methods

- (void)tableViewControllerWillAppear:(SCTableViewController *)tableViewController
{
	if(self.autoDismissDetailView)
		self.ownerTableViewModel.viewController.navigationController.navigationBarHidden
			= self.hideDetailViewNavigationBar;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[self.delegate detailViewWillAppearForCell:self withDetailTableViewModel:tableViewController.tableViewModel];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						detailViewWillAppearForRowAtIndexPath:indexPath
									 withDetailTableViewModel:tableViewController.tableViewModel];
		}
}

- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	self.ownerTableViewModel.viewController.navigationController.navigationBarHidden = FALSE;
	
	if(cancelTapped)
		return;
	
	[self commitDetailModelChanges:tableViewController.tableViewModel];
	
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillDisappearForCell:)])
	{
		[self.delegate detailViewWillDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					 detailViewWillDisappearForRowAtIndexPath:indexPath];
		}
}

- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewDidDisappearForCell:)])
	{
		[self.delegate detailViewDidDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailViewDidDisappearForRowAtIndexPath:indexPath];
		}
}

@end








@implementation SCObjectSelectionCell

@synthesize titlePropertyName;

+(id)cellWithText:(NSString *)cellText
  withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
		withItems:(NSArray *)cellItems withItemTitlePropertyName:(NSString *)itemTitlePropertyName
{
	return [[[[self class] alloc] initWithText:cellText 
							   withBoundObject:object withSelectedObjectPropertyName:propertyName 
									 withItems:cellItems
					 withItemTitlePropertyName:itemTitlePropertyName] autorelease];
}

-(id)initWithText:(NSString *)cellText
  withBoundObject:(NSObject *)object withSelectedObjectPropertyName:(NSString *)propertyName
		withItems:(NSArray *)cellItems withItemTitlePropertyName:(NSString *)itemTitlePropertyName
{
	if([self initWithText:cellText withBoundObject:object withPropertyName:propertyName])
	{
		self.items = cellItems;
		self.titlePropertyName = itemTitlePropertyName;
	}
	return self;
}

- (void)dealloc
{
	[titlePropertyName release];
	
	[super dealloc];
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCObjectSelectionAttributes class]])
		return;
	
	SCObjectSelectionAttributes *objectSelectionAttributes = (SCObjectSelectionAttributes *)attributes;

#ifdef _COREDATADEFINES_H	
	SCClassDefinition *classDef = objectSelectionAttributes.itemsEntityClassDefinition;
	if(classDef.entity)
	{
		// Create items from the items' entity
		NSFetchRequest *fetchRequest = objectSelectionAttributes.fetchRequest;
		if(!fetchRequest)
		{
			fetchRequest = [[NSFetchRequest alloc] init];
			
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
												initWithKey:classDef.keyPropertyName 
												ascending:YES];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
			[fetchRequest setSortDescriptors:sortDescriptors];
			
			[sortDescriptor release];
			[sortDescriptors release];
		}
		[fetchRequest setEntity:classDef.entity];
		
		self.items = [NSMutableArray arrayWithArray:[classDef.managedObjectContext 
													 executeFetchRequest:fetchRequest
													 error:NULL]];
		
		if(!objectSelectionAttributes.fetchRequest)
			[fetchRequest release];
	}
#endif	
	self.titlePropertyName = objectSelectionAttributes.itemsTitlePropertyName;
	
	// Synchronize selectedItemsIndexes
	[self.selectedItemsIndexes removeAllObjects];
	if(self.allowMultipleSelection)
	{
		NSMutableSet *boundSet = (NSMutableSet *)self.boundValue;
		for(NSObject *object in boundSet)
			[self.selectedItemsIndexes addObject:object];
	}
	else
	{
		NSObject *selectedObject = [self.boundObject valueForKey:self.boundPropertyName];
		int index = [self.items indexOfObjectIdenticalTo:selectedObject];
		if(index != NSNotFound)
			[self.selectedItemsIndexes addObject:[NSNumber numberWithInt:index]];
	}
}

// override superclass
- (NSString *)getTitleForItemAtIndex:(NSUInteger)index
{
	NSString *title = nil;
	@try 
	{
		NSObject *object = [self.items objectAtIndex:index];
		title = [object valueForKey:self.titlePropertyName];
	}
	@catch (NSException * e) 
	{
		// do nothing
	}
	
	return title;
}

// override superclass
- (SCSelectionSection *)createSelectionSection
{
	NSMutableArray *itemTitlesArray = [[NSMutableArray alloc] initWithCapacity:self.items.count];
	for(int i=0; i<self.items.count; i++)
	{
		[itemTitlesArray addObject:[self getTitleForItemAtIndex:i]];
	}
	
	SCSelectionSection *selectionSection = [SCSelectionSection sectionWithHeaderTitle:nil
																			withItems:itemTitlesArray];
	[itemTitlesArray release];
	
	return selectionSection;
}

// overrides superclass
- (void)commitChanges
{
	if(self.allowMultipleSelection)
	{
		if([self.boundValue isKindOfClass:[NSMutableSet class]])
		{
			NSMutableSet *boundValueSet = (NSMutableSet *)self.boundValue;
			[boundValueSet removeAllObjects];
			for(NSNumber *index in self.selectedItemsIndexes)
				[boundValueSet addObject:index];
		}
	}
	else
	{
		NSObject *selectedObject = nil;
		int index = [self.selectedItemIndex intValue];
		if(index >= 0)
			selectedObject = [self.items objectAtIndex:index];
		
		self.boundValue = selectedObject;
	}
}

@end










@interface SCObjectCell ()

- (void)setCellTextAndDetailText;

- (void)addObjectSectionToModel:(SCTableViewModel *)model;

@end



@implementation SCObjectCell

@synthesize objectClassDefinition;
@synthesize boundObjectTitleText;
@synthesize allowDetailView;
@synthesize detailViewModal;


+ (id)cellWithBoundObject:(NSObject *)object
{
	return [[[[self class] alloc] initWithBoundObject:object] autorelease];
}

+ (id)cellWithBoundObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithBoundObject:object 
								  withClassDefinition:classDefinition]
			autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		objectClassDefinition = nil;
		boundObjectTitleText = nil;
		allowDetailView = TRUE;
		detailViewModal = FALSE;
		self.detailTableViewStyle = UITableViewStyleGrouped;
		
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	return self;
}

- (id)initWithBoundObject:(NSObject *)object
{
	return [self initWithBoundObject:object withClassDefinition:nil];
}

- (id)initWithBoundObject:(NSObject *)object withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		boundObject = [object retain];
		
		if(!classDefinition && self.boundObject)
		{
			classDefinition = [SCClassDefinition definitionWithClass:[self.boundObject class]
									 autoGeneratePropertyDefinitions:YES];
		}
		
		self.objectClassDefinition = classDefinition;
	}
	return self;
}

- (void)dealloc
{
	[objectClassDefinition release];
	
	[super dealloc];
}

//override superclass
- (void)willDisplay
{
	[super willDisplay];
	
	if(self.boundObject)
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
	
	[self setCellTextAndDetailText];
}

//override superclass
- (void)cellValueChanged
{
	[self setCellTextAndDetailText];
	
	[super cellValueChanged];
}

- (void)addObjectSectionToModel:(SCTableViewModel *)model
{
	SCObjectSection *objectSection = [[SCObjectSection alloc] 
									  initWithHeaderTitle:nil 
									  withBoundObject:self.boundObject 
									  withClassDefinition:self.objectClassDefinition];
	objectSection.commitCellChangesLive = FALSE;
	objectSection.cellsImageViews = self.detailCellsImageViews;
	[model addSection:objectSection];
	[objectSection release];	
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	// commitChanges & ignore self.commitChangesLive setting as it's not applicable here
	//looping to include any custom user added sections too
	for(int i=0; i<detailModel.sectionCount; i++)
	{
		SCTableViewSection *section = [detailModel sectionAtIndex:i];
		if([section isKindOfClass:[SCObjectSection class]])
			[(SCObjectSection *)section commitCellChanges];
	}
	
	[self cellValueChanged];
}

//override superclass
- (void)didSelectCell
{
	self.ownerTableViewModel.activeCell = self;

	if(!self.allowDetailView || !self.boundObject)
		return;
	
	// Check for custom detail table view model
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailTableViewModelForRowAtIndexPath:)])
	{
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		SCTableViewModel *detailTableViewModel = [self.ownerTableViewModel.dataSource 
												  tableViewModel:self.ownerTableViewModel
												  customDetailTableViewModelForRowAtIndexPath:indexPath];
		if(detailTableViewModel)
		{
			self.tempDetailModel = [[SCTableViewModel alloc] initWithTableView:detailTableViewModel.modeledTableView
													   withViewController:detailTableViewModel.viewController];
			self.tempDetailModel.masterModel = self.ownerTableViewModel;
			[self.tempDetailModel setTargetForModelModifiedEvent:self action:@selector(tempDetailModelModified)];
			[self addObjectSectionToModel:self.tempDetailModel];
			[self.tempDetailModel sectionAtIndex:0].commitCellChangesLive = TRUE;
			[detailTableViewModel.modeledTableView reloadData];
			
			return;
		}
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
	if(self.detailViewTitle)
		detailViewController.title = self.detailViewTitle;
	else
		detailViewController.title = self.textLabel.text;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif
	
	[self addObjectSectionToModel:detailViewController.tableViewModel];
	
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

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCObjectAttributes class]])
		return;
	
	SCObjectAttributes *objectAttributes = (SCObjectAttributes *)attributes;
	SCClassDefinition *objectClassDef = 
	[objectAttributes.classDefinitions valueForKey:[NSString stringWithFormat:@"%s",
											 class_getName([self.boundObject class])]];
	if(objectClassDef)
		self.objectClassDefinition = objectClassDef;
}

- (void)setAllowDetailView:(BOOL)allow
{
	allowDetailView = allow;
	
	if(allow)
	{
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setBoundPropertyName:(NSString *)propertyName
{
	// set directly, do not use property for boundPropertyName
	boundPropertyName = [propertyName copy];
}

- (void)setCellTextAndDetailText
{
	if(self.boundObjectTitleText)
		self.textLabel.text = self.boundObjectTitleText;
	else
	{
		if(self.boundObject && self.objectClassDefinition.titlePropertyName)
		{
			self.textLabel.text = [self.objectClassDefinition titleValueForObject:self.boundObject];
		}
	}
	
	if(self.boundObject && self.objectClassDefinition.descriptionPropertyName)
	{
		NSString *detailText = nil;
#ifdef _COREDATADEFINES_H
		if([self.boundObject isKindOfClass:[NSManagedObject class]])
			detailText = [NSString stringWithFormat:@"%@", [(NSManagedObject *)self.boundObject 
														  valueForKeyPath:self.objectClassDefinition.descriptionPropertyName]];
		else
			detailText = [NSString stringWithFormat:@"%@", [self.boundObject 
														  valueForKey:self.objectClassDefinition.descriptionPropertyName]];
#else
		detailText = [NSString stringWithFormat:@"%@", [self.boundObject 
													  valueForKey:self.objectClassDefinition.descriptionPropertyName]];
#endif
		self.detailTextLabel.text = detailText;
	}
}

#pragma mark -
#pragma mark SCTableViewControllerDelegate methods

- (void)tableViewControllerWillAppear:(SCTableViewController *)tableViewController
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[self.delegate detailViewWillAppearForCell:self withDetailTableViewModel:tableViewController.tableViewModel];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						detailViewWillAppearForRowAtIndexPath:indexPath
									 withDetailTableViewModel:tableViewController.tableViewModel];
		}
}

- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
				 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	if(cancelTapped)
		return;
	
	[self commitDetailModelChanges:tableViewController.tableViewModel];
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillDisappearForCell:)])
	{
		[self.delegate detailViewWillDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					 detailViewWillDisappearForRowAtIndexPath:indexPath];
		}
}

- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewDidDisappearForCell:)])
	{
		[self.delegate detailViewDidDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailViewDidDisappearForRowAtIndexPath:indexPath];
		}
}

@end






@interface SCArrayOfObjectsCell ()

- (void)addObjectsSectionToModel:(SCTableViewModel *)model;

@end



@implementation SCArrayOfObjectsCell

@synthesize items;
@synthesize itemsSet;
@synthesize sortItemsSetAscending;
@synthesize itemsClassDefinitions;
@synthesize allowAddingItems;
@synthesize allowDeletingItems;
@synthesize allowMovingItems;
@synthesize allowEditDetailView;
@synthesize allowRowSelection;
@synthesize displayItemsCountInBadgeView;

+ (id)cellWithItems:(NSMutableArray *)cellItems
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithItems:cellItems 
							withClassDefinition:classDefinition] autorelease];
}

+ (id)cellWithItemsSet:(NSMutableSet *)cellItemsSet
   withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithItemsSet:cellItemsSet 
							   withClassDefinition:classDefinition] autorelease];
}

#ifdef _COREDATADEFINES_H
+ (id)cellWithEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithEntityClassDefinition:classDefinition] autorelease];
}
#endif

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if( (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) )
	{
		items = nil;
		itemsSet = nil;
		sortItemsSetAscending = TRUE;
		itemsClassDefinitions = [[NSMutableDictionary alloc] init];
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = TRUE;
		allowEditDetailView = TRUE;
		allowRowSelection = TRUE;
		displayItemsCountInBadgeView = TRUE;
	}
	
	return self;
}

- (id)initWithItems:(NSMutableArray *)cellItems
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		self.items = cellItems;
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			
#ifdef _COREDATADEFINES_H
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				self.allowMovingItems = FALSE;	// not applicable to core data
			}
#endif			
		}
	}
	return self;
}

- (id)initWithItemsSet:(NSMutableSet *)cellItemsSet
   withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithStyle:SC_DefaultCellStyle reuseIdentifier:nil])
	{
		self.itemsSet = cellItemsSet;
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			
#ifdef _COREDATADEFINES_H			
			if(classDefinition.entity)
			{
				coreDataBound = TRUE;
				self.allowMovingItems = FALSE;	// not applicable to core data
			}
#endif			
		}
			
	}
	return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	// Create the cellItems array
	NSMutableArray *cellItems = nil;
	
	if(classDefinition.entity)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:classDefinition.entity];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
											initWithKey:classDefinition.keyPropertyName 
											ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		cellItems = [NSMutableArray arrayWithArray:[classDefinition.managedObjectContext 
													executeFetchRequest:fetchRequest
													error:NULL]];
		
		[sortDescriptor release];
		[sortDescriptors release];
		[fetchRequest release];
	}
	
	return [self initWithItems:cellItems withClassDefinition:classDefinition];
}
#endif

- (void)dealloc
{
	[items release];
	[itemsSet release];
	[itemsClassDefinitions release];
	
	[super dealloc];
}

//override superclass
- (void)layoutSubviews
{
	if(self.displayItemsCountInBadgeView)
	{
		int count;
		if(self.itemsSet)
			count = [self.itemsSet count];
		else
			count = [self.items count];
		self.badgeView.text = [NSString stringWithFormat:@"%i", count];
	}
	
	[super layoutSubviews];
}

- (void)addObjectsSectionToModel:(SCTableViewModel *)model
{
	SCArrayOfObjectsSection *objectsSection;
	if(self.itemsSet)
	{
		SCClassDefinition *entityClassDef = nil;
		if([self.itemsClassDefinitions count])
		{
			entityClassDef = [self.itemsClassDefinitions 
							  valueForKey:[[self.itemsClassDefinitions allKeys] objectAtIndex:0]];
		}
		
		objectsSection = [[SCArrayOfObjectsSection alloc] initWithHeaderTitle:nil
																 withItemsSet:self.itemsSet
														  withClassDefinition:entityClassDef];
		objectsSection.sortItemsSetAscending = self.sortItemsSetAscending;
	}
	else
	{
		objectsSection = [[SCArrayOfObjectsSection alloc] initWithHeaderTitle:nil 
																	withItems:self.items 
														  withClassDefinition:nil];
	}
	[objectsSection.itemsClassDefinitions setDictionary:self.itemsClassDefinitions];
	objectsSection.allowAddingItems = self.allowAddingItems;
	objectsSection.allowDeletingItems = self.allowDeletingItems;
	objectsSection.allowMovingItems = self.allowMovingItems;
	objectsSection.allowEditDetailView = self.allowEditDetailView;
	objectsSection.allowRowSelection = self.allowRowSelection;
	if([model.viewController isKindOfClass:[SCTableViewController class]])
		objectsSection.addButtonItem = [(SCTableViewController *)model.viewController addButton];
	objectsSection.cellsImageViews = self.detailCellsImageViews;
	[model addSection:objectsSection];
	[objectsSection release];
}

- (void)commitDetailModelChanges:(SCTableViewModel *)detailModel
{
	[self cellValueChanged];
}

//override superclass
- (void)willDisplay
{
	[super willDisplay];
	
	if(self.items || self.itemsSet)
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}

//override superclass
- (void)didSelectCell
{
	self.ownerTableViewModel.activeCell = self;
	
	// If table is in edit mode, just display the bound object's detail view
	if(self.editing)
	{
		[super didSelectCell];
		return;
	}
	
	// Check for custom detail table view model
	if([self.ownerTableViewModel.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.ownerTableViewModel.dataSource 
		   respondsToSelector:@selector(tableViewModel:customDetailTableViewModelForRowAtIndexPath:)])
	{
		NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
		SCTableViewModel *detailTableViewModel = [self.ownerTableViewModel.dataSource 
												  tableViewModel:self.ownerTableViewModel
												  customDetailTableViewModelForRowAtIndexPath:indexPath];
		if(detailTableViewModel)
		{
			self.tempDetailModel = [[SCTableViewModel alloc] initWithTableView:detailTableViewModel.modeledTableView
													   withViewController:detailTableViewModel.viewController];
			self.tempDetailModel.masterModel = self.ownerTableViewModel;
			[self.tempDetailModel setTargetForModelModifiedEvent:self action:@selector(tempDetailModelModified)];
			[self addObjectsSectionToModel:self.tempDetailModel];
			[detailTableViewModel.modeledTableView reloadData];
			
			return;
		}
	}
	
	UINavigationController *navController = self.ownerTableViewModel.viewController.navigationController;
	
	if(!(self.items || self.itemsSet) || !navController)
		return;
	
	SCNavigationBarType navBarType;
	if(!self.allowAddingItems && !self.allowDeletingItems && !self.allowMovingItems)
		navBarType = SCNavigationBarTypeNone;
	else
	{
		if(self.allowAddingItems)
			navBarType = SCNavigationBarTypeAddEditRight;
		else
			navBarType = SCNavigationBarTypeEditRight;
	}
	SCTableViewController *detailViewController = [[SCTableViewController alloc] 
												   initWithStyle:self.detailTableViewStyle
												   withNavigationBarType:navBarType];
	detailViewController.ownerViewController = self.ownerTableViewModel.viewController;
	detailViewController.delegate = self;
	if(self.detailViewTitle)
		detailViewController.title = self.detailViewTitle;
	else
		detailViewController.title = self.textLabel.text;
	detailViewController.hidesBottomBarWhenPushed = self.detailViewHidesBottomBar;
#ifdef __IPHONE_3_2	
	if([SCHelper is_iPad])
		detailViewController.contentSizeForViewInPopover = 
			self.ownerTableViewModel.viewController.contentSizeForViewInPopover;
#endif
	
	[self addObjectsSectionToModel:detailViewController.tableViewModel];
	
	[self.ownerTableViewModel pauseAutoResizeForKeyboard];
	[self disableOwnerViewControllerDelegate];
	[navController pushViewController:detailViewController animated:TRUE];
	
	[detailViewController release];
}

//overrides superclass
- (void) setAttributesTo:(SCPropertyAttributes *)attributes
{
	[super setAttributesTo:attributes];
	
	if(![attributes isKindOfClass:[SCArrayOfObjectsAttributes class]])
		return;
	
	SCArrayOfObjectsAttributes *objectsArrayAttributes = (SCArrayOfObjectsAttributes *)attributes;
	[self.itemsClassDefinitions addEntriesFromDictionary:objectsArrayAttributes.classDefinitions];
	self.allowAddingItems = objectsArrayAttributes.allowAddingItems;
	self.allowDeletingItems = objectsArrayAttributes.allowDeletingItems;
	self.allowMovingItems = objectsArrayAttributes.allowMovingItems;
	self.allowEditDetailView = objectsArrayAttributes.allowEditingItems;
}

#pragma mark -
#pragma mark SCTableViewControllerDelegate methods

- (void)tableViewControllerWillAppear:(SCTableViewController *)tableViewController
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillAppearForCell:withDetailTableViewModel:)])
	{
		[self.delegate detailViewWillAppearForCell:self withDetailTableViewModel:tableViewController.tableViewModel];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillAppearForRowAtIndexPath:withDetailTableViewModel:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
						detailViewWillAppearForRowAtIndexPath:indexPath
									 withDetailTableViewModel:tableViewController.tableViewModel];
		}
}

- (void)tableViewControllerWillDisappear:(SCTableViewController *)tableViewController
					  cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if(self.editing)
	{
		[super tableViewControllerWillDisappear:tableViewController
							 cancelButtonTapped:cancelTapped doneButtonTapped:doneTapped];
		return;
	}
	
	[self.ownerTableViewModel resumeAutoResizeForKeyboard];
	[self enableOwnerViewControllerDelegate];
	
	if(cancelTapped)
		return;
	
	[self commitDetailModelChanges:tableViewController.tableViewModel];
	
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewWillDisappearForCell:)])
	{
		[self.delegate detailViewWillDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewWillDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					 detailViewWillDisappearForRowAtIndexPath:indexPath];
		}
}

- (void)tableViewControllerDidDisappear:(SCTableViewController *)tableViewController 
					 cancelButtonTapped:(BOOL)cancelTapped doneButtonTapped:(BOOL)doneTapped
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [self.delegate respondsToSelector:@selector(detailViewDidDisappearForCell:)])
	{
		[self.delegate detailViewDidDisappearForCell:self];
	}
	else
		if([self.ownerTableViewModel.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.ownerTableViewModel.delegate 
			   respondsToSelector:@selector(tableViewModel:detailViewDidDisappearForRowAtIndexPath:)])
		{
			NSIndexPath *indexPath = [self.ownerTableViewModel indexPathForCell:self];
			[self.ownerTableViewModel.delegate tableViewModel:self.ownerTableViewModel
					  detailViewDidDisappearForRowAtIndexPath:indexPath];
		}
}

@end







