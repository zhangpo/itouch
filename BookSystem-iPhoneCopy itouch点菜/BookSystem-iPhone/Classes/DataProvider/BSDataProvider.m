//
//  BSDataProvider.m
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"
#import "sharedData.h"

@implementation BSDataProvider
static BSDataProvider *sharedInstance = nil;
static NSString *strPDAID;
static NSDictionary *infoDict = nil;
static NSDictionary *pageConfigDict = nil;
static NSArray *allPages = nil;
static NSArray *allDetailPages = nil;
static NSLock *_loadingMutex = nil;
static NSMutableArray *aryOrders = nil;
static int dSendCount = 0;
CVLocalizationSetting *langSetting;
+ (BSDataProvider *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[super allocWithZone:NULL] init];
			
            //		CVDataProviderSetting *s = [CVDataProviderSetting sharedInstance];
			_loadingMutex = [[NSLock alloc] init];
            aryOrders = [[NSMutableArray alloc] init];
            NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [docPaths objectAtIndex:0];
            NSString *path = [docPath stringByAppendingPathComponent:kOrdersFileName];
            NSDictionary *dicOrders = [NSDictionary dictionaryWithContentsOfFile:path];
            NSArray *ary = [dicOrders objectForKey:@"orders"];
            
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName]];
            if (!dic){
                dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"count"];
                [dic writeToFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName] atomically:NO];
            }
            
           langSetting = langSetting = [CVLocalizationSetting sharedInstance];
            
            dSendCount = [[dic objectForKey:@"count"] intValue];
            [aryOrders addObjectsFromArray:ary];
            
            dic = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"pdaid.plist"]];
            if (!dic){
                dic = [NSDictionary dictionaryWithObject:@"8" forKey:@"pdaid"];
                [dic writeToFile:[docPath stringByAppendingPathComponent:@"pdaid.plist"] atomically:NO];
            }
            
//            strPDAID = [[[NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"pdaid.plist"]] objectForKey:@"pdaid"] retain];
            
            
        }
    }
    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
    NSString *equipment = [[NSUserDefaults standardUserDefaults] objectForKey:@"equipment"];
    if ([sw isEqualToString:@"zc"]) {
        strPDAID = [NSString stringWithFormat:@"8-%@",equipment];
    }else{
        strPDAID = equipment;
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}




- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
	//[_cache release];
}

- (id)autorelease {
    return self;
}

//菜品缓存
+ (NSDictionary *)currentOrder{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentOrder"];
    
    if (!dict){
        if (aryOrders.count>0){
            dict = [NSDictionary dictionaryWithObjectsAndKeys:aryOrders,@"foods",[NSDate date],@"date", nil];
            
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"CurrentOrder"];
        }
    }
    
    return dict;
}

+ (NSDictionary *)allCachedOrder{
    return [NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]];
}

+ (void)removeOrderOfName:(NSString *)name{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    [cacheDict removeObjectForKey:name];
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
    
    NSDictionary *current = [BSDataProvider currentOrder];
    if ([name isEqualToString:[current objectForKey:@"name"]]){
        [aryOrders removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentOrder"];
    }
}

+ (void)importOrderOfName:(NSString *)name{
    NSDictionary *order = [[BSDataProvider allCachedOrder] objectForKey:name];
    [aryOrders release];
    aryOrders = [[order objectForKey:@"foods"] retain];
    if (!aryOrders)
        aryOrders = [[NSMutableArray array] retain];
    [[BSDataProvider sharedInstance] saveOrders];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:order];
    [mut setObject:name forKey:@"name"];
    
    [[NSUserDefaults standardUserDefaults] setObject:mut forKey:@"CurrentOrder"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}

+ (NSArray *)cachedFoodList{
    NSDictionary *dict = [BSDataProvider allCachedOrder];
    
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

+ (BOOL)isCacheNameExist:(NSString *)name{
    BOOL bExist = NO;
    NSArray *ary = [BSDataProvider cachedFoodList];
    for (NSDictionary *cache in ary){
        if ([[cache objectForKey:@"name"] isEqualToString:name]){
            bExist = YES;
            break;
        }
    }
    
    return bExist;
}

+ (void)saveFoods:(NSArray *)foods withName:(NSString *)name{
    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[@"FoodCache.plist" documentPath]]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:foods,@"foods",[NSDate date],@"date", nil];
    [cacheDict setObject:dict forKey:name];
    
    [cacheDict writeToFile:[@"FoodCache.plist" documentPath] atomically:NO];
    
    [aryOrders removeAllObjects];
    [[BSDataProvider sharedInstance] saveOrders];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil userInfo:nil];
}

- (NSString *)cachedOrder:(NSDictionary *)order{
    NSArray *ary = [order objectForKey:@"foods"];
    NSString *name = [order objectForKey:@"name"];
    
    if (ary && [ary count]>0){
        ary = [self expendList:ary];
        
        
        NSMutableString *addition = [NSMutableString string];
        NSMutableString *tablist = [NSMutableString string];
        int foodnum;
        
//        NSString *pdaid = [NSString stringWithFormat:@"%@-%d",[self padID],[[[self currentPageConfig] objectForKey:@"number"] intValue]];
        NSString *pdaid = strPDAID;
        foodnum = [ary count];
        
        [addition appendString:@"|"];
        
        
        
        for (int i=0;i<foodnum;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            NSMutableArray *aryMut = [NSMutableArray array];
            
            if ([dic objectForKey:@"addition"])
                [aryMut addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            int additionCount = [aryMut count];
            for (int i=0;i<10;i++){
                if (i%2==0){
                    int index = i/2;
                    if (index<additionCount)
                        [addition appendString:[[aryMut objectAtIndex:index] objectForKey:@"DES"]];
                    [addition appendString:@"|"];
                }
                else{
                    int index = (i-1)/2;
                    if (index<additionCount){
                        NSString *additionprice = [[aryMut objectAtIndex:index] objectForKey:@"PRICE1"];
                        if (!additionprice)
                            additionprice = @"0.0";
                        [addition appendString:additionprice];
                    }
                    
                    [addition appendString:@"|"];
                }
                
            }
            
            int packid = [[[dic objectForKey:@"food"] objectForKey:@"PACKID"] intValue];
            int packcnt = [[[dic objectForKey:@"food"] objectForKey:@"PACKCNT"] intValue];
            packid = 0==packid?-1:packid;
            //            packcnt = 0==packcnt?-1:packcnt;
            
            float fTotal = [[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"priceKey"]?[dic objectForKey:@"priceKey"]:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]] floatValue];
            //            [tablist appendFormat:@"-1|0|%@|%@|%@|%@|0.00%@0|\n",[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:@"UNIT"],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            [tablist appendFormat:@"%d|%d|%@|%@|%@|%@|0.00%@0|^",packid,packcnt,[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"unitKey"]],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            
            addition = [NSMutableString string];
            [addition appendFormat:@"|"];
        }
        
        
        return [NSString stringWithFormat:@"+gettempfolio<pdaid:%@;name:%@;foodnum:%d;tablist:%@;>^",pdaid,name,foodnum,tablist];
    }else
        return nil;
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadFood:(NSString *)str{
    sw_dispatch_sync_on_main_thread(^{
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
        
        NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString performSelector:@selector(UUIDString)],[[NSDate date] timeIntervalSince1970]];
        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
//        NSString *filename = [NSString stringWithFormat:@"%@%lf",[UIDevice currentDevice].uniqueIdentifier,[[NSDate date] timeIntervalSince1970]];
//        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
        [uploader start];
    });
}

#pragma mark -
#pragma mark Data Get & Refresh

//中餐附加项
- (NSArray *)getAdditions_zc{
    NSMutableArray *ary = [NSMutableArray array];
    
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from attach";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary];
    
}

//单品附加项
- (NSArray *)getAdditions{
    NSMutableArray *ary = [NSMutableArray array];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from FoodFuJia where pcode='~_PCODE_~' or pcode=''";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                    strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                    strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary]; 

}

//单品附加项
- (NSArray *)getAdditionsQuanDan{
    NSMutableArray *ary = [NSMutableArray array];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from specialremark";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary];
    
}

//更新数据
- (NSDictionary *)updateData{
    NSDictionary *serversettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"ServerSettings"];
    NSDictionary *ftpsettings = [serversettings objectForKey:@"ftp"];
    NSString *username = [ftpsettings objectForKey:@"username"];
    NSString *password = [ftpsettings objectForKey:@"password"];
    NSString *ip = [ftpsettings objectForKey:@"ip"];
    
    NSString *ftpurl = [NSString stringWithFormat:@"ftp://%@:%@@%@/booksystem",username,password,ip];
    NSLog(@"%@",ftpurl);
    ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];
    
    NSURL *url = nil;
	NSURLRequest *request;
	url = [NSURL URLWithString:ftpurl];
	request = [[NSURLRequest alloc] initWithURL:url
									cachePolicy:NSURLRequestUseProtocolCachePolicy
								timeoutInterval:20.0];
	
	
	// retreive the data using timeout
	NSURLResponse* response;
	NSError *error;

	
	error = nil;
	response = nil;
	NSData *serviceData = [NSURLConnection sendSynchronousRequest:request 
                                        returningResponse:&response
                                                    error:&error];
	[request release];
	// 1001 is the error code for a connection timeout
	if (!serviceData) {
        //服务器超时，请检查网络链接或ftp设置是否正确
		NSLog( @"Server timeout!" );
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"empty",@"Message", nil];
	}
    

    NSData *sqldata = [[NSData alloc] initWithContentsOfURL:url];
    

 //   NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:url];
    
    if (sqldata){
        [sqldata writeToFile:[@"BookSystem.sqlite" documentPath] atomically:NO];  //更新服务器的数据库，写入沙盒
        [sqldata release];
        //读取更新带图片的表，需要更新资源的表，存入字典
//去掉下载图片
//        infoDict = [[NSDictionary alloc] initWithDictionary:[self dictFromSQL]];
    }else{
        [sqldata release];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Download Data Failed,Please check your ftp setting and re-lanuch the app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result", nil];
    }
    
    //更新图片或者资源到沙盒路径下
    NSArray *fileNames = [infoDict objectForKey:@"FileList"];
    int count = [fileNames count];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (int i=0;i<count;i++){
        sw_dispatch_sync_on_main_thread(^{
            [SVProgressHUD showProgress:((float)(i+1)/(float)count) status:[langSetting localizedString:@"Being updated"] maskType:SVProgressHUDMaskTypeClear];
        });
        NSString *fileName = [fileNames objectAtIndex:i];
        NSString *path = [fileName documentPath];
        
        BOOL bFileExist = [fileManager fileExistsAtPath:path];
        
        if (!bFileExist){
            NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
            NSData *sqldata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            [sqldata writeToFile:path atomically:NO];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
}

- (NSArray *)getADNames{
    return [infoDict objectForKey:@"Ads"];
}

- (void)refreshFiles{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSArray *fileNames = nil;
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
    NSDictionary *didict= [NSDictionary dictionaryWithContentsOfFile:settingPath];
    NSString *ftpurl = nil;
    if (didict!=nil)
        ftpurl = [didict objectForKey:@"url"];
    
    if (!ftpurl)
        ftpurl = kPathHeader;
    ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];
    
    
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:ftpurl]];
    [imgData writeToFile:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"] atomically:NO];
    [imgData release];
    infoDict = [self dictFromSQL];
    fileNames = [infoDict objectForKey:@"FileList"];
    int count = [fileNames count];
    for (int i=0;i<count;i++){
        NSString *fileName = [fileNames objectAtIndex:i];
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
        imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
        [imgData writeToFile:path atomically:NO];
    }
}

- (NSArray *)getAllFoods{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from food";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    strKey = nil;
                    strValue = nil;
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

NSInteger intSort2(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"class"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"class"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (NSArray *)getFoodList:(NSString *)cmd{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
//        sqlcmd = [NSString stringWithFormat:@"select * from food where %@ ORDER BY class ASC",cmd];
        sqlcmd = [NSString stringWithFormat:@"select m.name as UNIT,m1.name as UNIT2,m2.name as UNIT3,m3.name as UNIT4,m4.name as UNIT5,f.ITCODE,f.DES,f.PRICE,f.PRICE2,f.PRICE3,f.PRICE4,picBig,picSmall,pap,INIT,ISTC,TCMONEYMODE,UNITCUR,CLASS from food f left join measdoc m on f.unit = m.code left join measdoc m1 on f.UNIT2 = m.code left join measdoc m2 on f.UNIT3 = m.code left join measdoc m3 on f.UNIT4 = m.code left join measdoc m4 on f.UNIT5 = m.code where %@",cmd];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    strKey = nil;
                    strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:[ary sortedArrayUsingFunction:intSort2 context:NULL]];
}

- (NSMutableArray *)getCodeDesc{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSMutableArray *)getClassList{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from class ORDER BY GRP ASC";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)getClassByID:(NSString *)classid{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"select * from class where GRP = %@",classid];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [ary count]>0?[ary objectAtIndex:0]:nil;
}

- (NSArray *)getCovers{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from cover";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey=nil,*strValue=nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getCaptions{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from caption";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey=nil,*strValue=nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getAccounts{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from user";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)dictFromSQL{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSMutableArray *mutAds = [NSMutableArray array];
    NSMutableArray *mutFileList = [NSMutableArray array];

    NSMutableArray *mutClass = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
 //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        //Generate Ads & FileList
        //1 Ads
        sqlcmd = @"select * from ads";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutAds addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutAds forKey:@"Ads"];
        //2 FileList
        sqlcmd = @"select * from FileList";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *name = (char *)sqlite3_column_text(stat, 0);
                [mutFileList addObject:[NSString stringWithUTF8String:name]];
            }
        }
        sqlite3_finalize(stat);
        [ret setObject:mutFileList forKey:@"FileList"];
        
        
        //Generate Main Menu
        //1. Get image,name of MainMenu
        sqlcmd = @"select * from class";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                char *background = (char *)sqlite3_column_text(stat,0);
                int type = sqlite3_column_int(stat, 1);
                char *image = (char *)sqlite3_column_text(stat,2);
                char *name = (char *)sqlite3_column_text(stat, 3);
                char *recommend = (char *)sqlite3_column_text(stat, 4);
 
                NSMutableDictionary *mut = [NSMutableDictionary dictionary];
                [mut setObject:[NSNumber numberWithInt:type] forKey:@"type"];
                if (background)
                    [mut setObject:[NSString stringWithUTF8String:background] forKey:@"background"];
                if (image)
                     [mut setObject:[NSString stringWithUTF8String:image] forKey:@"image"];
                if (name)
                     [mut setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
                if (recommend)
                     [mut setObject:[NSString stringWithUTF8String:recommend] forKey:@"recommend"];
                
                [mutClass addObject:mut];
            }
        }
        sqlite3_finalize(stat);
        
        //2. Genereate by Food
        for (int i=0;i<[mutClass count];i++){
            NSMutableDictionary *mutC = [mutClass objectAtIndex:i];
            NSString *strOrder;
            NSString *strPrice = [[NSUserDefaults standardUserDefaults] stringForKey:@"price"];
            if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO";
            else if ([strPrice isEqualToString:@"PRICE"])
                strOrder = @"ITEMNO2";
            else
                strOrder = @"ITEMNO3";
            sqlcmd = [NSString stringWithFormat:@"select * from food where GRPTYP = %d and HSTA = 'Y' order by %@",[[[mutClass objectAtIndex:i] objectForKey:@"type"] intValue],strOrder];
            NSMutableArray *foods = [NSMutableArray array];
            if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
                while (sqlite3_step(stat)==SQLITE_ROW) {
                    int count = sqlite3_column_count(stat);
                    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                    for (int i=0;i<count;i++){
                        char *foodKey = (char *)sqlite3_column_name(stat, i);
                        char *foodValue = (char *)sqlite3_column_text(stat, i);
                        NSString *strKey = nil,*strValue = nil;
                        strKey = nil;
                        strValue = nil;
                        if (foodKey)
                            strKey = [NSString stringWithUTF8String:foodKey];
                        if (foodValue)
                            strValue = [NSString stringWithUTF8String:foodValue];
                        if (strKey && strValue)
                            [mutDC setObject:strValue forKey:strKey];
                    }
                    [foods addObject:mutDC];
                }
            }
            sqlite3_finalize(stat);
            
            if (foods && [foods count]>0)
                [mutC setObject:foods forKey:@"SubMenu"];
        }
        
        if (mutClass && [mutClass count]>0)
            [ret setObject:mutClass forKey:@"MainMenu"];
    }
    sqlite3_close(db);

    return ret;
}
- (NSDictionary *)dataDict{
    return infoDict;
}

