//
//  HiByeAppDelegate.h
//  HiBye
//
//  Created by shani hajbi on 10/20/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HiByeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow                            *window;
	UINavigationController				*navigationController;
    NSManagedObjectContext              *managedObjectContext;
    NSManagedObjectModel                *managedObjectModel;
    NSPersistentStoreCoordinator        *persistentStoreCoordinator;
	NSUserDefaults						*defaults;
	NSNumberFormatter					*formatter;
	 NSInteger                        hiByeGroupId;
   
}

@property (nonatomic, retain)  UIWindow                         *window;
@property (nonatomic, retain) UINavigationController				*navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator    *persistentStoreCoordinator;
@property                               NSInteger                        hiByeGroupId;

- (NSString *)applicationDocumentsDirectory;
- (void) updateStore;
- (void) CheckForHiByeGroup;
- (void)setupPortraitUserInterface;
- (void)saveAction:(id)sender;
@end
