//
//  ViewController.m
//  DM_iCloud
//
//  Created by brook on 2017/2/19.
//  Copyright © 2017年 brook. All rights reserved.
//

#import "ViewController.h"
#import "iCloudManager.h"
#import "ProfileViewController.h"

#define kDefaultRecordID @"PUB_Account_Asset"
#define kDefaultRecordType @"User"

@import CloudKit;

@interface ViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) BOOL isServiceOn;
@property (nonatomic, strong) UIButton *showPersonalInfoButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *statusTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, 150, 30)];
    statusTitle.text = @"iCloud 开启状态:";
    [self.view addSubview:statusTitle];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 80, 50, 30)];
    [self.view addSubview:self.statusLabel];
    
    [self checkStatus];
    
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkButton setTitle:@"检查开启状态" forState:UIControlStateNormal];
    checkButton.frame = CGRectMake(30, 130, 100, 35);
    [checkButton addTarget:self action:@selector(checkStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
    
    self.showPersonalInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.showPersonalInfoButton setTitle:@"我的资料" forState:UIControlStateNormal];
    self.showPersonalInfoButton.frame = CGRectMake(30, 180, 100, 35);
    [self.showPersonalInfoButton addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.showPersonalInfoButton];
}

- (void)checkStatus
{
    self.isServiceOn = [iCloudManager isCloudServiceOn];
    self.statusLabel.text = self.isServiceOn? @"ON" : @"OFF";
    self.showPersonalInfoButton.enabled = self.isServiceOn;
}

- (void)showProfile
{
    ProfileViewController *profile = [[ProfileViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profile];

    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)saveAccount
{
    NSString *userName = @"Hello";
    NSString *pwd = @"world";
    
//    [self addCloudDataWithPublic:YES recordID:@"PUB_Account" name:userName password:pwd];
    [self saveImageDataWithPublic:NO recordID:@"PUB_Account_Asset" name:userName password:pwd];
}

- (void)findAccount
{
    // 查找单条数据
    [self searchRecordWithRecordID:kDefaultRecordID withFormPublic:YES];
    // 查找多条数据
    [self searchRecordWithFormPublic:YES withRecordTypeName:kDefaultRecordType];
}

- (void)addCloudDataWithPublic:(BOOL)isPublic
                      recordID:(NSString *)recordID
                          name:(NSString *)name
                      password:(NSString *)password
{
    // CloudKit给应用程序分配部分空间,用于存储数据,首先要获取这个存储空间,这里我们直接获取了默认的存储器(可以自定义存储器):
    CKContainer *container= [CKContainer defaultContainer];
    CKDatabase *database;
    if (isPublic) {
        database = container.publicCloudDatabase; //公共数据
    }
    else
    {
        database = container.privateCloudDatabase; //隐藏数据
    }
    
    //创建主键ID  这个ID可以到时查找有用到
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:recordID];
    //创建CKRecord 保存数据
    CKRecord *noteRecord = [[CKRecord alloc] initWithRecordType:kDefaultRecordType recordID:noteId];
    
    //设置数据
    [noteRecord setObject:name forKey:@"name"];
    [noteRecord setObject:password forKey:@"password"];
    
    //保存操作
    [database saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
//            [self showAlertMessage:@"保存成功"];
            
            NSLog(@"保存成功");
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

//增加带图片的提交 图片的保存,需要用到CKAsset,他的初始化需要一个URL,所以这里,我先把图片数据保存到本地沙盒,生成一个URL,然后再去创建CKAsset:
-(void)saveImageDataWithPublic:(BOOL)isPublic recordID:(NSString *)recordID name:(NSString *)name password:(NSString *)password
{
    //保存图片 图片的保存,需要用到CKAsset,他的初始化需要一个URL,所以这里,我先把图片数据保存到本地沙盒,生成一个URL,然后再去创建CKAsset:
    UIImage *image=[UIImage imageNamed:@"icloudImage"];
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData == nil) {
        imageData = UIImageJPEGRepresentation(image, 0.6);
    }
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imagesTemp"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:tempPath]) {
        
        [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",tempPath,@"iCloudImage"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [imageData writeToURL:url atomically:YES];
    
    CKAsset *asset = [[CKAsset alloc]initWithFileURL:url];
    
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
    CKRecordID *noteId=[[CKRecordID alloc]initWithRecordName:recordID];
    //创建CKRecord 保存数据
    CKRecord *noteRecord = [[CKRecord alloc]initWithRecordType:kDefaultRecordType recordID:noteId];
    
    //设置数据
    [noteRecord setObject:name forKey:@"name"];
    [noteRecord setObject:password forKey:@"password"];
    [noteRecord setObject:asset forKey:@"userImage"];
    
    //保存操作
    [database saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"保存成功");
        }
        else {
            NSLog(@"保存保失败：%@", error);
        }
    }];
}

//查找单条记录
-(void)searchRecordWithRecordID:(NSString *)recordID withFormPublic:(BOOL)isPublic
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
    
//    __weak typeof(self)weakSelf = self;
    //查找操作
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        NSString *message=[NSString stringWithFormat:@"获得RecordID为%@ 的数据：%@，%@",recordID,[record objectForKey:@"name"],[record objectForKey:@"password"]];
//        [weakSelf showAlertMessage:message];
        
        NSLog(@"%@", message);
    }];
}

//查找多条记录（可以用谓词进行）
-(void)searchRecordWithFormPublic:(BOOL)isPublic withRecordTypeName:(NSString *)recordTypeName
{
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
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query= [[CKQuery alloc] initWithRecordType:recordTypeName predicate:predicate];
    
//    __weak typeof(self)weakSelf = self;
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray* _Nullable results, NSError * _Nullable error) {
//        [weakSelf showAlertMessage:[NSString stringWithFormat:@"%@",results]];
        NSLog(@"%@", [NSString stringWithFormat:@"%@",results]);
    }];
}

//更新一条记录 首先要查找出这一条  然后再对它进行修改
-(void)updateRecordWithFormPublic:(BOOL)isPublic withRecordTypeName:(NSString *)recordTypeName withRecordID:(NSString *)recordID
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
    
//    __weak typeof(self)weakSelf = self;
    //查找操作
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            
            //对原有的健值进行修改
            [record setObject:@"aa123456789" forKey:@"password"];
            //如果健值不存在 则会增加一个
            [record setObject:@"男" forKey:@"gender"];
            
            [database saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"修改保存成功");
//                    [weakSelf showAlertMessage:@"修改保存成功"];
                }
                else
                {
                    NSLog(@"%@", [NSString stringWithFormat:@"出错误 ：%@",error]);
//                    [weakSelf showAlertMessage:[NSString stringWithFormat:@"出错误 ：%@",error]];
                }
            }];
        }
    }];
}

@end
