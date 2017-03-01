//
//  ProfileViewController.m
//  DM_iCloud
//
//  Created by brook on 2017/2/27.
//  Copyright © 2017年 brook. All rights reserved.
//

#import "ProfileViewController.h"
#import "ATImagePickerController.h"
#import <CloudKit/CloudKit.h>
#import "ATAlertController.h"

#define kUserRecordType @"kUserInfo"

#define kUserRecordID @"kRIDProfile"
#define kUserRecordNickName @"kNickName"
#define kUserRecordAvatar @"kAvatar"


#define kPublicNoticeId @"kPublicNoticeId"
#define kPublicNoticeType @"kPublicNoticeType"
#define kPublicNoticeMessage @"kPublicNoticeMessage"

@interface ProfileViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nickNameField;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, assign) BOOL recordExist;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的信息";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPage)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveInfo)];
    
    self.nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 300, 35)];
    self.nickNameField.keyboardType = UIKeyboardTypeDefault;
    self.nickNameField.placeholder = @"昵称";
    self.nickNameField.delegate = self;
    [self.view addSubview:self.nickNameField];
    
    UILabel *avatar = [[UILabel alloc] initWithFrame:CGRectMake(50, 150, 100, 35)];
    avatar.text = @"我的头像:";
    [self.view addSubview:avatar];
    
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160, 150, 100, 100)];
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.avatarImageView];
    
    UIButton *changeImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeImageButton.frame = self.avatarImageView.frame;
    [changeImageButton addTarget:self action:@selector(changeAvatar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeImageButton];
    
    [self lookUpInfo];
    
    UIButton *clearInfo = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearInfo setTitle:@"清除信息" forState:UIControlStateNormal];
    [clearInfo setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    clearInfo.frame = CGRectMake(50, 200, 100, 35);
    [clearInfo addTarget:self action:@selector(clearInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearInfo];
    
    UIButton *sendPublic = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendPublic setTitle:@"通知消息" forState:UIControlStateNormal];
    sendPublic.frame = CGRectMake(50, 250, 100, 35);
    [sendPublic addTarget:self action:@selector(sendPublicMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendPublic];
    
    [self startSubscription];
}

- (void)startSubscription
{
    
    CKDatabase *publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"kPublicNoticeMessage = '111'"];
    
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:kPublicNoticeType predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    CKNotificationInfo *info = [CKNotificationInfo new];
    
    info.alertLocalizationKey = @"NEW_PARTY_ALERT_KEY";
    info.soundName = @"NewAlert.aiff";
    info.shouldBadge = YES;
    
    subscription.notificationInfo = info;
    
    [publicDB saveSubscription:subscription
             completionHandler:^(CKSubscription *subscription, NSError *error) {
                 //...
             }];
}

- (void)lookUpInfo
{
    [self searchRecordWithRecordID:kUserRecordID withFormPublic:NO];
}

- (void)sendPublicMsg
{
    CKContainer *container= [CKContainer defaultContainer];
    CKDatabase *database = container.publicCloudDatabase; //公共数据
    
    //创建主键ID  这个ID可以到时查找有用到
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@%f",kPublicNoticeId, [[NSDate date] timeIntervalSinceReferenceDate]]];
    //创建CKRecord 保存数据
    CKRecord *noteRecord = [[CKRecord alloc] initWithRecordType:kPublicNoticeType recordID:noteId];
    
    //设置数据
    [noteRecord setObject:@"111" forKey:kPublicNoticeMessage];
    
    //保存操作
    [database saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"保存成功" waitUntilDone:NO];
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)clearInfo
{
    if (self.recordExist) {
        // 删除信息
        [self deleteRecordWithFormPublic:NO withRecordID:kUserRecordID];
    }
}

- (void)saveInfo
{
    [self.view endEditing:YES];
    
    if (self.nickNameField.text.length > 0) {
        
        if (self.recordExist) {
            // 更新
            [self updateRecordWithFormPublic:NO withRecordID:kUserRecordID];
        }
        else {
            // 保存
            [self saveImageDataWithPublic:NO
                                 recordID:kUserRecordID
                                     name:self.nickNameField.text
                                   avatar:self.avatarImageView.image];
        }
    }
}

- (void)dismissPage
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)changeAvatar
{
    [ATImagePickerController showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary
                          fromViewController:self
                                finishAction:^(UIImage *resultImage) {
                                    self.avatarImageView.image = resultImage;
                                }
                                cancelAction:^{
                                
                                }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nickNameField) {
        self.nickNameField.text = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// 查找单条记录
- (void)searchRecordWithRecordID:(NSString *)recordID withFormPublic:(BOOL)isPublic
{
    //获得指定的ID
    CKRecordID *noteId = [[CKRecordID alloc]initWithRecordName:recordID];
    
    //获得容器
    CKContainer *container = [CKContainer defaultContainer];
    
    //获得数据的类型 是公有还是私有
    CKDatabase *database;
    if (isPublic) {
        database = container.publicCloudDatabase;
    }
    else
    {
        database = container.privateCloudDatabase;
    }
    
    //查找操作
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
        // 回调是在子线程
        // 失败时候获取重试时间
        if (error.code == CKErrorNetworkUnavailable ) {
            double retryAfterValue = [error.userInfo[CKErrorRetryAfterKey] doubleValue];
            NSDate *retryAfterDate = [NSDate dateWithTimeIntervalSinceNow:retryAfterValue];
        }
        
        if (record) {
            self.recordExist = YES;
            [self performSelectorOnMainThread:@selector(updateUIWithRecord:) withObject:record waitUntilDone:NO];
        }
        else {
            NSLog(@"no exist");
        }
    }];
}

