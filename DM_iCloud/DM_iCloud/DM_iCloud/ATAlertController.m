//
//  ATAlertController.m
//  AisToy
//
//  Created by brook on 16/3/19.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import "ATAlertController.h"

static ATAlertController *alertController = nil;

@interface ATAlertController() <UIActionSheetDelegate>

@property (nonatomic, strong) NSDictionary *actions;
@property (nonatomic, copy) ATActionSheetAction cancelAction;
@property (nonatomic, copy) ATActionSheetAction destructiveAction;
@property (nonatomic, weak) UIAlertController *alertController;

@end

@implementation ATAlertController

#pragma mark - --------------------退出清空--------------------

- (void)dealloc
{
    NSLog(@"dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

#pragma mark - --------------------初始化--------------------
#pragma mark - --------------------System--------------------
#pragma mark - --------------------功能函数--------------------

+ (UIViewController *)topMostViewController:(UIWindow *)window
{
    for (UIView *subView in window.subviews) {
        
        UIResponder *responder = subView.nextResponder;
        
        if ([responder isKindOfClass:UIViewController.class]) {
            return [self topViewController:(UIViewController *)responder];
        }
        
        // added this block of code for iOS 8 which puts a UITransitionView in between the UIWindow and the UILayoutContainerView
        if ([responder isEqual:window]) {
            
            for (UIView *subSubView in subView.subviews) {
                
                responder = subSubView.nextResponder;
                
                if ([responder isKindOfClass:UIViewController.class]) {
                    return [self topViewController:(UIViewController *)responder];
                }
            }
        }
    }
    
    return nil;
}

+ (UIViewController *)topViewController:(UIViewController *)controller
{
    BOOL isPresenting = NO;
    do {
        // this path is called only on iOS 6+, so -presentedViewController is fine here.
        UIViewController *presented = controller.presentedViewController;
        isPresenting = presented != nil;
        if (presented != nil) {
            controller = presented;
        }
        
    } while (isPresenting);
    
    return controller;
}

#pragma mark - --------------------手势事件--------------------
#pragma mark - --------------------按钮事件--------------------
#pragma mark - --------------------代理方法--------------------

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li", (long)buttonIndex);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (self.cancelAction) {
            self.cancelAction();
        }
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (self.destructiveAction) {
            self.destructiveAction();
        }
    }
    else {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        ATActionSheetAction action = [self.actions objectForKey:title];
        if (action) {
            action();
        }
    }
    
    alertController = nil;
}

#pragma mark - --------------------属性相关--------------------
#pragma mark - --------------------接口API--------------------

+ (void)initWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
         cancelAction:(void (^)(ATAlertView *sender))cancalAction
    otherButtonTitles:(NSString *)otherButtonTitles
          otherAction:(void (^)(ATAlertView *sender))otherAction
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        UIWindow *keyWindow = keyWindow = [[[UIApplication sharedApplication] delegate] window];
        
        // title传nil的话 会导致message字体变粗
        if (title == nil) {
            title = @"";
        }
        
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        if (cancelButtonTitle.length > 0) {
            UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction *action) {
                                                                          if (cancalAction) {
                                                                              cancalAction(nil);
                                                                          }
                                                                      }];
            [alertCtrl addAction:cancelAlertAction];
        }
        
        if (otherButtonTitles.length > 0) {
            UIAlertAction *otherAlertAction = [UIAlertAction actionWithTitle:otherButtonTitles
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         if (otherAction) {
                                                                             otherAction(nil);
                                                                         }
                                                                     }];
            [alertCtrl addAction:otherAlertAction];
        }
        
        [[self topMostViewController:keyWindow] presentViewController:alertCtrl animated:YES completion:nil];
        
    }
    else
    {
        [[[ATAlertView  alloc] initWithTitle:title
                                     message:message
                           cancelButtonTitle:cancelButtonTitle
                                cancelAction:cancalAction
                           otherButtonTitles:otherButtonTitles
                                 otherAction:otherAction] show];
    }
}

