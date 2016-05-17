//
//  HTEmailViewController.h
//  
//
//  Created by zz on 13-5-17.
//
//

#import <MessageUI/MessageUI.h>

typedef void(^EmailBlock)(MFMailComposeViewController *,MFMailComposeResult,NSError *);


@interface HTEmailViewController : MFMailComposeViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic,copy) EmailBlock block;

@end
