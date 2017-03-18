//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/6.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCRegisterViewController.h"

@interface WCRegisterViewController ()
- (IBAction)cancelBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;
- (IBAction)textChange:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;


@end

@implementation WCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置输入框背景图片
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerBtnClick:(id)sender {
    //注册
    // 保存注册的用户名和密码
    [WCAccount shareAccount].registerUser = self.userField.text;
    [WCAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册中...."];
    // 调用注册的方法
    __weak typeof (self) selfVc = self;
    [WCXMPPTool sharedWCXMPPTool].registerOperation = YES;
    [[WCXMPPTool sharedWCXMPPTool] xmppRegister:^(XMPPResultType resultType) {
        [selfVc handleXMPPResult:resultType];
    }];
    
}
- (IBAction)textChange:(id)sender{
    // 设置按钮是否可用
    BOOL enable = (self.userField.text.length != 0 &&  self.pwdField.text.length != 0);
    
    self.registerBtn.enabled = enable;
}
#pragma mark 处理注册的结果
-(void)handleXMPPResult:(XMPPResultType)resultType{
    //在主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1.隐藏提示
        [MBProgressHUD hideHUD];
        
        // 2.提示注册成功
        if (resultType == XMPPResultTypeRegisterSuccess) {
//            [MBProgressHUD showSuccess:@"恭喜注册成功，回到登录界面登录..."];
            if ([self.delegate respondsToSelector:@selector(registerViewControllerDidfinishedRegister)]) {
                [self.delegate registerViewControllerDidfinishedRegister];
            }
        } else {
            [MBProgressHUD showError:@"用户名已存在"];
        }
    });
}
@end
