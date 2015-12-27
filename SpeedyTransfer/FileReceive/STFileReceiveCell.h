//
//  STFileReceiveCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFileReceiveInfo.h"

@interface STFileReceiveCell : UITableViewCell

@property (nonatomic, strong) STFileReceiveInfo *transferInfo;

- (void)configCell;

@end
