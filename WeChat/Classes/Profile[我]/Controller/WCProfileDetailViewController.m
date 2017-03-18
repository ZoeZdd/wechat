//
//  WCProfileDetailViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/7.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "WCProfileDetailViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditVCardViewController.h"

@interface WCProfileDetailViewController ()<WCEditVCardViewControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView; //头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel; //昵称

@property (weak, nonatomic) IBOutlet UILabel *wechatNumLabel;//微信号
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *telLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//邮件

@end

@implementation WCProfileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"%@",NSHomeDirectory());
    
    XMPPvCardTemp *myvCard =  [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 获取头像
    if (myvCard.photo) {
        self.avatarImgView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 微信号 (显示用户名)
    self.wechatNumLabel.text =[WCAccount shareAccount].loginUser;
    
    self.nicknameLabel.text = myvCard.nickname;
    
    //公司
    self.orgNameLabel.text = myvCard.orgName;
    
    //部门
    if (myvCard.orgUnits.count > 0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    
    //职位
    self.titleLabel.text = myvCard.title;
    
    //电话
    //self.telLabel.text = myvCard.telecomsAddresses[0];
    //使用note充当电话
    self.telLabel.text = myvCard.note;
    
    //邮箱
    // 使用mailer充当
    self.emailLabel.text = myvCard.mailer;

}

#pragma mark 表格选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //根据cell不同tag进行相应的操作
    /*
     *tag = 0,换头像
     *tag = 1,进行到下一个控制器
     *tag = 2,不做任何操作
     */
    
    //获取cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    switch (selectedCell.tag) {
        case 0:
            WCLog(@"换头像");
            [self choseImg];
            break;
        case 1:
            WCLog(@"进入下一个控制器");
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:selectedCell];
            break;
        case 2:
            WCLog(@"不做任何操作");
            break;
        default:
            break;
    }

}

#pragma mark 选择图片
-(void)choseImg{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"图片库", nil];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WCLog(@"%ld",buttonIndex);
    if (buttonIndex == 2) return;
    
    // 图片选择器
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    
    //设置代理
    imgPC.delegate = self;
    
    //允许编辑图片
    imgPC.allowsEditing = YES;
    
    if (buttonIndex == 0) {//照相
        imgPC.sourceType =  UIImagePickerControllerSourceTypeCamera;
    }else{//图片库
        imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //显示控制器
    [self presentViewController:imgPC animated:YES completion:nil];
}
#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
     WCLog(@"%@",info);
    //获取修改后的图片
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    
    //更改cell里的图片
    self.avatarImgView.image = editedImg;
    
    //移除图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //把新的图片保存到服务器
    [self editVCardViewController:nil didFinishedSave:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取目标控制器
    id destVc = segue.destinationViewController;
    
    //设置编辑电子名片控制器的cell属性
    if ([destVc isKindOfClass:[WCEditVCardViewController class]]) {
        WCEditVCardViewController *editVc = destVc;
        editVc.cell = sender;
        //设置代理
        editVc.delegate = self;
    }

}
#pragma mark 编辑电子名片控制器的代理
-(void)editVCardViewController:(WCEditVCardViewController *)editVc didFinishedSave:(id)sender
{
    WCLog(@"完成保存");
    
    //获取当前电子名片
    XMPPvCardTemp *myVCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    //重新设置头像
    myVCard.photo = UIImageJPEGRepresentation(self.avatarImgView.image, 0.75);
    
    //重新设置myVCard里的属性
    myVCard.nickname = self.nicknameLabel.text;
    myVCard.orgName = self.orgNameLabel.text;
    
    if (self.departmentLabel.text != nil) {
        myVCard.orgUnits = @[self.departmentLabel.text];
    }
    
    myVCard.title = self.titleLabel.text;
    myVCard.note = self.telLabel.text;
    myVCard.mailer = self.emailLabel.text;
    
    //把数据保存到服务器
    // 内部实现数据上传是把整个电子名片数据都从新上传了一次，包括图片
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myVCard];
    

}
@end
