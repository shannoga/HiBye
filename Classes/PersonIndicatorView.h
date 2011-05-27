//
//  PersonIndicatorView.h
//  HiBye
//
//  Created by shani hajbi on 10/23/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//


#import <UIKit/UIKit.h>

@class Person;

@interface PersonIndicatorView : UIView {
	Person *person;
}

@property (nonatomic, retain) Person *person;

+ (CGSize)preferredViewSize;

@end
