//
//  UIImage+ZOE.m
//  WeChat
//
//  Created by 庄丹丹 on 2016/11/26.
//  Copyright © 2016年 庄丹丹. All rights reserved.
//

#import "UIImage+ZOE.h"

@implementation UIImage (ZOE)

+(UIImage *)stretchedImageWithName:(NSString *)name{
    
    UIImage *image = [UIImage imageNamed:name];
    int leftCap = image.size.width * 0.5;
    int topCap = image.size.height * 0.5;
    return [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

@end
