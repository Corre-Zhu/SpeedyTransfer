//
//  STSendHeaderView.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 16/2/21.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STSendHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger filesCount;
@property (nonatomic, assign) double fileSize;

@end
