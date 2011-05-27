//
//  PersonsDataSourceProtocol.h
//  HiBye
//
//  Created by shani hajbi on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "HiByeAppDelegate.h"
@protocol PersonsDataSource<NSObject> 

	@required
	
	// these properties are used by the view controller
	// for the navigation and tab bar
    @property (readonly) NSString                *name;
    @property (readonly) NSString                *navigationBarName;
    @property (readonly) NSInteger               hibyeGroupId;
   // @property (readonly) BOOL                    isShortPersonView;
    @property (readonly) NSManagedObjectContext *currentManagedObjectContext;
  
    @property (readonly) NSString               *entityName;
    @property (readonly) NSString               *keyName;
    @property (readonly) NSString               *nameKeyPath;
	@property (readonly) NSString   *perdicateForTableView;
	// this property determines the style of table view displayed
	@property (readonly) UITableViewStyle       tableViewStyle;
    @property (readonly) HiByeAppDelegate        *appDelegate;
	

	- (BOOL)isIpad;
    

	
	@optional
	
	// this optional protocol allows us to send the datasource this message, since it has the 
	// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void) saveContext;

	@end
