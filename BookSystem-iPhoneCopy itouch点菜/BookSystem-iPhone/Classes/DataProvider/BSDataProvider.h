//
//  BSDataProvider.h
//  BookSystem
//
//  Created by Dream on 11-3-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BSWebServiceAgent.h"
#import "CVLocalizationSetting.h"
#import "WhiteRaccoon.h"
//@"61.174.28.122:8010"
#define kPlistPath      @"ftp://shipader:shipader123@61.174.28.122/BookSystem/BookSystem.sqlite"
#define kPathHeader      @"ftp://1:1@192.168.0.241/BookSystem/"
#define kSocketServer   @"192.168.0.241:8010"
#define kPDAID          @"8"
#define  TCHAR unsigned char

#define msgSendTab      @"NotificationSendTab"
#define msgQuery        @"NotificationQuery"
#define msgGogo         @"NotifcationGogo"
#define msgChuck        @"NotificationChuck"
#define msgListTable    @"NotificationListTable"
#define msgOpenTable    @"NotificationOpenTable"
#define msgCancelTable  @"NotificationCancelTable"
#define msgPrint        @"NotificationPrint"


#define kBGFileName         @"BackgroundImage.plist"
#define kOrdersFileName     @"Orders.plist"
#define kOrdersCountFileName    @"OrdersCount.plist"
#define kFunctionControlFileName @"FunctionControl.plist"
@interface BSDataProvider : NSObject<NSStreamDelegate,WRRequestDelegate>{
    NSMutableData *data;
    
    NSInputStream *iStream;
    NSOutputStream *oStream;
    
    UIImage *imgBG;
    
}

+ (BSDataProvider *)sharedInstance;
+ (NSDictionary *)currentOrder;
+ (void)removeOrderOfName:(NSString *)name;
+ (void)importOrderOfName:(NSString *)name;
+ (NSDictionary *)allCachedOrder;
+ (NSArray *)cachedFoodList;
+ (BOOL)isCacheNameExist:(NSString *)name;
+ (void)saveFoods:(NSArray *)foods withName:(NSString *)name;
- (NSString *)cachedOrder:(NSDictionary *)order;
- (id)getDataFromSQLByCommand:(NSString *)cmd;
- (NSArray *)getADNames;
- (NSArray *)getAdditions;
- (NSArray *)getAdditionsQuanDan;//特别备注
- (void)refreshFiles;
- (NSDictionary *)dictFromSQL;
- (NSDictionary *)updateData;
- (NSDictionary *)dataDict;
- (void)getCachedFile;
- (NSMutableArray *)getAllFoods;
- (NSMutableArray *)getFoodList:(NSString *)cmd;
- (NSArray *)getAccounts;
- (NSArray *)getAllBG;
- (NSMutableArray *)getCodeDesc;
- (NSArray *)getCovers;
- (NSArray *)getCaptions;
-(NSDictionary *)registerDeviceId;
- (NSMutableArray *)getPackageWhere:(NSString *)str;

- (UIImage *)backgroundImage;
- (void)setBackgroundImage:(NSDictionary *)info;


- (void)orderFood:(NSDictionary *)info;
- (NSMutableArray *)orderedFood;
- (void)saveOrders;


- (void)writeToServer:(const uint8_t *)buf;

-(NSArray *)getOrdersBytabNum:(NSString *)tableNum;

- (void)getQueryResult:(NSString *)result;

