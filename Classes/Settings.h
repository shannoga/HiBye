//
//  Settings.h
//  HiBye
//
//  Created by shani hajbi on 9/13/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

@protocol SettingsDelegate;


    
#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import <CoreData/CoreData.h>
#import "CustumeCategories.h"
#import "TimerHeaderView.h"
@interface Settings : UITableViewController<SCTableViewModelDelegate,CustumeCategoriesDelegate> {
    id <SettingsDelegate>   delegate;
    SCTableViewModel        *tableModel;
    NSMutableArray          *numbers;
    UIImageView             *imageView;
    NSUserDefaults          *settings;
    SCLabelCell             *defaultTimerCell;
    NSMutableArray          *categories;
    NSMutableSet           *selectedIndexes;
    NSMutableArray          *activeCategories;
	NSMutableArray         *custumeCategories;
    NSManagedObjectContext  *managedObjectContext;
	BOOL					isIpad;
	NSUserDefaults			*defaults;
	NSDictionary			*categoriesDic;
	TimerHeaderView *timerHeaderView;
	SCSliderCell *sliderCell;

}

@property (nonatomic, assign) id <SettingsDelegate> delegate;

@property (nonatomic,retain)  NSMutableArray   *activeCategories;
@property (nonatomic,retain)  NSMutableArray   *custumeCategories;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property BOOL					isIpad;
@end

@protocol SettingsDelegate

- (void)settings:(Settings *)controller didFinishWithSave:(BOOL)save ;

@end