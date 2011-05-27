//
//  Settings.m
//  HiBye
//
//  Created by shani hajbi on 9/13/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"
#import "DatesFunctions.h"
#import <CoreData/CoreData.h>
#import "CustumeCategories.h"
#import "GlobalFunctions.h"
#import "TimerHeaderView.h"
#import "HiByeAppDelegate.h"
#import "TableViewDesignFunctions.h"
#import "DataDetectionView.h"
@implementation AddViewController
@synthesize delegate;
@synthesize saveBtn;
@synthesize timerHeaderView;
@synthesize isIpad;
@synthesize person;
@synthesize toolbar;
@synthesize hiByeGroupId;
@synthesize detectionArr;


- (id)initWithPerson:(Person*)personToAdd {
	if (self == [super init]) {
		self.person =personToAdd;
		existing=NO;
		if (self.person.compName!=nil) {
			existing=YES;
            
		}
	
	}
	return self;
}

- (void)loadView {
	
	defaults =[NSUserDefaults standardUserDefaults];

    NSMutableArray *categories = [[NSMutableArray alloc] initWithArray:[defaults  arrayForKey:@"activeCategories"]];
	self.tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
	self.title=NSLocalizedString(@"Add new contact",@"");
	
    
    UIBarButtonItem  *localsaveBtn = [[UIBarButtonItem alloc] 
									  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									  target:self action:@selector(save:)];
    
	localsaveBtn.enabled=NO;
	saveBtn = localsaveBtn;
	self.navigationItem.rightBarButtonItem = saveBtn;
	
    [localsaveBtn release];
	
	
	
	UIBarButtonItem  *cancelBtn = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								   target:self action:@selector(cancel:)];
    
	self.navigationItem.leftBarButtonItem = cancelBtn;
    [cancelBtn release];
	
    
	
	///tabbar btns
	
	UIBarButtonItem *phoneKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Phone"
																		style:UIBarButtonItemStyleDone
																	   target:self 
																	   action:@selector(changeKeboardType:)];
	phoneKeyboard.tag =0;
	UIBarButtonItem *mailKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Email"
												  style:UIBarButtonItemStyleDone
												 target:self 
																	   action:@selector(changeKeboardType:)];
	
	mailKeyboard.tag =1;
	UIBarButtonItem *urlKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"URL"
																		style:UIBarButtonItemStyleDone
																	   target:self 
																	   action:@selector(changeKeboardType:)];
	urlKeyboard.tag =2;
	
	
	//Use this to put space in between your toolbox buttons
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	NSArray *btns =[NSArray arrayWithObjects:phoneKeyboard,flexItem,mailKeyboard,flexItem,urlKeyboard,nil];
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	[toolbar setItems:btns];
	[toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[urlKeyboard release];
	[mailKeyboard release];
	[phoneKeyboard release];
	[flexItem release];
	
	
	tableModel = [[SCTableViewModel alloc] initWithTableView:self.tableView withViewController:self];
	SCTableViewSection *displaySection;
	if (!existing) {
	
     displaySection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Enter Details",@"")];
	
    SCTextFieldCell *nameCell = [SCTextFieldCell cellWithText:nil withPlaceholder:@"First & Last Name" withBoundKey:@"fln" withTextFieldTextValue:nil];
	[displaySection addCell:nameCell];

	restCell = [SCTextViewCell  cellWithText:nil withBoundKey:@"rest" withTextViewTextValue:nil];
	restCell.textView.inputAccessoryView =toolbar;
	restCell.textView.keyboardType = UIKeyboardTypePhonePad;
	restCell.detailTextLabel.numberOfLines=2;
	restCell.detailTextLabel.font=[UIFont systemFontOfSize:16];
	restCell.detailTextLabel.textColor=[UIColor lightGrayColor];
	restCell.detailTextLabel.text =@"Phone Numbers, Email Adressed and URL's";
	
	dataDetection = [[DataDetectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[dataDetection setDataDetection:detectionArr];

	displaySection.footerView = dataDetection;
	[displaySection addCell:restCell];
	}else {
		 displaySection = [SCTableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Set timer to",@"")];
		SCTableViewCell *nameCell = [SCTableViewCell cellWithText:person.compName];
		[displaySection addCell:nameCell];
		
	}

	timerSection = [SCTableViewSection section];
	
	TimerHeaderView *localTimerHeaderView  = [[TimerHeaderView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
	
	NSNumber *dayeLeft =[NSNumber numberWithInt:[defaults integerForKey:@"daysLeft"]];
	[localTimerHeaderView setTime:dayeLeft];
	timerHeaderView = localTimerHeaderView;
	timerSection.headerView = timerHeaderView;
	[localTimerHeaderView release];
	
	
	SCSliderCell *sliderCell = [SCSliderCell cellWithText:nil withBoundKey:@"sl" withSliderValue:dayeLeft];
	sliderCell.slider.maximumValue=[defaults floatForKey:@"maxDaysLeft"];
	sliderCell.slider.minimumValue=[defaults floatForKey:@"minDaysLeft"];
	sliderCell.slider.continuous=YES;
	
	sliderCell.slider.minimumValueImage = [UIImage imageNamed:@"emptyTimer.png"];
	sliderCell.slider.maximumValueImage = [UIImage imageNamed:@"fullTimer.png"];	
	
	[timerSection addCell:sliderCell];
	
	SCSegmentedCell *deletePolicyCell = [SCSegmentedCell cellWithText:nil withBoundKey:@"deletePolicy" withSelectedSegmentIndexValue:[NSNumber numberWithInt:0] withSegmentTitlesArray:[NSArray arrayWithObjects:@"Alert",@"Archive",@"Delete",nil]];
	
	[timerSection addCell:deletePolicyCell];
	timerSection.footerTitle = @"Sets the timer for the contact";
	[tableModel addSection:displaySection];
	[tableModel addSection:timerSection];
	
    
    SCTableViewSection *categoriesSection = [SCTableViewSection sectionWithHeaderTitle:nil];		
    NSString *categoryCellTitle;
    NSString *preCategory;
    NSNumber *preSelectedIndex;
    categoryCellTitle=  NSLocalizedString(@"Set category",@"");
    preCategory = NSLocalizedString(person.category_en,@"");
    preSelectedIndex = [NSNumber numberWithUnsignedInteger:[categories indexOfObject:preCategory]];
    
    SCSelectionCell *presetCategoriesCell = [SCSelectionCell cellWithText:categoryCellTitle withBoundKey:@"category" withSelectedIndexValue:preSelectedIndex withItems:categories];
    presetCategoriesCell.detailTableViewStyle = UITableViewStyleGrouped;
    presetCategoriesCell.label.text = preCategory;
    NSMutableArray * images = [[NSMutableArray alloc] init];
    UIImageView                         *imageView;
    for(int i=0;i<[categories count];i++){
        imageView=nil;
        imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[categories objectAtIndex:i]]];
        [images addObject:imageView];
        [imageView release];
    }
    presetCategoriesCell.detailCellsImageViews =images;
    presetCategoriesCell.tag=0;
    [tableModel addSection:categoriesSection];
    [categoriesSection addCell:presetCategoriesCell];
    
	detectionArr=[[NSMutableArray alloc] init];
    NSMutableDictionary *dic;
	NSInteger i = 0;
	while (i<4) {
		 dic = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:.3],[NSNumber numberWithInt:0],nil] forKeys:[NSArray arrayWithObjects:@"alpha",@"count",nil]];
		[detectionArr addObject:dic];
        i++;
	}	
    [dataDetection setDataDetection:detectionArr];
}


