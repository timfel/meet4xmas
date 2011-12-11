//
//  FirstViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "FirstViewController.h"
#import "RegistrationViewController.h"

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //TODO: if (![user loggedIn]) {...
    // Load the registration view modally. It will define a done button for the navigation controller.
    RegistrationViewController* registrationViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        registrationViewController = [[RegistrationViewController alloc] initWithNibName:@"RegistrationView_iPhone" bundle:nil];
    } else {
        registrationViewController = [[RegistrationViewController alloc] initWithNibName:@"RegistrationView_iPad" bundle:nil];
        // Only show a small form on the iPad, not full screen
        registrationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    registrationViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    registrationViewController.delegate = self;
    
    // Create a navigation controller and present it modally.
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:registrationViewController];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - RegistrationViewControllerDelegate

- (void)userRegisteredWithEmail:(NSString*)email
{
    //TODO: Should we really do that here?
    [self dismissModalViewControllerAnimated:YES];
}

- (void)registrationFailed
{
    //TODO: Oops! What now?
}

@end
