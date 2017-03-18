//
//  WCProfileViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface WCProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *weChatNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation WCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示头像和微信号
    
    //从数据库里取用户信息
    
    //获取登录用户信息的，使用电子名片模块
    
    // 登录用户的电子名片信息
    // 1.它内部会去数据查找
    XMPPvCardTemp *myvCard =  [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号 (显示用户名)
    // 为什么jid是空，原因是服务器返回的电子名片xmp数据没有JABBERJID的节点
    //self.wechatNumLabel.text = myvCard.jid.user;
    self.weChatNumLabel.text = [@"微信号:" stringByAppendingString:[WCAccount shareAccount].loginUser];
    
    self.nicknameLabel.text = [WCAccount shareAccount].loginUser;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutBtnClick:(id)sender {
    //注销
    [[WCXMPPTool sharedWCXMPPTool] xmppLogout];
    
    // 注销的时候，把沙盒的登录状态设置为NO
    [WCAccount shareAccount].login = NO;
    [[WCAccount shareAccount] saveToSandBox];
    
    //回登录的控制器
     [UIStoryboard showInitialVCWithName:@"Login"];
}

@end
