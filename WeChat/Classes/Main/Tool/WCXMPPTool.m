//
//  WCXMPPTool.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCXMPPTool.h"
#import "XMPPFramework.h"


/* 用户登录流程
 1.初始化XMPPStream
 
 2.连接服务器(传一个jid)
 
 3.连接成功,接着发送密码
 
 // 默认登录成功是不在线
 4.发送一个 "在线消息" 给服务器 -> 可以通知其他用户你在线
 
 */
@interface WCXMPPTool ()<XMPPStreamDelegate>{
//    XMPPStream  *_xmppStream; //与服务器交互的核心类
//    XMPPvCardAvatarModule *_vCardAvatar;// 头像模块
    
    XMPPResultBlock  _resultBlock;//结果回调Block
}

/**
 * 1.初始化XMPPStream
 */
-(void)setupStream;

/**
 * 2.连接服务器(传一个jid)
 */
-(void)connectToHost;

/**
 * 3.连接成功,接着发送密码
 */
-(void)sendPwdToHost;

/**
 * 4.发送一个 "在线消息" 给服务器
 */
-(void)sendOnline;

/**
 *  发送 “离线” 消息
 */
-(void)sendOffline;

/**
 *  与服务器断开连接
 */
-(void)disconncetFromHost;

@end


@implementation WCXMPPTool
singleton_implementation(WCXMPPTool)

#pragma mark - 私有方法
-(void)setupStream
{
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc] init];
    
    // 添加XMPP的模块
    // 1.添加 "电子名片" 的模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    // 激活
    [_vCard  activate:_xmppStream];
    
    // 电子名片模块还会配合 "头像模块" 一起使用
    // 2.添加 "头像模块"
    _vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    // 激活
    [_vCardAvatar activate:_xmppStream];
    
    // 3.添加 "花名册" 模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    // 4.添加 "消息" 模块
    _msgArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingStorage];
    [_msgArchiving activate:_xmppStream];
 
    
    // 设置代理 - 所有的代理方法都将在子线程被调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

// 释放资源
-(void)teardownStream{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_vCardAvatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _msgArchiving = nil;
    _msgArchivingStorage = nil;
    _roster = nil;
    _rosterStorage = nil;
    _vCardStorage = nil;
    _vCard = nil;
    _vCardAvatar = nil;
    _xmppStream = nil;
    
}

-(void)connectToHost
{
    if (!_xmppStream) {
        [self setupStream];
    }
    // 1.设置登录用户的jid
    XMPPJID *myJid = nil;
    // resource  用户登录客户端设备登录的类型
    
    WCAccount *account = [WCAccount shareAccount];
    
    if (self.isRegisterOperation) { //注册
        NSString *registerUser = [WCAccount shareAccount].registerUser;
        myJid = [XMPPJID jidWithUser:registerUser domain:account.domain resource:nil];
    } else {//登录
        NSString *loginUser = [WCAccount shareAccount].loginUser;
        myJid = [XMPPJID jidWithUser:loginUser domain:account.domain resource:@"iphone"];
    }
    
    _xmppStream.myJID = myJid;
    
    // 2.设置主机地址
    _xmppStream.hostName = account.host;
    
    // 3.设置主机端口号 (默认就是5222,可以不设置)
    _xmppStream.hostPort = account.port;
    
    // 4.发起连接
    NSError *error = nil;
    // 缺少必要的参数时就会发起连接失败 ? 没有设置jid
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        WCLog(@"%@",error);
    }else{
        WCLog(@"发起连接成功");
    }
    
}

-(void)sendPwdToHost
{
    NSError *error = nil;
    NSString *pwd = [WCAccount shareAccount].loginPwd;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        WCLog(@"%@",error);
    }
}

-(void)sendOnline
{
    // XMPP框架,已经把所以的指令封闭成对象
    XMPPPresence *presence = [XMPPPresence presence];
    WCLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}

-(void)sendOffline
{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}

-(void)disconncetFromHost
{
    [_xmppStream disconnect];
}
#pragma mark - XMPPSttream的代理
#pragma mark - 连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    WCLog(@"建立连接成功");
//    [self sendPwdToHost];
//    
//    // 回调resultBlock
//    if (_resultBlock) {
//        _resultBlock(XMPPResultTypeLoginSuccess);
//    }
    if (self.isRegisterOperation) { // 注册
        NSError *error = nil;
        NSString *reigsterPwd = [WCAccount shareAccount].registerPwd;
        [_xmppStream registerWithPassword:reigsterPwd error:&error];
        if (error) {
            WCLog(@"%@",error);
        }
    } else { // 登录
        [self sendPwdToHost];
    }

}
#pragma mark 与服务器断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
//    NSLog(@"%s %@",__func__,error);
    WCLog(@"与服务器断开连接%@",error);
}
#pragma mark - 登录成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    WCLog(@"登录成功");
    [self sendOnline];
    
    // 回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
        _resultBlock = nil;
    }
}

#pragma mark - 登录失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    WCLog(@"登录失败%@",error);
    // 回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
    
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    WCLog(@"注册成功");
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    WCLog(@"注册失败 %@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
    
}

#pragma mark - 公共方法
#pragma mark - 用户登录
-(void)xmppLogin:(XMPPResultBlock)resultBlock
{
    // 不管什么情况，把以前的连接断开
    [_xmppStream disconnect];

    // 保存resultBlock
    _resultBlock = resultBlock;
    
    // 连接服务器开始登录操作
    [self connectToHost];
}
#pragma mark 用户注册
-(void)xmppRegister:(XMPPResultBlock)resultBlock
{
    /* 注册步骤
     1.发送 "注册jid" 给服务器，请求一个长连接
     2.连接成功，发送注册密码
     */
    //保存block
    _resultBlock = resultBlock;
    
    // 去除以前的连接
    [_xmppStream disconnect];
    
    [self connectToHost];

}
#pragma mark 用户注销
-(void)xmppLogout
{
    // 1.发送 "离线消息" 给服务器
    [self sendOffline];
    // 2.断开与服务器的连接
    [self disconncetFromHost];
}

-(void)dealloc{
    [self teardownStream];
}
@end
