//
//  WCChatViewController.m
//  WeChat
//
//  Created by 庄丹丹 on 2017/3/18.
//  Copyright © 2017年 庄丹丹. All rights reserved.
//

#import "WCChatViewController.h"
#import "WCChatCell.h"
#import "XMPPvCardTemp.h"
#import "WCNavigationController.h"
@interface WCChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    NSFetchedResultsController *_resultContr;
}
/**输入工具条底部的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarBottomConstraint;
/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


/** 计算高度的cell工具对象 */
@property (nonatomic, strong) WCChatCell *chatCellTool;
@property (weak, nonatomic) IBOutlet UIButton *imageBtnClick;



@end

@implementation WCChatViewController

-(NSMutableArray *)dataSources{
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    
    return _dataSources;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
    self.title = self.friendJid.user;
    self.tableView.separatorColor = [UIColor clearColor];
    // 给计算高度的cell工具对象 赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    
    //1.监听键盘弹出，把inputToolbar(输入工具条)往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //2.监听键盘退出，inputToolbar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 加载数据
    [self loadMessage];
    
}
#pragma mark 从数据库加载聊天数据
-(void)loadMessage{
    //加载数据库的聊天数据
    
    // 1.上下文
    NSManagedObjectContext *msgContext = [WCXMPPTool sharedWCXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤 （当前登录用户 并且 好友的聊天消息）
    NSString *loginUserJid = [WCXMPPTool sharedWCXMPPTool].xmppStream.myJID.bare;
    WCLog(@"%@",loginUserJid);
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *err = nil;
    [_resultContr performFetch:&err];
    WCLog(@"%@",err);
    WCLog(@"%@",_resultContr.fetchedObjects);
    
    // 添加到数据源
    [self.dataSources addObjectsFromArray:_resultContr.fetchedObjects];
//    WCLog(@"%@",self.dataSources);
}
#pragma mark 键盘显示时会触发的方法
-(void)kbWillShow:(NSNotification *)noti{
    
    //1.获取键盘高度
    //1.1获取键盘结束时候的位置
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    
    
    //2.更改inputToolbar 底部约束
    self.inputToolBarBottomConstraint.constant = kbHeight;
    //添加动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}
#pragma mark 键盘退出时会触发的方法
-(void)kbWillHide:(NSNotification *)noti{
    //inputToolbar恢复原位
    self.inputToolBarBottomConstraint.constant = 0;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 设置label的数据
    //获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = self.dataSources[indexPath.row];
#warning 计算高度与前，一定要给messageLabel.text赋值
    self.chatCellTool.messageLabel.text = msgObj.body;
    
    return [self.chatCellTool cellHeghit];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取聊天信息
//    XMPPMessageArchiving_Message_CoreDataObject *msgObj = self.dataSources[indexPath.row];

    XMPPMessageArchiving_Message_CoreDataObject *msgObj = [_resultContr objectAtIndexPath:indexPath];
    WCChatCell *cell = nil;
    if ([[msgObj outgoing] boolValue] == YES) {//发送方的cell
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
        // 登录用户的电子名片信息
        // 1.它内部会去数据查找
        XMPPvCardTemp *myvCard =  [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
        
        // 获取头像
        if (myvCard.photo) {
            cell.chatListCellHeadImage.image = [UIImage imageWithData:myvCard.photo];
        }

    }else{//接收发方的cell
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    }
    //显示内容
    
    cell.messageLabel.text = msgObj.body;
    
    return cell;
    
    
}

#pragma mark - UITextView代理
#pragma mark 发送聊天数据
-(void)textViewDidChange:(UITextView *)textView{
    NSLog(@"%@",textView.text);
    NSString *txt = textView.text;
    // 监听Send事件--判断最后的一个字符是不是换行字符
    if ([textView.text hasSuffix:@"\n"]) {
        NSLog(@"发送操作");
        //怎么发聊天数据
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
        
        [msg addBody:txt];
        
        [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
        
        // 3.把消息添加到数据源，然后再刷新表格
        [self.dataSources addObject:msg];
        [self.tableView reloadData];

        // 清空输入框的文本
        textView.text = nil;

        // 4.把消息显示在顶部
        [self scrollToBottom];
    }
}


-(void)scrollToBottom{
    //1.获取最后一行
    if (self.dataSources.count == 0) {
        return;
    }
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSources.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark 数据库内容改变调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView reloadData];
    
    // 4.把消息显示在顶部
    [self scrollToBottom];
    
 
}

@end
