    //
//  PersonSortedByFirstNameDataSource.m
//  HiBye
//
//  Created by shani hajbi on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "PersonSortedByFirstNameDataSource.h"
#import "PersonsDataSourceProtocol.h"
#import "HiByeAppDelegate.h"
#import "GlobalFunctions.h"

@implementation PersonSortedByFirstNameDataSource
// ElementsDataSourceProtocol methods

// return the data used by the navigation controller and tab bar item

-init{
   return self;
}

- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
}

- (NSString *)navigationBarName {
	
	return NSLocalizedString(@"HiBye", @"");
}

- (NSString *)name {
	return NSLocalizedString(@"HiBye", @"");;
}

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (BOOL)isIpad{	
	return [GlobalFunctions isDeviceAniPad];
}


- (BOOL)showDisclosureIcon
{
	return YES;
}

-(NSString*)keyName{
    return @"firstLetter";
}
-(NSString*)nameKeyPath{
    return @"uppercaseFirstLetterOfName";
}

-(NSString*)perdicateForTableView{
    return  @"state !=-1";
}

-(HiByeAppDelegate*)appDelegate{

    return [[UIApplication sharedApplication]delegate];
}


-(NSInteger)hibyeGroupId{
	
    return[[self appDelegate]hiByeGroupId];
}

-(NSManagedObjectContext*)currentManagedObjectContext{
	
    return [[self appDelegate] managedObjectContext];
}



-(NSString*)entityName{
    return @"Person";
}

- (void) saveContext{
    
    [[self appDelegate] saveAction:self];
}




@end
