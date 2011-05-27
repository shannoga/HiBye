/*
 *  SCTableViewModel.m
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


#import "SCTableViewModel.h"



@interface SCTableViewModel ()

- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;
- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context;

@end




@implementation SCTableViewModel

@synthesize masterModel;
@synthesize modeledTableView;
@synthesize viewController;
@synthesize dataSource;
@synthesize delegate;
@synthesize editButtonItem;
@synthesize autoResizeForKeyboard;
@synthesize sectionIndexTitles;
@synthesize autoGenerateSectionIndexTitles;
@synthesize autoSortSections;
@synthesize hideSectionHeaderTitles;
@synthesize lockCellSelection;
@synthesize tag;
@synthesize previousActiveCell;
@synthesize activeCell;
@synthesize modelKeyValues;
@synthesize commitButton;


+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView
								 withViewController:_viewController] autorelease];
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
{
	if([self init])
	{
		target = nil;
		action = nil;
		masterModel = nil;
		
		modeledTableView = _modeledTableView;
		viewController = _viewController;
		dataSource = _viewController;
		delegate = _viewController;
		modeledTableView.dataSource = self;
		modeledTableView.delegate = self;
		
		editButtonItem = nil;
		sectionIndexTitles = nil;
		autoGenerateSectionIndexTitles = FALSE;
		autoSortSections = FALSE;
		hideSectionHeaderTitles = FALSE;
		lockCellSelection = FALSE;
		tag = 0;
		sections = [[NSMutableArray alloc] init];
		previousActiveCell = nil;
		activeCell = nil;
		
		modelKeyValues = [[NSMutableDictionary alloc] init];
		
		commitButton = nil;
		
		keyboardShown = FALSE;
		keyboardOverlap = 0;
		if([self.viewController isKindOfClass:[UITableViewController class]])
			self.autoResizeForKeyboard = FALSE;
		else
			self.autoResizeForKeyboard = TRUE;
		autoResizeStatus = self.autoResizeForKeyboard;
	}
	
	return self;
}

- (void)dealloc
{
	[self unregisterKeyboardNotifications];
	[editButtonItem release];
	[sectionIndexTitles release];
	[sections release];
	[modelKeyValues release];
	[commitButton release];

	[super dealloc];
}

- (NSArray *)sectionIndexTitles
{
	if(!self.autoGenerateSectionIndexTitles)
		return sectionIndexTitles;
	
	// Generate sectionIndexTitles
	NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.sectionCount];
	for(SCTableViewSection *section in sections)
		if([section.headerTitle length])
		{
			// Add first letter of the header title to section titles
			[titles addObject:[section.headerTitle substringToIndex:1]];
		}
	return titles;
}

- (void)setActiveCell:(SCTableViewCell *)cell
{
	if(activeCell == cell)
		return;
	
	previousActiveCell = activeCell;
	[previousActiveCell willDeselectCell];
	if(previousActiveCell.selected)
		[self.modeledTableView deselectRowAtIndexPath:[self indexPathForCell:previousActiveCell] animated:NO];
	
	activeCell = cell;
	
	NSIndexPath *indexPath = [self indexPathForCell:activeCell];
	[self.modeledTableView scrollToRowAtIndexPath:indexPath
								 atScrollPosition:UITableViewScrollPositionNone
										 animated:YES];
}

- (void)setCommitButton:(UIBarButtonItem *)button
{
	[commitButton release];
	commitButton = [button retain];
	
	commitButton.enabled = self.valuesAreValid;
}

- (NSIndexPath *)activeCellIndexPath
{
	return [self indexPathForCell:self.activeCell];
}

- (void)setAutoResizeForKeyboard:(BOOL)handleDidShow
{
	if([self.viewController isKindOfClass:[UITableViewController class]])
		return;
	
	autoResizeForKeyboard = handleDidShow;
	
	if(handleDidShow)
	{
		[self registerForKeyboardNotifications];
	}
	else
	{
		[self unregisterKeyboardNotifications];
	}
}

- (void)setEditButtonItem:(UIBarButtonItem *)barButtonItem
{
	[editButtonItem release];
	editButtonItem = [barButtonItem retain];
	
	editButtonItem.target = self;
	editButtonItem.action = @selector(didTapEditButtonItem);
}

- (void)valueChangedForSectionAtIndex:(NSUInteger)index
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:valueChangedForSectionAtIndex:)])
	{
		[self.delegate tableViewModel:self valueChangedForSectionAtIndex:index];
	}
	
	if(target)
		[target performSelector:action];
}

- (void)valueChangedForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!indexPath)
		return;
	
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	if(cell != self.activeCell)
	{
		if(self.activeCell.autoResignFirstResponder)
			[self.activeCell resignFirstResponder];
		if(!cell.reuseIdentifier)  // make sure it's a static cell, otherwise it could be deleted by UITableViewController and should not be referenced
			self.activeCell = cell;
		else
			self.activeCell = nil;
	}
	
	if(target)
		[target performSelector:action];
	
	if(self.commitButton)
		self.commitButton.enabled = self.valuesAreValid;
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:valueChangedForRowAtIndexPath:)])
	{
		[self.delegate tableViewModel:self valueChangedForRowAtIndexPath:indexPath];
	}
}

- (void)setTargetForModelModifiedEvent:(id)_target action:(SEL)_action
{
	target = _target;
	action = _action;
}

- (void)didTapEditButtonItem
{	
	BOOL editing = !self.modeledTableView.editing;		// toggle editing state
	
	if(editing)
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelWillBeginEditing:)])
		{
			[self.delegate tableViewModelWillBeginEditing:self];
		}
	}
	else
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelWillEndEditing:)])
		{
			[self.delegate tableViewModelWillEndEditing:self];
		}
	}
	
	[self.viewController setEditing:editing animated:TRUE];
	[self.modeledTableView setEditing:editing animated:TRUE];
	
	if(editing)
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelDidBeginEditing:)])
		{
			[self.delegate tableViewModelDidBeginEditing:self];
		}
	}
	else
	{
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModelDidEndEditing:)])
		{
			[self.delegate tableViewModelDidEndEditing:self];
		}
	}
}

- (void)replaceModeledTableViewWith:(UITableView *)tableView
{
	modeledTableView = tableView;
	modeledTableView.dataSource = self;
	modeledTableView.delegate = self;
}

- (NSUInteger)sectionCount
{
	return sections.count;
}

- (void)addSection:(SCTableViewSection *)section
{
	section.ownerTableViewModel = self;
	for(int i=0; i<section.cellCount; i++)
		[section cellAtIndex:i].ownerTableViewModel = self;
	[sections addObject:section];
	
	if(self.autoSortSections)
		[sections sortUsingSelector:@selector(compare:)];
}

- (void)insertSection:(SCTableViewSection *)section atIndex:(NSUInteger)index
{
	section.ownerTableViewModel = self;
	for(int i=0; i<section.cellCount; i++)
		[section cellAtIndex:i].ownerTableViewModel = self;
	[sections insertObject:section atIndex:index];
}

- (SCTableViewSection *)sectionAtIndex:(NSUInteger)index
{
	if(index < self.sectionCount)
		return [sections objectAtIndex:index];
	//else
	return nil;
}

- (SCTableViewSection *)sectionWithHeaderTitle:(NSString *)title
{
	for(SCTableViewSection *section in sections)
		if(title)
		{
			if([section.headerTitle isEqualToString:title])
				return section;
		}
		else
		{
			if(!section.headerTitle)
				return section;
		}
		
	
	return nil;
}

- (NSUInteger)indexForSection:(SCTableViewSection *)section
{
	return [sections indexOfObjectIdenticalTo:section];
}

- (void)removeSectionAtIndex:(NSUInteger)index
{
	[sections removeObjectAtIndex:index];
}

- (void)removeAllSections
{
	[sections removeAllObjects];
}

- (void)clear
{
	[self removeAllSections];
	[modelKeyValues removeAllObjects];
	activeCell = nil;
}

- (SCTableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
	return [[self sectionAtIndex:indexPath.section] cellAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForCell:(SCTableViewCell *)cell
{
	for(int i=0; i<self.sectionCount; i++)
	{
		NSUInteger index = [[self sectionAtIndex:i] indexForCell:cell];
		if(index == NSNotFound)
			continue;
		return [NSIndexPath indexPathForRow:index inSection:i];
	}
	return nil;
}

- (SCTableViewCell *)cellAfterCell:(SCTableViewCell *)cell rewindIfLastCell:(BOOL)rewind
{
	if(self.sectionCount==1 && [self sectionAtIndex:0].cellCount==1)
		return nil;		// only one cell in model
	
	NSIndexPath *indexPath = [self indexPathForCell:cell];
	SCTableViewSection *cellSection = [self sectionAtIndex:indexPath.section];
	if(indexPath.row+1 < cellSection.cellCount)
		return [cellSection cellAtIndex:indexPath.row+1];
	
	if(indexPath.section+1 < self.sectionCount)
		return [[self sectionAtIndex:indexPath.section+1] cellAtIndex:0];
	
	if(!rewind)
		return nil;
	
	return [[self sectionAtIndex:0] cellAtIndex:0];
}

- (BOOL)valuesAreValid
{
	for(SCTableViewSection *section in sections)
		if(!section.valuesAreValid)
			return FALSE;
	
	return TRUE;
}

- (void)reloadBoundValues
{
	for(SCTableViewSection *section in sections)
		[section reloadBoundValues];
}

- (void)pauseAutoResizeForKeyboard
{
	autoResizeStatus = self.autoResizeForKeyboard;
	self.autoResizeForKeyboard = FALSE;
}

- (void)resumeAutoResizeForKeyboard
{
	self.autoResizeForKeyboard = autoResizeStatus;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return self.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self sectionAtIndex:section].cellCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.hideSectionHeaderTitles)
		return nil;
	//else
	return [self sectionAtIndex:section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].footerTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if(index < self.sectionCount)
		return index;
	//else return the last section index
	return self.sectionCount-1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].editable;  
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].movable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return [self cellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
											forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		[(SCArrayOfItemsSection *)section commitEditingStyle:editingStyle 
											forCellAtIndexPath:indexPath];
	
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:commitEditingStyle:forRowAtIndexPath:)])
	{
		[self.dataSource tableViewModel:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
													toIndexPath:(NSIndexPath *)toIndexPath
{
	SCTableViewSection *section = [self sectionAtIndex:fromIndexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		[(SCArrayOfItemsSection *)section moveCellAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:moveRowAtIndexPath:toIndexPath:)])
	{
		[self.dataSource tableViewModel:self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willConfigureCell:)])
	{
		[cell.delegate willConfigureCell:cell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:willConfigureCell:forRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willConfigureCell:cell forRowAtIndexPath:indexPath];
		}
	
	CGFloat cellHeight = cell.height;
	// Check if the cell has an image in its section and resize accordingly
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section.cellsImageViews count] > indexPath.row)
	{
		UIImageView *imageView = [section.cellsImageViews objectAtIndex:indexPath.row];
		if([imageView isKindOfClass:[UIImageView class]])
		{
			if(cellHeight < imageView.image.size.height)
				cellHeight = imageView.image.size.height;
		}
	}
	
	return cellHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].shouldIndentWhileEditing;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	SCTableViewSection *scSection = [self sectionAtIndex:section];
	CGFloat height = scSection.headerHeight;
	UIFont *headerFont = nil;
	if(height == 0)
	{
		switch (tableView.style)
		{
			case UITableViewStylePlain:
				height = 22;
				headerFont = [UIFont boldSystemFontOfSize:17];
				break;
			case UITableViewStyleGrouped:
				height = 46;
				headerFont = [UIFont boldSystemFontOfSize:22];
				break;
		}
	}
	
	// Check that height is greater than the headerTitle text height
	CGSize constraintSize = CGSizeMake(self.modeledTableView.frame.size.width, 
									   self.modeledTableView.frame.size.height);
	CGFloat textHeight = 0;
	if(scSection.headerTitle)
	{
		textHeight = [scSection.headerTitle sizeWithFont:headerFont
									   constrainedToSize:constraintSize
										   lineBreakMode:UILineBreakModeWordWrap].height;
	}
	
	if(height < textHeight)
		height = textHeight;
	
	if(scSection.headerView && height<scSection.headerView.frame.size.height)
		height = scSection.headerView.frame.size.height;
	
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	SCTableViewSection *scSection = [self sectionAtIndex:section];
	CGFloat height = scSection.footerHeight;
	UIFont *footerFont = nil;
	if(height == 0)
	{
		switch (tableView.style)
		{
			case UITableViewStylePlain:
				height = 22;
				footerFont = [UIFont boldSystemFontOfSize:17];
				break;
			case UITableViewStyleGrouped:
				height = 22;
				footerFont = [UIFont boldSystemFontOfSize:19];
				break;
		}
	}
	
	// Check that height is greater than the footerTitle text height
	CGSize constraintSize = CGSizeMake(self.modeledTableView.frame.size.width, 
									   self.modeledTableView.frame.size.height);
	CGFloat textHeight = [scSection.footerTitle sizeWithFont:footerFont
										   constrainedToSize:constraintSize
											   lineBreakMode:UILineBreakModeWordWrap].height;
	if(height < textHeight)
		height = textHeight;
	
	if(scSection.footerView && height<scSection.footerView.frame.size.height)
		height = scSection.footerView.frame.size.height;
	
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].footerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellAtIndexPath:indexPath].cellEditingStyle;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *scCell = (SCTableViewCell *)cell;
	[scCell willDisplay];
	
	// Check if the cell has an image in its section
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section.cellsImageViews count] > indexPath.row)
	{
		UIImageView *imageView = [section.cellsImageViews objectAtIndex:indexPath.row];
		if([imageView isKindOfClass:[UIImageView class]])
			scCell.imageView.image = imageView.image;
	}
	
	if([scCell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [scCell.delegate respondsToSelector:@selector(willDisplayCell:)])
	{
		[scCell.delegate willDisplayCell:scCell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:willDisplayCell:forRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willDisplayCell:scCell forRowAtIndexPath:indexPath];
		}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.lockCellSelection)
		return nil;
	
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if(!cell.selectable)
		return nil;
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(willSelectCell:)])
	{
		[cell.delegate willSelectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:willSelectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self willSelectRowAtIndexPath:indexPath];
		}
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	if(cell != self.activeCell)
	{
		if(self.activeCell.autoResignFirstResponder)
			[self.activeCell resignFirstResponder];
		if(!cell.reuseIdentifier)  // make sure it's a static cell, otherwise it could be deleted by UITableViewController and should not be referenced
			self.activeCell = cell;
		else
			self.activeCell = nil;
	}
	
	SCTableViewSection *section = [self sectionAtIndex:indexPath.section];
	if([section isKindOfClass:[SCArrayOfItemsSection class]])
		[(SCArrayOfItemsSection *)section didSelectCellAtIndexPath:indexPath];
	else
		[activeCell didSelectCell];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(didSelectCell:)])
	{
		[cell.delegate didSelectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:didSelectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self didSelectRowAtIndexPath:indexPath];
		}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	[cell willDeselectCell];
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(didDeselectCell:)])
	{
		[cell.delegate didDeselectCell:cell];
	}
	else	
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate respondsToSelector:@selector(tableViewModel:didDeselectRowAtIndexPath:)])
		{
			[self.delegate tableViewModel:self didDeselectRowAtIndexPath:indexPath];
		}
}

- (void)tableView:(UITableView *)tableView 
					accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	SCTableViewCell *cell = [self cellAtIndexPath:indexPath];
	
	if([cell.delegate conformsToProtocol:@protocol(SCTableViewCellDelegate)]
	   && [cell.delegate respondsToSelector:@selector(accessoryButtonTappedForCell:)])
	{
		[cell.delegate accessoryButtonTappedForCell:cell];
	}
	else
		if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
		   && [self.delegate 
			   respondsToSelector:@selector(tableViewModel:accessoryButtonTappedForRowWithIndexPath:)])
		{
			[self.delegate tableViewModel:self accessoryButtonTappedForRowWithIndexPath:indexPath];
		}
}

#pragma mark -
#pragma mark Keyboard methods

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	if (keyboardShown) 
		return;
	
	keyboardShown = YES;
	
	// Get the size & animation details of the keyboard
	NSDictionary* userInfo = [aNotification userInfo];
#ifdef __IPHONE_3_2
	#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
	#else
		CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	#endif
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size; 
#endif
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	UIViewAnimationCurve animationCurve;
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	
	// Determine how much overlap exists between modeledTableView and the keyboard
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	CGRect convertedTableViewFrame = [keyWindow convertRect:self.modeledTableView.frame 
												   fromView:self.viewController.view];
	CGFloat tableLowerYCoord = convertedTableViewFrame.origin.y + convertedTableViewFrame.size.height;
	CGFloat keyboardUpperYCoord = keyWindow.frame.size.height - keyboardSize.height;
	keyboardOverlap = tableLowerYCoord - keyboardUpperYCoord;
	
	if(keyboardOverlap < 0)
		keyboardOverlap = 0;
	
	if(keyboardOverlap != 0)
	{
		CGRect tableFrame = self.modeledTableView.frame; 
		tableFrame.size.height -= keyboardOverlap;
		
		NSTimeInterval delay = 0;
		if(keyboardSize.height)
		{
			delay = (1 - keyboardOverlap/keyboardSize.height)*animationDuration;
			animationDuration = animationDuration * keyboardOverlap/keyboardSize.height;
		}
		
#ifdef __IPHONE_4_0
	#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(tableAnimationEnded:finished:contextInfo:)];
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];
		self.modeledTableView.frame = tableFrame;
		[UIView commitAnimations];
	#else
		[UIView animateWithDuration:animationDuration delay:delay 
							options:UIViewAnimationOptionCurveEaseInOut 
						 animations:^{ self.modeledTableView.frame = tableFrame; } 
						 completion:^(BOOL finished){ [self tableAnimationEnded:nil finished:nil contextInfo:nil]; }];
	#endif
#else
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(tableAnimationEnded:finished:contextInfo:)];
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:animationCurve];
		self.modeledTableView.frame = tableFrame;
		[UIView commitAnimations];
#endif
	}
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	keyboardShown = NO;
	
	if(keyboardOverlap == 0)
		return;
	
	// Get the size & animation details of the keyboard
	NSDictionary* userInfo = [aNotification userInfo];
#ifdef __IPHONE_3_2
	#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
	#else
		CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	#endif
#else
	CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size; 
#endif
    NSTimeInterval animationDuration;
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	CGRect tableFrame = self.modeledTableView.frame; 
	tableFrame.size.height += keyboardOverlap;
	
	if(keyboardSize.height)
		animationDuration = animationDuration * keyboardOverlap/keyboardSize.height;

#ifdef __IPHONE_4_0
	#ifdef DEPLOYMENT_OS_PRIOR_TO_3_2
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:animationDuration];
		self.modeledTableView.frame = tableFrame;
		[UIView commitAnimations];
	#else
		[UIView animateWithDuration:animationDuration animations:^{ self.modeledTableView.frame = tableFrame; }];
	#endif
#else
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.modeledTableView.frame = tableFrame;
    [UIView commitAnimations];
#endif
}

- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
	// Scroll to the active cell
	if(self.activeCell)
	{
		NSIndexPath *indexPath = [self indexPathForCell:self.activeCell];
		[self.modeledTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone
											 animated:YES];
	}
}


@end







@interface SCArrayOfItemsModel ()

- (void)generateSections;
- (NSString *)getHeaderTitleForItemAtIndex:(NSUInteger)index;

@end



@implementation SCArrayOfItemsModel

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
@synthesize addButtonItem;
@synthesize searchBar;


- (id)init
{
	if( (self=[super init]) )
	{
		tempSection = nil;
		items = nil;
		itemsAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		allowAddingItems = TRUE;
		allowDeletingItems = TRUE;
		allowMovingItems = FALSE;
		allowEditDetailView = TRUE;
		allowRowSelection = TRUE;
		detailViewModal = FALSE;
#ifdef __IPHONE_3_2
		detailViewModalPresentationStyle = UIModalPresentationFullScreen;
#endif
		
		detailTableViewStyle = UITableViewStyleGrouped;
		detailViewHidesBottomBar = TRUE;
		addButtonItem = nil;
		
		filteredArray = nil;
		searchBar = nil;
	}
	
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
			  withItems:(NSMutableArray *)_items
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{
		self.items = _items;  // setter will generate sections
	}
	return self;
}

- (void)dealloc
{
	[tempSection release];
	[items release];
	[addButtonItem release];
	[filteredArray release];
	[searchBar release];
	
	[super dealloc];
}

- (void)generateSections
{
	[self removeAllSections];
	
	NSArray *itemsArray;
	if(filteredArray)
		itemsArray = filteredArray;
	else
		itemsArray = self.items;
	
	for(int i=0; i<itemsArray.count; i++)
	{
		NSString *headerTitle = [self getHeaderTitleForItemAtIndex:i];
		SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionWithHeaderTitle:headerTitle];
		if(!section)
		{
			section = [self createSectionWithHeaderTitle:headerTitle];
			if(!section)
				continue;
			[self setPropertiesForSection:section];
			[self addSection:section];
		}
		[section.items addObject:[itemsArray objectAtIndex:i]];
	}
}

- (NSString *)getHeaderTitleForItemAtIndex:(NSUInteger)index
{
	NSArray *itemsArray;
	if(filteredArray)
		itemsArray = filteredArray;
	else
		itemsArray = self.items;
	
	NSString *headerTitleName = nil;
	if([self.dataSource conformsToProtocol:@protocol(SCTableViewModelDataSource)]
	   && [self.dataSource respondsToSelector:@selector(tableViewModel:sectionHeaderTitleForItem:AtIndex:)])
	{
		headerTitleName = [self.dataSource tableViewModel:self sectionHeaderTitleForItem:[itemsArray objectAtIndex:index]
												  AtIndex:index];
	}
	
	return headerTitleName;
}

- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return nil;  // method must be overridden by subclasses
}

- (void)setSearchBar:(UISearchBar *)sbar
{
	[searchBar release];
	searchBar = [sbar retain];
	searchBar.delegate = self;
}

- (void)setPropertiesForSection:(SCArrayOfItemsSection *)section
{
	section.itemsAccessoryType = self.itemsAccessoryType;
	section.allowAddingItems = self.allowAddingItems;
	section.allowDeletingItems = self.allowDeletingItems;
	section.allowMovingItems = self.allowMovingItems;
	section.allowEditDetailView = self.allowEditDetailView;
	section.allowRowSelection = self.allowRowSelection;
	section.detailViewModal = self.detailViewModal;
#ifdef __IPHONE_3_2
	section.detailViewModalPresentationStyle = self.detailViewModalPresentationStyle;
#endif
	section.detailTableViewStyle = self.detailTableViewStyle;
	section.detailViewHidesBottomBar = self.detailViewHidesBottomBar;
}

- (void)setItems:(NSMutableArray *)array
{
	[items release];
	items = [array retain];
	
	[self generateSections];
}

// override superclass
- (void)setAutoSortSections:(BOOL)autoSort
{
	[super setAutoSortSections:autoSort];
	
	if(autoSort)
		[self generateSections];
}

// override superclass
- (void)setItemsAccessoryType:(UITableViewCellAccessoryType)type
{
	itemsAccessoryType = type;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).itemsAccessoryType = type;
}

// override superclass
- (void)setAllowAddingItems:(BOOL)allow
{
	allowAddingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowAddingItems = allow;
}

// override superclass
- (void)setAllowDeletingItems:(BOOL)allow
{
	allowDeletingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowDeletingItems = allow;
}

// override superclass
- (void)setAllowMovingItems:(BOOL)allow
{
	allowMovingItems = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowMovingItems = allow;
}

// override superclass
- (void)setAllowEditDetailView:(BOOL)allow
{
	allowEditDetailView = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowEditDetailView = allow;
}

// override superclass
- (void)setAllowRowSelection:(BOOL)allow
{
	allowRowSelection = allow;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).allowRowSelection = allow;
}

// override superclass
- (void)setDetailViewModal:(BOOL)modal
{
	detailViewModal = modal;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewModal = modal;
}

#ifdef __IPHONE_3_2
// override superclass
- (void)setDetailViewModalPresentationStyle:(UIModalPresentationStyle)style
{
	detailViewModalPresentationStyle = style;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewModalPresentationStyle = style;
}
#endif

// override superclass
- (void)setDetailTableViewStyle:(UITableViewStyle)style
{
	detailTableViewStyle = style;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailTableViewStyle = style;
}

// override superclass
- (void)setDetailViewHidesBottomBar:(BOOL)hides
{
	detailViewHidesBottomBar = hides;
	for(int i=0; i<self.sectionCount; i++)
		((SCArrayOfItemsSection *)[self sectionAtIndex:i]).detailViewHidesBottomBar = hides;
}

- (void)setAddButtonItem:(UIBarButtonItem *)barButtonItem
{
	[addButtonItem release];
	addButtonItem = [barButtonItem retain];
	
	addButtonItem.target = self;
	addButtonItem.action = @selector(didTapAddButtonItem);
}

- (void)didTapAddButtonItem
{
	// Game plan: delegate presenting the add detail view to SCArrayOfItemsSection
	
	//cancel any search in progress
	if([self.searchBar.text length])
		self.searchBar.text = nil;
	
	SCArrayOfItemsSection *section;
	if(self.sectionCount)
	{
		section = (SCArrayOfItemsSection *)[self sectionAtIndex:0];
	}
	else
	{
		if(!tempSection)
		{
			tempSection = [[self createSectionWithHeaderTitle:nil] retain];
			tempSection.ownerTableViewModel = self;
			[self setPropertiesForSection:tempSection];
		}
		section = tempSection;
	}
	
	[section didTapAddButtonItem];
}

- (void)addNewItem:(NSObject *)newItem
{
	[self.items addObject:newItem];
	NSUInteger itemIndex = self.items.count-1;
	
	NSString *headerTitle = [self getHeaderTitleForItemAtIndex:itemIndex];
	SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionWithHeaderTitle:headerTitle];
	if(!section)
	{
		// Add new section
		section = [self createSectionWithHeaderTitle:headerTitle];
		[self setPropertiesForSection:section];
		[self addSection:section];
		NSUInteger sectionIndex = [self indexForSection:section];
		[self.modeledTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] 
							 withRowAnimation:UITableViewRowAnimationLeft];
		if(self.autoGenerateSectionIndexTitles)
		{
			[self.modeledTableView reloadData]; // reloadSectionIndexTitles not working!
		}
	}
	
	[section addNewItem:newItem];
}

// Overrides superclass
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	
	// Remove the section if empty
	SCArrayOfItemsSection *section = (SCArrayOfItemsSection *)[self sectionAtIndex:indexPath.section];
	if(!section.items.count)
	{
		[self removeSectionAtIndex:indexPath.section];
		[self.modeledTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
							 withRowAnimation:UITableViewRowAnimationRight];
		if(self.autoGenerateSectionIndexTitles)
		{
			[self.modeledTableView reloadData]; // reloadSectionIndexTitles not working!
		}
	}
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModel:searchBarSelectedScopeButtonIndexDidChange:)])
	{
		[self.delegate tableViewModel:self searchBarSelectedScopeButtonIndexDidChange:selectedScope];
	}
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarBookmarkButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarBookmarkButtonClicked:self];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sBar
{
	[self.searchBar resignFirstResponder];
	self.searchBar.text = nil;
	
	[filteredArray release];
	filteredArray = nil;
	[self generateSections];
	[self.modeledTableView reloadData];
	
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarCancelButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarCancelButtonClicked:self];
	}
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarResultsListButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarResultsListButtonClicked:self];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sBar
{
	if([self.delegate conformsToProtocol:@protocol(SCTableViewModelDelegate)]
	   && [self.delegate respondsToSelector:@selector(tableViewModelSearchBarSearchButtonClicked:)])
	{
		[self.delegate tableViewModelSearchBarSearchButtonClicked:self];
	}
}

@end







@implementation SCArrayOfStringsModel

- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return [SCArrayOfStringsSection sectionWithHeaderTitle:title withItems:[NSMutableArray array]];
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sbar textDidChange:(NSString *)searchText
{
	if([sbar.text length])
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", sbar.text];
		[filteredArray release];
		filteredArray = [[self.items filteredArrayUsingPredicate:predicate] retain];
	}
	else
	{
		filteredArray = nil;
	}
	
	[self generateSections];
	[self.modeledTableView reloadData];
}

@end








@interface SCArrayOfObjectsModel ()

- (void)generateItemsArrayFromItemsSet;
- (SCClassDefinition *)firstClassDefinition;  // Returns the 1st classdef in classDefinitions

@end



@implementation SCArrayOfObjectsModel

@synthesize itemsClassDefinitions;
@synthesize itemsSet;
@synthesize sortItemsSetAscending;
@synthesize searchPropertyName;


+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
						withItems:(NSMutableArray *)_items
			  withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
										  withItems:_items 
								withClassDefinition:classDefinition] autorelease];
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
					 withItemsSet:(NSMutableSet *)_itemsSet
			  withClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
									   withItemsSet:_itemsSet 
								withClassDefinition:classDefinition] autorelease];
}

#ifdef _COREDATADEFINES_H
+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
						  withEntityClassDefinition:classDefinition] autorelease];
}

+ (id)tableViewModelWithTableView:(UITableView *)_modeledTableView
			   withViewController:(UIViewController *)_viewController
		withEntityClassDefinition:(SCClassDefinition *)classDefinition
				   usingPredicate:(NSPredicate *)predicate
{
	return [[[[self class] alloc] initWithTableView:_modeledTableView withViewController:_viewController
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
		searchPropertyName = nil;
	}
	
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
			  withItems:(NSMutableArray *)_items
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{		
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
		}
		self.items = _items;  // setter will generate sections
	}
	return self;
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
		   withItemsSet:(NSMutableSet *)_itemsSet
	withClassDefinition:(SCClassDefinition *)classDefinition
{
	if([self initWithTableView:_modeledTableView withViewController:_viewController])
	{	
		if(classDefinition)
		{
			[self.itemsClassDefinitions setValue:classDefinition forKey:classDefinition.className];
			self.itemsSet = _itemsSet;	// setter also generates items array
		}
	}
	return self;
}

#ifdef _COREDATADEFINES_H
- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
	withEntityClassDefinition:(SCClassDefinition *)classDefinition
{
	return [self initWithTableView:_modeledTableView withViewController:_viewController
				withEntityClassDefinition:classDefinition usingPredicate:nil];
}

- (id)initWithTableView:(UITableView *)_modeledTableView
	 withViewController:(UIViewController *)_viewController
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
	
	return [self initWithTableView:_modeledTableView withViewController:_viewController
						 withItems:sectionItems
			   withClassDefinition:classDefinition];
}
#endif

- (void)dealloc
{
	[itemsClassDefinitions release];
	[itemsSet release];
	[searchPropertyName release];
		
	[super dealloc];
}

// override superclass method
- (SCArrayOfItemsSection *)createSectionWithHeaderTitle:(NSString *)title
{
	return [SCArrayOfObjectsSection sectionWithHeaderTitle:title withItems:[NSMutableArray array] 
									   withClassDefinition:[self firstClassDefinition]];
}

// override superclass method
- (void)setPropertiesForSection:(SCArrayOfItemsSection *)section
{
	[super setPropertiesForSection:section];
	
	if([section isKindOfClass:[SCArrayOfObjectsSection class]])
	{
		[[(SCArrayOfObjectsSection *)section itemsClassDefinitions] 
		 addEntriesFromDictionary:self.itemsClassDefinitions];
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

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)sbar textDidChange:(NSString *)searchText
{
	if([sbar.text length])
	{
		SCClassDefinition *objClassDef = [self firstClassDefinition];
		
		if(!self.searchPropertyName)
			self.searchPropertyName = objClassDef.titlePropertyName;
		
		NSArray *searchProperties;
		if([self.searchPropertyName isEqualToString:@"*"])
		{
			searchProperties = [NSMutableArray arrayWithCapacity:objClassDef.propertyDefinitionCount];
			for(int i=0; i<objClassDef.propertyDefinitionCount; i++)
				[(NSMutableArray *)searchProperties addObject:[objClassDef propertyDefinitionAtIndex:i].name];
		}
		else
		{
			searchProperties = [self.searchPropertyName componentsSeparatedByString:@";"];
		}

		NSMutableString *predicateFormat = [NSMutableString string];
		for(int i=0; i<searchProperties.count; i++)
		{
			NSString *property = [searchProperties objectAtIndex:i];
			if(i==0)
				[predicateFormat appendFormat:@"%@ contains[c] '%@'", property, sbar.text];
			else
				[predicateFormat appendFormat:@" OR %@ contains[c] '%@'", property, sbar.text];
		}
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
		
		[filteredArray release];
		@try 
		{
			filteredArray = [[self.items filteredArrayUsingPredicate:predicate] retain];
		}
		@catch (NSException * e) 
		{
			// handle any unexpected property-name behavior gracefully
			filteredArray = [[NSArray alloc] init]; //empty array
		}
	}
	else
	{
		filteredArray = nil;
	}
	
	[self generateSections];
	[self.modeledTableView reloadData];
}

@end