-(void)changeKeboardType:(id)sender
{
	UIButton *btn = (UIButton*)sender;
	switch (btn.tag) {
		case 1:
			[restCell.textView setKeyboardType:UIKeyboardTypeEmailAddress];
			break;
		case 2:
			[restCell.textView setKeyboardType:UIKeyboardTypeURL];
			break;
		case 3:
			[restCell.textView setKeyboardType:UIKeyboardTypeDefault];
			break;
			
		default:
			[restCell.textView setKeyboardType:UIKeyboardTypePhonePad];
			break;
	}
	[restCell.textView resignFirstResponder];
	[restCell.textView becomeFirstResponder];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside down
	if (!isIpad) {
		return (interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown);
	}
    return YES;
}

#pragma mark -
#pragma mark SCTableViewModelDelegate methods

- (void)tableViewModel:(SCTableViewModel *) tableViewModel valueChangedForRowAtIndexPath:(NSIndexPath *) indexPath
{
    NSDataDetector *dataDetector;
    NSArray *matches;
    NSString *note;
    
    BOOL mailDetected = NO;
    BOOL phoneDetected = NO;
    BOOL urlDetected = NO;
    BOOL noteDetected = NO;
    NSUInteger mailCount = 0;
    NSUInteger phoneCount = 0;
    NSUInteger urlCount = 0;
    NSString *urlString;
    NSString *subStringToCheck;
    NSURL *url;
    
	NSString *a = [tableModel.modelKeyValues valueForKey:@"fln"];
	NSString *data = [tableModel.modelKeyValues valueForKey:@"rest"];
	NSNumber *c = [tableModel.modelKeyValues valueForKey:@"sl"];
    NSLog(@" first data = %@",data);
	switch (indexPath.section) {
            
		case 0:
			switch (indexPath.row) {
				case 0:
					
					break;
				case 1:
                    
                    dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes error:nil];
                    matches = [dataDetector matchesInString:data options:0 range:NSMakeRange(0, [data length])];

                    note = data;
                    
                    for (NSTextCheckingResult *match in matches) {
                        if ([match resultType] == NSTextCheckingTypeLink) {
                                url = [match URL];
                                urlString = [url absoluteString];
                                subStringToCheck = [urlString substringToIndex:6];
                                 
                            if ([subStringToCheck isEqualToString:@"mailto"]) {
                                mailDetected=YES;
                                mailCount++;
								data = [data stringByReplacingOccurrencesOfString:
										[urlString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""] withString:@""];
								 NSLog(@"data = %@",data);
                            }else {
                                urlDetected=YES;
                                urlCount++;
								BOOL urlExist = [self webFileExists:url];
								NSLog(@"urlExist = %@",urlExist ? @"YES":@"NO");
                                data = [data stringByReplacingOccurrencesOfString:
										[urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""] withString:@""];
								 NSLog(@"data = %@",data);

                            }
                            
                        }else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                            NSString *phoneNumber = [match phoneNumber];
                            data = [data stringByReplacingOccurrencesOfString:phoneNumber withString:@""];
                            phoneDetected=YES;
                            phoneCount++;
                        }
                        
                        
                    }
                    NSError *error = NULL;
					NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:0 error:&error];
					NSUInteger numberOfMatches = [regex numberOfMatchesInString:data
																		options:0
																		  range:NSMakeRange(0, [data length])];
                    if(numberOfMatches>0){
                        person.note = data;
                        noteDetected=YES;
                       
                    }
                    
         
                    [[detectionArr objectAtIndex:0] setObject:[NSNumber numberWithFloat:phoneDetected ? 1:0.3] forKey:@"alpha"];
                    [[detectionArr objectAtIndex:1] setObject:[NSNumber numberWithFloat:mailDetected ? 1:0.3] forKey:@"alpha"];
                    [[detectionArr objectAtIndex:2] setObject:[NSNumber numberWithFloat:urlDetected ? 1:0.3] forKey:@"alpha"];
                    [[detectionArr objectAtIndex:3] setObject:[NSNumber numberWithFloat:noteDetected ? 1:0.3] forKey:@"alpha"];
                    [[detectionArr objectAtIndex:0] setObject:[NSNumber numberWithInt:phoneCount] forKey:@"count"];
                    [[detectionArr objectAtIndex:1] setObject:[NSNumber numberWithInt:mailCount] forKey:@"count"];
                    [[detectionArr objectAtIndex:2] setObject:[NSNumber numberWithInt:urlCount] forKey:@"count"];
                    [dataDetection setDataDetection:detectionArr];
                    
                    
                    
                    
                    data=nil;
                    
                    
					break;
			}
			
			break;
			
		case 1:
			[timerHeaderView setTime:c];
			break;

	}
	
	if([a length]>0||[tableModel.modelKeyValues valueForKey:@"rest"]||existing){
		saveBtn.enabled=YES;
	}else if(!existing){
		saveBtn.enabled=NO;
	}
	if ([tableModel.modelKeyValues valueForKey:@"rest"]==0) {
		restCell.detailTextLabel.text =@"Phone Numbers, Email Adressed and URL's";
	}else {
		restCell.detailTextLabel.text =@"";
	}

}


