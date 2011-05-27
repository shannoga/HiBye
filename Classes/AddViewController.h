//
//  AddViewController.h
//  HiBye
//
//  Created by shani hajbi on 10/31/10.
//  Copyright 2010 shani hajbi. All rights reserved.
//


	
	@protocol AddViewControllerDelegate;
	
	
    
#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import <CoreData/CoreData.h>
#import "CustumeCategories.h"
#import "Person.h"
#import "TimerHeaderView.h"
#import "DataDetectionView.h"

	@interface AddViewController : UITableViewController<SCTableViewModelDelegate,UITextFieldDelegate> {
		id <AddViewControllerDelegate>   delegate;
		SCTableViewModel        *tableModel;
		UIBarButtonItem			*saveBtn;
		BOOL					isIpad;
		NSMutableArray		*detectionArr;
		Person					*person;
		SCTableViewSection		*timerSection;
		TimerHeaderView			*timerHeaderView;
		UIToolbar				*toolbar;
		SCTextViewCell			*restCell;
		NSInteger				hiByeGroupId;
		NSUserDefaults			*defaults;
		BOOL					existing;
		DataDetectionView		*dataDetection;
		
	}
	
	@property (nonatomic, assign) id <AddViewControllerDelegate>	delegate;
	@property (nonatomic, retain) UIBarButtonItem					*saveBtn;
	@property (nonatomic, retain) Person							*person;
	@property (nonatomic, retain) TimerHeaderView					*timerHeaderView;
	@property (nonatomic, retain) UIToolbar							*toolbar;
	@property (nonatomic, retain) NSMutableArray				*detectionArr;
	@property (nonatomic) NSInteger									hiByeGroupId;
	@property BOOL													isIpad;

- (id)initWithPerson:(Person*)personToAdd;
-(BOOL) webFileExists:(NSURL*)url;
@end
	

@protocol AddViewControllerDelegate
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save;	
@end
	
