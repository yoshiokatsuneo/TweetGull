//
//  TweetEditViewController.m
//  tweettest1
//
//  Created by Tsuneo Yoshioka on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetEditViewController.h"

@interface TweetEditViewController ()

@end

@implementation TweetEditViewController
@synthesize textView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)send:(id)sender {
    [self.delegate tweetEditViewControllerSend:self text:self.textView.text];
}

- (IBAction)cancel:(id)sender {
    [self.delegate tweetEditViewControllerCancel:self];
}
@end
