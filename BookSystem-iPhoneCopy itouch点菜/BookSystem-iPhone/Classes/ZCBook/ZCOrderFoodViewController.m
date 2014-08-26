//
//  BSOrderFoodViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "ZCOrderFoodViewController.h"
#import "BSDataProvider.h"
@interface ZCOrderFoodViewController ()

@end


@implementation ZCOrderFoodViewController
@synthesize aryResult,aryAddition,strUnitKey,strPriceKey;

- (void)dealloc{
    self.aryResult = nil;
    self.aryAddition = nil;
    self.strUnitKey = nil;
    self.strPriceKey = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBGColor:nil];
    [self addNavButtonAndTitle:@"点菜"];
	// Do any additional setup after loading the view.
    
    self.strUnitKey = @"UNIT";
    self.strPriceKey = @"PRICE";
    self.aryResult = [NSMutableArray array];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.delegate = self;
    
    
    tvResult = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height-50)];
    tvResult.backgroundColor = [UIColor clearColor];
    tvResult.delegate = self;
    tvResult.dataSource = self;
    [self.view addSubview:tvResult];
    tvResult.tableHeaderView = searchBar;
    [searchBar release];
    [tvResult release];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)orderClicked{
    
}

- (void)additionClicked{
    
}

- (void)sendClicked{
    
}

- (void)buttonClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.tag==0)
        btnBook.selected = !btnOrdered;
    else
        btnOrdered.selected = !btnBook;
}

- (void)adjustFrame:(NSNotification *)notification{
    NSLog(@"User Info:%@",notification.userInfo);
    
    //    NSIndexPath *indexPath = nil;
    //    if ([aryMessages count]>0){
    //        indexPath = [[tvMessages indexPathsForVisibleRows] lastObject];
    //    }
    
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float h = rect.size.height;
    
    float y = self.view.frame.size.height-h;
    
    NSLog(@"Keyboard Height:%f",h);
    
    
    
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        tvResult.frame = CGRectMake(0, 50, 320, y-50);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideKeyboard{
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        tvResult.frame = CGRectMake(0, 50, 320, self.view.frame.size.height-50);
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)swiped{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    
    cell.textLabel.text = [[aryResult objectAtIndex:indexPath.row] objectForKey:@"DES"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@元/%@",[[aryResult objectAtIndex:indexPath.row] objectForKey:@"PRICE"],[[aryResult objectAtIndex:indexPath.row] objectForKey:@"UNIT"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return aryResult.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self addFood:[aryResult objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
}


- (void)addFood:(NSDictionary *)foodInfo byCount:(NSString *)count{
    
    NSString *itcode = [foodInfo objectForKey:@"ITCODE"];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    
    BOOL bFinded = NO;
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"]
            && ![[food objectForKey:@"isPack"] boolValue]
            && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
            bFinded = YES;
            float total = [[food objectForKey:@"total"] floatValue];
            total += [count floatValue];
            
            if (total>0){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
            }else
                [ary removeObject:food];
            
            [dp saveOrders];
            break;
        }
    }
    
    
    if (!bFinded && [count floatValue]>0){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:foodInfo forKey:@"food"];
        [dict setObject:count forKey:@"total"];
        
        
        
        
        if (self.aryAddition)
            [dict setObject:aryAddition forKey:@"addition"];
        
        if (self.strUnitKey){
            [dict setObject:strUnitKey forKey:@"unitKey"];
            [dict setObject:strPriceKey forKey:@"priceKey"];
        }
        
        [dp orderFood_zc:dict];
        
        //        self.aryAddition = nil;
        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";
        
    }
    
    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
//    [SVProgressHUD showWithStatus:@""];
//    [SVProgressHUD dismissWithSuccess:@"添加成功" afterDelay:2];
}

#pragma mark -  UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    
    
    
    [aryResult removeAllObjects];
    
    
    
    if ([searchText length]>0){
        int count = strlen([searchText UTF8String]);
        int len = [searchText length];
        
        char a = [searchText characterAtIndex:0];
        
        if (a>='0' && a<='9'){
            NSArray *ary = [dp getFoodList:[NSString stringWithFormat:@"ITCODE like '%%%@%%'",searchText]];
            [aryResult addObjectsFromArray:ary];
        }
        else if (count==len && ((a>='A' && a<='Z') || (a>='a' && a<='z'))){
            NSArray *ary = [dp getFoodList:[NSString stringWithFormat:@"(DESCE like '%%%@%%') or (INIT like '%%%@%%')",searchText,searchText]];
            [aryResult addObjectsFromArray:ary];
        }
        else{
            NSArray *ary = [dp getFoodList:[NSString stringWithFormat:@"DES like '%%%@%%'",searchText]];
            [aryResult addObjectsFromArray:ary];
        }
    }
    
    
    
    
    [tvResult reloadData];
}
@end
