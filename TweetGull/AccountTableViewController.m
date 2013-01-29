//
//  AccountTableViewController.m
//  TweetGull
//
//  Created by Yoshioka Tsuneo on 8/16/12.
//  Copyright (c) 2012 Yoshioka Tsuneo. All rights reserved.
//

#import "AccountTableViewController.h"
#import "TwitterAPI.h"
#import "Accounts.h"
#import "BlocksKit.h"
#import "AppDelegate.h"
#import "Misc.h"

@interface AccountTableViewController ()
{
    Accounts *accounts;
    
    UIBarButtonItem *aDoneButtonItem;
    UIBarButtonItem *aEditButtonItem;
}
@end

@implementation AccountTableViewController
@synthesize editButton;
@synthesize tableView;

#if 0
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#endif
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    accounts = [Accounts defaultAccounts];
    aEditButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAccounts:)];
    aDoneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editAccounts:)];

    // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.navigationItem.leftBarButtonItem = editButtonItem = editButton;
    // self.aNavigationItem.leftBarButtonItem = doneButtonItem;
    //self.editButtonItem.title = @"aaaaaa";
    // self.editButton.title = @"aaaaaa";
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accounts forKey:@"Accounts"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
// #warning Incomplete method implementation.
    // Return the number of rows in the section.
    // return 0;
    return accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    int index = indexPath.row;

    cell.textLabel.text = [NSString stringWithFormat:@"@%@", [accounts nameAtIndex:index]];
    
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        int index = indexPath.row;
        NSString *name = [accounts nameAtIndex:index];
        [accounts removeObjectForName:name];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
    int index = indexPath.row;
    NSString *name = [accounts nameAtIndex:index];
    [Accounts setCurrentAccount:name];
    [self.delegate accountTableViewControllerDidFinish:self];
}

- (IBAction)addAccount:(id)sender {
    TwitterAPI *twitterAPI = [[TwitterAPI alloc] init];
    [twitterAPI signInReal:self callback:^{
        if(twitterAPI.user.screen_name){
            NSString *password = twitterAPI.authPersistenceResponseString;
            [accounts setPassword:password forAccount:twitterAPI.user.screen_name];
            [tableView reloadData];
//            GTMOAuthAuthentication *auth = twitterAPI.auth;
            
//            [((AppDelegate*)([UIApplication sharedApplication].delegate)) sendProvicerOauth_token:auth.token  oauth_token_secret:auth.tokenSecret serviceProvider:auth.serviceProvider user_id:auth.userId screen_name:auth.screenName];
            
            [Misc askToFollowTweetGull:self twitterAPI:twitterAPI callback:nil];
        }
    }];
}

- (IBAction)editAccounts:(id)sender {
    tableView.editing = ! tableView.editing;
    if(tableView.editing){
        // self.editButton.title = NSLocalizedString(@"Done", nil);
        // self.editButton.style = UIBarButtonItemStyleDone;
        // self.editButton.style = UIBarButtonItemStyleDone;
        self.aNavigationItem.leftBarButtonItem = aDoneButtonItem;
    }else{
        // self.editButton.title = NSLocalizedString(@"Edit", nil);
        // self.editButton.style = UIBarButtonItemStylePlain;
        self.aNavigationItem.leftBarButtonItem = aEditButtonItem;
    }
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    sleep(0);
}
@end
