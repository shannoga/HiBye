

#import <UIKit/UIKit.h>

@class Person;

@interface PersonTileView : UIView {
	Person *person;
}
 
@property (nonatomic, retain) Person *person;

+ (CGSize)preferredViewSize;

@end
