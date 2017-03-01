//
//  iCloudManager.m
//  DM_iCloud
//
//  Created by brook on 2017/2/27.
//  Copyright © 2017年 brook. All rights reserved.
//

#import "iCloudManager.h"

@implementation iCloudManager

+ (BOOL)isCloudServiceOn
{
    id cloudUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (cloudUrl) {
        NSLog(@"iCloud : on / cloudurl = %@", cloudUrl);
        return YES;
    }
    else {
        NSLog(@"iCloud : off");
        return NO;
    }
}

@end
