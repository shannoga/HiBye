//
//  DataDetectionView.h
//  HiBye
//
//  Created by shani hajbi on 1/30/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataDetectionView : UIView {
	float phoneAlpha;
	float mailAlpha;
	float urlAlpha;
	float noteAlpha;
	NSNumber *phoneCount;
	NSNumber *mailCount;
	NSNumber *urlCount;
}

-(void)setDataDetection:(NSMutableArray*)arr;
@end
