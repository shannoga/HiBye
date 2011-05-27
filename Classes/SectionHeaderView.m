

#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SectionHeaderView


@synthesize titleLabel, section;


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}


-(id)initWithFrame:(CGRect)frame title:(NSString*)title{
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor lightGrayColor];
		UIFont *font =  [UIFont fontWithName:@"Futura" size:14];
        //CGSize stringSize = CGSizeFromString(title);
     
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 100.0;
		titleLabelFrame.origin.y += 5.0;
        titleLabelFrame.size.width -= 5.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.text =  [title capitalizedString];
        titleLabel.font = font;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
	
		 
        /*
        // Set the colors for the gradient layer.
        static NSMutableArray *colors = nil;
        if (colors == nil) {
            colors = [[NSMutableArray alloc] initWithCapacity:3];
            UIColor *color = nil;
            color = [UIColor colorWithRed:149.0/255.0 green:197.0/255.0 blue:221.0/255.0 alpha:1];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:149.0/255.0 green:197.0/255.0 blue:221.0/255.0 alpha:.7];
            [colors addObject:(id)[color CGColor]];
            color = [UIColor colorWithRed:149.0/255.0 green:197.0/255.0 blue:221.0/255.0 alpha:.8];
            [colors addObject:(id)[color CGColor]];
        }
        [(CAGradientLayer *)self.layer setColors:colors];
        [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.48], [NSNumber numberWithFloat:1.0], nil]];
        
	*/
		
		
		
    }
    
    return self;
}




- (void)dealloc {
    [titleLabel release];
    [super dealloc];
}


@end
