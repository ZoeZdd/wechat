//
//  WCEditVCardViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/7.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCEditVCardViewController.h"

@interface WCEditVCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation WCEditVCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.title = self.cell.textLabel.text;
    
    
    //设置输入框默认数值
    self.textField.text = self.cell.detailTextLabel.text;
}
- (IBAction)cancle:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveBtnClick:(id)sender {
    //1.把cell的detailTextLabel的值更改
    self.cell.detailTextLabel.text = self.textField.text;
    
    [self.cell layoutSubviews];
    //2.当前控制器销毁
    [self.navigationController popViewControllerAnimated:YES];
    
    //3.通知上一个控制器
    if ([self.delegate respondsToSelector:@selector(editVCardViewController:didFinishedSave:)]) {
        [self.delegate editVCardViewController:self didFinishedSave:sender];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
