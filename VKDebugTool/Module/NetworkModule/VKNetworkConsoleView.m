//
//  VKNetworkConsoleView.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKNetworkConsoleView.h"
#import "VKNetworkLogger.h"
@interface VKNetworkConsoleView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *requestTable;

@property (nonatomic,strong) NSMutableArray *requestDataArr;

@property (nonatomic,strong) NSMutableArray *requestArr;

@property (nonatomic,strong) NSString *pasteboardString;


@end

@implementation VKNetworkConsoleView


-(UITableView *)requestTable
{
    if (!_requestTable) {
        _requestTable = [[UITableView alloc]initWithFrame:self.bounds];
        _requestTable.delegate = self;
        _requestTable.dataSource = self;
        _requestTable.backgroundColor = [UIColor clearColor];
        [self addSubview:_requestTable];
    }
    return _requestTable;
}


-(void)showConsole{
    [super showConsole];
    [self addLogNotificationObserver];
    [self showLogManagerOldLog];
}

-(void)hideConsole
{
    [super hideConsole];
    [self removeLogNotificationObserver];
}

-(void)showLogManagerOldLog
{
    self.requestDataArr = [[NSMutableArray alloc]initWithArray:[VKNetworkLogger singleton].logDataArray];
    self.requestArr = [[NSMutableArray alloc]initWithArray:[VKNetworkLogger singleton].logReqArray];
    [self.requestTable reloadData];
}

-(void)addLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationGet:) name:VKNetDataLogNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationDataGet:) name:VKNetReqLogNotification object:nil];
}

-(void)removeLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)logNotificationGet:(NSNotification *)noti
{
    NSURLRequest * request = noti.object;
    if (request) {
        [self.requestArr addObject:request];
    }
}

-(void)logNotificationDataGet:(NSNotification *)noti
{
    NSURLRequest * request = noti.object;
    if (request) {
        [self.requestDataArr addObject:request];
    }
    [self.requestTable reloadData];
}

#pragma mark  tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestDataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *requestID = @"VKRequestID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:requestID];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    if (indexPath.row < self.requestArr.count) {
        NSURLRequest *req = self.requestArr[indexPath.row];
        cell.textLabel.text = req.URL.absoluteString;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURLRequest *req = self.requestArr[indexPath.row];
    NSString *strurl = req.URL.absoluteString;
    
    NSData *reqData = self.requestDataArr[indexPath.row];
    NSString *strdata = [[NSJSONSerialization JSONObjectWithData:reqData options:kNilOptions error:nil] description];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"返回数据" message:strdata delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"复制", nil];
    [alert show];
    
    NSString *pasteboardstr = [NSString stringWithFormat:@"URL: %@ \n\n Data: %@",strurl,strdata];
    self.pasteboardString = pasteboardstr;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//复制
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.pasteboardString;
        self.pasteboardString = nil;
    }
}

@end
