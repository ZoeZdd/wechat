//
//  WCAccount.h
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAccount : NSObject

@property(nonatomic,copy,readonly)NSString *userJid;
/**
 *  登录的用户名
 */
@property (nonatomic,copy) NSString *loginUser;
/**
 *  登录的密码
 */
@property (nonatomic,copy) NSString *loginPwd;

/**
 * 判断用户是否登录
 */
@property (nonatomic,assign,getter=isLogin) BOOL login;

/**
 *  注册的用户
 */
@property(nonatomic,copy)NSString *registerUser;

/**
 *  注册的密码
 */
@property(nonatomic,copy)NSString *registerPwd;

+(instancetype)shareAccount;

/**
 * 保存最新的登录用户数据到沙盒
 */
-(void)saveToSandBox;

/**
 *  服务器的域名
 */
@property(nonatomic,copy,readonly)NSString *domain;

/**
 *  服务器IP
 */
@property(nonatomic,copy,readonly)NSString *host;
/**
 * 服务器的端口
 */
@property(nonatomic,assign,readonly)int port;

@end
