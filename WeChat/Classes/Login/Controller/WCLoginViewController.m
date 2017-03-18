//
//  WCLoginViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/25.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCLoginViewController.h"
#import "WCRegisterViewController.h"

@interface WCLoginViewController ()<WCRegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation WCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置密码输入框的样式
    [self setupPwdFieldStyle];
    
    // 设置用户输入框的样式
    [self setupUserFieldStyle];
    
    NSLog(@"%@",NSHomeDirectory());
}

-(void)setupTextFieldStyleWithTextField:(UITextField *)textField leftViewImageName:(NSString *)leftViewImageName {
    // 设置输入框的背景图片
    textField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    // 输入框左边的图片
    UIImageView *leftView = [[UIImageView alloc] init];
    
    // 设置尺寸
    CGRect imageBound = textField.bounds;
    // 宽度高度一样
    imageBound.size.width = imageBound.size.height;
    leftView.bounds = imageBound;
    
    // 设置图片
    leftView.image = [UIImage imageNamed:leftViewImageName];
    
    // 设置图片居中显示
    leftView.contentMode = UIViewContentModeCenter;
    
    // 添加TextFiled的左边视图
    textField.leftView = leftView;
    
    // 设置TextField左边的总是显示
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)setupPwdFieldStyle{
    [self setupTextFieldStyleWithTextField:self.pwdField leftViewImageName:@"Card_Lock"];
}
- (IBAction)textChange:(id)sender {
    //登录按钮的禁用
//    self.loginBtn.enabled = (self.pwdField.text.length > 0 && self.userField.text.length > 0);
    self.loginBtn.enabled = (self.pwdField.text > 0);
}

-(void)setupUserFieldStyle
{
    [self setupTextFieldStyleWithTextField:self.userField leftViewImageName:@"aio_chat_buddy_normal"];
}

- (IBAction)loginBtnClick:(id)sender {
    // 1.判断有没有输入用户名和密码
    if (self.userField.text.length == 0 || self.pwdField.text.length == 0) {
        WCLog(@"请输入用户名和密码");
        return;
    }
    
    // 给用户提示
    [MBProgressHUD showMessage:@"正在登录ing...."];

    // 2.登录服务器
       // 2.1 把用户和密码先放在Account单例
    [WCAccount shareAccount].loginUser = self.userField.text;
    [WCAccount shareAccount].loginPwd = self.pwdField.text;
    
      // 2.2 调用AppDelegate的XMPPLogin的方法
    // ?怎么把appdelegate的登录结果告诉WCLoginViewControllers控制器
    // 》代理
    // 》block
    // 》通知
    
    // block会对self进行强引用
    __weak typeof(self) selfVc = self;
    //自己写的block ，有强引用的时候，使用弱引用,系统block,我基本可次理
    [[WCXMPPTool sharedWCXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        if (resultType == XMPPResultTypeLoginSuccess) {
            WCLog(@"登录成功");
            // 3.登陆成功跳转到主界面
            [selfVc handlXMPPResultType:resultType];
        }else{
            WCLog(@"登录失败");
        }
    }];
}

#pragma mark 处理结果
-(void)handlXMPPResultType:(XMPPResultType)resultType{
    // 回到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        if (resultType == XMPPResultTypeLoginSuccess) {
            WCLog(@"登录成功");
            // 3.登录成功切换到主界面
            [UIStoryboard showInitialVCWithName:@"Main"];
            
            // 设置当前的登录状态
            [WCAccount shareAccount].login = YES;
            
            // 保存登录帐户信息到沙盒
            [[WCAccount shareAccount] saveToSandBox];
            
        }else{
            WCLog(@"登录失败");
            [MBProgressHUD showError:@"用户名或者密码不正确"];
        }

     });
                   
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)destVc;
        id rootVc = nav.viewControllers[0];
        
        // 注册控制器
        if ([rootVc isKindOfClass:[WCRegisterViewController class]]) {
            WCRegisterViewController *registerVc = (WCRegisterViewController *)rootVc;
            registerVc.delegate = self;
        }
        
    }

}

#pragma mark -注册控制器代理
#pragma mark 注册完成
-(void)registerViewControllerDidfinishedRegister
{
    [MBProgressHUD showSuccess:@"注册成功，请再次输入密码登录" toView:self.view ];
    
    
    self.userField.text = [WCAccount shareAccount].registerUser;
    
    // 消失模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