- (void)getCachedFile{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSArray *fileNames = nil;
    NSString *ftpurl = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"]])
    {
        NSString *settingPath = [docPath stringByAppendingPathComponent:@"setting.plist"];
        NSDictionary *didict= [[NSDictionary alloc] initWithContentsOfFile:settingPath];
        
        if (didict!=nil)
            ftpurl = [didict objectForKey:@"url"];
        
        if (!ftpurl)
            ftpurl = kPathHeader;
        ftpurl = [ftpurl stringByAppendingPathComponent:@"BookSystem.sqlite"];

        NSData *sqldata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:ftpurl]];
        [sqldata writeToFile:[docPath stringByAppendingPathComponent:@"BookSystem.sqlite"] atomically:NO];
        [didict release];
        [sqldata release];
    }
    
    infoDict = [self dictFromSQL];
    fileNames = [infoDict objectForKey:@"FileList"];
    int count = [fileNames count];
    for (int i=0;i<count;i++){
        NSString *fileName = [fileNames objectAtIndex:i];
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        if (![fileManager fileExistsAtPath:path]){
            NSString *strURL = [[ftpurl stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
            NSData *sqldata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            [sqldata writeToFile:path atomically:NO];
        }
        
    }
}

- (void)writeToServer:(const uint8_t *)buf{
    [oStream write:buf maxLength:strlen((char*)buf)];
}


#pragma mark  套餐
- (NSMutableArray *)getPackage:(NSString *)str{
//    NSString *path1=[NSString stringWithFormat:@"%@/Documents/BookSystem.sqlite",NSHomeDirectory()];
//    FMDatabase *db = [[FMDatabase alloc]initWithPath:path1];
//    if(![db open])
//    {
//        return Nil;
//    }
//    NSMutableArray *array=[[NSMutableArray alloc] init];
//    NSString *str=[NSString stringWithFormat:@"SELECT PRODUCTTC_ORDER FROM products_sub WHERE PCODE = '%@' AND defualtS = '0' GROUP BY PRODUCTTC_ORDER ORDER BY CAST(PRODUCTTC_ORDER as SIGNED) ASC",tag];
//    NSLog(@"%@",str);
//    FMResultSet *rs = [db executeQuery:str];
//    while ([rs next]){
//        [array addObject:[rs stringForColumn:@"PRODUCTTC_ORDER"]];
//    }
//    NSString *str2=[NSString stringWithFormat:@"SELECT * from food where itcode='%@'",tag];
//    FMResultSet *rs2 = [db executeQuery:str2];
//    NSString *PKID,*pcode,*pcname,*TCMONEYMODE;
//    while ([rs2 next]){
//        PKID=[rs2 stringForColumn:@"item"];
//        pcode=[rs2 stringForColumn:@"itcode"];
//        pcname=[rs2 stringForColumn:@"DES"];
//        TCMONEYMODE=[rs2 stringForColumn:@"TCMONEYMODE"];
//    }
//    NSMutableArray *array2=[[NSMutableArray alloc] init];
//    for(int j=0;j<[array count];j++){
//        NSString *str1=[NSString stringWithFormat:@"SELECT * from products_sub where pcode='%@' and PRODUCTTC_ORDER =%@ ORDER BY defualtS ASC",tag,[array objectAtIndex:j]];
//        NSLog(@"%@",str1);
//        FMResultSet *rs1 = [db executeQuery:str1];
//        NSMutableArray *array1=[[NSMutableArray alloc] init];
//        NSString *min,*max;
//        while([rs1 next]) {
//            if ([[rs1 stringForColumn:@"defualtS"] intValue]==0) {
//                min=[rs1 stringForColumn:@"MINCNT"];
//                max=[rs1 stringForColumn:@"MAXCNT"];
//            }
//            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];;
//            [dict setObject:PKID forKey:@"PKID"];
//            [dict setValue:pcode forKey:@"Tpcode"];
//            [dict setValue:pcname forKey:@"TPNANE"];
//            [dict setValue:[rs1 stringForColumn:@"pcode1"] forKey:@"ITCODE"];
//            [dict setValue:[rs1 stringForColumn:@"pname"] forKey:@"DES"];
//            [dict setValue:min forKey:@"tpmin"];
//            [dict setValue:max forKey:@"tpmax"];
//            if (![[rs1 stringForColumn:@"NADJUSTPRICE"] isEqualToString:@"~_NADJUSTPRICE_~"]) {
//                [dict setValue:[rs1 stringForColumn:@"NADJUSTPRICE"] forKey:@"addprice"];
//            }else
//            {
//                [dict setValue:@"0.0" forKey:@"addprice"];
//            }
//            if (![[rs1 stringForColumn:@"GROUPTITLE"] isEqualToString:@"~_GROUPTITLE_~"]) {
//                [dict setValue:[rs1 stringForColumn:@"GROUPTITLE"] forKey:@"GROUPTITLE"];
//            }else
//            {
//                [dict setValue:@"" forKey:@"GROUPTITLE"];
//            }
//            [dict setValue:[rs1 stringForColumn:@"MINCNT"] forKey:@"pmin"];
//            [dict setValue:[rs1 stringForColumn:@"MAXCNT"] forKey:@"pmax"];
//            [dict setValue:[rs1 stringForColumn:@"unit"] forKey:@"UNIT"];
//            [dict setValue:[rs1 stringForColumn:@"price1"] forKey:@"PRICE"];
//            [dict setValue:[rs1 stringForColumn:@"CNT"] forKey:@"CNT"];
//            [dict setValue:TCMONEYMODE forKey:@"TCMONEYMODE"];
//            NSString *str1=[NSString stringWithFormat:@"SELECT UNITCUR from food where ITCODE='%@'",[rs1 stringForColumn:@"pcode1"]];
//            FMResultSet *rs2 = [db executeQuery:str1];
//            while ([rs2 next]) {
//                [dict setValue:[rs2 stringForColumn:@"UNITCUR"] forKey:@"Weightflg"];
//            }
//            [array1 addObject:dict];
//        }
//        if ([array1 count]>1) {
//            [array1 removeObjectAtIndex:0];
//        }
//        [array2 addObject:array1];
//    }
//    [db close];
//    return array2;

    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"select * from products_sub where PCODE = '%@'",str];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSMutableArray *)getPackageWhere:(NSString *)str{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"select * from products_sub where PCODE = %@",str];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSMutableArray *)getPackage{
    NSMutableArray *packArray = [[NSMutableArray alloc] init];
    NSMutableArray *array = [self getPackage2];
    for (NSMutableDictionary *dic in array) {
        NSString *packageid = [dic objectForKey:@"PACKID"];
        NSArray *foods = [self getFoodListOfPackage:packageid];
        //  [dic setObject:(foods != NULL?foods:@"0") forKey:@"foods"];
        if (foods == NULL) {
            continue;
        }
        [dic setObject:foods forKey:@"foods"];
        [packArray addObject:dic];
    }
    return packArray;
}

- (NSMutableArray *)getPackage2{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from package";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

#pragma mark -
#pragma mark 上传菜品，催菜，退菜，查询订单，登陆
- (void)orderFood:(NSDictionary *)info{
    //info包括菜品信息＋数量＋附加项
    //增加价格和单位信息
    if ([info objectForKey:@"food"]){
        int i = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        i++;
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:info];
        if (![mut objectForKey:@"unitKey"]){
            [mut setObject:@"UNIT" forKey:@"unitKey"];
            [mut setObject:@"PRICE" forKey:@"priceKey"];
        }
        [mut setObject:[NSNumber numberWithInt:i] forKey:@"OrderTimeCount"];
        [mut setObject:[NSNumber numberWithBool:NO] forKey:@"ISTC"];
        [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"OrderTimeCount"];
        info = [NSDictionary dictionaryWithDictionary:mut];
        [aryOrders addObject:info]; 
    }else if ([info objectForKey:@"foods"]){
        int j = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        j++;

        NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:info];
        [mutdict setObject:[NSNumber numberWithInt:j] forKey:@"OrderTimeCount"];
        if (![mutdict objectForKey:@"unitKey"]){
            [mutdict setObject:@"UNIT" forKey:@"unitKey"];
            [mutdict setObject:@"PRICE" forKey:@"priceKey"];
        }
        [aryOrders addObject:mutdict];
        
        [[NSUserDefaults standardUserDefaults] setInteger:j forKey:@"OrderTimeCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [self saveOrders];
    
}


- (void)orderFood_zc:(NSDictionary *)info{
    //info包括菜品信息＋数量＋附加项
    //增加价格和单位信息
    if ([info objectForKey:@"food"]){
        int i = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        i++;
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:info];
        if (![mut objectForKey:@"unitKey"]){
            [mut setObject:@"UNIT" forKey:@"unitKey"];
            [mut setObject:@"PRICE" forKey:@"priceKey"];
        }
        
        
        [mut setObject:[NSNumber numberWithInt:i] forKey:@"OrderTimeCount"];
        [mut setObject:[NSNumber numberWithBool:NO] forKey:@"isPack"];
        [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"OrderTimeCount"];
        
        info = [NSDictionary dictionaryWithDictionary:mut];
        
        [aryOrders addObject:info];
    }else if ([info objectForKey:@"foods"]){
        //        NSArray *ary = [info objectForKey:@"foods"];
        NSString *packName = [[info objectForKey:@"foods"] objectForKey:@"DES"];
        NSString *packID = [[info objectForKey:@"foods"] objectForKey:@"PACKID"];
        NSString *packPrice = [[info objectForKey:@"foods"] objectForKey:@"PRICE"];
        NSArray *ary = [[info objectForKey:@"foods"] objectForKey:@"foods"];
        
        if ([ary isKindOfClass:[NSArray class]]) {
            ary = [[info objectForKey:@"foods"] objectForKey:@"foods"];
        }else{
            NSMutableArray *mut = [[NSMutableArray alloc] init];
            [mut addObject:ary];
            ary = [NSMutableArray arrayWithArray:mut];
        }
        
        int j = [[NSUserDefaults standardUserDefaults] integerForKey:@"OrderTimeCount"];
        j++;
        NSMutableArray *foods = [NSMutableArray array];
        for (int i=0;i<[ary count];i++){
            NSDictionary *dict = [self getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITEM = %@",[[ary objectAtIndex:i] objectForKey:@"ITEM"]]];
            
            if (dict){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dict];
                [mut setObject:[[info objectForKey:@"foods"] objectForKey:@"PACKID"] forKey:@"PACKID"];
                [mut setObject:@"1" forKey:@"PACKCNT"];
                [mut setObject:@"1" forKey:@"total"];
                
                
                //                info = [NSDictionary dictionaryWithDictionary:mut];
                
                [foods addObject:mut];
            }
            
        }
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:info];
        [mutdict setObject:packName forKey:@"DES"];
        [mutdict setObject:packID forKey:@"PACKID"];
        [mutdict setObject:packPrice forKey:@"PRICE"];
        
        [mutdict setObject:[NSNumber numberWithInt:j] forKey:@"OrderTimeCount"];
        [mutdict setObject:foods forKey:@"foods"];
        [mutdict setObject:[NSNumber numberWithBool:YES] forKey:@"isPack"];
        if (![mutdict objectForKey:@"unitKey"]){
            [mutdict setObject:@"UNIT" forKey:@"unitKey"];
            [mutdict setObject:@"PRICE" forKey:@"priceKey"];
        }
        [aryOrders addObject:mutdict];
        
        [[NSUserDefaults standardUserDefaults] setInteger:j forKey:@"OrderTimeCount"];
    }
    
    
    [self saveOrders];
    
}



- (NSMutableArray *)orderedFood{
    return aryOrders;
    
    NSMutableArray *ary = [NSMutableArray array];
    
    NSMutableSet *mutset = [NSMutableSet set];
    
    for (int i=0;i<[aryOrders count];i++){
        if (![mutset containsObject:[[aryOrders objectAtIndex:i] objectForKey:@"OrderTimeCount"]])
            [mutset addObject:[[aryOrders objectAtIndex:i] objectForKey:@"OrderTimeCount"]];
    }

    NSArray *aryset = [mutset allObjects];
    for (int i=0;i<[aryset count];i++){
        NSArray *resultary = [[[NSSet setWithArray:aryOrders] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.OrderTimeCount == %d",[[aryset objectAtIndex:i] intValue]]] allObjects];
        
        if ([resultary count]>1){
            NSString *suitid = [[resultary lastObject] objectForKey:@"PACKID"];
            NSDictionary *suitdetail = [self getPackageDetail:suitid];
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:suitdetail];
            [mutdict setObject:resultary forKey:@"foods"];
            [mutdict setObject:[NSNumber numberWithBool:YES] forKey:@"ISTC"];
            
            [ary addObject:mutdict];
            
        }else{
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[resultary lastObject]];
            [mutdict setObject:[NSNumber numberWithBool:NO] forKey:@"ISTC"];
            
            [ary addObject:mutdict];
        }
    }
    
    return ary;
}


