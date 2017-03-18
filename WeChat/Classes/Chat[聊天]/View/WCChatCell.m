//
//  WCChatCell.m
//  WeChat
//
//  Created by 庄丹丹 on 2017/3/18.
//  Copyright © 2017年 庄丹丹. All rights reserved.
//

#import "WCChatCell.h"

@implementation WCChatCell


/** 返回cell的高度*/
-(CGFloat)cellHeghit{
    //1.重新布局子控件
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
    
}
@end
