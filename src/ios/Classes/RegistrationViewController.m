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
#import "AppDelegate.h"

NSString* kDefaultRegistrationViewNibNameIPhone = @"RegistrationView_iPhone";
NSString* kDefaultRegistrationViewNibNameIPad = @"RegistrationView_iPad";

@interface RegistrationViewController()

- (IBAction) registrationDone:(id)sender;

@end

@implementation RegistrationViewController

@synthesize delegate = _delegate;
@synthesize emailTextField = _emailTextField;

- (RegistrationViewController*)initWithDefaultNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [self initWithNibName:kDefaultRegistrationViewNibNameIPhone bundle:nil];
    } else {
        return [self initWithNibName:kDefaultRegistrationViewNibNameIPad bundle:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

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
    NSArray* appointments;
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    if (![ServiceProxy registerAccount: self.emailTextField.text withDeviceToken:appDelegate.deviceToken receiveAppointments:appointments]) {
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
        [self dismissModalViewControllerAnimated:YES];
        [self.delegate userRegisteredWithEmail:self.emailTextField.text gotAppointments:appointments];
    }
}

@end
