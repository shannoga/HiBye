//
//  TableViewDesignFunctions.h
//  HiBye
//
//  Created by shani hajbi on 9/11/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TableViewDesignFunctions : NSObject {

}


+(void)setCellDesign:(UITableViewCell*)cell;
+(void)setTableViewDesign:(UITableView*)tableView;
+(void)setCellDesignForGrouped:(UITableViewCell*)cell;
+(void)setCellBgForGrouped:(UITableViewCell*)cell imageName:(NSString*)imageName;
+(void)setTransparentBgToCell:(UITableViewCell*)cell;

@end
