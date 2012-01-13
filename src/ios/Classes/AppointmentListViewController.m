//
//  AppointmentListViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "AppointmentListViewController.h"
#import "RegistrationViewController.h"
#import "ServiceProtocols.h"

NSString* kAppointmentCellReusableIdentifier = @"AppointmentCell";

@interface AppointmentListViewController()

    @property (nonatomic, strong)NSArray* appointments;

@end

@implementation AppointmentListViewController

@synthesize appointments = _appointments;

#pragma mark - Accessors

- (void)setAppointments:(NSArray *)appointments
{
    _appointments = appointments;
    [(UITableView*)self.view reloadData];
}


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

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

#pragma mark - IBActions

- (IBAction)createAppointment:(id)sender
{
    //TODO: Present CreateAppointmentView
}

#pragma mark - RegistrationViewControllerDelegate

- (void)userRegisteredWithEmail:(NSString*)email gotAppointments:(NSArray *)appointments
{
    self.appointments = appointments;
    //TODO: Should we really do that here?
    [self dismissModalViewControllerAnimated:YES];
}

- (void)registrationFailed
{
    //TODO: Oops! What now?
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<Appointment> appointment = [self.appointments objectAtIndex:[indexPath indexAtPosition:0]];
    if (appointment == nil) {
        return nil;
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAppointmentClassName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAppointmentClassName];
    }
    
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%d:%@", appointment.identifier, appointment.message];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointments.count;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id<Appointment> appointment = [self.appointments objectAtIndex:[indexPath indexAtPosition:0]];
    //TODO: Present Appointment details view
}

@end