- (NSDictionary *)pGogo:(NSDictionary *)info{
    NSString *user,*pwd;
    NSString *pdaid = strPDAID;
    user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    int tab = [[info objectForKey:@"tab"] intValue];
    NSString *foodnum = [info objectForKey:@"num"];

    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%d&oSerial=%@",pdaid,user,tab,foodnum];

    NSDictionary *dict = [self bsService:@"pGogo" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",
                    [[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
        }
    }else{
         return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}


//中餐账单查询
- (NSDictionary *)pQuery_zc:(NSDictionary *)info{
    NSMutableDictionary *dicMut = [NSMutableDictionary dictionary];
    
    NSString *user,*pwd;
    NSString *pdaid = [info objectForKey:@"pdaid"];
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    NSString *table = [info objectForKey:@"table"];
    
    pdaid = strPDAID;

    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@&iRecNo=0",pdaid,user,table];
    
    NSDictionary *dict = [self bsService:@"zcQuery" arg:strParam];
    NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];//[[[[[[dict objectForKey:@"string"] objectForKey:@"text"]  componentsSeparatedByString:@"<Buffer>"] objectAtIndex:1] componentsSeparatedByString:@"</Buffer>"] objectAtIndex:0];
    NSArray *ary = [result componentsSeparatedByString:@"<"];
    
    if (result && [result rangeOfString:@"error"].location!=NSNotFound){
        [dicMut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
        [dicMut setObject:[[[[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"Message"];
    }else{
        if (![result isEqualToString:@"+query<end>"]){
            
            NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            
            NSArray *aryFenhao = [content componentsSeparatedByString:@";"];
            if ([aryFenhao count]>3){
                NSString *tab = [[[aryFenhao objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *total = [[[aryFenhao objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *people = [[[aryFenhao objectAtIndex:2] componentsSeparatedByString:@":"] objectAtIndex:1];
                
                [dicMut setObject:tab forKey:@"tab"];
                [dicMut setObject:total forKey:@"total"];
                [dicMut setObject:people forKey:@"people"];
                
                NSString *account = [[[aryFenhao objectAtIndex:3] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSArray *aryAcc = [account componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
                int countAcc = [aryAcc count];
                
                NSMutableArray *aryMut = [NSMutableArray array];
                for (int i=0;i<countAcc;i++){
                    NSMutableDictionary *mutFood = [NSMutableDictionary dictionary];
                    NSString *strAcc = [aryAcc objectAtIndex:i];
                    NSArray *aryStr = [strAcc componentsSeparatedByString:@"^"];
                    
                    if ([aryStr count]>8){
                        [mutFood setObject:[aryStr objectAtIndex:0] forKey:@"num"];
                        [mutFood setObject:[aryStr objectAtIndex:1] forKey:@"name"];
                        [mutFood setObject:[aryStr objectAtIndex:2] forKey:@"total"];
                        [mutFood setObject:[aryStr objectAtIndex:3] forKey:@"price"];
                        [mutFood setObject:[aryStr objectAtIndex:4] forKey:@"unit"];
                        [mutFood setObject:[aryStr objectAtIndex:5] forKey:@"add1"];
                        [mutFood setObject:[aryStr objectAtIndex:6] forKey:@"add2"];
                        [mutFood setObject:[[[aryStr objectAtIndex:7] componentsSeparatedByString:@"#"] objectAtIndex:1] forKey:@"waiter"];
                        [mutFood setObject:[aryStr objectAtIndex:8] forKey:@"PACKID"];
                        [aryMut addObject:mutFood];
                    }
                    
                }
                
                [dicMut setObject:aryMut forKey:@"account"];
                
                
            }
        }
    }
    return dicMut;
}

//快餐查询账单
- (NSDictionary *)pQuery:(NSDictionary *)info{
    NSString *pdaid,*userCode,*pwd,*comOrDetach,*tableNum,*orderID;
    pdaid = strPDAID;
    tableNum = [info objectForKey:@"table"];
    if (!tableNum) {
        tableNum = [info objectForKey:@"phone"];
    }
    orderID = [info objectForKey:@"orderID"];
    if (!orderID) {
        orderID = [info objectForKey:@"orderId"];
    }
    NSLog(@"table==>%@",tableNum);
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    comOrDetach = @"1"; // 0 分开发送  1 合并发送
    //queryProduct?&deviceId=777&userCode=4&tableNum=6&mancouonts=&womancounts=&orderId=&chkCode=&comOrDetach=0
    NSMutableDictionary *dicMutInfo = [NSMutableDictionary dictionary];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&mancouonts=&womancounts=&orderId=&chkCode=&comOrDetach=%@",pdaid,userCode,tableNum,comOrDetach];
    NSDictionary *dict = [self bsService:@"queryProduct" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:queryProductResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] isEqualToString:@"0"]) {
            //获取男人数、女人数、账单号、台位等基本信息
            NSArray *aryInfo = [result componentsSeparatedByString:@"#"];
            NSArray *aryInfoRes =[[aryInfo objectAtIndex:[aryInfo count]-2] componentsSeparatedByString:@"@"];//人数
            NSString *additions = [aryInfo objectAtIndex:[aryInfo count]-1];//公共附加项
            NSArray *aryAddition = [additions componentsSeparatedByString:@";"];
            NSMutableString *strAdditions = [NSMutableString string];
            for (NSString *s in aryAddition) {
                NSArray *ary1 = [s componentsSeparatedByString:@"@"];
                if ([ary1 count] >= 2) {
                    [strAdditions appendString:[ary1 objectAtIndex:1]];
                    [strAdditions appendString:@"、"];
                }
            }
            NSArray *orderArray =[[aryInfo objectAtIndex:[aryInfo count]-3] componentsSeparatedByString:@";"];
            NSMutableArray *orders=[NSMutableArray array];
            for (NSString *str in orderArray) {
                if (str!=[orderArray lastObject]) {
                    NSArray *order = [str componentsSeparatedByString:@"@"];
                    
                    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                    [dict setObject:[order objectAtIndex:2] forKey:@"name"];
                    [dict setObject:[order objectAtIndex:3] forKey:@"price"];
                    [orders addObject:dict];
                }
                
            }
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:2] forKey:@"womanCount"];
            [dicMutInfo setObject:orders forKey:@"orders"];
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:1] forKey:@"manCount"];
            [dicMutInfo setObject:[ary objectAtIndex:1] forKey:@"orderId"];
            [dicMutInfo setObject:tableNum forKey:@"tableNum"];
            [dicMutInfo setObject:strAdditions forKey:@"Additions"];
            
            NSArray *ary = [[aryInfo objectAtIndex:0] componentsSeparatedByString:@";"];
//            NSMutableDictionary *dicResult = [NSMutableDictionary dictionary];
            NSMutableArray *aryResult = [NSMutableArray array];
            int c = [ary count];
            for (int z=0; z<c-1; z++) {
                NSString *str = [ary objectAtIndex:z];
                NSArray *itemAry = [str componentsSeparatedByString:@"@"];
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
                [mutDic setValue:[itemAry objectAtIndex:1]  forKey:@"orderid"];
                [mutDic setValue:[itemAry objectAtIndex:2]  forKey:@"PKID"];
                [mutDic setValue:[itemAry objectAtIndex:3]  forKey:@"pcode"];
                [mutDic setValue:[itemAry objectAtIndex:4]  forKey:@"pcname"];
                [mutDic setValue:[itemAry objectAtIndex:5]  forKey:@"tpcode"];
                [mutDic setValue:[itemAry objectAtIndex:6]  forKey:@"TPNAME"];
                [mutDic setValue:[itemAry objectAtIndex:7]  forKey:@"TPNUM"];
                [mutDic setValue:[itemAry objectAtIndex:8]  forKey:@"pcount"];
                [mutDic setValue:[itemAry objectAtIndex:9]  forKey:@"promonum"];
//                NSArray *aryFujiaCode = [[itemAry objectAtIndex:10] componentsSeparatedByString:@"!"];
                NSArray *aryFujiaName = [[itemAry objectAtIndex:11] componentsSeparatedByString:@"!"];
//                NSArray *aryFujiaPrice = [[itemAry objectAtIndex:13] componentsSeparatedByString:@"!"];
                NSMutableString *strAdditions = [NSMutableString string];
                
                for (int j = 0;j<[aryFujiaName count];j++) {
                    [strAdditions appendString:[aryFujiaName objectAtIndex:j]];
                    [strAdditions appendString:@","];
                }
                float prict=0.0;
                for (int j = 0;j<[[[itemAry objectAtIndex:13] componentsSeparatedByString:@"!"] count];j++) {
                    prict+=[[[[itemAry objectAtIndex:13] componentsSeparatedByString:@"!"] objectAtIndex:j] floatValue];
                    
                }
                
//                NSMutableDictionary *dicFuJia = [NSMutableDictionary dictionary];
//                NSMutableArray *aryFujia = [NSMutableArray array];
//                if ([aryFujiaName count] == [aryFujiaCode count]) {
//                    for (int j = 0;j<[aryFujiaName count];j++) {
//                        if (![[aryFujiaCode objectAtIndex:j] isEqualToString:@""]) {
//                            [dicFuJia setValue:[aryFujiaCode objectAtIndex:j] forKey:@"fujiacode"];
//                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
//                            [dicFuJia setValue:[aryFujiaPrice objectAtIndex:j] forKey:@"fujiaprice"];
//                            [aryFujia addObject:dicFuJia];
//                        }
//                    }
//                }else{
//                    for (int j = 0;j<[aryFujiaName count];j++) {
//                        if (![[aryFujiaName objectAtIndex:j] isEqualToString:@""]) {
//                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
//                            [aryFujia addObject:dicFuJia];
//                        }
//                    }
//                }
                [mutDic setValue:strAdditions  forKey:@"additions"];
                //                    [mutDic setValue:[mutDic objectForKey:11]  forKey:@"fujianame"];
                [mutDic setValue:[itemAry objectAtIndex:12]  forKey:@"price"];
                [mutDic setValue:[NSString stringWithFormat:@"%.2f",prict]  forKey:@"fujiaprice"];
                [mutDic setValue:[itemAry objectAtIndex:14]  forKey:@"weight"];
                [mutDic setValue:[itemAry objectAtIndex:15]  forKey:@"weightflg"];
                [mutDic setValue:[itemAry objectAtIndex:16]  forKey:@"unit"];
                [mutDic setValue:[itemAry objectAtIndex:17]  forKey:@"ISTC"];
                [aryResult addObject:mutDic];
            }
            //注释的部分是将套餐的子类放到foods的中的方法
//            if (aryResult) {
//                NSMutableArray *aryTC = [NSMutableArray array];;
//                for (NSDictionary *dic in aryResult) {
//                    if ([[dic objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
//                        [aryTC addObject:dic];
//                    }
//                }
//                NSMutableArray *aryOver = [NSMutableArray array];
//                if ([aryTC count] > 0) {
//                    
//                    for (NSDictionary *dicTC in aryTC) {
//                        NSMutableArray *aryAddItemTC = [NSMutableArray array];
//                        for (NSDictionary *dicResultTC in aryResult) {
//                            if ([[dicTC objectForKey:@"PKID"] isEqualToString:[dicResultTC objectForKey:@"PKID"]] && [[dicResultTC objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dicTC objectForKey:@"pcode"] isEqualToString:[dicTC objectForKey:@"tpcode"]]) {
//                                [aryAddItemTC addObject:dicResultTC];
//                            }
//                        }
//                        [dicTC setValue:aryAddItemTC forKey:@"foods"];
//                        [aryOver addObject:dicTC];
//                    }
//                }
//                for (NSDictionary *dic in aryResult) {
//                    aryTC = [NSMutableArray array];
//                    if (![[dic objectForKey:@"ISTC"] isEqualToString:@"1"]) {
//                        [aryOver addObject:dic];
//                    }
//                }
//            
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryOver,@"Message",dicMutInfo,@"Info", nil];
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryResult,@"Message",dicMutInfo,@"Info", nil];
        }else{
            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"order not food"],@"Message", nil];
            }else{
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
            }
        }
        }else{
//            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"No order"],@"Message",nil,@"Info", nil];
//            }else{
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],[ary objectAtIndex:1],@"Message",nil,@"Info", nil];
//            }
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message",nil,@"Info", nil];
    }
    return nil;
}



//查询全单
- (NSDictionary *)queryCompletely:(NSDictionary *)info{
    NSString *pdaid,*userCode,*pwd,*tableNum,*orderID;
    pdaid = strPDAID;
    tableNum = [info objectForKey:@"table"];
    if (!tableNum) {
        tableNum = [info objectForKey:@"phone"];
    }
    orderID = [info objectForKey:@"orderID"];
    if (!orderID) {
        orderID = [info objectForKey:@"orderId"];
    }
    NSDictionary *dicResult = (NSDictionary *)[[BSDataProvider sharedInstance] getOrdersBytabNum:tableNum];
    if ([[dicResult objectForKey:@"Result"] boolValue]) {
        orderID = [dicResult objectForKey:@"orderID"];
    }
    NSLog(@"table==>%@",tableNum);
    NSLog(@"orderID--->%@",orderID);
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    //queryCompletely?&deviceId=88&userCode=4&tableNum=5&orderId=H000053
    NSMutableDictionary *dicMutInfo = [NSMutableDictionary dictionary];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",pdaid,userCode,tableNum,orderID];
    NSDictionary *dict = [self bsService:@"queryCompletely" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:queryCompletelyResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] isEqualToString:@"0"]) {
            //获取男人数、女人数、账单号、台位等基本信息
            NSArray *aryInfo = [result componentsSeparatedByString:@"#"];
            NSArray *aryInfoRes =[[aryInfo objectAtIndex:[aryInfo count]-2] componentsSeparatedByString:@"@"];
            NSString *additions = [aryInfo objectAtIndex:[aryInfo count]-1];
            NSArray *aryAddition = [additions componentsSeparatedByString:@";"];
            NSMutableString *strAdditions = [NSMutableString string];
            for (NSString *s in aryAddition) {
                NSArray *ary = [s componentsSeparatedByString:@"@"];
                if ([ary count] >= 2) {
                    [strAdditions appendString:[ary objectAtIndex:1]];
                    [strAdditions appendString:@"、"];
                }
            }
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:2] forKey:@"womanCount"];
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:1] forKey:@"manCount"];
            [dicMutInfo setObject:[ary objectAtIndex:1] forKey:@"orderId"];
            [dicMutInfo setObject:tableNum forKey:@"tableNum"];
            [dicMutInfo setObject:strAdditions forKey:@"Additions"];
            
            NSArray *ary = [[aryInfo objectAtIndex:0] componentsSeparatedByString:@";"];
            //            NSMutableDictionary *dicResult = [NSMutableDictionary dictionary];
            NSMutableArray *aryResult = [NSMutableArray array];
            int c = [ary count];
            for (int z=0; z<c-1; z++) {
                NSString *str = [ary objectAtIndex:z];
                NSArray *itemAry = [str componentsSeparatedByString:@"@"];
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
                [mutDic setValue:[itemAry objectAtIndex:1]  forKey:@"orderid"];
                [mutDic setValue:[itemAry objectAtIndex:2]  forKey:@"PKID"];
                [mutDic setValue:[itemAry objectAtIndex:3]  forKey:@"pcode"];
                [mutDic setValue:[itemAry objectAtIndex:4]  forKey:@"pcname"];
                [mutDic setValue:[itemAry objectAtIndex:5]  forKey:@"tpcode"];
                [mutDic setValue:[itemAry objectAtIndex:6]  forKey:@"TPNAME"];
                [mutDic setValue:[itemAry objectAtIndex:7]  forKey:@"TPNUM"];
                [mutDic setValue:[itemAry objectAtIndex:8]  forKey:@"pcount"];
                [mutDic setValue:[itemAry objectAtIndex:9]  forKey:@"promonum"];
                NSArray *aryFujiaCode = [[itemAry objectAtIndex:10] componentsSeparatedByString:@"!"];
                NSArray *aryFujiaName = [[itemAry objectAtIndex:11] componentsSeparatedByString:@"!"];
                NSArray *aryFujiaPrice = [[itemAry objectAtIndex:13] componentsSeparatedByString:@"!"];
//                [mutDic setValue:[itemAry objectAtIndex:13]  forKey:@"fujiaprice"];
                NSMutableDictionary *dicFuJia = [NSMutableDictionary dictionary];
                NSMutableArray *aryFujia = [NSMutableArray array];
                if ([aryFujiaName count] == [aryFujiaCode count]) {
                    for (int j = 0;j<[aryFujiaName count];j++) {
                        if (![[aryFujiaCode objectAtIndex:j] isEqualToString:@""]) {
                            [dicFuJia setValue:[aryFujiaCode objectAtIndex:j] forKey:@"fujiacode"];
                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
                            [dicFuJia setValue:[aryFujiaPrice objectAtIndex:j] forKey:@"fujiaprice"];
                            [aryFujia addObject:dicFuJia];
                        }
                    }
                }else{
                    for (int j = 0;j<[aryFujiaName count];j++) {
                        if (![[aryFujiaName objectAtIndex:j] isEqualToString:@""]) {
                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
                            [aryFujia addObject:dicFuJia];
                        }
                    }
                }
                [mutDic setValue:aryFujia  forKey:@"additions"];
//                [mutDic setValue:aryFujia  forKey:@"additions"];
                //                    [mutDic setValue:[mutDic objectForKey:11]  forKey:@"fujianame"];
                [mutDic setValue:[itemAry objectAtIndex:12]  forKey:@"price"];
                
                [mutDic setValue:[itemAry objectAtIndex:14]  forKey:@"weight"];
                [mutDic setValue:[itemAry objectAtIndex:15]  forKey:@"weightflg"];
                [mutDic setValue:[itemAry objectAtIndex:16]  forKey:@"unit"];
                [mutDic setValue:[itemAry objectAtIndex:17]  forKey:@"ISTC"];
                [mutDic setValue:[itemAry objectAtIndex:18]  forKey:@"rushCount"];//催菜次数
                [mutDic setValue:[itemAry objectAtIndex:19]  forKey:@"pullCount"];//划菜数量
                [mutDic setValue:[itemAry objectAtIndex:20]  forKey:@"IsQuit"];//推菜标志（0为退菜，1为正常）
                [mutDic setValue:[itemAry objectAtIndex:21]  forKey:@"QuitCause"];//退菜原因
                [aryResult addObject:mutDic];
            }
            //注释的部分是将套餐的子类放到foods的中的方法
            //            if (aryResult) {
            //                NSMutableArray *aryTC = [NSMutableArray array];;
            //                for (NSDictionary *dic in aryResult) {
            //                    if ([[dic objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
            //                        [aryTC addObject:dic];
            //                    }
            //                }
            //                NSMutableArray *aryOver = [NSMutableArray array];
            //                if ([aryTC count] > 0) {
            //
            //                    for (NSDictionary *dicTC in aryTC) {
            //                        NSMutableArray *aryAddItemTC = [NSMutableArray array];
            //                        for (NSDictionary *dicResultTC in aryResult) {
            //                            if ([[dicTC objectForKey:@"PKID"] isEqualToString:[dicResultTC objectForKey:@"PKID"]] && [[dicResultTC objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dicTC objectForKey:@"pcode"] isEqualToString:[dicTC objectForKey:@"tpcode"]]) {
            //                                [aryAddItemTC addObject:dicResultTC];
            //                            }
            //                        }
            //                        [dicTC setValue:aryAddItemTC forKey:@"foods"];
            //                        [aryOver addObject:dicTC];
            //                    }
            //                }
            //                for (NSDictionary *dic in aryResult) {
            //                    aryTC = [NSMutableArray array];
            //                    if (![[dic objectForKey:@"ISTC"] isEqualToString:@"1"]) {
            //                        [aryOver addObject:dic];
            //                    }
            //                }
            //
            //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryOver,@"Message",dicMutInfo,@"Info", nil];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryResult,@"Message",dicMutInfo,@"Info", nil];
        }
//        else if ([[ary objectAtIndex:0] isEqualToString:@"-1"]){
//            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
//                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",@"1",@"MG", nil];
//            }
//        }
    }else{
        //            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
        //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"No order"],@"Message",nil,@"Info", nil];
        //            }else{
        //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],[ary objectAtIndex:1],@"Message",nil,@"Info", nil];
        //            }
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message",nil,@"Info", nil];
    }
    return nil;
}


