//
//  AddInviteeViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 19.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "AddInviteeViewController.h"

NSString* kDefaultAddInviteeViewNibNameIPhone = @"AddInviteeView_iPhone";
NSString* kDefaultAddInviteeViewNibNameIPad = @"AddInviteeView_iPad";

@interface AddInviteeViewController()

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@implementation AddInviteeViewController

@synthesize delegate = _delegate;
@synthesize emailTextField = _emailTextField;

- (AddInviteeViewController*)initWithDefaultNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [self initWithNibName:kDefaultAddInviteeViewNibNameIPhone bundle:nil];
    } else {
        //TODO
        return [self initWithNibName:kDefaultAddInviteeViewNibNameIPad bundle:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add invitee";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if (self.delegate != nil) {
        [self.delegate inviteeAddedWithEmail:self.emailTextField.text];
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(addingInviteeByEmailCanceled)]) {
        [self.delegate addingInviteeByEmailCanceled];
    }
}

@end
