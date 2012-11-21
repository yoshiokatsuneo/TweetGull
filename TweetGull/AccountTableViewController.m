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

@interface AccountTableViewController ()
{
    Accounts *accounts;
    UIBarButtonItem *doneButtonItem;
    UIBarButtonItem *editButtonItem;
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
    
    editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAccounts:)];
    doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editAccounts:)];
    
    self.navigationItem.leftBarButtonItem = editButtonItem;
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

    cell.textLabel.text = [accounts nameAtIndex:index];
    
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
        }
    }];
}

- (IBAction)editAccounts:(id)sender {
    tableView.editing = ! tableView.editing;
    if(tableView.editing){
        self.navigationItem.leftBarButtonItem = doneButtonItem;
    }else{
        self.navigationItem.leftBarButtonItem = editButtonItem;
    }
}
@end
