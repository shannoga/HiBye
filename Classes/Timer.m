//
//  Timer.m
//  HiBye
//
//  Created by shani hajbi on 1/12/11.
//  Copyright 2011 shani hajbi. All rights reserved.
//

#import "Timer.h"
#import <QuartzCore/QuartzCore.h>

@implementation Timer


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor=[UIColor clearColor];
        // Initialization code.
		
		//UIImage *masker1 = [UIImage imageNamed:@"Traveling.png"];
		//UIImage *masker2 = [UIImage imageNamed:@"Professionals_B.png"];
		//UIImageView *m = [[UIImageView alloc] initWithImage:[self maskImage:masker2 withMask:masker1]];
		//m.backgroundColor=[UIColor clearColor];
		//m.frame = CGRectMake(0, 0, masker1.size.width, masker1.size.height);
		//[self addSubview:m];
        NSLog(@"shani");
    }
    return self;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
	CGImageRef maskRef = maskImage.CGImage; 
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
 CAShapeLayer  *shapeLayer = [CAShapeLayer layer];

	
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGPathAddEllipseInRect(cgPath, NULL, CGRectMake(0, 0, 300, 300));
	CGPathAddEllipseInRect(cgPath, NULL, CGRectMake(50, 50, 200, 200));
	
	// Now create the UIBezierPath object
	UIBezierPath* aPath = [UIBezierPath bezierPath];
	aPath.CGPath = cgPath;
	aPath.usesEvenOddFillRule = YES;
	
	// After assigning it to the UIBezierPath object, you can release
	// your CGPathRef data type safely.
	CGPathRelease(cgPath);
	
 shapeLayer.path = cgPath;
 UIColor *fillColor = [UIColor colorWithHue:0.625 saturation:0.4 brightness:0.5 alpha:1.0];
 shapeLayer.fillColor = fillColor.CGColor;
 UIColor *strokeColor = [UIColor colorWithHue:0.625 saturation:0.4 brightness:0.9 alpha:1.0];
 shapeLayer.strokeColor = strokeColor.CGColor;
 shapeLayer.lineWidth = 2.0;
 shapeLayer.fillRule = kCAFillRuleNonZero;
 [self.layer addSublayer:shapeLayer];
}


- (void)dealloc {
    [super dealloc];
}


@end
