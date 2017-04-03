//
//  STFileSegementControl.h
//  SpeedyTransfer
//
//  Created by zhuzhi on 17/2/12.
//  Copyright © 2017年 ZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STFileSegementControlDelegate <NSObject>

- (void)didTapBack;
- (void)didSelectIndex:(NSInteger)index;

@end

@interface STFileSegementControl : UIView

@property (nonatomic, weak)id<STFileSegementControlDelegate> delegate;
@property (nonatomic, strong) NSString *title;

- (void)setSelectedIndex:(NSInteger)index;

@end
