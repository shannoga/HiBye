//
//  TimerHeaderView.h
//  HiBye
//
//  Created by shani hajbi on 1/12/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimerHeaderView : UIView {
	
	UILabel *lbl;
	NSString *formattedTimer;
	NSNumberFormatter *formater;
}

@property (nonatomic, retain)UILabel *lbl;
@property (nonatomic, retain)NSString *formattedTimer;
- (void)setTime:(NSNumber *)aTime;
@end
