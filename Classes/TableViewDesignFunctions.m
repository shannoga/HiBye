//
//  TableViewDesignFunctions.m
//  HiBye
//
//  Created by shani hajbi on 9/11/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "TableViewDesignFunctions.h"


@implementation TableViewDesignFunctions



+(void)setTableViewDesign:(UITableView*)tableView{

[tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
// Configure the table view.
tableView.rowHeight = 44 ;
//searchDisplayController.searchResultsTableView.rowHeight = 44;
tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//[tableView.searchDisplayController.searchResultsTableView setSeparatorColor:[UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:163.0/255.0 alpha:.5]];
//[tableView.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]]];
//tableView.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//tableView.clearsSelectionOnViewWillAppear = NO;
tableView.scrollEnabled = YES;
}

+(void)setCellDesign:(UITableViewCell*)cell{
    
    
    
    UIImageView* img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gBg.png"]];
    [cell setBackgroundView:img];
    [img setImage:[UIImage imageNamed:@"body.png"]];
    
    [cell setSelectedBackgroundView:img];
    [img release];
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:17];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.shadowColor = [UIColor darkGrayColor];
    cell.textLabel.shadowOffset = CGSizeMake(0, -1);
    cell.textLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"body.png"]];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
} 

+(void)setCellDesignForGrouped:(UITableViewCell*)cell{
    
    UIView *backgroundView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    backgroundView1.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backgroundView1;
    [backgroundView1 release];
    
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:20];
    cell.textLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:69.0/255.0 alpha:1];
    cell.textLabel.shadowColor = [UIColor whiteColor];
    cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
} 

+(void)setCellBgForGrouped:(UITableViewCell*)cell imageName:(NSString*)imageName {
    
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [img setClipsToBounds:YES];
    [cell setBackgroundView:img];
    [img release];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}


+(void)setTransparentBgToCell:(UITableViewCell*)cell{
		UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
		backgroundView.backgroundColor = [UIColor clearColor];
		cell.backgroundView = backgroundView;
		[backgroundView release];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

@end