// Now handle the willConfigureCell method
- (void)tableViewModel:(SCTableViewModel *)tableViewModel willConfigureCell:(SCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
  
	

}



- (void)tableViewModel:(SCTableViewModel *) tableViewModel willDisplayCell:(SCTableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath
{
	//cell.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"phone.png"]];
    //cell.imageView.image = [UIImage imageNamed:@"phone.png"];
	cell.height = 44;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor =[UIColor clearColor];
	
	if (existing && indexPath.section==0) {
		[TableViewDesignFunctions setTransparentBgToCell:cell];

	}
}

-(BOOL) webFileExists:(NSURL*)url {
	
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSLog(@"statusCode = %d", [response statusCode]);
	
	if ([response statusCode] == 404)
		return NO;
	else
		return YES;
}

- (void)save:(id)sender {
		ABRecordRef ref;
		CFErrorRef error = NULL; 
		ABAddressBookRef addressbook = ABAddressBookCreate();
	
	
	if (!existing) {
		ref = ABPersonCreate();
		NSString *name = [tableModel.modelKeyValues valueForKey:@"fln"];
		NSString *data = [tableModel.modelKeyValues valueForKey:@"rest"];
		
		if ([name length]>0) {
			person.compName=name;
			ABRecordSetValue(ref, kABPersonCompositeNameFormatFirstNameFirst, name, &error);
			person.firstLetter=[[name substringToIndex:1]capitalizedString];
		}else{
            person.compName=@"No Name";
            person.firstLetter = @"#";
        }

		if (data!=nil) {
			
			NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllSystemTypes error:nil];
			NSArray *matches = [dataDetector matchesInString:data options:0 range:NSMakeRange(0, [data length])];
			ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMutableMultiValueRef multiMail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			ABMutableMultiValueRef multiUrl = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			NSString *note = data;
			
			for (NSTextCheckingResult *match in matches) {
				if ([match resultType] == NSTextCheckingTypeLink) {
					NSURL *url = [match URL];
					NSString *urlString = [url absoluteString];
					NSString *subStringToCheck = [urlString substringToIndex:6];
					note = [data stringByReplacingOccurrencesOfString:[url absoluteString] withString:@""];

					if ([subStringToCheck isEqualToString:@"mailto"]) {
						ABMultiValueAddValueAndLabel(multiMail,[urlString substringFromIndex:7] ,kABWorkLabel, NULL);
						ABRecordSetValue(ref, kABPersonEmailProperty, multiMail,nil);
						
					}else {
						
						ABMultiValueAddValueAndLabel(multiUrl,urlString,kABPersonHomePageLabel, NULL);
						ABRecordSetValue(ref, kABPersonURLProperty, multiUrl,nil);
					}

				}else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
					NSString *phoneNumber = [match phoneNumber];
					
					ABMultiValueAddValueAndLabel(multiPhone, phoneNumber,kABPersonPhoneMainLabel, NULL);
					ABRecordSetValue(ref, kABPersonPhoneProperty, multiPhone,NULL);
					data = [data stringByReplacingOccurrencesOfString:phoneNumber withString:@""];
				}
				
				
			}
			CFRelease(multiPhone);
			CFRelease(multiMail);
			CFRelease(multiUrl);
			
			if([data length]>0){
			ABRecordSetValue(ref, kABPersonNoteProperty, person.note, &error);
            }
			
            data=nil;
			
			

		}
		
	}else {
		ref = ABAddressBookGetPersonWithRecordID(addressbook,[person.ID intValue]);

	}

        person.category=NSLocalizedString(@"No Category",@"");
        person.category_en=@"No Category";
		//set default image;
		[GlobalFunctions setCategoryImageToPerson:@"No Category_B" Ref:ref];
		NSDictionary *datesDic = [NSDictionary dictionaryWithDictionary:[GlobalFunctions setDefaultTimerSettingsToPerson:ref]];
		person.ddate=[datesDic objectForKey:@"deletionDate"];
		person.deletion_policy = [datesDic objectForKey:@"deletionPolicy"];
		person.state = [datesDic objectForKey:@"state"];
		
		ABAddressBookAddRecord(addressbook, ref, &error);
		ABRecordRef HiByeGroup = ABAddressBookGetGroupWithRecordID(addressbook, hiByeGroupId);
		BOOL didAdd = ABGroupAddMember(HiByeGroup,ref,&error);
	
		if (!didAdd) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error while adding person to HiBye group %@", &error);
			exit(-1);  // Fail
		}
		
		BOOL didSave = ABAddressBookSave(addressbook, &error);
	
		if (!didSave) {
		// Update to handle the error appropriately.
			NSLog(@"Unresolved error while saving address book%@", &error);
			exit(-1);  // Fail
		}
		
        ABRecordID ID = ABRecordGetRecordID(ref);
        NSInteger recordID = (NSInteger)ID;
        person.ID =[NSNumber numberWithInt:recordID];
		
	
		CFRelease(ref);
		//CFRelease(addressbook);
		
		[delegate addViewController:self didFinishWithSave:YES];

}



- (void)cancel:(id)sender {
	
	[delegate addViewController:self didFinishWithSave:NO];
}



- (void)dealloc {
	[toolbar release];
	[detectionArr release];
	[timerHeaderView release];
    [super dealloc];
}


@end

