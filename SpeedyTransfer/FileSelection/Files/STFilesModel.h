//
//  STFilesModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/4/4.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STFilesModel : NSObject

@property (nonatomic, strong) NSArray *dataSource;

- (void)initData;
- (void)deleteFiles:(NSArray *)files;

@end
