//
//  HTEmailViewController.h
//  helloTalk
//
//  Created by 任健生 on 13-5-17.
//
//

#import <MessageUI/MessageUI.h>

typedef void(^EmailBlock)(MFMailComposeViewController *,MFMailComposeResult,NSError *);


@interface HTEmailViewController : MFMailComposeViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic,copy) EmailBlock block;

@end
