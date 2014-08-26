//
//  BSCacheViewController.m
//  BookSystem
//
//  Created by Stan Wu on 3/2/13.
//
//

#import "BSCacheViewController.h"
#import "BSDataProvider.h"
#import "SVProgressHUD.h"

@interface BSCacheViewController ()

@end

@implementation BSCacheViewController
@synthesize aryCache,dicCache;

- (void)viewDidLoad
{
    [super viewDidLoad];//540 620
	// Do any additional setup after loading the view.
    isServerCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"CacheOnServer"];
    self.dicCache = [NSMutableDictionary dictionary];
    
    self.navigationItem.title = @"菜品暂存";
    //    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(releaseSelf)] autorelease];
    [self addNavButtonWithTitle:@"完成" atPosition:SWNavItemPositionLeft action:@selector(releaseSelf)];
    
    
    NSDictionary *current = [BSDataProvider currentOrder];
    if ([current objectForKey:@"name"])
        [self addNavButtonWithTitle:@"保存修改" atPosition:SWNavItemPositionRight action:@selector(savecurrentClicked)];
    else
        [self addNavButtonWithTitle:@"暂存当前菜品" atPosition:SWNavItemPositionRight action:@selector(saveClicked)];
    
    tvCache = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20)];
    tvCache.delegate = self;
    tvCache.dataSource = self;
    [self.view addSubview:tvCache];
    [tvCache release];
    
    if (isServerCache)
        [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    NSLog(@"111");
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
//}

- (void)loadData{
    @autoreleasepool {
        
    }
}

- (void)savecurrentClicked{
    NSArray *ary = [[BSDataProvider sharedInstance] orderedFood];
    if (ary.count>0){
        NSDictionary *current = [BSDataProvider currentOrder];
        if (isServerCache)
            [self saveFoods:[current objectForKey:@"foods"] withName:[current objectForKey:@"name"]];
        else
            [BSDataProvider saveFoods:[current objectForKey:@"foods"] withName:[current objectForKey:@"name"]];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrder"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self addNavButtonWithTitle:@"暂存当前菜品" atPosition:SWNavItemPositionRight action:@selector(saveClicked)];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"已点菜品为空，无法保存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"保存", nil];
        [alert show];
        [alert release];
    }
    
}

- (void)saveClicked{
    NSArray *ary = [[BSDataProvider sharedInstance] orderedFood];
    if (ary.count>0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入暂存的名字" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        [alert release];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您还没有点菜，菜品列表为空，无法保存" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)releaseSelf{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    //    [self performSelector:@selector(release) withObject:nil afterDelay:0.5f];
}


#pragma mark -  UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"保存"]){
        UITextField *tf = [alertView textFieldAtIndex:0];
        NSString *name = tf.text;
        
        if (name.length>0){
            BOOL isExist = isServerCache?[self isCacheNameExist:name]:[BSDataProvider isCacheNameExist:name];
            if (isExist){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"当前名称已被使用，请重新输入一个名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
                [alert show];
                [alert release];
            }else{
                if (isServerCache)
                    [self saveFoods:[[BSDataProvider sharedInstance] orderedFood] withName:tf.text];
                else
                    [BSDataProvider saveFoods:[[BSDataProvider sharedInstance] orderedFood] withName:tf.text];
                
                [tvCache reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存失败" message:@"请为菜品暂存输入一个名称，方便您下次导入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }else if ([buttonTitle isEqualToString:@"确定"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入暂存的名字" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        [alert release];
    }
}

#pragma mark - UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CacheCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    
    NSDictionary *info = [(isServerCache?[self cachedFoodList]:[BSDataProvider cachedFoodList])objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[info objectForKey:@"name"]];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    cell.detailTextLabel.text = [formatter stringFromDate:[info objectForKey:@"date"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  isServerCache?[[self cachedFoodList] count]:[[BSDataProvider cachedFoodList] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:isServerCache?nil:@"删除" otherButtonTitles:@"导入", nil];
    as.tag = indexPath.row;
    [as showInView:self.view];
    [as release];
}

#pragma mark -  UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"删除"]){
        [BSDataProvider removeOrderOfName:[[[BSDataProvider cachedFoodList] objectAtIndex:actionSheet.tag] objectForKey:@"name"]];
        [tvCache reloadData];
        
        NSDictionary *current = [BSDataProvider currentOrder];
        if ([current objectForKey:@"name"])
            [self addNavButtonWithTitle:@"保存修改" atPosition:SWNavItemPositionRight action:@selector(savecurrentClicked)];
        else
            [self addNavButtonWithTitle:@"暂存当前菜品" atPosition:SWNavItemPositionRight action:@selector(saveClicked)];
    }else if ([buttonTitle isEqualToString:@"导入"]){
        [BSDataProvider importOrderOfName:[[[BSDataProvider cachedFoodList] objectAtIndex:actionSheet.tag] objectForKey:@"name"]];
        [tvCache reloadData];
        
        //        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存修改" style:UIBarButtonItemStyleBordered target:self action:@selector(savecurrentClicked)] autorelease];
        [self addNavButtonWithTitle:@"保存修改" atPosition:SWNavItemPositionRight action:@selector(savecurrentClicked)];
        
    }
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSString *title;
    if (bSucceed){
        title = @"上传暂存菜品成功";//@"传菜成功";
        [tvCache reloadData];
    }
    else
        title = @"上传暂存菜品失败";//@"传菜失败";
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showSuccessWithStatus:title];
    });
    
    
    //    [SVProgressHUD dismissWithSuccess:title afterDelay:2];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
    
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    NSString *title = @"上传暂存菜品失败";//@"传菜失败";
    
    //    [SVProgressHUD dismissWithError:title afterDelay:2];
    bs_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showErrorWithStatus:title];
    });
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadOrder:(NSDictionary *)order{
    bs_dispatch_sync_on_main_thread(^{
        NSString *str = [[BSDataProvider sharedInstance] cachedOrder:order];
        NSString *settingPath = [@"setting.plist" documentPath];
        NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *ftpurl = nil;
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [ftpurl hostName];
        uploader.username = [[ftpurl account] objectForKey:@"username"];
        uploader.password = [[ftpurl account] objectForKey:@"password"];
        
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        uploader.path = [NSString stringWithFormat:@"/temporary/%@.order",[[order objectForKey:@"name"] MD5]];
        
        [uploader start];
    });
}



