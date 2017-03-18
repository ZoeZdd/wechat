//
//  WCAccount.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCAccount.h"

#define kUserKey @"user"
#define kPwdKey @"pwd"
#define kLoginKey @"login"

static NSString *domain = @"teacher.local";
static NSString *host = @"127.0.0.1";
static int port = 5222;

@implementation WCAccount

+(instancetype)shareAccount
{
    return [[self alloc] init];
}

#pragma mark - 分配内存创建对象
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    NSLog(@"%s",__func__);
    static WCAccount *account;
    
    // 为了线程安全
    // 三个线程同时调用这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        if (account == nil) {
            account = [super allocWithZone:zone];
            
            //从沙盒获取上次的用户登录信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            account.loginUser = [defaults objectForKey:kUserKey];
            account.loginPwd = [defaults objectForKey:kPwdKey];
            account.login = [defaults boolForKey:kLoginKey];
//        }
    });
    return account;
}

-(void)saveToSandBox{
    
    // 保存user pwd login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUserKey];
    [defaults setObject:self.loginPwd forKey:kPwdKey];
    [defaults setBool:self.isLogin forKey:kLoginKey];
    [defaults synchronize];
    
}
-(NSString *)domain
{
    return domain;
}
-(NSString *)host
{
    return host;
}
-(int)port
{
    return port;
}
-(NSString *)userJid{
    return [NSString stringWithFormat:@"%@@%@",self.loginUser,domain];
}

@end
