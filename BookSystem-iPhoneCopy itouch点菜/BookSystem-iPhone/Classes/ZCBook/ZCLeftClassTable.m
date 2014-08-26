//
//  ZCLeftClassTable.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-3.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "ZCLeftClassTable.h"
#import "BSDataProvider.h"

@implementation ZCLeftClassTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ZCreloadLeftTable" object:nil];
    }
    return self;
}

//刷新table通知方法
-(void)reloadTable{
    [self reloadData];
}
-(void)_init{
    BSDataProvider *dataPro = [BSDataProvider sharedInstance];
    classArray = [[NSMutableArray alloc] init];
    classArray = [[dataPro getClassList] retain];
    
    self.delegate = self;
    self.dataSource = self;
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    
    
    NSMutableArray *mutAry = (NSMutableArray *)[dataPro getPackage];
    isPack = YES;
    if ([mutAry count] >0) {
        isPack = YES;
    }else{
        isPack = NO;
    }
    
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ZCtypeResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    int count = 0;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    if (isPack) {
        for (NSMutableDictionary *dic in aryMutOrder) {
            if ([[[dic objectForKey:@"food"] objectForKey:@"CLASS"] integerValue] == indexPath.row && ![[dic objectForKey:@"isPack"] boolValue]) {
                count = count + [[dic objectForKey:@"total"] intValue];
            }else if (indexPath.row == 0 && [[dic objectForKey:@"isPack"] boolValue]){
                count = count + [[dic objectForKey:@"total"] intValue];
            }
        }
    }else{
        for (NSMutableDictionary *dic in aryMutOrder) {
            if ([[[dic objectForKey:@"food"] objectForKey:@"CLASS"] integerValue] == indexPath.row+1) {
                count = count + [[dic objectForKey:@"total"] intValue];
            }
        }
    }
    
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    NSString *strCount = @"";
    if (count > 0) {
        strCount = [NSString stringWithFormat:@"%d",count];
    }else{
        strCount = @"";
    }
    cell.detailTextLabel.text = strCount;
    if (isPack) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"套餐";
        }else{
            NSDictionary *dic =  [classArray objectAtIndex:indexPath.row-1];
            cell.textLabel.text = [dic objectForKey:@"DES"];
        }
    }else{
        NSDictionary *dic =  [classArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic objectForKey:@"DES"];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isPack) {
        return [classArray count]+1;
    }else{
        return [classArray count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *typeID = typeID = [NSString stringWithFormat:@"%d",indexPath.row];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCChangeTypeNotification" object:typeID];
}

-(void)dealloc{
    [super dealloc];
    classArray = nil;
    [classArray release];
}

@end