+ (void)initInputAlertWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
                   cancelAction:(void (^)(ATAlertView *sender))cancalAction
              otherButtonTitles:(NSString *)otherButtonTitles
                    otherAction:(void (^)(ATAlertView *sender, NSString *inputText))otherAction
                   keyboardType:(UIKeyboardType)keyboardType
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        UIWindow *keyWindow = keyWindow = [[[UIApplication sharedApplication] delegate] window];
        
        // title传nil的话 会导致message字体变粗
        if (title == nil) {
            title = @"";
        }
        
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        ATAlertController *controller = [[ATAlertController alloc] init];
        alertController = controller;
        alertController.alertController = alertCtrl;
        
        __weak typeof(controller)weakController = controller;
        
        [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.keyboardType = keyboardType;
            
            [[NSNotificationCenter defaultCenter] addObserver:weakController
                                                     selector:@selector(alertTextFieldDidChange:)
                                                         name:UITextFieldTextDidChangeNotification
                                                       object:textField];
        }];
        
        
        if (cancelButtonTitle.length > 0) {
            UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction *action) {
                                                                          
                                                                          [[NSNotificationCenter defaultCenter]
                                                                           removeObserver:self
                                                                           name:UITextFieldTextDidChangeNotification
                                                                           object:nil];
                                                                          
                                                                          if (cancalAction) {
                                                                              cancalAction(nil);
                                                                          }
                                                                          
                                                                          alertController = nil;
                                                                      }];
            [alertCtrl addAction:cancelAlertAction];
        }
        
        if (otherButtonTitles.length > 0) {
            UIAlertAction *otherAlertAction = [UIAlertAction actionWithTitle:otherButtonTitles
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         
                                                                         [[NSNotificationCenter defaultCenter]
                                                                          removeObserver:self
                                                                          name:UITextFieldTextDidChangeNotification
                                                                          object:nil];
                                                                         
                                                                         if (otherAction) {
                                                                             
                                                                             UITextField *account = alertCtrl.textFields.firstObject;
                                                                             
                                                                             otherAction(nil, account.text);
                                                                         }
                                                                         
                                                                         alertController = nil;
                                                                     }];
            [alertCtrl addAction:otherAlertAction];
            otherAlertAction.enabled = NO;
            
        }
        [[self topMostViewController:keyWindow] presentViewController:alertCtrl animated:YES completion:nil];
        
    }
    else
    {
        [[[ATAlertView  alloc] initWithInputAlertTitle:title
                                               message:message
                                     cancelButtonTitle:cancelButtonTitle
                                          cancelAction:cancalAction
                                     otherButtonTitles:otherButtonTitles
                                           otherAction:otherAction
                                          keyboardType:keyboardType] show];
    }
}

+ (void)initInputAlertWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
                   cancelAction:(void (^)(ATAlertView *sender))cancalAction
              otherButtonTitles:(NSString *)otherButtonTitles
                    otherAction:(void (^)(ATAlertView *sender, NSString *inputText))otherAction
{
    [self initInputAlertWithTitle:title
                          message:message
                cancelButtonTitle:cancelButtonTitle
                     cancelAction:cancalAction
                otherButtonTitles:otherButtonTitles
                      otherAction:otherAction
                     keyboardType:UIKeyboardTypePhonePad];
}

+ (void)showAppCommonAlertMessage:(NSString *)message
{
    [self initWithTitle:nil
                message:message
      cancelButtonTitle:@"确认"
           cancelAction:^(ATAlertView *sender) {
           }
      otherButtonTitles:nil
            otherAction:nil];
}

+ (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                    cancelAction:(ATActionSheetAction)cancelAction
                destructiveTitle:(NSString *)destructiveTitle
               destructiveAction:(ATActionSheetAction)destructiveAction
                   defaultTitles:(NSArray *)titles
                  defaultActions:(NSArray *)actions

{
    if (titles.count != actions.count) {
        NSLog(@"titles.count != actions.count");
        return;
    }
    
    UIWindow *keyWindow = keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
        if (cancelTitle.length > 0) {
            UIAlertAction *cancelSheetAction = [UIAlertAction actionWithTitle:cancelTitle
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction *action) {
                                                                          if (cancelAction) {
                                                                              cancelAction();
                                                                          }
                                                                      }];
            [alertCtrl addAction:cancelSheetAction];
        }
        
        if (destructiveTitle.length > 0) {
            UIAlertAction *destructiveSheetAction = [UIAlertAction actionWithTitle:destructiveTitle
                                                                             style:UIAlertActionStyleDestructive
                                                                           handler:^(UIAlertAction *action) {
                                                                               if (destructiveAction) {
                                                                                   destructiveAction();
                                                                               }
                                                                           }];
            [alertCtrl addAction:destructiveSheetAction];
        }
        
        for (int i = 0; i < titles.count; i++) {
            NSString *title = [titles objectAtIndex:i];
            ATActionSheetAction defaultAction = [actions objectAtIndex:i];
            UIAlertAction *defaultAlertAction = [UIAlertAction actionWithTitle:title
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction *action) {
                                                                         if (defaultAction) {
                                                                             defaultAction();
                                                                         }
                                                                     }];
            [alertCtrl addAction:defaultAlertAction];
        }
        
        [[self topMostViewController:keyWindow] presentViewController:alertCtrl animated:YES completion:nil];
        
    }
    else
    {
        ATAlertController *controller = [[ATAlertController alloc] init];
        controller.cancelAction = cancelAction;
        controller.destructiveAction = destructiveAction;
        
        alertController = controller;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                 delegate:alertController
                                                        cancelButtonTitle:cancelTitle
                                                   destructiveButtonTitle:destructiveTitle
                                                        otherButtonTitles:nil];
        
        NSMutableDictionary *actionDic = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < titles.count; i++) {
            NSString *title = [titles objectAtIndex:i];
            ATActionSheetAction action = [actions objectAtIndex:i];
            [actionSheet addButtonWithTitle:title];
            [actionDic setObject:action forKey:title];
        }
        alertController.actions = actionDic;
        
        [actionSheet showInView:((UIViewController *)[self topMostViewController:keyWindow]).view];
    }
}

- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    if (alertController) {
        UITextField *login = alertController.alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.alertController.actions.lastObject;
        okAction.enabled = login.text.length > 0;
    }
}

@end
