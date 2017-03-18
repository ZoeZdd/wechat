//
//  WCChatCell.h
//  WeChat
//
//  Created by 庄丹丹 on 2017/3/18.
//  Copyright © 2017年 庄丹丹. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *ReceiverCell = @"ReceiverCell";
static NSString *SenderCell = @"SenderCell";
@interface WCChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatListCellHeadImage;

-(CGFloat)cellHeghit;
@end