#pragma mark - Server Cache Data Provider
- (NSDictionary *)allCachedOrder{
    return dicCache;
}

- (void)removeOrderOfName:(NSString *)name{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    [cacheDict removeObjectForKey:name];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
    
    NSDictionary *current = [BSDataProvider currentOrder];
    if ([name isEqualToString:[current objectForKey:@"name"]]){
        NSMutableArray *aryOrders = [[BSDataProvider sharedInstance] orderedFood];
        [aryOrders removeAllObjects];
        [[BSDataProvider sharedInstance] saveOrders];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrder"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)importOrderOfName:(NSString *)name{
    NSDictionary *order = [dicCache objectForKey:name];
    NSMutableArray *aryOrders = [[BSDataProvider sharedInstance] orderedFood];
    [aryOrders removeAllObjects];
    [aryOrders addObjectsFromArray:[order objectForKey:@"foods"]];
    [[BSDataProvider sharedInstance] saveOrders];
    
    
    NSMutableDictionary *mut = [NSDictionary dictionaryWithDictionary:order];
    [mut setObject:name forKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}

- (NSArray *)cachedFoodList{
    NSDictionary *dict = dicCache;
    
    NSMutableArray *mut = [NSMutableArray array];
    
    for (NSString *key in dict.allKeys){
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:key]];
        [mutdict setObject:key forKey:@"name"];
        [mut addObject:mutdict];
    }
    
    [mut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        
        double interval = [[dict1 objectForKey:@"date"] timeIntervalSinceDate:[dict2 objectForKey:@"date"]];
        
        
        return interval>0?NSOrderedAscending:(interval<0?NSOrderedDescending:NSOrderedSame);
    }];
    
    return mut;
}

- (BOOL)isCacheNameExist:(NSString *)name{
    BOOL bExist = NO;
    NSArray *ary = [self cachedFoodList];
    for (NSDictionary *cache in ary){
        if ([[cache objectForKey:@"name"] isEqualToString:name]){
            bExist = YES;
            break;
        }
    }
    
    return bExist;
}

- (void)saveFoods:(NSArray *)foods withName:(NSString *)name{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",[NSDate date],@"date", nil];
    [dicCache setObject:dict forKey:name];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mut setObject:name forKey:@"name"];
    
    [self uploadOrder:mut];
    
    [tvCache reloadData];
    
    [[[BSDataProvider sharedInstance] orderedFood] removeAllObjects];
    [[BSDataProvider sharedInstance] saveOrders];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil userInfo:nil];
}

@end
