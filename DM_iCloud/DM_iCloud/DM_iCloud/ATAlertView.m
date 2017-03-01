//
//  ATAlertView.m
//  AisToy
//
//  Created by brook on 16/3/25.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import "ATAlertView.h"

@interface ATAlertView () <UIAlertViewDelegate>

@property (nonatomic, copy) void (^onCancelButtonClicked)(ATAlertView *alertView);
@property (nonatomic, copy) void (^onOtherButtonClicked)(ATAlertView *alertView);
@property (nonatomic, copy) void (^onInputOtherButtonClicked)(ATAlertView *alertView, NSString *inputText);

@end

@implementation ATAlertView

#pragma mark - --------------------退出清空--------------------

- (void)dealloc
{
    self.onOtherButtonClicked = nil;
    self.onCancelButtonClicked = nil;
}

#pragma mark - --------------------初始化--------------------

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                 cancelAction:(void (^)(ATAlertView *sender))cancalAction
            otherButtonTitles:(NSString *)otherButtonTitles
                  otherAction:(void (^)(ATAlertView *sender))otherAction
{
    if (title == nil) {
        title = @"";
    }
    
    self = [self initWithTitle:title
                       message:message
                      delegate:self
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:otherButtonTitles, nil];
    
    if (self) {
        self.onCancelButtonClicked	= cancalAction;
        self.onOtherButtonClicked	= otherAction;
    }
    return self;
}

- (instancetype)initWithInputAlertTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                           cancelAction:(void (^)(ATAlertView *sender))cancalAction
                      otherButtonTitles:(NSString *)otherButtonTitles
                            otherAction:(void (^)(ATAlertView *sender, NSString *inputText))otherAction
                           keyboardType:(UIKeyboardType)keyboardType
{
    if (title == nil) {
        title = @"";
    }
    
    self = [self initWithTitle:title
                       message:message
                      delegate:self
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:otherButtonTitles, nil];
    self.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    if (self) {
        self.onCancelButtonClicked = cancalAction;
        self.onInputOtherButtonClicked = otherAction;
        UITextField *textfiled = [self textFieldAtIndex:0];
        textfiled.keyboardType = keyboardType;
    }
    
    return self;
}

#pragma mark - --------------------System--------------------
#pragma mark - --------------------功能函数--------------------
#pragma mark - --------------------手势事件--------------------
#pragma mark - --------------------按钮事件--------------------
#pragma mark - --------------------代理方法--------------------

#pragma mark - UIAlertDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            if (self.onCancelButtonClicked)
            {
                self.onCancelButtonClicked(self);
            }
            
            break;
        }
        case 1:
        {
            if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
            {
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                if (self.onInputOtherButtonClicked) {
                    self.onInputOtherButtonClicked(self, textField.text);
                }
            }
            else if (self.onOtherButtonClicked)
            {
                self.onOtherButtonClicked(self);
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        return (textField.text.length > 0);
    }
    else {
        return YES;
    }
}

#pragma mark - --------------------属性相关--------------------
#pragma mark - --------------------接口API--------------------

@end