- (void)updateUIWithRecord:(CKRecord *)record
{
    if (record == nil) {
        self.nickNameField.text = @"";
        self.avatarImageView.image = nil;
    }
    else {
        self.nickNameField.text = [record objectForKey:kUserRecordNickName];
        
        CKAsset *asset = [record objectForKey:kUserRecordAvatar];
        if (asset) {
            NSURL *url = [asset fileURL];
            self.avatarImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }
    }
}

- (CKAsset *)getAssetFromImage:(UIImage *)avatar
{
    if (avatar) {
//        NSData *imageData = UIImagePNGRepresentation(avatar);
        NSData *imageData = UIImageJPEGRepresentation(avatar, 0.5);
        NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imagesTemp"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:tempPath]) {
            
            [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",tempPath,@"iCloudImage"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [imageData writeToURL:url atomically:YES];
        
        return [[CKAsset alloc] initWithFileURL:url];
    }
    
    return nil;
}

//增加带图片的提交 图片的保存,需要用到CKAsset,他的初始化需要一个URL,所以这里,我先把图片数据保存到本地沙盒,生成一个URL,然后再去创建CKAsset:
- (void)saveImageDataWithPublic:(BOOL)isPublic
                       recordID:(NSString *)recordID
                           name:(NSString *)name
                         avatar:(UIImage *)avatarImage
{
    //保存图片 图片的保存,需要用到CKAsset,他的初始化需要一个URL,所以这里,我先把图片数据保存到本地沙盒,生成一个URL,然后再去创建CKAsset:
    
    CKAsset *asset = [self getAssetFromImage:avatarImage];
    
    //与iCloud进行交互
    CKContainer *container=[CKContainer defaultContainer];
    CKDatabase *database;
    if (isPublic) {
        database=container.publicCloudDatabase; //公共数据
    }
    else
    {
        database=container.privateCloudDatabase;//隐藏数据
    }
    
    //创建主键ID  这个ID可以到时查找有用到
    CKRecordID *noteId = [[CKRecordID alloc]initWithRecordName:recordID];
    //创建CKRecord 保存数据
    CKRecord *noteRecord = [[CKRecord alloc]initWithRecordType:kUserRecordType recordID:noteId];
    
    //设置数据
    [noteRecord setObject:name forKey:kUserRecordNickName];
    if (asset) {
        [noteRecord setObject:asset forKey:kUserRecordAvatar];
    }
    
    //保存操作
    [database saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"保存成功");
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"保存成功" waitUntilDone:NO];
            self.recordExist = YES;
        }
        else {
            NSLog(@"保存保失败：%@", error);
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"保存失败" waitUntilDone:NO];
        }
    }];
}

//更新一条记录 首先要查找出这一条  然后再对它进行修改
-(void)updateRecordWithFormPublic:(BOOL)isPublic
                     withRecordID:(NSString *)recordID
{
    //获得指定的ID
    CKRecordID *noteId=[[CKRecordID alloc]initWithRecordName:recordID];
    
    //获得容器
    CKContainer *container=[CKContainer defaultContainer];
    
    //获得数据的类型 是公有还是私有
    CKDatabase *database;
    if (isPublic) {
        database=container.publicCloudDatabase;
    }
    else
    {
        database=container.privateCloudDatabase;
    }
    
    //查找操作
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            
            //对原有的健值进行修改
            [record setObject:self.nickNameField.text forKey:kUserRecordNickName];
            //如果健值不存在 则会增加一个
//            [record setObject:@"男" forKey:@"gender"];
            
            if (self.avatarImageView.image) {
                CKAsset *asset = [self getAssetFromImage:self.avatarImageView.image];
                [record setObject:asset forKey:kUserRecordAvatar];
            }
            
            [database saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"修改保存成功");
                    [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"修改保存成功" waitUntilDone:NO];
                }
                else
                {
                    NSLog(@"%@", [NSString stringWithFormat:@"出错误 ：%@",error]);
                    [self performSelectorOnMainThread:@selector(showAlert:) withObject:[NSString stringWithFormat:@"出错误 ：%@",error] waitUntilDone:NO];
                }
            }];
        }
    }];
}

//删除记录
- (void)deleteRecordWithFormPublic:(BOOL)isPublic withRecordID:(NSString *)recordID
{
    //获得指定的ID
    CKRecordID *noteId=[[CKRecordID alloc]initWithRecordName:recordID];
    
    //获得容器
    CKContainer *container=[CKContainer defaultContainer];
    
    //获得数据的类型 是公有还是私有
    CKDatabase *database;
    if (isPublic) {
        database=container.publicCloudDatabase;
    }
    else
    {
        database=container.privateCloudDatabase;
    }
    
    [database deleteRecordWithID:noteId completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"删除成功");
            self.recordExist = NO;
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"删除成功" waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(updateUIWithRecord:) withObject:nil waitUntilDone:NO];
            return;
        }
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"删除失败" waitUntilDone:NO];
        NSLog(@"%@", [NSString stringWithFormat:@"删除失败 %@",error]);
    }];
}

- (void)showAlert:(NSString *)text
{
    [ATAlertController showAppCommonAlertMessage:text];
}

@end
