//
//  LimboPersonDeatails.h
//  HiBye
//
//  Created by shani hajbi on 5/31/10.
//  Copyright 2010 shannoga. All rights reserved.
//
@protocol ArchivedPersonDeatailsDelegate;

#import <UIKit/UIKit.h>
#import "Person.h"
#import "PersonViewController.h"

@interface ArchivedPersonDeatails : UIViewController <UIActionSheetDelegate,PersonViewControllerDelegate>{
	id <ArchivedPersonDeatailsDelegate> delegate;

	Person					*person;
	NSMutableArray          *categories;
	NSUserDefaults			*defaults;
	NSInteger				rawCount; 
	BOOL					isIpad;
	NSInteger				hiByeGroupId;
	
}
-(void)restorePerson:(NSInteger)btnId;
-(void) restoreOptions;
-(void)removeFromContext;

@property (nonatomic, assign) id <ArchivedPersonDeatailsDelegate> delegate;
@property (nonatomic, retain) Person					*person;
@property (nonatomic) NSInteger				hiByeGroupId;
@end

@protocol ArchivedPersonDeatailsDelegate
- (void)archivedPersonDeatails:(ArchivedPersonDeatails *)controller didFinishWithRestore:(BOOL)restore withPerson:(NSManagedObject*)person;
@end




