//
//  AccountTableViewController.h
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/16/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountTableViewController;

@protocol AccountTableViewControllerDelegate <NSObject>
-(void)accountTableViewControllerDidFinish:(AccountTableViewController*)controller;
@end

@interface AccountTableViewController : UIViewController
- (IBAction)addAccount:(id)sender;
- (IBAction)editAccounts:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property id<AccountTableViewControllerDelegate> delegate;
@end
