

#import <Foundation/Foundation.h>



@interface SectionHeaderView : UIView {
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger section;


-(id)initWithFrame:(CGRect)frame title:(NSString*)title;
@end