//查询全单（附加项）
- (NSDictionary *)queryWholeProducts:(NSDictionary *)info{
    NSString *pdaid,*userCode,*pwd,*tableNum,*orderID;
    pdaid = strPDAID;
    tableNum = [info objectForKey:@"table"];
    if (!tableNum) {
        tableNum = [info objectForKey:@"phone"];
    }
    orderID = [info objectForKey:@"orderID"];
    if (!orderID) {
        orderID = [info objectForKey:@"orderId"];
    }
    NSDictionary *dicResult = (NSDictionary *)[[BSDataProvider sharedInstance] getOrdersBytabNum:tableNum];
    if ([[dicResult objectForKey:@"Result"] boolValue]) {
        orderID = [dicResult objectForKey:@"orderID"];
    }
    NSLog(@"table==>%@",tableNum);
    NSLog(@"orderID--->%@",orderID);
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    //queryCompletely?&deviceId=88&userCode=4&tableNum=5&orderId=H000053
    NSMutableDictionary *dicMutInfo = [NSMutableDictionary dictionary];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",pdaid,userCode,tableNum,orderID];
    NSDictionary *dict = [self bsService:@"queryWholeProducts" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:queryWholeProductsResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] isEqualToString:@"0"]) {
            //获取男人数、女人数、账单号、台位等基本信息
            NSArray *aryInfo = [result componentsSeparatedByString:@"#"];
            NSArray *aryInfoRes =[[aryInfo objectAtIndex:[aryInfo count]-2] componentsSeparatedByString:@"@"];
            NSString *additions = [aryInfo objectAtIndex:[aryInfo count]-1];
            NSArray *aryAddition = [additions componentsSeparatedByString:@";"];
            NSMutableString *strAdditions = [NSMutableString string];
            for (NSString *s in aryAddition) {
                NSArray *ary = [s componentsSeparatedByString:@"@"];
                if ([ary count] >= 2) {
                    [strAdditions appendString:[ary objectAtIndex:1]];
                    [strAdditions appendString:@"、"];
                }
            }
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:2] forKey:@"womanCount"];
            [dicMutInfo setObject:[aryInfoRes objectAtIndex:1] forKey:@"manCount"];
            [dicMutInfo setObject:[ary objectAtIndex:1] forKey:@"orderId"];
            [dicMutInfo setObject:tableNum forKey:@"tableNum"];
            [dicMutInfo setObject:strAdditions forKey:@"Additions"];
            
            NSArray *ary = [[aryInfo objectAtIndex:0] componentsSeparatedByString:@";"];
            //            NSMutableDictionary *dicResult = [NSMutableDictionary dictionary];
            NSMutableArray *aryResult = [NSMutableArray array];
            int c = [ary count];
            for (int z=0; z<c-1; z++) {
                NSString *str = [ary objectAtIndex:z];
                NSArray *itemAry = [str componentsSeparatedByString:@"@"];
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
                [mutDic setValue:[itemAry objectAtIndex:1]  forKey:@"orderid"];
                [mutDic setValue:[itemAry objectAtIndex:2]  forKey:@"PKID"];
                [mutDic setValue:[itemAry objectAtIndex:3]  forKey:@"pcode"];
                [mutDic setValue:[itemAry objectAtIndex:4]  forKey:@"pcname"];
                [mutDic setValue:[itemAry objectAtIndex:5]  forKey:@"tpcode"];
                [mutDic setValue:[itemAry objectAtIndex:6]  forKey:@"TPNAME"];
                [mutDic setValue:[itemAry objectAtIndex:7]  forKey:@"TPNUM"];
                [mutDic setValue:[itemAry objectAtIndex:8]  forKey:@"pcount"];
                [mutDic setValue:[itemAry objectAtIndex:9]  forKey:@"promonum"];
                NSArray *aryFujiaCode = [[itemAry objectAtIndex:10] componentsSeparatedByString:@"!"];
                NSArray *aryFujiaName = [[itemAry objectAtIndex:11] componentsSeparatedByString:@"!"];
                NSArray *aryFujiaPrice = [[itemAry objectAtIndex:13] componentsSeparatedByString:@"!"];
//                [mutDic setValue:[itemAry objectAtIndex:13]  forKey:@"fujiaprice"];
                
//                NSMutableString *strAdditions = [NSMutableString string];
//                
//                for (int j = 0;j<[aryFujiaName count];j++) {
//                    [strAdditions appendString:[aryFujiaName objectAtIndex:j]];
//                    [strAdditions appendString:@"、"];
//                }
                
                
                NSMutableArray *aryFujia = [NSMutableArray array];
                if ([aryFujiaName count] == [aryFujiaCode count]) {
                    for (int j = 0;j<[aryFujiaName count];j++) {
                        if (![[aryFujiaCode objectAtIndex:j] isEqualToString:@""]) {
                            NSMutableDictionary *dicFuJia = [NSMutableDictionary dictionary];
                            [dicFuJia setValue:[aryFujiaCode objectAtIndex:j] forKey:@"fujiacode"];
                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
                            [dicFuJia setValue:[aryFujiaPrice objectAtIndex:j] forKey:@"fujiaprice"];
                            [aryFujia addObject:dicFuJia];
                        }
                    }
                }else{
                    for (int j = 0;j<[aryFujiaName count];j++) {
                        if (![[aryFujiaName objectAtIndex:j] isEqualToString:@""]) {
                            NSMutableDictionary *dicFuJia = [NSMutableDictionary dictionary];
                            [dicFuJia setValue:[aryFujiaName objectAtIndex:j] forKey:@"fujianame"];
                            [aryFujia addObject:dicFuJia];
                        }
                    }
                }
                [mutDic setValue:aryFujia  forKey:@"additions"];
                //                [mutDic setValue:aryFujia  forKey:@"additions"];
                //                    [mutDic setValue:[mutDic objectForKey:11]  forKey:@"fujianame"];
                [mutDic setValue:[itemAry objectAtIndex:12]  forKey:@"price"];
                
                [mutDic setValue:[itemAry objectAtIndex:14]  forKey:@"weight"];
                [mutDic setValue:[itemAry objectAtIndex:15]  forKey:@"weightflg"];
                [mutDic setValue:[itemAry objectAtIndex:16]  forKey:@"unit"];
                [mutDic setValue:[itemAry objectAtIndex:17]  forKey:@"ISTC"];
                [mutDic setValue:[itemAry objectAtIndex:18]  forKey:@"rushCount"];//催菜次数
                [mutDic setValue:[itemAry objectAtIndex:19]  forKey:@"pullCount"];//划菜数量
                [mutDic setValue:[itemAry objectAtIndex:20]  forKey:@"IsQuit"];//推菜标志（0为退菜，1为正常）
                [mutDic setValue:[itemAry objectAtIndex:21]  forKey:@"QuitCause"];//退菜原因
                [mutDic setValue:[itemAry objectAtIndex:22]  forKey:@"rushOrCall"];//1即起  2叫起
                [mutDic setValue:[itemAry objectAtIndex:23]  forKey:@"priceDanJian"];//单价
                [aryResult addObject:mutDic];
            }
            //注释的部分是将套餐的子类放到foods的中的方法
            //            if (aryResult) {
            //                NSMutableArray *aryTC = [NSMutableArray array];;
            //                for (NSDictionary *dic in aryResult) {
            //                    if ([[dic objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
            //                        [aryTC addObject:dic];
            //                    }
            //                }
            //                NSMutableArray *aryOver = [NSMutableArray array];
            //                if ([aryTC count] > 0) {
            //
            //                    for (NSDictionary *dicTC in aryTC) {
            //                        NSMutableArray *aryAddItemTC = [NSMutableArray array];
            //                        for (NSDictionary *dicResultTC in aryResult) {
            //                            if ([[dicTC objectForKey:@"PKID"] isEqualToString:[dicResultTC objectForKey:@"PKID"]] && [[dicResultTC objectForKey:@"ISTC"] isEqualToString:@"1"] && [[dicTC objectForKey:@"pcode"] isEqualToString:[dicTC objectForKey:@"tpcode"]]) {
            //                                [aryAddItemTC addObject:dicResultTC];
            //                            }
            //                        }
            //                        [dicTC setValue:aryAddItemTC forKey:@"foods"];
            //                        [aryOver addObject:dicTC];
            //                    }
            //                }
            //                for (NSDictionary *dic in aryResult) {
            //                    aryTC = [NSMutableArray array];
            //                    if (![[dic objectForKey:@"ISTC"] isEqualToString:@"1"]) {
            //                        [aryOver addObject:dic];
            //                    }
            //                }
            //
            //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryOver,@"Message",dicMutInfo,@"Info", nil];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryResult,@"Message",dicMutInfo,@"Info", nil];
        }else if ([[ary objectAtIndex:0] isEqualToString:@"-1"]){
            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",@"1",@"MG", nil];
            }
        }
    }else{
        //            if ([[ary objectAtIndex:1] isEqualToString:@"NULL"]) {
        //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"No order"],@"Message",nil,@"Info", nil];
        //            }else{
        //                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],[ary objectAtIndex:1],@"Message",nil,@"Info", nil];
        //            }
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message",nil,@"Info", nil];
    }
    return nil;
}



