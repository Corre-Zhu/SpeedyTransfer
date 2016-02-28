//
//  STContactInfo.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/19.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef void(^GetContactsCompletionHandler)(NSArray *array);

@interface STContactInfo : NSObject<NSCopying>

@property (nonatomic, assign) NSInteger recordId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *vcardString;
@property (nonatomic) double size;

// 读取手机通讯录
+ (void)getContactsModelListWithCompletion:(GetContactsCompletionHandler)handler;
+ (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef;

@end
