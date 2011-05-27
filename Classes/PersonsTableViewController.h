//
//  PersonsTableViewController.h
//  HiBye
//
//  Created by shani hajbi on 9/20/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "PersonsDataSourceProtocol.h"
#import "PersonViewController.h"
#import "Settings.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ArchivedPersonDeatails.h"
#import "AddViewController.h"
#import "TISwipeableTableView.h"
#import "PersonCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@protocol PersonViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end

@class Person;


@interface PersonsTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
																	NSFetchedResultsControllerDelegate,UIActionSheetDelegate,
																	ABPeoplePickerNavigationControllerDelegate,
																	ABPersonViewControllerDelegate,PersonViewControllerDelegate,SettingsDelegate,
																	ArchivedPersonDeatailsDelegate,AddViewControllerDelegate,
																	UISearchBarDelegate,UISearchDisplayDelegate,ADBannerViewDelegate,
TISwipeableTableViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,PersonCellDelegate,UINavigationControllerDelegate> {
    
   
																		
	id<PersonsDataSource> dataSource;
	UIToolbar	*myToolbar;
	ADBannerView *banner;
	UIView *contentView;																															
	UITableView                         *theTableView;
	NSManagedObjectContext             *addingManagedObjectContext;	   
    NSFetchedResultsController          *fetchedResultsController;
    ABPeoplePickerNavigationController  *pickPersonPicker;
    UISegmentedControl                  *segmentedControl ;
	BOOL	transitioning;
	BOOL								isIpad;
	BOOL isArchive;
	NSInteger hibyeGroupId;
	UISearchDisplayController			*searchDisplayController;
	UISearchBar							*searchBar;
	NSMutableArray *mainitems;	
	NSMutableArray	*archiveitems;
	NSMutableArray *activeIndexPaths;
	NSUserDefaults *defaults;

	
}
@property(nonatomic, retain)  ADBannerView *banner;	
@property(nonatomic, retain)  UIView *contentView;	
@property (nonatomic,retain) UISearchDisplayController			*searchDisplayController;
@property (nonatomic,retain) UISearchBar						*searchBar;
@property  (nonatomic, retain) UIToolbar	*myToolbar;
@property  (nonatomic, retain) NSMutableArray *activeIndexPaths;

@property (nonatomic,retain) NSManagedObjectContext             *addingManagedObjectContext;	   
@property (nonatomic,retain) NSFetchedResultsController         *fetchedResultsController;
@property (nonatomic,retain) UITableView                        *theTableView;
@property (nonatomic,retain) id<PersonsDataSource>        dataSource;
@property (nonatomic,retain) ABPeoplePickerNavigationController *pickPersonPicker;
@property (nonatomic,retain) UISegmentedControl                  *segmentedControl ;

- (void)configureCell:(PersonCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (id)initWithDataSource:(id<PersonsDataSource>)theDataSource;
-(void)showPeoplePickerController;
-(void)createADBannerView;
-(void)layoutForCurrentOrientation:(BOOL)animated;
- (void)addPerson:(NSInteger)recoreId name:(NSString*)compName existing:(BOOL)existing;
@end

