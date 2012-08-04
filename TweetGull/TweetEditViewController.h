//
//  TweetEditViewController.h
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetEditViewController;

@protocol TweetEditViewControllerDelegate <NSObject>

-(void)tweetEditViewControllerSend:(TweetEditViewController*)tweetEditViewController text:(NSString*)text;
-(void)tweetEditViewControllerCancel:(TweetEditViewController*)tweetEditViewController;
@end

@interface TweetEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property id<TweetEditViewControllerDelegate>delegate;
- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;

@end