//中餐查询
- (NSDictionary *)pQuery1:(NSDictionary *)info{
    NSMutableDictionary *dicMut = [NSMutableDictionary dictionary];
    NSString *userCode,*pwd,*tableNum,*orderID,*pdaid,*manCounts,*womanCounts,*chkCode,*comOrdetach;
    pdaid = strPDAID;
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    tableNum = [info objectForKey:@"table"];
    orderID = [info objectForKey:@"orderID"];
    manCounts = @"1";
    womanCounts = @"1";
    chkCode = userCode;       //查询单授权人
    comOrdetach = @"1";  //账单分开发送 0  合并发送 1
    
    //queryProduct?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&orderId=%@&chkCode=%@&comOrdetach=%@
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&orderId=%@&chkCode=%@&comOrdetach=%@",pdaid,userCode,tableNum,manCounts,womanCounts,orderID,chkCode,comOrdetach];
    
    NSDictionary *dict = [self bsService:@"pQuery" arg:strParam];
    
    NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];
    
    return nil;
    
    NSArray *ary = [result componentsSeparatedByString:@"<"];
    
    if (result && [result rangeOfString:@"error"].location!=NSNotFound){
        [dicMut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
        [dicMut setObject:[[[[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"Message"];
    }else{
        if (![result isEqualToString:@"+query<end>"]){
            
            NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            
            NSArray *aryFenhao = [content componentsSeparatedByString:@";"];
            if ([aryFenhao count]>3){
                NSString *tab = [[[aryFenhao objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *total = [[[aryFenhao objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSString *people = [[[aryFenhao objectAtIndex:2] componentsSeparatedByString:@":"] objectAtIndex:1];
                
                [dicMut setObject:tab forKey:@"tab"];
                [dicMut setObject:total forKey:@"total"];
                [dicMut setObject:people forKey:@"people"];
                
                NSString *account = [[[aryFenhao objectAtIndex:3] componentsSeparatedByString:@":"] objectAtIndex:1];
                NSArray *aryAcc = [account componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
                int countAcc = [aryAcc count];
                
                NSMutableArray *aryMut = [NSMutableArray array];
                for (int i=0;i<countAcc;i++){
                    NSMutableDictionary *mutFood = [NSMutableDictionary dictionary];
                    NSString *strAcc = [aryAcc objectAtIndex:i];
                    NSArray *aryStr = [strAcc componentsSeparatedByString:@"^"];
                    
                    if ([aryStr count]>8){
                        [mutFood setObject:[aryStr objectAtIndex:0] forKey:@"num"];
                        [mutFood setObject:[aryStr objectAtIndex:1] forKey:@"name"];
                        [mutFood setObject:[aryStr objectAtIndex:2] forKey:@"total"];
                        [mutFood setObject:[aryStr objectAtIndex:3] forKey:@"price"];
                        [mutFood setObject:[aryStr objectAtIndex:4] forKey:@"unit"];
                        [mutFood setObject:[aryStr objectAtIndex:5] forKey:@"add1"];
                        [mutFood setObject:[aryStr objectAtIndex:6] forKey:@"add2"];
                        [mutFood setObject:[[[aryStr objectAtIndex:7] componentsSeparatedByString:@"#"] objectAtIndex:1] forKey:@"waiter"];
                        [mutFood setObject:[aryStr objectAtIndex:8] forKey:@"PACKID"];
                        [aryMut addObject:mutFood];
                    }
                    
                }
                
                [dicMut setObject:aryMut forKey:@"account"];
                
                
            }
        }
    }
    return dicMut;
}


- (NSDictionary *)pChuck:(NSDictionary *)info{
    NSString *pdaid,*user,*pwd,*tab,*reason,*foodnum,*userName,*password;
    /*
     function pChuck(PdaID,User,GrantEmp,GrantPass,oSerial,Rsn,Cnt,oStr:PChar):PChar; stdcall; //退菜
     
     参数说明：
     PdaID       :PDA号 //格式'1-1'第一个1为PDA编码，第二个为餐厅号 ，默认为1
     USER        :工号
     GrantEmp    :授权人工号
     GrantPass   :授权人密码
     oSerial     :菜品流水号
     Rsn         :退菜原因码
     Cnt         :退菜数量
     oStr        :返回值
     */
    pdaid = strPDAID;
    user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    
    userName = [info objectForKey:@"user"];
    password = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];

    tab = [info objectForKey:@"tab"];
    reason = [info objectForKey:@"rsn"];
    foodnum = [info objectForKey:@"total"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&GrantEmp=%@&GrantPass=%@&oSerial=%@&Rsn=%@&Cnt=%@",pdaid,user,userName,password,tab,reason,foodnum];
    
    
    NSDictionary *dict = [self bsService:@"pChuck" arg:strParam];
//    NSString *strValue = [[dict objectForKey:@"string"] objectForKey:@"text"];
    if (dict){
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];//[[[[strValue componentsSeparatedByString:@"<oStr>"] objectAtIndex:1] componentsSeparatedByString:@"</oStr>"] objectAtIndex:0];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }
        else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",
                    [[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
        }
    }
    return nil;    
}
//中餐
- (NSArray *)expendList_zhongcan:(NSArray *)ary{
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        BOOL isPack = [[dict objectForKey:@"isPack"] boolValue];
        NSString *total = [NSString stringWithFormat:@"%.2f",[[dict objectForKey:@"total"] floatValue] * 1.00];
        if (isPack){
            NSArray *foods = [dict objectForKey:@"foods"];
            for (int j=0;j<[foods count];j++){
                NSDictionary *food = [foods objectAtIndex:j];
                NSMutableArray *addition = [food objectForKey:@"addition"];
              //  [food removeObjectForKey:@"addition"];
                NSMutableDictionary *mutfood = [NSMutableDictionary dictionaryWithObject:food forKey:@"food"];
                if (addition != NULL) {
                    [mutfood setObject:addition forKey:@"addition"];
                }
                [mutfood setObject:@"PRICE" forKey:@"priceKey"];
                [mutfood setObject:total forKey:@"total"];
                [mutfood setObject:@"UNIT" forKey:@"unitKey"];
                [mut addObject:mutfood];
                
            }
        }else 
            [mut addObject:dict];
    }
    
    return [NSArray arrayWithArray:mut];
}

- (NSArray *)expendList:(NSArray *)ary options:(NSDictionary *)info{
    NSMutableArray *mut = [NSMutableArray array];
    NSString *pdanum,*userCode,*pwd,*tableNum,*orderID,*PKID;
    for (int i=0;i<[ary count];i++){
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[ary objectAtIndex:i]];
//        dict = [ary objectAtIndex:i];
        BOOL isPack = [[dict objectForKey:@"ISTC"] boolValue];
        pdanum = strPDAID;
        userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
        pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
        tableNum = [info objectForKey:@"tableNum"];
        orderID = [info objectForKey:@"orderID"];
        
        int t = [[dict objectForKey:@"total"] intValue];
//        NSString *total = [NSString stringWithFormat:@"%i",t-1];
        if (isPack){
            for (int i = 0; i < t; i++) {
                NSString *total = [NSString stringWithFormat:@"%i",i];
                NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval a=[dat timeIntervalSince1970];
                NSString *timeString = [NSString stringWithFormat:@"%f", a];
                
                PKID=[NSString stringWithFormat:@"%@%@%@%@%@%ld",pdanum,userCode,pwd,tableNum,orderID,(long)timeString];
                
                NSMutableDictionary *mutD = [[NSMutableDictionary alloc] init];
                [mutD setValue:PKID forKey:@"PKID"];
                NSMutableDictionary *foodTC = [[NSMutableDictionary alloc] init];
                [foodTC setValue:[dict objectForKey:@"ITCODE"] forKey:@"ITCODE"];
                [foodTC setValue:[dict objectForKey:@"DES"] forKey:@"DES"];
                [foodTC setValue:[dict objectForKey:@"PRICE"] forKey:@"PRICE"];
                [foodTC setValue:@"套" forKey:@"UNIT"];
                [mutD setValue:foodTC forKey:@"food"];
                
                [mutD setValue:[dict objectForKey:@"ITCODE"] forKey:@"tpcode"];
                [mutD setValue:[dict objectForKey:@"DES"] forKey:@"pcname"];
                [mutD setValue:total forKey:@"TPNUM"];
                [mutD setValue:@"1" forKey:@"total"];
                [mutD setValue:@"1" forKey:@"ISTC"];
                
                [mut addObject:mutD];  //添加套餐作为一条数据
                
                NSArray *foods = [dict objectForKey:@"foods"];
                for (int j=0;j<[foods count];j++){
                    NSDictionary *food = [foods objectAtIndex:j];
                    NSMutableArray *addition = [food objectForKey:@"addition"];
                    //  [food removeObjectForKey:@"addition"];
                    NSMutableDictionary *mutfood = [NSMutableDictionary dictionaryWithObject:food forKey:@"food"];
                    if (addition != NULL) {
                        [mutfood setObject:addition forKey:@"addition"];
                    }
                    [mutfood setObject:@"PRICE" forKey:@"priceKey"];
                    [mutfood setObject:@"1" forKey:@"total"];
                    [mutfood setObject:@"UNIT" forKey:@"unitKey"];
                    
                    [mutfood setObject:total forKey:@"TPNUM"];
                    [mutfood setObject:[dict objectForKey:@"ITCODE"] forKey:@"tpcode"];
                    [mutfood setObject:[dict objectForKey:@"DES"] forKey:@"pcname"];
                    [mutfood setObject:@"1" forKey:@"ISTC"];
                    [mutfood setValue:PKID forKey:@"PKID"];
                    [mut addObject:mutfood];
                    
                }
            }
            
        }else{
            NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%f", a];
            NSString *interval = [timeString substringFromIndex:12];
            
            PKID=[NSString stringWithFormat:@"%@%@%@%@%@%ld",pdanum,userCode,pwd,tableNum,orderID,(long)timeString];
//            PKID=[NSString stringWithFormat:@"%@%@%@%@%@%ld%@",pdanum,userCode,pwd,tableNum,orderID,(long)interval,[[dict objectForKey:@"food"] objectForKey:@"DES"]];
            [dict setValue:PKID forKey:@"PKID"];
            [mut addObject:dict];
        }
    }
    
    return [NSArray arrayWithArray:mut];
}

- (NSArray *)expendList:(NSArray *)ary{
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<[ary count];i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        BOOL isPack = [[dict objectForKey:@"isPack"] boolValue];
        NSString *total = [NSString stringWithFormat:@"%.2f",[[dict objectForKey:@"total"] floatValue] * 1.00];
        if (isPack){
            NSArray *foods = [dict objectForKey:@"foods"];
            for (int j=0;j<[foods count];j++){
                NSDictionary *food = [foods objectAtIndex:j];
                NSMutableArray *addition = [food objectForKey:@"addition"];
                //  [food removeObjectForKey:@"addition"];
                NSMutableDictionary *mutfood = [NSMutableDictionary dictionaryWithObject:food forKey:@"food"];
                if (addition != NULL) {
                    [mutfood setObject:addition forKey:@"addition"];
                }
                [mutfood setObject:@"PRICE" forKey:@"priceKey"];
                [mutfood setObject:total forKey:@"total"];
                [mutfood setObject:@"UNIT" forKey:@"unitKey"];
                [mut addObject:mutfood];
                
            }
        }else
            [mut addObject:dict];
    }
    
    return [NSArray arrayWithArray:mut];
}

- (NSArray *)foldList:(NSArray *)ary{
    NSMutableArray *mut = [NSMutableArray array];
    NSMutableArray *mutpack = [NSMutableArray array];
    for (int i=0;i<[ary count];i++){
        NSDictionary *food = [ary objectAtIndex:i];
        if ([[food objectForKey:@"PACKID"] intValue]>0)
            [mutpack addObject:food];
        else
            [mut addObject:food];
    }
    
    NSMutableSet *mutset = [NSMutableSet set];
    
    for (int i=0;i<[mutpack count];i++){
        if (![mutset containsObject:[[mutpack objectAtIndex:i] objectForKey:@"PACKID"]])
            [mutset addObject:[[mutpack objectAtIndex:i] objectForKey:@"PACKID"]];
    }
    return nil;
}

//中餐发送
- (NSString *)pSendTab_zc:(NSArray *)ary options:(NSDictionary *)info{
    if (ary && [ary count]>0){
        ary = [self expendList:ary];

        NSString *pdaid,*user,*acct,*tb,*usr,*pn,*type,*cmd,*pwd;
        NSMutableString *addition = [NSMutableString string];
        NSMutableString *tablist = [NSMutableString string];
        int tabid,foodnum;
        
        pdaid = strPDAID;
        user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
        pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
        if (pwd)
            user = [NSString stringWithFormat:@"%@-%@",user,pwd];
        tabid = dSendCount++;
         NSString *commandString = @"0";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
            commandString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommandString"];
        }
        acct = commandString?commandString:@"0";
        tb = [info objectForKey:@"table"];
        usr = [info objectForKey:@"usr"];
        usr = usr?usr:user;
        pn = [info objectForKey:@"pn"];//@"4";
        if (0==[pn intValue])
            pn = @"4";
        foodnum = [ary count];  //菜品数量
        type = [info objectForKey:@"type"]; //type  即起 叫起

        
        [addition appendString:@"|"];
        
         NSMutableArray *commonAry = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommonAdditions"];
        
        for (int i=0;i<foodnum;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            NSMutableArray *aryMut = [NSMutableArray array];
            
           // [commonAry addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            if ([info objectForKey:@"common"])
                [aryMut addObjectsFromArray:[info objectForKey:@"common"]];
            if (commonAry) {
                [aryMut addObjectsFromArray:commonAry];
            }
            if ([dic objectForKey:@"addition"])
                [aryMut addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            int additionCount = [aryMut count];
            for (int i=0;i<10;i++){
                if (i%2==0){
                    int index = i/2;
                    if (index<additionCount)
                        [addition appendString:[[aryMut objectAtIndex:index] objectForKey:@"DES"]];
                    [addition appendString:@"|"];
                }
                else{
                    int index = (i-1)/2;
                    if (index<additionCount){
                        NSString *additionprice = [[aryMut objectAtIndex:index] objectForKey:@"PRICE1"];
                        if (!additionprice)
                            additionprice = @"0.0";
                        [addition appendString:additionprice];
                    }
                        
                    [addition appendString:@"|"];
                }
                
            }
            
            int packid = [[[dic objectForKey:@"food"] objectForKey:@"PACKID"] intValue];
            int packcnt = [[[dic objectForKey:@"food"] objectForKey:@"PACKCNT"] intValue];
            packid = 0==packid?-1:packid;
//            packcnt = 0==packcnt?-1:packcnt;
            
            float fTotal = [[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"priceKey"]?[dic objectForKey:@"priceKey"]:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]] floatValue];
//            [tablist appendFormat:@"-1|0|%@|%@|%@|%@|0.00%@0|\n",[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:@"UNIT"],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            [tablist appendFormat:@"%d|%d|%@|%@|%@|%@|0.00%@0|^",packid,packcnt,[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"unitKey"]],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            
            addition = [NSMutableString string];
            [addition appendFormat:@"|"];
        }

        
        cmd = [NSString stringWithFormat:@"+sendtab<pdaid:%@;user:%@;tabid:%d;acct:%@;tb:%@;usr:%@;pn:%@;foodnum:%d;type:%@;tablist:%@;>^",pdaid,user,tabid,acct,tb,usr,pn,foodnum,type,tablist];
        
        return cmd;
        [self uploadFood:cmd];
        

        
        NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&PdaSerial=%d&Acct=%@&TblInit=%@&Waiter=%@&Pax=%@&zCnt=%d&Typ=%@&sbBuffer=%@",pdaid,user,tabid,acct,tb,usr,pn,foodnum,type,tablist];
        
        
        
        
        NSDictionary *dict;
        dict = [self bsService:@"pSendTab" arg:strParam];
        if (dict) {

            NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
            NSArray *ary = [result componentsSeparatedByString:@"<"];
            NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
            if (range.location != NSNotFound) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",
                        [[[[[ary objectAtIndex:1] componentsSeparatedByString:@"msg:"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",[[[[[ary objectAtIndex:1] componentsSeparatedByString:@"msg"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1],@"tab", nil];
            } else {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[[[[[ary objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0],@"Message",nil];
            }
        }
    }
    
    return nil;
}


- (NSString *)pSendTab1:(NSArray *)ary options:(NSDictionary *)info{
    if (ary && [ary count]>0){
        ary = [self expendList:ary];
        
        NSString *pdaid,*user,*acct,*tb,*usr,*pn,*type,*cmd,*pwd;
        NSMutableString *addition = [NSMutableString string];
        NSMutableString *tablist = [NSMutableString string];
        int tabid,foodnum;
        
        pdaid = strPDAID;
        user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
        pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
        if (pwd)
            user = [NSString stringWithFormat:@"%@-%@",user,pwd];
        tabid = dSendCount++;
        NSString *commandString = @"0";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
            commandString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommandString"];
        }
        acct = commandString?commandString:@"0";
        tb = [info objectForKey:@"table"];
        usr = [info objectForKey:@"usr"];
        usr = usr?usr:user;
        pn = [info objectForKey:@"pn"];//@"4";
        if (0==[pn intValue])
            pn = @"4";
        foodnum = [ary count];  //菜品数量
        type = [info objectForKey:@"type"]; //type  即起 叫起
        
        
        [addition appendString:@"|"];
        
        NSMutableArray *commonAry = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommonAdditions"];
        
        for (int i=0;i<foodnum;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            NSMutableArray *aryMut = [NSMutableArray array];
            
            // [commonAry addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            if ([info objectForKey:@"common"])
                [aryMut addObjectsFromArray:[info objectForKey:@"common"]];
            if (commonAry) {
                [aryMut addObjectsFromArray:commonAry];
            }
            if ([dic objectForKey:@"addition"])
                [aryMut addObjectsFromArray:[dic objectForKey:@"addition"]];
            
            int additionCount = [aryMut count];
            for (int i=0;i<10;i++){
                if (i%2==0){
                    int index = i/2;
                    if (index<additionCount)
                        [addition appendString:[[aryMut objectAtIndex:index] objectForKey:@"DES"]];
                    [addition appendString:@"|"];
                }
                else{
                    int index = (i-1)/2;
                    if (index<additionCount){
                        NSString *additionprice = [[aryMut objectAtIndex:index] objectForKey:@"PRICE1"];
                        if (!additionprice)
                            additionprice = @"0.0";
                        [addition appendString:additionprice];
                    }
                    
                    [addition appendString:@"|"];
                }
                
            }
            
            int packid = [[[dic objectForKey:@"food"] objectForKey:@"PACKID"] intValue];
            int packcnt = [[[dic objectForKey:@"food"] objectForKey:@"PACKCNT"] intValue];
            packid = 0==packid?-1:packid;
            //            packcnt = 0==packcnt?-1:packcnt;
            
            float fTotal = [[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"priceKey"]?[dic objectForKey:@"priceKey"]:[[NSUserDefaults standardUserDefaults] stringForKey:@"price"]] floatValue];
            //            [tablist appendFormat:@"-1|0|%@|%@|%@|%@|0.00%@0|\n",[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:@"UNIT"],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            [tablist appendFormat:@"%d|%d|%@|%@|%@|%@|0.00%@0|^",packid,packcnt,[[dic objectForKey:@"food"] objectForKey:@"ITCODE"],[dic objectForKey:@"total"],[[dic objectForKey:@"food"] objectForKey:[dic objectForKey:@"unitKey"]],[NSString stringWithFormat:@"%.2f",fTotal],addition];
            
            addition = [NSMutableString string];
            [addition appendFormat:@"|"];
        }
        
        
        cmd = [NSString stringWithFormat:@"+sendtab<pdaid:%@;user:%@;tabid:%d;acct:%@;tb:%@;usr:%@;pn:%@;foodnum:%d;type:%@;tablist:%@;>^",pdaid,user,tabid,acct,tb,usr,pn,foodnum,type,tablist];
        
        return cmd;
    }
    
    return nil;
}

//发送菜
- (NSDictionary *)pSendTab:(NSArray *)ary options:(NSDictionary *)info{
    if (ary && [ary count]>0){
        ary = [self expendList:ary options:info];
        
    NSString *pdanum,*userCode,*pwd,*tableNum,*orderID,*rebackReason;
    NSString *PKID,*Pcode,*PCname,*Tpcode,*TPNAME,*TPNUM,*pcount,*Price,*Weight,*Weightflg,*isTC,*promonum,*immediateOrWait,*UNIT;
    NSMutableString *Fujiacode,*FujiaName,*FujiaPrice;
//    tableNum
    pdanum = strPDAID;
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    tableNum = [info objectForKey:@"tableNum"];
    orderID = [info objectForKey:@"orderID"];
    rebackReason = @"";  //退菜原因
    immediateOrWait = [info objectForKey:@"immediateOrWait"]; //即起叫起
    //PKID=_PKID,Pcode=_Pcode,PCname=_PCname,Tpcode=_Tpcode,TPNAME=_TPNAME,TPNUM=_TPNUM,pcount=_pcount,Fujiacode=_Fujiacode,Price=_Price,Weight=_Weight,Weightflg=_Weightflg
    
    NSMutableString *mutfood = [NSMutableString string];
    for (int i=0; i<ary.count; i++) {
        NSDictionary *mutDic = [ary objectAtIndex:i];
        NSDictionary *dict=[mutDic objectForKey:@"food"];
        Fujiacode=[NSMutableString string];
        FujiaName=[NSMutableString string];
        FujiaPrice=[NSMutableString string];
        
//        PKID=[NSString stringWithFormat:@"%@%@%@%@%@%ld%@",pdanum,userCode,pwd,tableNum,orderID,(long)interval,[dict objectForKey:@"DES"]];
        PKID = [mutDic objectForKey:@"PKID"];
        Pcode=[dict objectForKey:@"ITCODE"];//菜品的 产品编码
        if (!Pcode) {
            Pcode=[dict objectForKey:@"PCODE1"];  //套餐子菜品的 产品名称
        }
        PCname = @"";
//        PCname=[dict objectForKey:@"DES"];//菜品的 产品名称
//        if (!PCname) {
//            PCname=[dict objectForKey:@"PNAME"];  //套餐子菜品的 产品名称
//        }
        
        Tpcode=[mutDic objectForKey:@"tpcode"];   //套餐编码
        TPNAME = @"";
//        TPNAME=[mutDic objectForKey:@"pcname"];   //套餐名称
        TPNUM=[mutDic objectForKey:@"TPNUM"];     //套餐序号
        
        NSInteger count = [[mutDic objectForKey:@"total"] integerValue];
        pcount= [NSString stringWithFormat:@"%d",count];    //数量

//        pcount= [NSString stringWithFormat:@"%@",[mutDic objectForKey:@"total"]];    //数量
        
        promonum=@"0";  //赠送数量 ？？暂时没有
        
        NSArray *array=[mutDic objectForKey:@"addition"];
        for (NSDictionary *dict1 in array) {
            [Fujiacode appendFormat:@"%@",[dict1 objectForKey:@"FOODFUJIA_ID"]];
            [Fujiacode appendString:@"!"];
//            [FujiaName appendFormat:@"%@",[dict1 objectForKey:@"FoodFuJia_Des"]];
            [FujiaName appendString:@"!"];
            [FujiaPrice appendFormat:@"%@",[dict1 objectForKey:@"FoodFujia_Checked"]];
            [FujiaPrice appendString:@"!"];
        }
//        FujiaName = @"";
        
        Price=[dict objectForKey:@"PRICE"];  //价格
        if (!Price) {
            Price=[dict objectForKey:@"PRICE1"];
        }
        if ([[dict objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
            Weight=[dict objectForKey:@"UNITCUR2"];
            Weightflg=@"2"; //第二单位标志  1 第一单位  2 第二单位
        }else{
            Weight=@"0";                         //第二单位重量
            //        Weightflg=[dict objectForKey:@"UNIT2"];
            Weightflg=@"1"; //第二单位标志  1 第一单位  2 第二单位
        }
        
        UNIT = @"";
//        UNIT=[dict objectForKey:@"UNIT"];   //单位
        isTC=[mutDic objectForKey:@"ISTC"];   //是否是套餐
        if (!isTC) {
            isTC = @"0";
        }
        
        [mutfood appendFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@",PKID,Pcode,PCname,Tpcode,TPNAME,TPNUM,pcount,promonum,Fujiacode,FujiaName,Price,FujiaPrice,Weight,Weightflg,UNIT,isTC];
        [mutfood appendString:@";"];
    }
        
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&chkCode=%@&tableNum=%@&orderId=%@&productList=%@&rebackReason=%@&immediateOrWait=%@",pdanum,userCode,@"",tableNum,orderID,mutfood,rebackReason,immediateOrWait];
    
    NSDictionary *dict = [self bsService:@"checkFoodAvailable" arg:strParam];
    
        if (dict) {
            NSString *result = [[[dict objectForKey:@"ns:sendcResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
            NSArray *ary = [result componentsSeparatedByString:@"@"];
            NSString *content = [ary objectAtIndex:0];
            if ([content isEqualToString:@"0"]) {
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
            }else
                return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"Too many to send"],@"Message", nil];
        }
    }
    return nil;
}

//发送公共附加项 ,特别备注
- (NSDictionary *)pSpecialRemark:(NSDictionary *)info{

    NSString *pdaid,*userCode,*orderID,*flag;
    pdaid = strPDAID;
    userCode = userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    orderID = [info objectForKey:@"orderID"];
    flag = @"1";  // 添加是 1  取消是 0
    
     NSMutableArray *commonAry = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommonAdditions"];
    NSMutableString *remarkId = [NSMutableString string];
    NSMutableString *remark = [NSMutableString string];
    
    for (NSDictionary *dicAdditions in commonAry) {
        [remarkId appendFormat:@"%@",[dicAdditions objectForKey:@"Id"]];
        [remarkId appendString:@"!"];
        [remark appendFormat:@"%@",[dicAdditions objectForKey:@"DES"]];
        [remark appendString:@"!"];
    }
    //deviceId=888&userCode=1&orderId=H000028&remarkIdList=11!1!&remarkList=白汤!甜麻辣汁!&flag=1
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&remarkIdList=%@&remarkList=%@&flag=%@",pdaid,userCode,orderID,remarkId,remark,flag];
    NSDictionary *dict = [self bsService:@"specialRemark" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:specialRemarkResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }
    return nil;
    
}


//中餐
- (NSDictionary *)pListTable_zc:(NSDictionary *)info{
    //+listtable<user:%s;pdanum:%s;floor:%s;area:%s;status:%s;>\r\n
    //'全部状态' '空闲' '开台点菜' '开台未点' '预订' '预结'全部楼层=ALLFLOOR全部区域=ALLAREA全部状态=ALLSTA
    /*
     '空闲'=A  
     '开台点菜'=B
     '开台未点'=C
     '预订'=D
     '预结'=E
     */
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    
    NSString *user,*pdanum,*floor,*area,*status;
    NSString *cmd;
    user = @"-";
    pdanum = strPDAID;
    floor = [info objectForKey:@"floor"];
    if (!floor)
        floor = @"";
    area = [info objectForKey:@"area"];
    if (!area)
        area = @"";
    status = [info objectForKey:@"status"];
    if (!status)
        status = @"";
    
    cmd = [NSString stringWithFormat:@"+listtable<user:%@;pdanum:%@;floor:%@;area:%@;status:%@;>\r\n",user,pdanum,floor,area,status];
   
    NSString *strParam = [NSString stringWithFormat:@"?User=%@&Floor=%@&Area=%@&Status=%@&PdaId=%@&iRecNo=",user,floor,area,status,pdanum];
    NSDictionary *dict = [self bsService:@"ZcpListTable" arg:strParam];
   
    if (dict){
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        if ([[content componentsSeparatedByString:@":"] count]<2){
            
            [mut setObject:[NSNumber numberWithBool:YES] forKey:@"Result"];
            
            NSArray *aryTables = [content componentsSeparatedByString:@"|"];
            
            NSMutableArray *mutTables = [NSMutableArray array];
            
            for (NSString *strTable in aryTables){
                
                NSArray *aryTableInfo = [strTable componentsSeparatedByString:@"^"];
                NSMutableDictionary *mutTable = [NSMutableDictionary dictionary];
                
                if ([aryTableInfo count]>=4){
                    [mutTable setObject:[aryTableInfo objectAtIndex:0] forKey:@"code"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:1] forKey:@"short"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:2] forKey:@"name"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:3] forKey:@"status"];
                    
                    [mutTables addObject:mutTable];
                }
                
            }
            
            [mut setObject:mutTables forKey:@"Message"];
            
        }
        else{
            NSRange range = [content rangeOfString:@"error"];
            if (range.location!=NSNotFound){
                [[NSNotificationCenter defaultCenter] postNotificationName:msgListTable object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"查询失败",@"Message", nil]];
            }
        }
    }
    
    
    return mut;
}

//快餐查询台位状态
- (NSDictionary *)pListTable:(NSDictionary *)info{
    //+listtable<user:%s;pdanum:%s;floor:%s;area:%s;status:%s;>\r\n
    //'全部状态' '空闲' '开台点菜' '开台未点' '预订' '预结'全部楼层=ALLFLOOR全部区域=ALLAREA全部状态=ALLSTA
    /*
     '空闲'=A
     '开台点菜'=B
     '开台未点'=C
     '预订'=D
     '预结'=E
     */
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    
    NSString *user,*pdanum,*floor,*area,*status;
    NSString *cmd;
    user =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    
    pdanum = strPDAID;
    floor = [info objectForKey:@"floor"];
    if (!floor)
        floor = @"";
    area = [info objectForKey:@"area"];
    if (!area)
        area = @"";
    status = [info objectForKey:@"status"];
    if (!status)
        status = @"";
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&area=%@&floor=%@&state=%@",pdanum,user,area,floor,status];
    NSDictionary *dict = [self bsService:@"pListTable" arg:strParam];
    
    if (dict){
        NSString *result = [[[dict objectForKey:@"ns:listTablesResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *aryTables = [result componentsSeparatedByString:@";"];
            NSMutableArray *mutTables = [NSMutableArray array];
            for (NSString *strTable in aryTables){
                NSArray *aryTableInfo = [strTable componentsSeparatedByString:@"@"];
                NSMutableDictionary *mutTable = [NSMutableDictionary dictionary];
                if ([aryTableInfo count]>=5){
                    [mutTable setObject:[aryTableInfo objectAtIndex:0] forKey:@"code"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:1] forKey:@"FloorId"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:2] forKey:@"areaId"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:3] forKey:@"name"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:4] forKey:@"status"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:5] forKey:@"tablename"];
                    [mutTable setObject:[aryTableInfo objectAtIndex:6] forKey:@"person"];
                    [mutTables addObject:mutTable];
                }else{
                   [mut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
                   [mut setObject:[aryTableInfo objectAtIndex:1] forKey:@"Message"];
                    return mut;
                }
                
            }
            [mut setObject:[NSNumber numberWithBool:YES] forKey:@"Result"];
            [mut setObject:mutTables forKey:@"Message"];
            return mut;
        }else{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:msgListTable object:dic];
            return dic;
        }
   
    
}

//中餐开台
- (NSDictionary *)pStart_zc:(NSDictionary *)info{
    //"+start<pdaid:%s;user:%s;table:%s;peoplenum:%s;waiter:%s;acct:%s;>\r\n")},//3.开台start
    NSString *pdaid,*user,*table,*peoplenum,*waiter,*acct,*pwd;
//    NSString *cmd;

    pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    table = [info objectForKey:@"table"];
    peoplenum = [info objectForKey:@"people"];
    waiter = [info objectForKey:@"waiter"];
    if (!waiter)
        waiter = user;
    if (!peoplenum)
        peoplenum = @"0";
    acct = @"1";
    

    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%@&TblInit=%@&Pax=%@&Waiter=%@",pdaid,user,acct,table,peoplenum,waiter];
    NSDictionary *dict = [self bsService:@"zcStart" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:1],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:1],@"Message", nil];
    }
    return nil;
  //   点击确定后后跳出一个窗口，输入人数和服务员号，以及工号密码，服务员号和人数可不输，人数不输为0，服务员好为空。
     
}

- (NSDictionary *)pStart:(NSDictionary *)info{
    //"+start<pdaid:%s;user:%s;table:%s;peoplenum:%s;waiter:%s;acct:%s;>\r\n")},//3.开台start
    NSString *pdaid,*userCode,*tableNum,*man,*woman;
    pdaid = strPDAID;
    userCode = [info objectForKey:@"userCode"];
    tableNum = [info objectForKey:@"tableNum"];
    woman = [info objectForKey:@"woman"];
    man = [info objectForKey:@"man"];
    if (!woman)
        woman = @"0";
    if (!man)
        man = @"0";
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@&ktKind=1&openTablemwyn=1",pdaid,userCode,tableNum,man,woman];
    NSDictionary *dict = [self bsService:@"pStart" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:startcResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//中餐取消开台
- (NSDictionary *)pOver_zc:(NSDictionary *)info{
    //+over<pdaid:%s;user:%s;table:%s;>\r\n")},4.取消开台
    NSString *pdaid,*user,*table,*pwd;
    
    pdaid = [info objectForKey:@"pdaid"];
    pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    
    table = [info objectForKey:@"table"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@",pdaid,user,table];
    NSDictionary *dict = [self bsService:@"pOver" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent lastObject],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent lastObject],@"Message", nil];
    }
    return nil;
}

//取消开台
- (NSDictionary *)pOver:(NSDictionary *)info{
    NSString *pdaid,*userCode,*tableNum,*pwd;
    
    pdaid = strPDAID;
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    tableNum = [info objectForKey:@"table"];
   // ?&deviceId=%@&userCode=%@&tableNum=%@&currentState=&nextState=1
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&currentState=&nextState=1",pdaid,userCode,tableNum];
    NSDictionary *dict = [self bsService:@"changTableState" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:changTableStateResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}
//中餐换台
- (NSDictionary *)pChangeTable_zc:(NSDictionary *)info{
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n")},//6.换台changetable
    //+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n
    NSString *pdaid,*user,*oldtable,*newtable,*pwd,*userName;

    
    pdaid = strPDAID;
    userName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    user = [NSString stringWithFormat:@"%@-%@",userName,pwd];
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];

    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@-%@&dTblInit=&Typ=",pdaid,user,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"pSigntebC" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        if ([result rangeOfString:@"ok"].location==NSNotFound){
            NSString *msg = [[[[result componentsSeparatedByString:@"error:"] objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",msg,@"Message",nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",nil];
    }
    return nil;
}
//换台
- (NSDictionary *)pChangeTable:(NSDictionary *)info{
    NSString *pdaid,*userCode,*oldtable,*newtable,*pwd;
    
    
    pdaid = strPDAID;//[info objectForKey:@"pdaid"];
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];
    
    //changeTable?&deviceId=81&userCode=1&tablenumSource=1&tablenumDest=2
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tablenumSource=%@&tablenumDest=%@",pdaid,userCode,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"pSignTeb" arg:strParam];

    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:changeTableResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//并台
- (NSDictionary *)pCombineTable:(NSDictionary *)info{
    NSString *pdaid,*userCode,*oldtable,*newtable,*pwd;
    
    pdaid = strPDAID;//[info objectForKey:@"pdaid"];
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    
    oldtable = [info objectForKey:@"oldtable"];
    newtable = [info objectForKey:@"newtable"];
    
    //changeTable?&deviceId=81&userCode=1&tablenumSource=1&tablenumDest=2
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableList=%@@%@",pdaid,userCode,oldtable,newtable];
    NSDictionary *dict = [self bsService:@"combineTable" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:combineTableResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//- (NSDictionary *)pPrintQuery:(NSDictionary *)info{
//    //+printquery<pdaid:%s;user:%s;tab:%s;type:%s;>\r\n"
//    NSString *pdaid,*user,*tab,*type,*pwd;
//
//    
//    pdaid = strPDAID;
//    user = [info objectForKey:@"user"];
//    pwd = [info objectForKey:@"pwd"];
//    if (pwd)
//        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
//    tab = [info objectForKey:@"tab"];
//    type = [info objectForKey:@"type"];
//
//    
//    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%@&Typ=%@",pdaid,user,tab,type];
//    
//    NSDictionary *dict = [self bsService:@"pPrintQuery" arg:strParam];
//    if (dict) {
//       NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
//        NSArray *ary = [result componentsSeparatedByString:@"<"];
//        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
//        NSArray *aryContent = [content componentsSeparatedByString:@":"];
//        NSRange range = [content rangeOfString:@"error"];
//        if (range.location!=NSNotFound){
//            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
//        }
//        else
//            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
//    }    
//    return nil;
//}

- (NSDictionary *)pPrintQuery:(NSDictionary *)info{
    //+printquery<pdaid:%s;user:%s;tab:%s;type:%s;>\r\n"
    NSString *pdaid,*user,*tab,*type,*pwd;
    
    
    pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    tab = [info objectForKey:@"tab"];
    type = [info objectForKey:@"type"];
    
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Acct=%@&Typ=%@",pdaid,user,tab,type];
    
    NSDictionary *dict = [self bsService:@"pPrintQuery" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@":"];
        NSRange range = [content rangeOfString:@"error"];
        if (range.location!=NSNotFound){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
        }
        else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:2],@"Message", nil];
    }
    return nil;
}

- (NSDictionary *)pListSubscribeOfTable:(NSDictionary *)info{
    NSString *pdaid,*user,*table;
    
    pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    table = [info objectForKey:@"table"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&TblInit=%@",pdaid,user,table];
    
    NSDictionary *dict = [self bsService:@"pListSubscribeOfTable" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        NSArray *aryContent = [content componentsSeparatedByString:@"^"];
        
        
        NSMutableDictionary *mut = [NSMutableDictionary dictionary];
        for (NSString *subcontent in aryContent){
            NSArray *arysub = [subcontent componentsSeparatedByString:@":"];
            NSString *key = [arysub objectAtIndex:0];
            
            NSMutableString *strsub = [NSMutableString string];
            for (int i=1;i<[arysub count];i++){
                [strsub appendString:[arysub objectAtIndex:i]];
                if (i!=[arysub count]-1)
                    [strsub appendString:@":"];
            }
            NSString *value = [strsub length]>0?strsub:nil;
            
            if (value)
                [mut setObject:value forKey:key];
        }
        
        NSArray *arary = [result componentsSeparatedByString:@"account:"];
        NSMutableString *mutstr = [NSMutableString string];
        if ([arary count]>1){
            NSString *account = [arary objectAtIndex:1];
            NSArray *foodsary = [account componentsSeparatedByString:@"^"];
            int foodcount = [foodsary count]/8;
            for (int j=0;j<foodcount;j++){
                [mutstr appendString:@"\n"];
                for (int k=0;k<8;k++){
                    [mutstr appendFormat:@"%@ ",[foodsary objectAtIndex:8*j+k]];
                }
            }
        }
        if ([mutstr length]>0){
            [mut setObject:mutstr forKey:@"account"];
        }
        
        dict = [NSDictionary dictionaryWithDictionary:mut];
    } 

    
    return dict;
}

- (NSArray *)pListResv:(NSDictionary *)info{
    NSString *pdaid,*user;
    
    pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@",pdaid,user];
    
    NSDictionary *dict = [self bsService:@"pListResv" arg:strParam];
    
    NSMutableArray *mut = [NSMutableArray array];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
        content = [content stringByReplacingOccurrencesOfString:@"acct:" withString:@""];
        NSArray *aryContent = [content componentsSeparatedByString:@"|"];
        
        
        
        for (NSString *subcontent in aryContent){
            NSArray *arysub = [subcontent componentsSeparatedByString:@"^"];
            
            
            if ([arysub count]>7){
                
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
                [mutdict setObject:[arysub objectAtIndex:0] forKey:@"acct"];
                for (int i=1;i<8;i++){
                    NSArray *kv = [[arysub objectAtIndex:i] componentsSeparatedByString:@":"];
                    NSString *key = [kv objectAtIndex:0];
                    NSMutableString *strsub = [NSMutableString string];
                    for (int i=1;i<[kv count];i++){
                        [strsub appendString:[kv objectAtIndex:i]];
                        if (i!=[kv count]-1)
                            [strsub appendString:@":"];
                    }
                    NSString *value = [strsub length]>0?strsub:nil;
                    
                    if (value)
                        [mutdict setObject:value forKey:key];
                }
                
                [mut addObject:mutdict];
            }
        }
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:mut,@"Result", nil];
    } 
    
    return [mut count]>0?mut:nil;
}
//中餐登陆
- (NSDictionary *)pLoginUser_zc:(NSDictionary *)info{
    NSString *user,*pwd;
    
    user = [info objectForKey:@"username"];
    pwd = [info objectForKey:@"password"];

    NSString *padID = strPDAID;
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&User=%@&Pass=%@",padID,user,pwd];
    
    NSDictionary *dict = [self bsService:@"zcLoginUser" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        NSRange range = [[ary objectAtIndex:1] rangeOfString:@"ok"];
        if (range.length > 0){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",@"登陆失败",@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network timeout"],@"Message", nil];
    }
}
//登陆
- (NSDictionary *)pLoginUser:(NSDictionary *)info{
    NSString *user,*pwd;
    
    user = [info objectForKey:@"username"];
    pwd = [info objectForKey:@"password"];
    NSString *pdaid = strPDAID;
//    NSString *pdaid = [NSString stringWithFormat:@"%@",[self padID]];
//    UIDevice *myDevice = [UIDevice currentDevice];
//    NSString *deviceID = [myDevice uniqueIdentifier];equipment
    NSString *deviceID = [NSString performSelector:@selector(UUIDString)];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&handvId=%@&userCode=%@&userPass=%@",pdaid,deviceID,user,pwd];
    NSDictionary *dict = [self bsService:@"pLoginUser" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:loginResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if (ary == nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"server not open"],@"Message", nil];
        }
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"time",[ary objectAtIndex:2],@"jurisdiction",[ary objectAtIndex:3],@"decimal",[ary objectAtIndex:4],@"posVersion",[ary objectAtIndex:5],@"dataVersion", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network timeout"],@"Message", nil];
    }
    return dict;
}

//注销
- (NSDictionary *)pLoginOut{
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    NSString *pdaid = strPDAID;
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",pdaid,userCode];
    NSDictionary *dict = [self bsService:@"loginOut" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:loginOutResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if (ary == nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"server not open"],@"Message", nil];
        }
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return dict;
}

