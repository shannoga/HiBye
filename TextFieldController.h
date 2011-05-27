

#import <UIKit/UIKit.h>

@interface TextFieldController : UITableViewController <UITextFieldDelegate>
{

	UITextField		*textFieldRounded;
	
		
	NSArray			*dataSourceArray;
}

@property (nonatomic, retain, readonly) UITextField	*textFieldRounded;


@property (nonatomic, retain) NSArray *dataSourceArray;

@end
