//
//  STFileTransferCell.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/26.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFileTransferInfo.h"

@interface STFileTransferCell : UITableViewCell

@property (nonatomic, strong) STFileTransferInfo *transferInfo;
@property (nonatomic, strong) UIButton *openButton;

- (void)configCell;

@end