- (NSDictionary *)pListTable_zc:(NSDictionary *)info;//中餐查台位
- (NSDictionary *)pQuery_zc:(NSDictionary *)info;//中餐查账单
- (NSDictionary *)pStart_zc:(NSDictionary *)info;//中餐开台
- (NSDictionary *)pOver_zc:(NSDictionary *)info;//中餐取消开台
- (NSDictionary *)pChangeTable_zc:(NSDictionary *)info;//中餐换台
- (NSString *)pSendTab_zc:(NSArray *)ary options:(NSDictionary *)info;//中餐发送
- (void)orderFood_zc:(NSDictionary *)info;//中餐用
- (NSArray *)getAdditions_zc;//中餐附加项
- (NSDictionary *)pLoginUser_zc:(NSDictionary *)info;//中餐登陆
- (NSString *)pSendTab:(NSArray *)ary options:(NSDictionary *)info;
- (NSDictionary *)pListTable:(NSDictionary *)info;
- (NSDictionary *)pQuery:(NSDictionary *)info;
- (NSDictionary *)pGogo:(NSDictionary *)info;
- (NSDictionary *)pChuck:(NSDictionary *)info;
- (NSDictionary *)pStart:(NSDictionary *)info;
- (NSDictionary *)pChangeTable:(NSDictionary *)info;
- (NSDictionary *)pCombineTable:(NSDictionary *)info;
- (NSDictionary *)pOver:(NSDictionary *)info;
- (NSDictionary *)pPrintQuery:(NSDictionary *)info;
- (BOOL)pCommentFood:(NSDictionary *)info;
- (NSArray *)pGetFoodComment:(NSDictionary *)info;
- (NSString *)pGetFoodVideo:(NSDictionary *)info;
- (NSDictionary *)pListSubscribeOfTable:(NSDictionary *)info;
- (NSArray *)pListResv:(NSDictionary *)info;
- (NSDictionary *)pLoginUser:(NSDictionary *)info;
- (NSDictionary *)pSpecialRemark:(NSDictionary *)info;
-(NSDictionary *)pCheckAuth:(NSDictionary *)info;
- (NSDictionary *)pLoginOut;
-(NSDictionary *)callPubitem:(NSDictionary *)dicInfo productList:(NSArray *)aryResult; //推菜
-(NSDictionary *)callElide:(NSDictionary *)dicInfo productList:(NSArray *)aryResult;
-(NSDictionary *)soldOut;//沽清
-(NSDictionary *)getWaitList;
-(NSDictionary *)addWait:(NSDictionary *)info;
-(NSDictionary *)cancelWait:(NSDictionary *)info;
-(NSDictionary *)changeTableNum:(NSDictionary *)info;//预定转正式台位
- (NSDictionary *)queryCompletely:(NSDictionary *)info;//全单
-(NSDictionary *)suppProductsFinish:(NSDictionary *)info;//菜齐
-(NSDictionary *)updateDataVersion:(NSString *)dataVersion;//更新版本号
- (NSDictionary *)queryWholeProducts:(NSDictionary *)info;//全单（附加项）
-(NSDictionary *)reCallElide:(NSDictionary *)dicInfo productList:(NSArray *)aryResult;//反划菜
//List Table
- (NSArray *)getArea;
- (NSArray *)getFloor;
- (NSArray *)getStatus;

- (NSDictionary *)bsService:(NSString *)api arg:(NSString *)arg;
- (NSString *)bsService_string:(NSString *)api arg:(NSString *)arg;
- (NSDictionary *)checkFoodAvailable:(NSArray *)ary;

#pragma mark -  Template Functions
- (NSArray *)pageConfigList;
- (NSDictionary *)resourceConfig;
- (NSDictionary *)buttonConfig;
- (NSDictionary *)foodDetailConfig;
- (NSArray *)menuItemList;
- (NSUInteger)totalPages;
- (NSArray *)foodListForClass:(NSString *)classid;
- (NSDictionary *)pageInfoAtIndex:(NSUInteger)index;
- (NSArray *)allPages;
- (NSArray *)allDetailPages;
- (NSMutableArray *)getClassList;
- (NSDictionary *)getClassByID:(NSString *)classid;
- (NSDictionary *)getFoodByCode:(NSString *)itcode;
//  套餐相关
//- (NSDictionary *)getPackageByID:(NSString *)packageid;
- (NSDictionary *)getPackage;
- (NSDictionary *)getPackageDetail:(NSString *)packageid;
- (NSArray *)getShiftFood:(NSString *)foodid ofPackage:(NSString *)packageid;
- (NSMutableArray *)getPackage:(NSString *)str;

