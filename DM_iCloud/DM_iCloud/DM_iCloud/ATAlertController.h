//
//  ATAlertController.h
//  AisToy
//
//  Created by brook on 16/3/19.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import "ATAlertView.h"

typedef void(^ATActionSheetAction)(void);

@interface ATAlertController : NSObject

+ (void)initWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
         cancelAction:(void (^)(ATAlertView *sender))cancalAction
    otherButtonTitles:(NSString *)otherButtonTitles
          otherAction:(void (^)(ATAlertView *sender))otherAction;

+ (void)initInputAlertWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
                   cancelAction:(void (^)(ATAlertView *sender))cancalAction
              otherButtonTitles:(NSString *)otherButtonTitles
                    otherAction:(void (^)(ATAlertView *sender, NSString *inputText))otherAction;

+ (void)showAppCommonAlertMessage:(NSString *)message;

+ (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                    cancelAction:(ATActionSheetAction)cancelAction
                destructiveTitle:(NSString *)destructiveTitle
               destructiveAction:(ATActionSheetAction)destructiveAction
                   defaultTitles:(NSArray *)titles
                  defaultActions:(NSArray *)actions;

@end