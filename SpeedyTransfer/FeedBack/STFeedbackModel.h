//
//  STFeedbackModel.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/1/3.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STFeedbackModel : NSObject

@property (nonatomic, strong) NSArray *dataSource;

- (void)sendFeedback:(NSString *)feedback;

@end
