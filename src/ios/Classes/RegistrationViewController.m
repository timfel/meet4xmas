//
//  RegisterViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "RegistrationViewController.h"

#import "HessianKit.h"
#import "ServiceProxy.h"

@interface RegistrationViewController()

- (IBAction) registrationDone:(id)sender;

@end

@implementation RegistrationViewController

@synthesize delegate = _delegate;
@synthesize emailTextField = _emailTextField;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Register";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(registrationDone:)];
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
	return YES;
}

#pragma mark - Navigation bar callbacks

- (IBAction)registrationDone:(id)sender
{
    NSArray* array;
    if (![ServiceProxy registerAccount: array forUser:self.emailTextField.text]) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                          message:@"Something went wrong while registering your e-mail address. Please try again later." 
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok" 
                                                otherButtonTitles:nil];
        [message show];
        if (self.delegate != nil) {
            [self.delegate registrationFailed];
        }
    } else if (self.delegate != nil) {
        [self.delegate userRegisteredWithEmail:self.emailTextField.text];
    }
}

@end
