//
//  CustumeCategories.m
//  HiBye
//
//  Created by shani hajbi on 10/25/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//

#import "CustumeCategories.h"

@implementation CustumeCategories
@synthesize categories;
@synthesize delegate;
@synthesize textFieldRounded;
@synthesize isIpad;

#define kLeftMargin				50.0
#define kTopMargin				10.0
#define kRightMargin			20.0
#define kTweenMargin			10.0
#define kTextFieldWidth         180.0
#define kTextFieldHeight		25.0

const NSInteger kViewTag = 1;
#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
  //  if([categories count] ==0){
   //     self.categories = [[NSMutableArray alloc] initWithObjects:@"",nil];
   // }
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];

}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"view wil disapear");
    [delegate custumeCategories:self didFinishWithArray:categories];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside down
	if (!isIpad) {
		return (interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown);
	}
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [categories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;	
		
		cell = [tableView dequeueReusableCellWithIdentifier:@"CellTextField_ID"];
		if (cell == nil)
		{
			// a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTextField_ID"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *textField = [self textFieldRounded];
            textField.text = [self.categories objectAtIndex:indexPath.row];
			
			// retrieve an image
			NSString *imagefile = [[NSBundle mainBundle] 
								   pathForResource:@"CustomCategory" ofType:@"png"];
			UIImage *ui = [[UIImage alloc] initWithContentsOfFile:imagefile];
			//set the image on the table cell
			cell.imageView.image = ui;
			
            textField.tag = indexPath.row;
            [cell.contentView addSubview:textField];
		}
   
          return cell;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(self.tableView.editing){
        //if([categories count]==1){
        return YES;  
       // }
    }
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
  
     addedCell = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSIndexPath *path = [NSIndexPath indexPathForRow:textField.tag inSection:0];

   if([textField.text length]==0 && textField.tag!=[categories count]-1){
       [categories removeObjectAtIndex:path.row];
       [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];   
         [self updateTesxtFielsdTags];   
   }else if(textField.tag!=[categories count]-1){
       
       [categories replaceObjectAtIndex:path.row withObject:textField.text];
         [self updateTesxtFielsdTags];   
   }
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
       [self updateTesxtFielsdTags];  
    NSLog(@"textfield tag = %i",textField.tag);
    if(self.tableView.editing){
    if((textField.text.length==0&&!addedCell&&textField.tag==[categories count]-1) || [categories count]==1){
        addedCell = YES;
        NSString *cat = @"";
        [categories insertObject:cat atIndex:[categories count]];
        NSIndexPath *path = [NSIndexPath indexPathForRow:[categories count]-1 inSection:0];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
      
        [self.tableView setEditing:NO];
        [self.tableView setEditing:YES];
    }
  }
    return YES;
}

-(void)updateTesxtFielsdTags{
    
    for(int i=0;i<[categories count];i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        UITextField *tf = [cell.contentView.subviews objectAtIndex:0];
        tf.tag = i;
        
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.row ==[categories count]-1){
        return NO;
    }
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
     
    if(indexPath.row != [categories count]-1){
        return UITableViewCellEditingStyleDelete;
    }else{
         return UITableViewCellEditingStyleInsert;
    }

     
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *tf = [cell.contentView.subviews objectAtIndex:0];
        [tf resignFirstResponder];
         [categories removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
       [self updateTesxtFielsdTags];
       
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
       ///////
    }   
    if(editingStyle ==UITableViewCellEditingStyleNone){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *tf = [cell.contentView.subviews objectAtIndex:0];
        tf.userInteractionEnabled=NO;
        [ tf resignFirstResponder];
        [self updateTesxtFielsdTags];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did end editing");
     [self updateTesxtFielsdTags];  
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    
   
    NSString *stringToMove = [[categories objectAtIndex:fromIndexPath.row] retain];
    [categories removeObjectAtIndex:fromIndexPath.row];
    [categories insertObject:stringToMove atIndex:toIndexPath.row];
    [stringToMove release];
    
    
    [self.tableView setEditing:NO];
    [self.tableView setEditing:YES];
    
     [self updateTesxtFielsdTags]; 
 
    
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}





#pragma mark -
#pragma mark Text Fields


- (UITextField *)textFieldRounded
{
	
		CGRect frame = CGRectMake(kLeftMargin, kTopMargin, kTextFieldWidth, kTextFieldHeight);
		textFieldRounded = [[UITextField alloc] initWithFrame:frame];
		
		textFieldRounded.borderStyle = UITextBorderStyleNone;
		textFieldRounded.textColor = [UIColor blackColor];
		textFieldRounded.font = [UIFont boldSystemFontOfSize:17.0];
		textFieldRounded.placeholder = @"enter category";
		textFieldRounded.backgroundColor = [UIColor whiteColor];
		textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		
		textFieldRounded.keyboardType = UIKeyboardTypeDefault;
		textFieldRounded.returnKeyType = UIReturnKeyDone;
		
		textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	textFieldRounded.textAlignment = UITextAlignmentLeft;
		
		textFieldRounded.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
		// Add an accessibility label that describes what the text field is for.
		[textFieldRounded setAccessibilityLabel:NSLocalizedString(@"RoundedTextField", @"")];
	
	return textFieldRounded;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [categories release];
    [super dealloc];
}


@end

