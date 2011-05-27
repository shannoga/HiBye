

#import "PersonTileView.h"
#import "Person.h"


@implementation PersonTileView
@synthesize person;

+ (CGSize)preferredViewSize {
	return CGSizeMake(50,44);
}


- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
		person = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
 
- (void)drawRect:(CGRect)rect {
	//CGPoint point;
	// get the image that represents the element physical state and draw it
    NSString *img = [NSString stringWithFormat:@"%@.png", person.category_en];
    UIImage *backgroundImage = [UIImage imageNamed:img];
    
	CGRect personCategoryRectangle = CGRectMake((55-[backgroundImage size].width)/2 ,(44-[backgroundImage size].height)/2, [backgroundImage size].width, [backgroundImage size].height);
	[backgroundImage drawInRect:personCategoryRectangle];
    
	
	[[UIColor blackColor] set];
	
	// draw the categoryName
	//UIFont *font = [UIFont boldSystemFontOfSize:10  ];
   //CGSize stringSize = [person.category sizeWithFont:font];
	//point = CGPointMake((70-stringSize.width)/2 ,30);
	//[person.category  drawAtPoint:point withFont:font];
	

}


- (void)dealloc {
	[person release];
	[super dealloc];
}


@end
