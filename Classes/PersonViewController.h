//
//  PersonViewController.h
//  HiBye
//
//  Created by shani hajbi on 9/14/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"
#import "Person.h"
#import "TimerHeaderView.h"


@protocol PersonViewControllerDelegate;

@class Person;

@interface PersonViewController : UIViewController <SCTableViewModelDelegate,UIActionSheetDelegate,ADBannerViewDelegate>{
        id <PersonViewControllerDelegate>    delegate;
        Person								*person;
		NSUndoManager						*undoManager;
        SCTableViewModel                    *tableModel;
        NSMutableArray                      *categories;
		
		SCTableViewCell                     *HedearCell;
        SCLabelCell                         *timerCell;
        UIImageView                         *imageView;
		NSArray								*actionSheetTitelsArray;
		UINavigationBar						*navigationBar;
		UIToolbar							*myToolbar;
		TimerHeaderView						*timerHeaderView;
		NSUserDefaults						*defaults;
		UITableView							*theTableView;
		BOOL								justShowed;
		BOOL								isIpad;
		BOOL								didSaveChanges;
		ADBannerView *banner;
		UIView *contentView;
	
}


@property (nonatomic, assign) id <PersonViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray			*actionSheetTitelsArray;
@property (nonatomic, retain) Person			*person;
@property (nonatomic, retain) NSUndoManager		*undoManager;
@property (nonatomic, retain) UIToolbar			*myToolbar;
@property (nonatomic, retain) UITableView		*theTableView;
@property (nonatomic, retain) UINavigationBar	*navigationBar;
@property BOOL									isIpad;
@property(nonatomic, retain)  UIView *contentView;	
@property(nonatomic, retain)  ADBannerView *banner;


-(void)setActionSheet:(id)sender;
-(void)setUpUndoManager;
-(void)cleanUpUndoManager;
-(void)updateRightBarButtonItemState;

-(void)layoutForCurrentOrientation:(BOOL)animated;
-(void)createADBannerView;
@end

@protocol PersonViewControllerDelegate
@optional

//called when new person added
- (void)personViewController:(PersonViewController *)controller didFinishWithSave:(BOOL)save;
- (void)personViewController:(PersonViewController *)controller didFinishWithAdd:(BOOL)save;

//called when a person is restored back from time out list
- (void)personViewController:(PersonViewController *)controller  didFinishWithChange:(BOOL)save person:(Person*)person withAction:(NSInteger)actionIndex;

- (void)personViewController:(PersonViewController *)controller didLengthPersonTimer:(BOOL)length person:(Person*)personToRepaste personIndex:(NSIndexPath*)indexPath;
@end