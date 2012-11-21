//
//  UsersTableViewController.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 9/25/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "UsersTableViewController.h"
#import "Users.h"
#import "TwitterAPI.h"
#import "TweetsRequestUserTimeline.h"
#import "MasterViewController.h"

@interface UsersTableViewController ()
{
    Users *users;
}
@end

@implementation UsersTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchUsers];
}

- (void)fetchUsers
{
    [[TwitterAPI defaultTwitterAPI] fetchUsers:self usersRequest:self.usersRequest callback:^(Users *users_){
        users = users_;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    int index = indexPath.row;
    NSDictionary *dic = users[index];
    
    cell.textLabel.text = dic[@"screen_name"];
    cell.detailTextLabel.text = dic[@"name"];
    cell.imageView.image = nil;
    NSString *image_url = dic[@"profile_image_url"];
    NSLog(@"image_url=%@", image_url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([cell.textLabel.text isEqual:dic[@"screen_name"]]){
                cell.imageView.image = [UIImage imageWithData:data];
                [cell setNeedsLayout];
            }
        });
    });
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTweets"]){
        NSInteger index = self.tableView.indexPathForSelectedRow.row;
        NSDictionary *user_dic = users[index];
        
        MasterViewController *masterViewController = [segue destinationViewController];
        TweetsRequestUserTimeline * tweetsRequestUserTimeline = [[TweetsRequestUserTimeline alloc] init];
        tweetsRequestUserTimeline.user = [[User alloc] initWithDictionary:user_dic];
        masterViewController.tweetsRequest = tweetsRequestUserTimeline;
    }
}
@end
