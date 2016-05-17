//
//  HTDrawView.h
//  
//
//  Created by zz on 13-7-30.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HTDrawBlock)();

@interface HTDrawView : UIView

@property (nonatomic,copy) HTDrawBlock drawBlock;

@end
