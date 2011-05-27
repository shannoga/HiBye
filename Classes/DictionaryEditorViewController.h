//
//  DictionaryEditorViewController.h
//  Samples App
//
//  Copyright 2010 Sensible Cocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTableViewModel.h"

@interface DictionaryEditorViewController : UITableViewController <SCTableViewModelDataSource, SCTableViewModelDelegate> {
	
	SCTableViewModel *tableModel;
	
	NSMutableArray *arrayOfDictionaries;
}

@end
