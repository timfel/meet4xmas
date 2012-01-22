//
//  AppointmentListViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "AppointmentListViewController.h"
#import "AppDelegate.h"
#import "RegistrationViewController.h"
#import "CreateAppointmentViewController.h"
#import "ServiceProtocols.h"
#import "ServiceProxy.h"

NSString* kAppointmentCellReusableIdentifier = @"AppointmentCell";

@interface AppointmentListViewController()

@property (nonatomic, strong)NSMutableArray* appointments;

- (void)presentRegistrationView;
- (void)presentCreateAppointmentView;

@end

@implementation AppointmentListViewController

@synthesize appointments = _appointments;

#pragma mark - Accessors

- (void)setAppointments:(NSMutableArray *)appointments
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
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil) {
        [self presentRegistrationView];
    }
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

- (void)presentRegistrationView
{
    // Load the registration view modally. It will define a done button for the navigation controller.
    RegistrationViewController* registrationViewController = [[RegistrationViewController alloc] initWithDefaultNib];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        registrationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    registrationViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    registrationViewController.delegate = self;
    
    // Create a navigation controller and present it modally.
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:registrationViewController];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)presentCreateAppointmentView
{
    CreateAppointmentViewController* createAppointmentViewController = [[CreateAppointmentViewController alloc] initWithDefaultNib];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        createAppointmentViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    createAppointmentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    createAppointmentViewController.delegate = self;
    
    // Create a navigation controller and present it modally.
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:createAppointmentViewController];
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark - IBActions

- (IBAction)createAppointment:(id)sender
{
    [self presentCreateAppointmentView];
}

- (IBAction)logoutUser:(id)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = nil;
    
    [self presentRegistrationView];
}

#pragma mark - RegistrationViewControllerDelegate

- (void)userRegisteredWithEmail:(NSString*)email gotAppointments:(NSArray *)appointmentIds
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = email;
    
    self.appointments = [[NSMutableArray alloc] init];
    
    for (AppointmentId appointmentId in appointmentIds) {
        id<Response> response = [ServiceProxy getAppointmentForID:appointmentId];
        if (response.success) {
            [self.appointments addObject:response.payload];
        }
    }
    
    [(UITableView*)self.view reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)registrationFailed
{
    //TODO: Oops! What now?
}

#pragma mark - CreateAppointmentViewControllerDelegate

- (void)createdAppointment:(AppointmentId)appointmentId
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.appointments.count inSection:0];
    
    id<Response> response = [ServiceProxy getAppointmentForID:appointmentId];
    if (response.success) {
        [self.appointments addObject:response.payload];
    } else {
        //TODO: Error handling
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [(UITableView*)self.view insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)creationCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAppointmentCellReusableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAppointmentCellReusableIdentifier];
    }
    
    id<Appointment> appointment = [self.appointments objectAtIndex:indexPath.row];
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@:%@", appointment.identifier, appointment.message];
    
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
    id<Appointment> appointment = [self.appointments objectAtIndex:indexPath.row];
    //TODO: Present Appointment details view
}

@end
