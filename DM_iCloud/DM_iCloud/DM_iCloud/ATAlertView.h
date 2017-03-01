//
//  ATAlertView.h
//  AisToy
//
//  Created by brook on 16/3/25.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import <UIKit/UIKit.h>

// 检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ATAlertView : UIAlertView

/**
 *    使用block创建一个弹出框。如果某个按钮没有动作要求，请提供nil
 *    @param title 标题
 *    @param message	信息
 *    @param cancelButtonTitle 取消按钮标题
 *    @param cancalAction		取消按钮的动作
 *    @param otherButtonTitles 其他按钮标题
 *    @param otherAction 其他的按钮的动作
 *    @return 初始化好的弹出框
 */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                 cancelAction:(void (^)(ATAlertView *sender))cancalAction
            otherButtonTitles:(NSString *)otherButtonTitles
                  otherAction:(void (^)(ATAlertView *sender))otherAction;

/** 创建一个带输入框的 AlertView */
- (instancetype)initWithInputAlertTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                           cancelAction:(void (^)(ATAlertView *sender))cancalAction
                      otherButtonTitles:(NSString *)otherButtonTitles
                            otherAction:(void (^)(ATAlertView *sender, NSString *inputText))otherAction
                           keyboardType:(UIKeyboardType)keyboardType;

@end
