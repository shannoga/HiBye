//
//  ArchivedPersonView.h
//  HiBye
//
//  Created by shani hajbi on 1/9/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface ArchivedPersonView : UIScrollView {

	Person *person;
}

@property (nonatomic, retain) Person *person;

@end
