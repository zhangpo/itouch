//
//  AKQueryAllOrders.m
//  BookSystem
//
//  Created by sundaoran on 13-12-2.
//
//

#import "AKQueryAllOrders.h"

@implementation AKQueryAllOrders
{
    UIButton *_orderButton;
    UITableView *_tableView;
    BOOL ischange;
    NSMutableArray *_orderArray;
}
@synthesize deleagte=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"选择当前台位单号"];
        //        493/354
        
        _orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_orderButton setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]];
        _orderButton.frame=CGRectMake(100, 90, 300, 40);
        [_orderButton setTitle:[NSString stringWithFormat:@"点击选择台位账单"] forState:UIControlStateNormal];
        
        [AKsNetAccessClass sharedNetAccess].zhangdanId=[NSString stringWithFormat:@"%@",_orderButton.titleLabel.text];
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"zhangdanDown.png"] forState:UIControlStateNormal];                _orderButton.tintColor=[UIColor blackColor];
        [_orderButton addTarget:self action:@selector(ButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(220, 200, 80, 40);
        [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.frame=CGRectMake(320, 200, 80, 40);
        [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
        [buttonCancle addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(100, 130, 300, 200) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        
        ischange=YES;
        
        [self addSubview:_orderButton];
        [self addSubview:buttonSure];
        [self addSubview:buttonCancle];
    }
    return self;
}

-(void)setOrderArray:(NSMutableArray *)array
{
    _orderArray=[[NSMutableArray alloc]initWithArray:array];
    if([array count]==1)
    {
        AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
        netAccess.PeopleManNum=[NSString stringWithFormat:@"%@",[[[array lastObject]componentsSeparatedByString:@";" ]objectAtIndex:1]];
        netAccess.PeopleWomanNum=[NSString stringWithFormat:@"%@",[[[array lastObject]componentsSeparatedByString:@";" ]objectAtIndex:2]];
        [_delegate ordersSelectSure:netAccess.zhangdanId];
    }
    
}

-(void)cancleButtonClick
{
    [_delegate ordersSelectCancle];
}

-(void)sureButtonClick
{
    if([_orderButton.titleLabel.text isEqualToString:@"点击选择台位账单"])
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未选择账单"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
        
    }
    else
    {
        [_delegate ordersSelectSure:_orderButton.titleLabel.text];
    }
}

-(void)ButtonClick
{
    if(ischange)
    {
        [self addSubview:_tableView];
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"zhangdanRight.png"] forState:UIControlStateNormal];
        ischange=NO;
    }
    else
    {
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"zhangdanDown.png"] forState:UIControlStateNormal];
        [_tableView removeFromSuperview];
        ischange =YES;
    }
}
#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orderArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"cell";
    UITableViewCell *cell=[_tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.textLabel.text=[[[_orderArray objectAtIndex:indexPath.row]componentsSeparatedByString:@";"]objectAtIndex:0];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_orderButton setTitle:[NSString stringWithFormat:@"%@",[[[_orderArray objectAtIndex:indexPath.row]componentsSeparatedByString:@";" ]objectAtIndex:0]] forState:UIControlStateNormal];
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    netAccess.zhangdanId=[NSString stringWithFormat:@"%@",[[[_orderArray objectAtIndex:indexPath.row]componentsSeparatedByString:@";" ]objectAtIndex:0]];
    netAccess.PeopleManNum=[NSString stringWithFormat:@"%@",[[[_orderArray objectAtIndex:indexPath.row]componentsSeparatedByString:@";" ]objectAtIndex:1]];
    netAccess.PeopleWomanNum=[NSString stringWithFormat:@"%@",[[[_orderArray objectAtIndex:indexPath.row]componentsSeparatedByString:@";" ]objectAtIndex:2]];
    
    [_orderButton setBackgroundImage:[UIImage imageNamed:@"zhangdanDown.png"] forState:UIControlStateNormal];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_tableView removeFromSuperview];
    ischange=YES;
}

-(void)successFromWebServie:(ASIHTTPRequest *)request
{
    
}
/*
 3.6 获取指定台位的未结算账单
 函数名:
 String getOrdersBytabNum(String deviceID,String userCode, String tableNum)
 IPAD 预结算时候调用获取账单 输入参数说明:
 deviceID:设备编号 userCode:登录编号 tableNum:台位编号
 返回值说明 : 形如: 0@ ORDERIDLISTS ORDERIDLISTS 未结算账单列表 (ORDERID1;ORDERID2;ORDERID3)
 不同账单之间用分号(;) 分隔。
 */

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 
 
 3.7 查询指定账单的产品接口
 函数名:
 String queryProduct ( String deviceID,String usercode,String tablEnum, String
 mancouonts,String womancounts,String orderId,String chkCode,String comOrdetach )
 IPAD 预结算时候调用获取账单明细 输入参数:
 deviceID: 设备编号 usercode:登录编号 tablEnum:台位编号 mancouonts:男人数 womancounts:女人数 orderId:账单号 chkCode:查询单授权人
 机密 9/17
 ￼北京辰森世纪科技股份有限公司
 ￼comOrdetach: 相同菜品合并发送还是分开发送 0 分开发送 1 合并发送 返回值说明:
 判断是否是已结账单,如果为未结账单格式如下 分开发送
 PRODUCTLIST 菜品列表 (
 PKID@pcode@ PCname @tpcode@ TPNAME @ TPNUM @pcount@fujiacode@price@weight@weightflg@ ISTC )
 PKID 产品唯一编码
 Pcode 产品编码
 PCname 产品名称
 Tpcode 套餐编码
 TPNAME 套餐名称
 TPNUM 套餐序号 (从 0 开始, 每个套餐独立开始) pcount 数量
 Fujiacode 附加项编码
 Price 价格
 Weight 第二单位重量
 Weightflg 第二单位标志 1 第一单位 2 第二单位 ISTC 是否套餐 0 不是 1是
 pkid@pcode@pcname@tpcode@tpname@tpnum@pcount@fujiacode@price@weight@weightfl g@istc; pkid@pcode@pcname@tpcode@tpname@tpnum@pcount@fujiacode@price@weight@weightfl g@istc
 每个菜品单独发送,不同行之间用分号(;) 分隔。 合并发送时 pkid 为空
 已结账单:
 菜品明细与优惠支付之间增加字符 ‘~’ 区分菜品或支付 支付格式:
 PKID@pcode@ PCname @tpcode@ TPNAME @ TPNUM@pcount@fujiacode @price@weight@weightflg@ ISTC~优惠或支付方式编码@优惠或支付方式名称@金额
 合并显示时 pkid 为空 其中优惠或支付方式编码或名称包括合计找零等
 */


@end
