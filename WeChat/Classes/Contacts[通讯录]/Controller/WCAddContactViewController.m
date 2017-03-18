//
//  WCAddContactViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/7.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCAddContactViewController.h"

@interface WCAddContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation WCAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)addContactBtnClick:(id)sender {
    //添加好友
    // 获取用户输入好友名称
    NSString *user = self.textField.text;
    
    //1.不能添加自己为好友
    if ([user isEqualToString:[WCAccount shareAccount].loginUser]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    //2.已经存在好友无需添加
    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[WCAccount shareAccount].domain resource:nil];
    
    BOOL userExists = [[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream];
    if (userExists) {
        [self showMsg:@"好友已经存在"];
        return;
    }
    
    //3.添加好友 (订阅)
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:userJid];

    // 添加好友在现有的openfire存在的问题
    // 1.添加不存在的好友,通讯录里面也显示了好友
    //  解决方法1: 服务器可以拦截好友添加的请求 如果当前数据库没有好友,不要返回信息
    // 2.解决方法2: 过滤数据库subscription的查询
    /*
       none  对方没有同意添加好友
       to    发送给对方的请求
       from   别人发来的请求
       both  双方互为好友
     */
}

-(void)showMsg:(NSString *)msg{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [av show];
}

@end
