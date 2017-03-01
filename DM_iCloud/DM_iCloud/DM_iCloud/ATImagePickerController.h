//
//  ATImagePickerController.h
//  AisToy
//
//  Created by brook on 16/7/30.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^ATCameraAuthorizationResult)(BOOL deviceSupport, AVAuthorizationStatus status);
typedef void(^ATImagePickerSelectSuccessAction)(UIImage *resultImage);
typedef void(^ATImagePickerSelectCancelAction)(void);

@interface ATImagePickerController : UIImagePickerController

+ (void)checkCameraAuthorizationStatus:(ATCameraAuthorizationResult)resultAction;
+ (BOOL)checkAssetsLibraryAuthorizationStatus;
+ (void)showImagePicker:(UIImagePickerControllerSourceType)type
     fromViewController:(UIViewController *)viewController
           finishAction:(ATImagePickerSelectSuccessAction)successAction
           cancelAction:(ATImagePickerSelectCancelAction)cancelAction;

@end
