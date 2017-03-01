//
//  ATImagePickerController.m
//  AisToy
//
//  Created by brook on 16/7/30.
//  Copyright © 2016年 AisToy. All rights reserved.
//

#import "ATImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ATImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) ATImagePickerSelectSuccessAction successAction;
@property (nonatomic, copy) ATImagePickerSelectCancelAction cancelAction;

@end

@implementation ATImagePickerController

#pragma mark - --------------------退出清空--------------------
#pragma mark - --------------------初始化--------------------
#pragma mark - --------------------System--------------------
#pragma mark - --------------------功能函数--------------------
#pragma mark - --------------------手势事件--------------------
#pragma mark - --------------------按钮事件--------------------
#pragma mark - --------------------代理方法--------------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *oriImage = nil;
    UIImage *scaledImage = nil;
    
    if (picker.allowsEditing) {
        oriImage = [info objectForKey:UIImagePickerControllerEditedImage];
        scaledImage = oriImage;
    } else {
        oriImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CGSize size = oriImage.size;
        CGFloat ratio;
        int scale = [UIScreen mainScreen].scale;
        if (size.width > size.height) {
            ratio = [UIScreen mainScreen].bounds.size.width*scale / size.width;
        } else {
            ratio = [UIScreen mainScreen].bounds.size.height*scale / size.height;
        }
        
        CGRect rect = CGRectMake(0., 0., (ratio * size.width), (ratio * size.height));
        UIGraphicsBeginImageContext(rect.size);
        [oriImage drawInRect:rect];
        
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    }
        
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.successAction) {
            self.successAction(scaledImage);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.cancelAction) {
            self.cancelAction();
        }
    }];
}

#pragma mark - --------------------属性相关--------------------
#pragma mark - --------------------接口API--------------------

+ (void)checkCameraAuthorizationStatus:(ATCameraAuthorizationResult)resultAction
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 可以使用摄像头
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            if (resultAction) {
                resultAction(YES, authStatus);
            }
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted)
                {
                    // 点击允许访问时调用
                    if (resultAction) {
                        resultAction(YES, AVAuthorizationStatusAuthorized);
                    }
                }
                else
                {
                    // 这里用户拒绝了系统许可弹框
                    if (resultAction) {
                        resultAction(YES, AVAuthorizationStatusDenied);
                    }
                }
            }];
        }
        else {
            if (resultAction) {
                resultAction(YES, AVAuthorizationStatusAuthorized);
            }
        }
    }
    else {
        // 没有摄像头
        NSLog(@"没有摄像头");
        if (resultAction) {
            resultAction(NO, AVAuthorizationStatusDenied);
        }
    }
}

+ (BOOL)checkAssetsLibraryAuthorizationStatus
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}

+ (void)showImagePicker:(UIImagePickerControllerSourceType)type
     fromViewController:(UIViewController *)viewController
           finishAction:(ATImagePickerSelectSuccessAction)successAction
           cancelAction:(ATImagePickerSelectCancelAction)cancelAction
{
    ATImagePickerController *pickerController = [[ATImagePickerController alloc] init];
    pickerController.delegate = pickerController;
    pickerController.successAction = successAction;
    pickerController.cancelAction = cancelAction;
    pickerController.sourceType = type;
    pickerController.allowsEditing = YES;
    
    [viewController.navigationController presentViewController:pickerController animated:YES completion:nil];
}

@end
