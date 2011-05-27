//
//  PersonCell.h
//  SwipeableExample
//
//  Created by Tom Irving on 16/06/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
@protocol PersonCellDelegate;

#import <Foundation/Foundation.h>
#import "TISwipeableTableView.h"


@class PersonsTableViewController;
@class Person;
@interface PersonCell : TISwipeableTableViewCell<UIActionSheetDelegate> {
	id <PersonCellDelegate>    delegate;
	Person * person;
	UIView *backViewUIHolder;
	NSMutableArray						*recipientsArray;
	PersonsTableViewController *mainController;

}
@property (nonatomic, retain) id <PersonCellDelegate>   delegate;
@property (nonatomic, retain) Person * person;
@property (nonatomic, retain) UIView *backViewUIHolder;

- (void)drawShadowsWithHeight:(CGFloat)shadowHeight opacity:(CGFloat)opacity InRect:(CGRect)rect forContext:(CGContextRef)context;

@end


@protocol PersonCellDelegate
@optional

//called when new person added
- (void)personCell:(PersonCell *)controller displayMailComposerSheet:(NSString*)recipient;
- (void)personCell:(PersonCell *)controller displaySMSComposerSheet:(NSString*)recipient;
-(void)createEvent;

@end