//
//  BSCacheViewController.h
//  BookSystem
//
//  Created by Stan Wu on 3/2/13.
//
//

#import <UIKit/UIKit.h>
#import "WhiteRaccoon.h"

@interface BSCacheViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,WRRequestDelegate>{
    UITableView *tvCache;
    
    BOOL isServerCache;
    NSMutableDictionary *dicCache;
}
@property (nonatomic,strong) NSMutableArray *aryCache;
@property (nonatomic,strong) NSMutableDictionary *dicCache;

@end