- (NSArray *)getShiftFood_zc:(NSString *)foodid ofPackage:(NSString *)packageid;//中餐套餐
#pragma mark - New Demo
- (NSArray *)topPages;
-(NSDictionary *)pYgSpclList:(NSDictionary *)info;


//预结算
- (NSArray *)getsettlementoperate:(NSString *)flag;
-(NSDictionary *)userPayment:(NSDictionary *)info fangShi:(NSArray *)aryFangShi;//现金结算
- (NSArray *)getCoupon_kind;
- (NSArray *)getCoupon_main:(NSString *)kind;
-(NSDictionary *)userCounp:(NSDictionary *)info CounpInfo:(NSDictionary *)dicCounp;
@end


/*
 
 char* scCommandWord[22]=
 { 
 {("+login<user:%s;password:%s;>\r\n")}, //0.登陆login
 {("+logout<user:%s;>\r\n")},//1.退出登陆logout
 {("+listtable<user:%s;pdanum:%s;floor:%s;area:%s;status:%s;>\r\n")},// 2.查询桌位list table  
 {("+start<pdaid:%s;user:%s;table:%s;peoplenum:%s;waiter:%s;acct:%s;>\r\n")},//3.开台start
 {("+over<pdaid:%s;user:%s;table:%s;>\r\n")},//4.取消开台
 {("+sendtab<pdaid:%s;user:%s;tabid:%d;acct:%s;tb:%s;usr:%s;pn:%s;foodnum:%d;type:%s;tablist:%s;>\r\n")},//5.发送菜单
 {("+changetable<pdaid:%s;user:%s;oldtable:%s;newtable:%s;>\r\n")},//6.换台changetable
 {("+signteb<pdaid:%s;user:%s;tabto:%s;intotab:%s;type:%s;>\r\n")},//7.标记并单
 {("+query<pdaid:%s;user:%s;table:%s;>\r\n")},//8.查询
 {("+gogo<pdaid:%s;user:%s;tab:%s;foodnum:%s;>\r\n")},//9.催菜
 {("+rebate<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;rebatetype:%s;foodnum:%s;pic:%s;ispic:%d;>\r\n")},//10.打折//fwang modif
 {("+printquery<pdaid:%s;user:%s;tab:%s;type:%s;>\r\n")},//11.打印
 {("+printtab<pdaid:%s;user:%s;tab:%s;>\r\n")},//12.打印
 {("+chuck<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;result:%s;foodnum:%s;>\r\n")}, //13.退菜
 {("+listsubscribetab<pdaid:%s;user:%s;table:%s;>\r\n")}, //14.显示预订单
 {("+entersubscribetab<pdaid:%s;user:%s;tab:%s;num:%s;>\r\n")},  //15.预定单转成正式单
 {("+updata<pdaid:%s;user:%s;updatatype:%s;cls:%s;>\r\n") },//16.更新//fwang modif
 {("+modifyfoodnum<pdaid:%s;user:%s;foodid:%s;newnum:%.2f;oldnum:%.2f;>\r\n") },//17.更改数量
 {("+gototab<pdaid:%s;user:%s;tab:%s;foodnum:%s;>\r\n") },//18.转单  
 {("+set_branch<pdaid:%s;branch:%s;>\r\n") },//19.set branch  
 {("+customer<pdaid:%s;user:%s;tab:%s;data:%s;>\r\n") },//20.customer
 {("+card<pdaid:%s;user:%s;id:%s;pwd:%s;tab:%s;do:%s;vip:%s;vpwd:%s;money:%s;type:%s;>\r\n") }//21.card
 };
 
 */
