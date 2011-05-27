//
//  CustumeCategories.h
//  HiBye
//
//  Created by shani hajbi on 10/25/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//
@protocol CustumeCategoriesDelegate;


#import <UIKit/UIKit.h>





@interface CustumeCategories : UITableViewController<UITextFieldDelegate> {
    id <CustumeCategoriesDelegate>   delegate;
    NSMutableArray *categories;
    UITextField		*textFieldRounded;
    BOOL addedCell;
	BOOL isIpad;

}
@property (nonatomic,assign) id <CustumeCategoriesDelegate>   delegate;
@property (nonatomic,retain) NSMutableArray *categories;
@property (nonatomic,retain) UITextField *textFieldRounded;
@property BOOL isIpad;

-(void)updateTesxtFielsdTags;

@end



@protocol CustumeCategoriesDelegate


- (void)custumeCategories:(CustumeCategories *)controller didFinishWithArray:(NSMutableArray*)categoriesArray ;

@end