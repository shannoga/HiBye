//
//  PersonIndicatorView.m
//  HiBye
//
//  Created by shani hajbi on 10/23/10.
//  Copyright (c) 2010 shani hajbi. All rights reserved.
//

#import "PersonIndicatorView.h"
#import "Person.h"


@implementation PersonIndicatorView

@synthesize person;

+ (CGSize)preferredViewSize {
	return CGSizeMake(44,44);
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		person = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    // get the image that represents the element physical state and draw it
    if(person){
    NSString *img = [NSString stringWithFormat:@"%@.png", person.state];
    UIImage *backgroundImage = [UIImage imageNamed:img];
    
	CGRect personCategoryRectangle = CGRectMake((44-[backgroundImage size].width)/2 ,
												(44-[backgroundImage size].height)/2,
												[backgroundImage size].width,
												[backgroundImage size].height);
	[backgroundImage drawInRect:personCategoryRectangle];
	}
    
}


- (void)dealloc {
	[person release];
	[super dealloc];
}


@end
