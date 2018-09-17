//
//  CYNavigationController.h
//
//  Created by Candy on 2018/9/17.
//  Copyright © 2018年 Candy. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PopAnimationType){
    PopAnimationTypeFromeBehind = 0, // 动画效果从后往前  默认效果
    PopAnimationTypeliner = 1, // 动画效果从左向右平滑
};

@interface CYNavigationController : UINavigationController<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, assign) PopAnimationType popAnimationType;
@property (nonatomic,assign) BOOL canDragBack;

@end
