

#import "TextFieldController.h"
#import "Constants.h"

#define kTextFieldWidth	260.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

const NSInteger kViewTag = 1;

@implementation TextFieldController

@synthesize textFieldNormal, textFieldRounded, textFieldSecure, textFieldLeftView, dataSourceArray;

- (void)dealloc
{
	[textFieldNormal release];
	[textFieldRounded release];
	[textFieldSecure release];
	[textFieldLeftView release];
	
	[dataSourceArray release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataSourceArray = [NSArray arrayWithObjects:
								[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField", kSectionTitleKey,
								 @"TextFieldController.m: textFieldNormal", kSourceKey,
								 self.textFieldNormal, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField Rounded", kSectionTitleKey,
								 @"TextFieldController.m: textFieldRounded", kSourceKey,
								 self.textFieldRounded, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField Secure", kSectionTitleKey,
								 @"TextFieldController.m: textFieldSecure", kSourceKey,
								 self.textFieldSecure, kViewKey,
							 nil],
							
							[NSDictionary dictionaryWithObjectsAndKeys:
								 @"UITextField (with LeftView)", kSectionTitleKey,
								 @"TextFieldController.m: textFieldLeftView", kSourceKey,
								 self.textFieldLeftView, kViewKey,
								 nil],
							nil];
	
	self.title = NSLocalizedString(@"TextFieldTitle", @"");
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	//
	[textFieldNormal release];
	textFieldNormal = nil;		
	[textFieldRounded release];
	textFieldRounded = nil;
	[textFieldSecure release];
	textFieldSecure = nil;
	[textFieldLeftView release];
	textFieldLeftView = nil;
	
	self.dataSourceArray = nil;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ([indexPath row] == 0) ? 50.0 : 22.0;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
	if (row == 0)
	{
		static NSString *kCellTextField_ID = @"CellTextField_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
			UIView *viewToCheck = nil;
			viewToCheck = [cell.contentView viewWithTag:kViewTag];
			if (!viewToCheck)
				[viewToCheck removeFromSuperview];
		}
		
		UITextField *textField = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kViewKey];
		[cell.contentView addSubview:textField];
	}
	else /* (row == 1) */
	{
		static NSString *kSourceCell_ID = @"SourceCell_ID";
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.highlightedTextColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
		}
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex: indexPath.section] valueForKey:kSourceKey];
	}
	
    return cell;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}


#pragma mark -
#pragma mark Text Fields

- (UITextField *)textFieldNormal
{
	if (textFieldNormal == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldNormal = [[UITextField alloc] initWithFrame:frame];
		
		textFieldNormal.borderStyle = UITextBorderStyleBezel;
		textFieldNormal.textColor = [UIColor blackColor];
		textFieldNormal.font = [UIFont systemFontOfSize:17.0];
		textFieldNormal.placeholder = @"<enter text>";
		textFieldNormal.backgroundColor = [UIColor whiteColor];
		textFieldNormal.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		
		textFieldNormal.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
		textFieldNormal.returnKeyType = UIReturnKeyDone;
		
		textFieldNormal.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldNormal.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldNormal.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldNormal setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
	}	
	return textFieldNormal;
}

- (UITextField *)textFieldRounded
{
	if (textFieldRounded == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldRounded = [[UITextField alloc] initWithFrame:frame];
		
		textFieldRounded.borderStyle = UITextBorderStyleRoundedRect;
		textFieldRounded.textColor = [UIColor blackColor];
		textFieldRounded.font = [UIFont systemFontOfSize:17.0];
		textFieldRounded.placeholder = @"<enter text>";
		textFieldRounded.backgroundColor = [UIColor whiteColor];
		textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		
		textFieldRounded.keyboardType = UIKeyboardTypeDefault;
		textFieldRounded.returnKeyType = UIReturnKeyDone;
		
		textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldRounded.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldRounded.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldRounded setAccessibilityLabel:NSLocalizedString(@"RoundedTextField", @"")];
	}
	return textFieldRounded;
}

- (UITextField *)textFieldSecure
{
	if (textFieldSecure == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldSecure = [[UITextField alloc] initWithFrame:frame];
		textFieldSecure.borderStyle = UITextBorderStyleBezel;
		textFieldSecure.textColor = [UIColor blackColor];
		textFieldSecure.font = [UIFont systemFontOfSize:17.0];
		textFieldSecure.placeholder = @"<enter password>";
		textFieldSecure.backgroundColor = [UIColor whiteColor];
		
		textFieldSecure.keyboardType = UIKeyboardTypeDefault;
		textFieldSecure.returnKeyType = UIReturnKeyDone;	
		textFieldSecure.secureTextEntry = YES;	// make the text entry secure (bullets)
		
		textFieldSecure.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldSecure.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldSecure.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldSecure setAccessibilityLabel:NSLocalizedString(@"SecureTextField", @"")];
	}
	return textFieldSecure;
}

- (UITextField *)textFieldLeftView
{
	if (textFieldLeftView == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldLeftView = [[UITextField alloc] initWithFrame:frame];
		textFieldLeftView.borderStyle = UITextBorderStyleBezel;
		textFieldLeftView.textColor = [UIColor blackColor];
		textFieldLeftView.font = [UIFont systemFontOfSize:17.0];
		textFieldLeftView.placeholder = @"<enter text>";
		textFieldLeftView.backgroundColor = [UIColor whiteColor];
		
		textFieldLeftView.keyboardType = UIKeyboardTypeDefault;
		textFieldLeftView.returnKeyType = UIReturnKeyDone;	
		
		textFieldLeftView.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldLeftView.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
		
		// Add an accessibility label that describes the text field.
		[textFieldLeftView setAccessibilityLabel:NSLocalizedString(@"CheckMarkIcon", @"")];
		
		textFieldLeftView.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment_check.png"]];
		textFieldLeftView.leftViewMode = UITextFieldViewModeAlways;
		
		textFieldLeftView.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	}
	return textFieldLeftView;
}

@end

