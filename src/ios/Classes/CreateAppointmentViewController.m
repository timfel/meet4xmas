//
//  CreateAppointmentViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 13.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "CreateAppointmentViewController.h"

NSString* kDefaultCreateAppointmentViewNibNameIPhone = @"CreateAppointmentView_iPhone";
NSString* kDefaultCreateAppointmentViewNibNameIPad = @"CreateAppointmentView_iPad";

@interface CreateAppointmentViewController()

- (void)done:(id)sender;
- (void)cancel:(id)sender;

@end

@implementation CreateAppointmentViewController

@synthesize delegate = _delegate;
@synthesize descriptionTextField = _descriptionTextField;

- (CreateAppointmentViewController *)initWithDefaultNib
{
    //TODO: iPad
    return [self initWithNibName:kDefaultCreateAppointmentViewNibNameIPhone bundle:nil];
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
    self.navigationItem.title = @"Create Appointment";
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

- (void)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    //TODO
}

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if (self.delegate != nil) {
        [self.delegate creationCanceled];
    }
}

@end