//授权
-(NSDictionary *)pCheckAuth:(NSDictionary *)info
{
    NSString *padID = strPDAID;
    NSString *user=[info objectForKey:@"userCode"];
    NSString *pass=[info objectForKey:@"userPass"];
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&userPass=%@",padID,user,pass];
    NSDictionary *dict = [self bsService:@"checkAuth" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:checkAuthResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }
    return dict;
}

//推菜
-(NSDictionary *)callPubitem:(NSDictionary *)dicInfo productList:(NSArray *)aryResult{
    NSString *tableNum,*orderId,*userCode,*deviceId,*productList;
    tableNum = [dicInfo objectForKey:@"tableNum"];
    orderId = [dicInfo objectForKey:@"orderId"];
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    deviceId = strPDAID;
    NSString *pkid,*tpname,*tpnum,*fujiacode,*fujianame,*fujiaprice,*order,*pcname,*pcode,*pcount,*price,*promonum,*tpcode,*unit,*weight,*weightflg,*ISTC,*product;
    fujiacode = @"";
    fujianame = @"";
    productList = @"";
    
    
    for (NSDictionary *dicResult in aryResult) {
        product = nil;
        pkid = [dicResult objectForKey:@"PKID"];
        tpname = [dicResult objectForKey:@"TPNAME"];
        tpnum = [dicResult objectForKey:@"TPNUM"];
        NSArray *aryAdditions = [dicResult objectForKey:@"additions"];
        for (NSDictionary *dicAdditions in aryAdditions) {
            if (![[dicAdditions objectForKey:@"fujiacode"] isEqualToString:@""]) {
                fujiacode = [fujiacode stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujiacode"]];
                fujianame = [fujianame stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujianame"]];
            }
        }
        fujiaprice = [dicResult objectForKey:@"fujiaprice"];
        order = [dicResult objectForKey:@"orderid"];
        pcname = [dicResult objectForKey:@"pcname"];
        pcode= [dicResult objectForKey:@"pcode"];
        pcount = [dicResult objectForKey:@"pcount"];
        price = [dicResult objectForKey:@"price"];
        promonum = [dicResult objectForKey:@"promonum"];
        tpcode = [dicResult objectForKey:@"tpcode"];
        unit = [dicResult objectForKey:@"unit"];
        weight = [dicResult objectForKey:@"weight"];
        weightflg = [dicResult objectForKey:@"weightflg"];
        ISTC = [dicResult objectForKey:@"ISTC"];
        product = [NSString stringWithFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@%@@",pkid,pcode,pcname,tpcode,tpname,tpnum,pcount,promonum,fujiacode,fujianame,price,fujiaprice,weight,weightflg,unit,ISTC];
        productList = [productList stringByAppendingFormat:@"%@;",product];
    }
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",deviceId,userCode,orderId,tableNum,productList];
    NSDictionary *dict = [self bsService:@"callPubitem" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:callPubitemResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSLog(@"%@",[ary objectAtIndex:1]);
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//划菜
-(NSDictionary *)callElide:(NSDictionary *)dicInfo productList:(NSArray *)aryResult{
    NSString *tableNum,*orderId,*userCode,*deviceId,*productList,*PKID;
    tableNum = [dicInfo objectForKey:@"tableNum"];
    orderId = [dicInfo objectForKey:@"orderId"];
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    deviceId = strPDAID;
    NSString *tpnum,*fujiacode,*fujianame,*pcode,*tpcode,*weightflg,*ISTC,*product,*elideCount;
//     NSString *pkid,*tpname,*tpnum,*fujiacode,*fujianame,*fujiaprice,*order,*pcname,*pcode,*pcount,*price,*promonum,*tpcode,*unit,*weight,*weightflg,*ISTC,*product,*elideCount;
    
    productList = @"";
    
    
    for (NSDictionary *dicResult in aryResult) {
        fujiacode = @"";
        fujianame = @"";
        product = nil;
//        pkid = [dicResult objectForKey:@"PKID"];
//        tpname = [dicResult objectForKey:@"TPNAME"];
        tpnum = [dicResult objectForKey:@"TPNUM"];
        NSArray *aryAdditions = [dicResult objectForKey:@"additions"];
        for (NSDictionary *dicAdditions in aryAdditions) {
            if (![[dicAdditions objectForKey:@"fujiacode"] isEqualToString:@""]) {
                fujiacode = [fujiacode stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujiacode"]];
                fujianame = [fujianame stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujianame"]];
            }
        }
        PKID = [dicResult objectForKey:@"PKID"];
//        fujiaprice = [dicResult objectForKey:@"fujiaprice"];
//        order = [dicResult objectForKey:@"orderid"];
//        pcname = [dicResult objectForKey:@"pcname"];
        pcode= [dicResult objectForKey:@"pcode"];
//        pcount = [dicResult objectForKey:@"pcount"];
//        price = [dicResult objectForKey:@"price"];
//        promonum = [dicResult objectForKey:@"promonum"];
        tpcode = [dicResult objectForKey:@"tpcode"];
//        unit = [dicResult objectForKey:@"unit"];
//        weight = [dicResult objectForKey:@"weight"];
        weightflg = [dicResult objectForKey:@"weightflg"];
        ISTC = [dicResult objectForKey:@"ISTC"];
        elideCount = [dicResult objectForKey:@"elideCount"];
        if (!elideCount) {
            elideCount = @"1";
        }
        product = [NSString stringWithFormat:@"%@@%@@%@@%@@%@@%@@%@@%@",pcode,tpcode,tpnum,fujiacode,weightflg,ISTC,elideCount,PKID];
        productList = [productList stringByAppendingFormat:@"%@;",product];
    }
    //callElide?&deviceId=88&userCode=4&orderId=H000053&tableNum=5&productList=70600027@@@@@0@1;
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",deviceId,userCode,orderId,tableNum,productList];
    NSDictionary *dict = [self bsService:@"callElide" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:callElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSLog(@"%@",[ary objectAtIndex:1]);
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//反划菜
-(NSDictionary *)reCallElide:(NSDictionary *)dicInfo productList:(NSArray *)aryResult{
    NSString *tableNum,*orderId,*userCode,*deviceId,*productList,*PKID;
    tableNum = [dicInfo objectForKey:@"tableNum"];
    orderId = [dicInfo objectForKey:@"orderId"];
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    deviceId = strPDAID;
    NSString *tpnum,*pcode,*tpcode,*weightflg,*ISTC,*product,*elideCount;
    //     NSString *pkid,*tpname,*tpnum,*fujiacode,*fujianame,*fujiaprice,*order,*pcname,*pcode,*pcount,*price,*promonum,*tpcode,*unit,*weight,*weightflg,*ISTC,*product,*elideCount;
    productList = @"";
    
    
    for (NSDictionary *dicResult in aryResult) {
        product = nil;
        //        pkid = [dicResult objectForKey:@"PKID"];
        //        tpname = [dicResult objectForKey:@"TPNAME"];
        tpnum = [dicResult objectForKey:@"TPNUM"];
        NSArray *aryAdditions = [dicResult objectForKey:@"additions"];
        NSString  *fujiacode=@"";
        NSString  *fujianame=@"";
        for (NSDictionary *dicAdditions in aryAdditions) {
            if (![[dicAdditions objectForKey:@"fujiacode"] isEqualToString:@""]) {
                fujiacode = [fujiacode stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujiacode"]];
                fujianame = [fujianame stringByAppendingFormat:@"%@!",[dicAdditions objectForKey:@"fujianame"]];
            }
        }
        PKID = [dicResult objectForKey:@"PKID"];
        //        fujiaprice = [dicResult objectForKey:@"fujiaprice"];
        //        order = [dicResult objectForKey:@"orderid"];
        //        pcname = [dicResult objectForKey:@"pcname"];
        pcode= [dicResult objectForKey:@"pcode"];
        //        pcount = [dicResult objectForKey:@"pcount"];
        //        price = [dicResult objectForKey:@"price"];
        //        promonum = [dicResult objectForKey:@"promonum"];
        tpcode = [dicResult objectForKey:@"tpcode"];
        //        unit = [dicResult objectForKey:@"unit"];
        //        weight = [dicResult objectForKey:@"weight"];
        weightflg = [dicResult objectForKey:@"weightflg"];
        ISTC = [dicResult objectForKey:@"ISTC"];
        elideCount = [dicResult objectForKey:@"elideCount"];
        if (!elideCount) {
            elideCount = @"1";
        }
        product = [NSString stringWithFormat:@"%@@%@@%@@%@@%@@%@@%@@%@",pcode,tpcode,tpnum,fujiacode,weightflg,ISTC,elideCount,PKID];
        productList = [productList stringByAppendingFormat:@"%@;",product];
    }
    //callElide?&deviceId=88&userCode=4&orderId=H000053&tableNum=5&productList=70600027@@@@@0@1;
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&orderId=%@&tableNum=%@&productList=%@",deviceId,userCode,orderId,tableNum,productList];
    NSDictionary *dict = [self bsService:@"reCallElide" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:reCallElideResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSLog(@"%@",[ary objectAtIndex:1]);
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}


//http://192.168.0.18:8080/ChoiceWebService/services/HHTSocket?/soldOut?&deviceId=777&userCode=1
//沽清
-(NSDictionary *)soldOut{
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",deviceID,userCode];
    NSDictionary *dict = [self bsService:@"soldOut" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:soldOutResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSLog(@"%@",[ary objectAtIndex:1]);
            NSMutableArray *aryMut = [NSMutableArray arrayWithArray:ary];
            [aryMut removeObjectAtIndex:0];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryMut,@"soldOutList", nil];
        }else if ([content isEqualToString:@"1"]){
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

-(NSDictionary *)getOrdersBytabNum:(NSString *)tableNum{
    NSString *pdaid,*userCode,*pwd;
    pdaid = strPDAID;
    userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@",pdaid,userCode,tableNum];
    NSDictionary *dict = [self bsService:@"getOrdersBytabNum" arg:strParam];
    
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:getOrdersBytabNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] isEqualToString:@"0"]) {
            NSArray *aryResult = [NSArray array];
            NSString *strResult = [ary objectAtIndex:1];
            aryResult = [strResult componentsSeparatedByString:@";"];
            int count = [aryResult count];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryResult objectAtIndex:2],@"womanCount",[aryResult objectAtIndex:1],@"manCount",[aryResult objectAtIndex:0],@"orderID", nil];
            
//            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryResult objectAtIndex:count-1],@"womanCount",[aryResult objectAtIndex:count-2],@"manCount",[aryResult objectAtIndex:count-3],@"orderID", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }
    return nil;
}

//获取等位列表
-(NSDictionary *)getWaitList{
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@",deviceID,userCode];
    NSDictionary *dict = [self bsService:@"queryReserveTableNum" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:queryReserveTableNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@";"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSMutableArray *aryMut = [NSMutableArray array];
            NSArray *aryR = [result componentsSeparatedByString:@"@"];
            for (NSString *strR in aryR) {
                NSArray *aryItem = [strR componentsSeparatedByString:@";"];
                NSMutableDictionary *dicMut = [NSMutableDictionary dictionary];
                [dicMut setValue:[aryItem objectAtIndex:1] forKey:@"phone"];
                [dicMut setValue:[aryItem objectAtIndex:2] forKey:@"orderId"];
                [dicMut setValue:[aryItem objectAtIndex:3] forKey:@"misorderid"];
                [dicMut setValue:[aryItem objectAtIndex:4] forKey:@"man"];
                [dicMut setValue:[aryItem objectAtIndex:5] forKey:@"woman"];
                [aryMut addObject:dicMut];
            }
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryMut,@"Message", nil];
        }else{
            NSArray *ary1 = [result componentsSeparatedByString:@"@"];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary1 objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//添加等位
-(NSDictionary *)addWait:(NSDictionary *)info{
    NSString *man,*woman,*phone;
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    phone = [info objectForKey:@"phone"];
    man = [info objectForKey:@"man"];
    woman = [info objectForKey:@"woman"];
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&manCounts=%@&womanCounts=%@",deviceID,userCode,phone,man,woman];
    NSDictionary *dict = [self bsService:@"reserveTableNum" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:reserveTableNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSLog(@"%@",[ary objectAtIndex:1]);
            NSMutableArray *aryMut = [NSMutableArray arrayWithArray:ary];
            [aryMut removeObjectAtIndex:0];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",aryMut,@"soldOutList", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}
//cancelReserveTableNum
//删除预定

-(NSDictionary *)cancelWait:(NSDictionary *)info{
    NSString *waitNum,*phone;
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    waitNum = [info objectForKey:@"misorderid"];
    phone = [info objectForKey:@"phone"];
    
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&misOrderId=%@",deviceID,userCode,phone,waitNum];
    NSDictionary *dict = [self bsService:@"cancelReserveTableNum" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:cancelReserveTableNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSString *str = [ary objectAtIndex:1];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",str,@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//预定转正式台位
-(NSDictionary *)changeTableNum:(NSDictionary *)info{
    //changeTableNum?deviceId=777&userCode=1&tablenumSource=18254109366
    //&tablenumDest=2&orderId=H000005
    NSString *tablenumSource,*tablenumDest,*orderID;
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    
    tablenumSource = [info objectForKey:@"phone"];
    tablenumDest = [info objectForKey:@"tableNumDest"];
    orderID = [info objectForKey:@"orderID"];
    
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tablenumSource=%@&tablenumDest=%@&orderId=%@",deviceID,userCode,tablenumSource,tablenumDest,orderID];
    NSDictionary *dict = [self bsService:@"changeTableNum" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:changeTableNumResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSString *str = [ary objectAtIndex:1];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",str,@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

//注册设备
-(NSDictionary *)registerDeviceId
{
    //    UIDevice *myDevice = [UIDevice currentDevice];
    //    NSString *deviceID = [myDevice uniqueIdentifier];
    NSString *deviceID = [NSString performSelector:@selector(UUIDString)];
    NSString *strParam =[NSString stringWithFormat:@"?&handvId=%@",deviceID];
    NSDictionary *dict = [self bsService:@"registerDeviceId" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:registerDeviceIdResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary1 = [result componentsSeparatedByString:@"@"];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary1 objectAtIndex:1],@"Message", nil];
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network timeout"],@"Message", nil];
    }
    return nil;
}

//菜齐
-(NSDictionary *)suppProductsFinish:(NSDictionary *)info{
    //suppProductsFinish
   // ?deviceId=007&userCode=14&tableNum=2&orderId=H000341
    NSString *tableNum,*orderID;
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    
    tableNum = [info objectForKey:@"tableNum"];
    orderID = [info objectForKey:@"orderId"];
    
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@",deviceID,userCode,tableNum,orderID];
    NSDictionary *dict = [self bsService:@"suppProductsFinish" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:suppProductsFinishResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSString *str = [ary objectAtIndex:1];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",str,@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}



//更新版本号
-(NSDictionary *)updateDataVersion:(NSString *)dataVersion{
    //updateDataVersion?
    //&deviceId=007&userCode=15&dataVersion=140208001
    NSString *deviceID = strPDAID;
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    NSString *strParam =[NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&dataVersion=%@",deviceID,userCode,dataVersion];
    NSDictionary *dict = [self bsService:@"updateDataVersion" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:updateDataVersionResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            NSString *str = [ary objectAtIndex:1];
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",str,@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
}

#pragma mark -
#pragma mark Process Received Data
- (void)getQueryResult:(NSString *)result{
    if ([result length]>0){
        NSArray *ary = [result componentsSeparatedByString:@"<"];
        if ([ary count]>1){
            //+sendtab
            NSString *cmd = [ary objectAtIndex:0];
            if ([cmd isEqualToString:@"+sendtab"]){
                NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
                
                NSMutableDictionary *mut = [NSMutableDictionary dictionary];
                NSRange range = [content rangeOfString:@"ok"];
                if (range.location!=NSNotFound){
                    [mut setObject:[NSNumber numberWithBool:YES] forKey:@"Result"];
                    [mut setObject:[[content componentsSeparatedByString:@"msg:"] objectAtIndex:1] forKey:@"Message"];
                    [mut setObject:[[[[content componentsSeparatedByString:@"msg:"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"tab"];
                    
                    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *docPath = [docPaths objectAtIndex:0];
                    [[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:dSendCount] forKey:@"count"] 
                     writeToFile:[docPath stringByAppendingPathComponent:kOrdersCountFileName] atomically:NO];
                }
                else{
                    [mut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
                    [mut setObject:[[content componentsSeparatedByString:@"error:"] objectAtIndex:1] forKey:@"Message"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:msgSendTab object:nil userInfo:mut];
            }
            else if ([cmd isEqualToString:@"+printquery"]){
                //Recived Data:+printquery<error:台号错误或已结帐或未定义查询单打印机!>
                NSString *content = [[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0];
                NSArray *aryContent = [content componentsSeparatedByString:@":"];
                NSRange range = [content rangeOfString:@"error"];
                if (range.location!=NSNotFound){
                    [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint 
                                                                        object:nil 
                                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[aryContent objectAtIndex:1],@"Message", nil]];
                }
                else{
                    int dCocount = [aryContent count];
                    if (dCocount>1)
                        [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[aryContent objectAtIndex:1],@"Message", nil]];
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:msgPrint object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",nil]];
                }
            }
            
        }
    }
}

- (void)saveOrders{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:kOrdersFileName];
    NSArray *aryOrd = [NSArray arrayWithArray:aryOrders];
    if ([aryOrd count]>0){
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in aryOrd){
            if ([[dic objectForKey:@"total"] intValue]!=0)
                [ary addObject:dic];
        }
        if ([ary count]>0){
            NSDictionary *dict = [NSDictionary dictionaryWithObject:ary forKey:@"orders"];
            [dict writeToFile:path atomically:NO];        
        }
    }
    else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateOrderedNumber" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshOrderStatus" object:nil];
}



- (UIImage *)backgroundImage{
    if (!imgBG){
        NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPaths objectAtIndex:0];
        NSString *path = [docPath stringByAppendingPathComponent:kBGFileName];
        NSString *imgpath = nil;
        
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
        if (!dic){
            NSArray *ary = [self getAllBG];
            if (ary>0)
                dic = [ary objectAtIndex:0];
            else
                dic = [NSDictionary dictionaryWithObject:@"defaultbg.jpg" forKey:@"name"];
            [dic writeToFile:path atomically:NO];
        }
        
        imgpath = [docPath stringByAppendingPathComponent:[dic objectForKey:@"name"]];
        
        imgBG = [[UIImage alloc] initWithContentsOfFile:imgpath];
    }
    
    
    return imgBG;
    
}

- (void)setBackgroundImage:(NSDictionary *)info{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:kBGFileName];
    [info writeToFile:path atomically:NO];
    
    [imgBG release];
    imgBG = nil;
}

- (NSArray *)getAllBG{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from background";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg{
    BSWebServiceAgent *agent = [[BSWebServiceAgent alloc] init];
    NSDictionary *dict = [agent GetData:api arg:arg];
    [agent release];
    return dict;
}

- (NSString *)bsService_string:(NSString *)api arg:(NSString *)arg{
    BSWebServiceAgent *agent = [[BSWebServiceAgent alloc] init];
    [agent GetData:api arg:arg];
    NSString *str = agent.strData;

    [agent release];
    
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return str;
}
//List Table
- (NSArray *)getArea{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc where code = 'AR'";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getFloor{
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"select * from codedesc where code = 'LC'";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return ary;
}

- (NSArray *)getStatus{
CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    
    NSString *langCode = [langSetting localizedString:@"LangCode"];
    
    if ([langCode isEqualToString:@"en"])
        return [NSArray arrayWithObjects:@"Idle",@"Ordered",@"No order",nil];
    else if ([langCode isEqualToString:@"cn"])
        return [NSArray arrayWithObjects:@"空闲",@"开台点菜",@"开台未点",nil];
    else
        return [NSArray arrayWithObjects:@"空閒",@"開台點菜",@"開台未點",nil];

}

- (BOOL)pCommentFood:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];
    NSString *level = [info objectForKey:@"level"];
    NSString *comment = [info objectForKey:@"comment"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"comments.plist"];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!mut)
        mut = [NSMutableDictionary dictionary];
    
    NSArray *ary = [mut objectForKey:itcode];
    NSMutableArray *mutary = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:itcode,@"itcode",level,@"level",comment,@"comment", nil]];
    [mutary addObjectsFromArray:ary];
    
    [mut setObject:mutary forKey:itcode];
    
    [mut writeToFile:path atomically:NO];
    
    return YES;
    

    /*
    NSString *param = [NSString stringWithFormat:@"?itcode=%@&level=%@&comment=%@",itcode,level,comment];
    
    NSDictionary *dict = [self bsService:@"pCommentFood" arg:param];
    
    NSString *OStr = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
    
    NSRange range = [OStr rangeOfString:@"提交成功"];
    
    return (range.location!=NSNotFound);
     */
}

- (NSArray *)pGetFoodComment:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"comments.plist"];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    
    return [mut objectForKey:itcode];
    
    /*
    NSString *itcode = [info objectForKey:@"itcode"];;
    
    
    NSString *param = [NSString stringWithFormat:@"?itcode=%@",itcode];
    
    NSDictionary *dict = [self bsService:@"pGetFoodComment" arg:param];
    
    NSArray *ary = [[[[dict objectForKey:@"DataTable"] objectForKey:@"diffgr:diffgram"] objectForKey:@"NewDataSet"] objectForKey:@"ds"];
    if ([ary isKindOfClass:[NSDictionary class]])
        ary = [NSArray arrayWithObject:ary];
    
    NSMutableArray *mut = [NSMutableArray array];
    
    for (int i=0;i<[ary count];i++){
        NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
        
        NSDictionary *dictcomment = [ary objectAtIndex:i];
        NSString *strcomment = [[dictcomment objectForKey:@"comment"] objectForKey:@"text"];
        const char *cstr = [strcomment cStringUsingEncoding:NSUTF8StringEncoding];
        
        BOOL bchar = NO;
        
        NSMutableString *mutstr = [NSMutableString string];
        for (int j=0;j<strlen(cstr);j++){
            if (cstr[j]!='\n' && cstr[j]!=' ')
                bchar = YES;
            
            if (bchar)
                [mutstr appendFormat:@"%c",cstr[j]];
            
        }
        
        if ([mutstr length]>0)
            [mutdict setObject:mutstr forKey:@"comment"];
        
        NSString *level = [[dictcomment objectForKey:@"lv"] objectForKey:@"text"];
        for (int k=1;k<=5;k++){
            if ([level rangeOfString:[NSString stringWithFormat:@"%d",k]].location!=NSNotFound){
                level = [NSString stringWithFormat:@"%d",k];
                break;
            }
        }
        if ([level intValue]!=0)
            [mutdict setObject:level forKey:@"level"];
        
        if ([mutdict count]>0)
            [mut addObject:mutdict];
    }
    
    return [mut count]>0?[NSArray arrayWithArray:mut]:nil;
     
     */
}

- (NSString *)pGetFoodVideo:(NSDictionary *)info{
    NSString *itcode = [info objectForKey:@"itcode"];;
    return @"http://www.5stan.com/test.mov";
    NSString *param = [NSString stringWithFormat:@"?itcode=%@",itcode];
    
    NSDictionary *dict = [self bsService:@"pGetFoodVideo" arg:param];
    
    NSString *path = [[[dict objectForKey:@"video"] objectForKey:@"Videopath"] objectForKey:@"text"];
    [path stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [path stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    return [path length]>0?path:nil;
}


#pragma mark - Template Functions
- (NSArray *)pageConfigList{
    if (!pageConfigDict){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PageConfig.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!dict)
            dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
        pageConfigDict = [dict retain];
    }
    
    
    NSArray *ary = [pageConfigDict objectForKey:@"PageList"];
    
    return ary;
}

- (NSDictionary *)resourceConfig{
    if (!pageConfigDict){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PageConfig.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!dict)
            dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
        pageConfigDict = [dict retain];
    }
    
    
    NSDictionary *dict = [pageConfigDict objectForKey:@"ResourceConfig"];
    
    return dict;
}

- (NSDictionary *)foodDetailConfig{
    if (!pageConfigDict){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PageConfig.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!dict)
            dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
        pageConfigDict = [dict retain];
    }
    
    
    NSDictionary *dict = [pageConfigDict objectForKey:@"FoodDetail"];
    
    return dict;
}

- (NSDictionary *)buttonConfig{
    if (!pageConfigDict){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PageConfig.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!dict)
            dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
        pageConfigDict = [dict retain];
    }
    
    
    NSDictionary *dict = [pageConfigDict objectForKey:@"ButtonConfig"];
    
    return dict;
}

- (NSArray *)menuItemList{
    if (!pageConfigDict){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PageConfig.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!dict)
            dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PageConfigDemo" ofType:@"plist"]];
        pageConfigDict = [dict retain];
    }
    
    
    NSArray *ary = [pageConfigDict objectForKey:@"MenuItemList"];
    
    return ary;
}

- (NSUInteger)totalPages{
    NSArray *ary = [self pageConfigList];
    
    int total = 0;
    for (NSDictionary *info in ary){
        if ([[info objectForKey:@"type"] isEqualToString:@"类别"]){
            NSArray *foods = [self foodListForClass:[info objectForKey:@"classid"]];
            int page = (int)([foods count]/9)+[foods count]%9==0?0:1;
            total += page;
        }   
        else
            total++;
    }
    
    return total;
}

- (NSArray *)foodListForClass:(NSString *)classid{
    return  [self getFoodList:[NSString stringWithFormat:@"GRPTYP = %@",classid]];
}


- (NSArray *)topPages{
    //封面 广告 推荐菜 类别列表
//    NSArray *allpages = [self pageConfigList];
//    NSMutableArray *mut = [NSMutableArray array];
//    
//    for (int i=0;i<allpages.count;i++){
//        NSDictionary *dict = [allpages objectAtIndex:i];
//        if ([[dict objectForKey:@"type"] isEqualToString:@"类别"]){
//            
//        }
//    }
    NSMutableArray *mut = [NSMutableArray array];
    
    NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
    if ([self getCovers].count>0){
        [mutdict setObject:[NSMutableArray array] forKey:@"images"];
        for (NSDictionary *didi in [self getCovers])
            [[mutdict objectForKey:@"images"] addObject:[didi objectForKey:@"cover"]];
    }
        
    [mutdict setObject:@"封面" forKey:@"type"];
    [mut addObject:mutdict];
    
    NSArray *ary = [self getClassList];
    

    for (int i=0;i<[ary count];i++){
        if (i%9==0){
            mutdict = [NSMutableDictionary dictionaryWithObject:@"类别列表" forKey:@"type"];
            [mutdict setObject:[NSMutableArray array] forKey:@"categories"];
            [mut addObject:mutdict];
        }
            
        [[mutdict objectForKey:@"categories"] addObject:[ary objectAtIndex:i]];
    }
    
    return [NSArray arrayWithArray:mut];
    
}

- (NSArray *)allPages{
    if (!allPages){
        NSArray *ary = [self pageConfigList];
        NSMutableArray *mut = [NSMutableArray array];
        
        for (int i=0;i<[ary count];i++){
            NSDictionary *dict = [ary objectAtIndex:i];
            [mut addObject:dict];
//            if ([[dict objectForKey:@"type"] isEqualToString:@"类别"]){
//                NSArray *foods = [self foodListForClass:[dict objectForKey:@"classid"]];
//                int page = (int)([foods count]/9)+[foods count]%9==0?0:1;//该类别有多少页
//                
//                
//                for (int j=0;j<page;j++){
//                    NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//                    NSMutableArray *mutfoods = [NSMutableArray array];
//                    for (int k=0;k<9;k++){
//                        if (j*9+k<[foods count])
//                            [mutfoods addObject:[foods objectAtIndex:j*9+k]];
//                    }
//                    [mutdict setObject:mutfoods forKey:@"foods"];//该类别页对应的菜品列表
//                    
//                    [mut addObject:mutdict];//添加一页
//                }
//                
//            }else{
//                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//                [mut addObject:mutdict];
//            }
        }
        
        allPages = [mut count]>0?[[NSArray arrayWithArray:mut] retain]:nil;
    }
    
    
    return allPages;
}

- (NSArray *)allDetailPages{
    if (!allDetailPages){
        NSArray *ary = [self pageConfigList];
        NSMutableArray *mut = [NSMutableArray array];
        
        for (int i=0;i<[ary count];i++){
            NSDictionary *dict = [ary objectAtIndex:i];
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"菜品列表"]){
                NSArray *foods = [dict objectForKey:@"foods"];                
                for (int j=0;j<[foods count];j++){
                    NSArray *itcodes = [[[foods objectAtIndex:j] objectForKey:@"ITCODE"] componentsSeparatedByString:@","];
                    NSString *itcode = [itcodes objectAtIndex:0];
                    
                    NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[self getDataFromSQLByCommand:[NSString stringWithFormat:@"select * from food where ITCODE = '%@'",itcode]]];
                    [mutdict setObject:@"菜品详情" forKey:@"type"];
                    [mutdict setObject:[dict objectForKey:@"classid"] forKey:@"classid"];
                    
                    NSString *bg = [[foods objectAtIndex:j] objectForKey:@"background"];
                    if (!bg)
                        bg = [dict objectForKey:@"background"];
                    
                    if (bg)
                        [mutdict setObject:bg forKey:@"background"];
                    
                    [mut addObject:mutdict];//添加一页
                }
                
            }else{
//                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//                [mut addObject:mutdict];
            }
        }
        
        allDetailPages = [mut count]>0?[[NSArray arrayWithArray:mut] retain]:nil;
    }
    
    
    return allDetailPages;
}

- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index{
    NSArray *ary = [self allPages];
    
    return index<[ary count]?[ary objectAtIndex:index]:nil; 
}
//  套餐相关
- (NSArray *)getFoodListOfPackage:(NSString *)packageid{
    NSString *cmd = [NSString stringWithFormat:@"select * from PACKDTL where PACKID = %@",packageid];
    
    return [self getDataFromSQLByCommand:cmd];
}

- (NSDictionary *)getFoodByCode:(NSString *)itcode{
    NSString *cmd = [NSString stringWithFormat:@"select * from food where ITCODE = %@",itcode];
    
    return [self getDataFromSQLByCommand:cmd];
}

- (NSDictionary *)getPackageDetail:(NSString *)packageid{
    NSArray *foods = [self getFoodListOfPackage:packageid];
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    if (foods)
        [mut setObject:foods forKey:@"foods"];
    NSString *cmd = [NSString stringWithFormat:@"select * from PACKAGE where PACKID = %@",packageid];
    
    NSDictionary *dict = [self getDataFromSQLByCommand:cmd];
    
    if (dict)
        [mut setValuesForKeysWithDictionary:dict];
    
    return [mut count]>0?[NSDictionary dictionaryWithDictionary:mut]:nil;
    
}

- (NSArray *)getShiftFood:(NSString *)foodid ofPackage:(NSString *)packageid{
    NSString *cmd = [NSString stringWithFormat:@"select * from products_sub where PRODUCTTC_ORDER = '%@' and PCODE = '%@'",foodid,packageid];
    
    return [self getDataFromSQLByCommand:cmd];
}

- (NSArray *)getShiftFood_zc:(NSString *)foodid ofPackage:(NSString *)packageid{
    NSString *cmd = [NSString stringWithFormat:@"select * from ITEMPKG where PACKID = %@ and ITEM = %@",packageid,foodid];
    
    return [self getDataFromSQLByCommand:cmd];
}

- (NSDictionary *)checkFoodAvailable:(NSArray *)ary{
    NSString *pdanum = strPDAID;
    NSString *tableNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tableNum"] lowercaseString];
    NSString *userCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    NSString *pwd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
    NSString *user = [NSString stringWithFormat:@"%@-%@",userCode,pwd];
    NSMutableString *mutfood = [NSMutableString string];
    
    for (int i=0;i<ary.count;i++){
        NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
        for (int j=0;j<foods.count;j++){
            NSDictionary *food = [foods objectAtIndex:j];
            if ([[food objectForKey:@"PACKID"] boolValue]) {
                NSArray *aryPack = [food objectForKey:@"foods"];
                for (NSDictionary *dicPack in aryPack) {
                    NSString *foodid = [dicPack objectForKey:@"ITCODE"];
                    NSString *count = [dicPack objectForKey:@"total"];
                    
                    [mutfood appendFormat:@"%@^%@",foodid,count];
                    [mutfood appendString:@";"];
                }
            }else{
                NSString *foodid = [[food objectForKey:@"food"] objectForKey:@"ITCODE"];
                NSString *count = [food objectForKey:@"total"];
                
                [mutfood appendFormat:@"%@^%@",foodid,count];
                [mutfood appendString:@";"];
            }
        }
    }
//pFreeGetC?PdaId=8-1&oSerial=100001^1.0;&User=1-1&GrantEmp=1090&GrantPass=&Rsn=
    NSString *strParam = [NSString stringWithFormat:@"?PdaId=%@&oSerial=%@&User=%@&GrantEmp=%@&GrantPass=&Rsn=",pdanum,mutfood,user,tableNum];
    NSDictionary *dict = [self bsService:@"pFreeGetC" arg:strParam];
    NSString *str = [[[dict objectForKey:@"Root"] objectForKey:@"OStr"] objectForKey:@"text"];
    
    NSMutableDictionary *mutret = [NSMutableDictionary dictionary];
    BOOL isOK = NO;
    NSString *msg = nil;
    if (str){
        if ([str rangeOfString:@"ok"].location!=NSNotFound){
            isOK = YES;
        }else{
            NSRange start = [str rangeOfString:@":"];
            NSRange end = [str rangeOfString:@">"];
            
            if (start.location!=NSNotFound && end.location!=NSNotFound){
                NSRange sub = NSMakeRange(start.location+1, ((int)end.location-(int)start.location-1)>=0?(end.location-start.location-1):0);
                if (sub.length>0)
                    msg = [str substringWithRange:sub];
                
            }
        }
    }
    
    [mutret setObject:[NSNumber numberWithBool:isOK] forKey:@"Result"];
    if (!isOK){
        [mutret setObject:msg?msg:@"查询沽清失败" forKey:@"Message"];
    }
    
    return mutret;
}

// SQLite相关
- (id)getDataFromSQLByCommand:(NSString *)cmd{
    id ret = nil;
    NSMutableArray *ary = [NSMutableArray array];
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd = cmd;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
//            NSLog(@"%@",stat);
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *foodKey = (char *)sqlite3_column_name(stat, i);
                    char *foodValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (foodKey)
                        strKey = [NSString stringWithUTF8String:foodKey];
                    if (foodValue)
                        strValue = [NSString stringWithUTF8String:foodValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    if ([ary count]==1){
        NSDictionary *dict = [ary objectAtIndex:0];
        if (1==[dict count])
            ret = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        else if ([dict count]>1)
            ret = dict;
    }else if ([ary count]>1)
        ret = ary;
    
    
    return ret;
}

//销售看板
-(NSDictionary *)pYgSpclList:(NSDictionary *)info
{
    NSMutableDictionary *dicMut = [NSMutableDictionary dictionary];
    
    NSString *user,*pwd;
    NSString *pdaid = strPDAID;
    user = [info objectForKey:@"user"];
    pwd = [info objectForKey:@"pwd"];
    if (pwd)
        user = [NSString stringWithFormat:@"%@-%@",user,pwd];
    
    NSString *strParam = [NSString stringWithFormat:@"?PdaID=%@&User=%@&Dept=&ITCODE=",pdaid,user];
    NSDictionary *dict = [self bsService:@"checkLook" arg:strParam];
    NSLog(@"%@",dict);
    NSString *result = [[[dict objectForKey:@"Root"] objectForKey:@"Buffer"] objectForKey:@"text"];//[[[[[[dict objectForKey:@"string"] objectForKey:@"text"]  componentsSeparatedByString:@"<Buffer>"] objectAtIndex:1] componentsSeparatedByString:@"</Buffer>"] objectAtIndex:0];
    NSArray *ary = [result componentsSeparatedByString:@"<"];
    
    if ([result rangeOfString:@"error"].location!=NSNotFound){
        [dicMut setObject:[NSNumber numberWithBool:NO] forKey:@"Result"];
        [dicMut setObject:[[[[[ary objectAtIndex:1] componentsSeparatedByString:@">"] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] forKey:@"Message"];
    }
    else
    {
        if (![result isEqualToString:@"+query<end>"])
        {
            NSLog(@"%@",result);
            NSArray *countent=[result componentsSeparatedByString:@"#"];
            NSMutableArray *dataArray=[[NSMutableArray alloc]init];
            for (int j=0;j<[countent count];j++)
            {
                if(![[countent objectAtIndex:j ] isEqualToString:@""])
                {
                    NSArray *values=[[countent objectAtIndex:j ] componentsSeparatedByString:@"^"];
                    NSMutableDictionary *dictValue=[[NSMutableDictionary alloc]init];
                    [dictValue setObject:[values objectAtIndex:0] forKey:@"lookId"];
                    [dictValue setObject:[values objectAtIndex:1] forKey:@"lookName"];
                    [dictValue setObject:[values objectAtIndex:2] forKey:@"lookShi"];
                    [dictValue setObject:[values objectAtIndex:3] forKey:@"lookYu"];
                    [dictValue setObject:[values objectAtIndex:4] forKey:@"lookwan"];
                    [dataArray addObject:dictValue];
                    [dicMut setObject:dataArray forKey:@"lookMessage"];
                }
            }
        }
        
    }
    return dicMut;
    
}

#pragma mark - 预结算
//SELECT *FROM settlementoperate WHERE OPERATEGROUPID='5'
//现金银行卡的结算种类
- (NSArray *)getsettlementoperate:(NSString *)flag{
    NSMutableArray *ary = [NSMutableArray array];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID = %@",flag];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary];
    
}

//查询优惠方式的种类
- (NSArray *)getCoupon_kind{
    NSMutableArray *ary = [NSMutableArray array];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = @"SELECT *FROM coupon_kind";
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary];
    
}

//查询优惠方式
- (NSArray *)getCoupon_main:(NSString *)kind{
    NSMutableArray *ary = [NSMutableArray array];
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    NSString *sqlcmd;
    //   char *errorMsg;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        sqlcmd = [NSString stringWithFormat:@"SELECT * FROM coupon_main WHERE KINDID = %@",kind];
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [NSArray arrayWithArray:ary];
    
}

//现金结算
-(NSDictionary *)userPayment:(NSDictionary *)info fangShi:(NSArray *)aryFangShi{
    
    NSString *deviceId,*usercode,*tableNum,*orderId,*integralOverall,*cardNumber;
    NSMutableString *paymentID,*paymentCnt,*paymentMoney,*payFinish;
    NSString *zhaoLingCode,*zhaoLingMoney,*moLingMoney;
    
    NSArray *ary = [self getsettlementoperate:@"6"];
    zhaoLingCode = [[ary lastObject] objectForKey:@"OPERATE"];
    zhaoLingMoney = [[sharedData sharedInstance] zhaoLingMoney];
    moLingMoney = [[sharedData sharedInstance] moLingMoney];
    
    deviceId = strPDAID;
    usercode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    tableNum = [info objectForKey:@"tableNum"];
    orderId = [info objectForKey:@"orderId"];
    integralOverall = @"0";
    cardNumber = @"0";
    
    paymentID = [NSMutableString string];
    paymentCnt = [NSMutableString string];
    paymentMoney = [NSMutableString string];
    payFinish = [NSMutableString string];
    
    for (NSDictionary *dic in aryFangShi) {
        if ([dic objectForKey:@"OPERATE"]) {
            [paymentID appendFormat:@"%@!",[dic objectForKey:@"OPERATE"]];
            [paymentCnt appendFormat:@"%@!",@"1"];
            [paymentMoney appendFormat:@"%@!",[dic objectForKey:@"money"]];
            [payFinish appendFormat:@"%@!",@"0"];
        }
    }
    [paymentID appendFormat:@"%@!",zhaoLingCode];
    [paymentCnt appendFormat:@"%@!",zhaoLingMoney];
    [paymentMoney appendFormat:@"%@!",moLingMoney];
    [payFinish appendFormat:@"%@!",@"1"];
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&paymentId=%@&paymentCnt=%@&mpaymentMoney=%@&payFinish=%@&integralOverall=%@&cardNumber=%@",deviceId,usercode,tableNum,orderId,paymentID,paymentCnt,paymentMoney,payFinish,integralOverall,cardNumber];
    NSDictionary *dict = [self bsService:@"userPayment" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:userPaymentResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;

}


//优惠方式
-(NSDictionary *)userCounp:(NSDictionary *)info CounpInfo:(NSDictionary *)dicCounp{
//    deviceId： 设备编号
//    userCode：登录编号
//    tableNum：台位编号
//    orderId： 优惠券编码
//    counpCnt：优惠券数量
//    counpMoney：优惠券金额
    NSString *deviceId,*usercode,*tableNum,*orderId,*counpId,*counpCnt,*counpMoney;
    
    deviceId = strPDAID;
    usercode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    tableNum = [info objectForKey:@"tableNum"];
    orderId = [info objectForKey:@"orderId"];
    
    counpId = [dicCounp objectForKey:@"CODE"];
    counpCnt = @"1";
    counpMoney = nil;
    
    NSString *strParam = [NSString stringWithFormat:@"?&deviceId=%@&userCode=%@&tableNum=%@&orderId=%@&counpId=%@&counpCnt=%@&counpMoney=%@",deviceId,usercode,tableNum,orderId,counpId,counpCnt,counpMoney];
    NSDictionary *dict = [self bsService:@"userCounp" arg:strParam];
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:userCounpResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        NSString *content = [ary objectAtIndex:0];
        if ([content isEqualToString:@"0"]) {
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"Result",ary,@"Message", nil];
        }else{
            return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[ary objectAtIndex:1],@"Message", nil];
        }
    }else{
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"Result",[langSetting localizedString:@"network connection timeout"],@"Message", nil];
    }
    return nil;
    
}

@end
