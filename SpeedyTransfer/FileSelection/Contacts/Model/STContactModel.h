//
//  STContactModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetContactsCompletionHandler)(NSArray *array);

@interface STContactModel : NSObject

@property (nonatomic, assign) NSInteger recordId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIImage *image;

// 读取手机通讯录
+ (void)getContactsModelListWithCompletion:(GetContactsCompletionHandler)handler;

@end
