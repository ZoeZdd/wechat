//
//  WCRegisterViewController.h
//  WeChat
//
//  Created by 庄丹丹 on 2016/12/6.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCRegisterViewControllerDelegate <NSObject>

// 注册完成
- (void)registerViewControllerDidfinishedRegister;

@end
@interface WCRegisterViewController : UIViewController

@property (nonatomic,weak) id<WCRegisterViewControllerDelegate> delegate;

@end
