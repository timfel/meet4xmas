//
//  AppointmentDetailViewController.m
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "AppointmentDetailViewController.h"
#import "AppDelegate.h"
#import "ServiceProxy.h"
#import "MapAnnotation.h"
#import <MapKit/MapKit.h>
#import "MKMapView+FitAnnotations.h"
#import "CWValueObject.h"


NSString* kDefaultAppointmentDetailViewNibNameIPhone = @"AppointmentDetailView_iPhone";
NSString* kDefaultAppointmentDetailViewNibNameIPad = @"AppointmentDetailView_iPad";

NSString* kParticipantCellReusableIdentifier = @"ParticipantCell";

NSArray *sectionGroups;

@implementation AppointmentDetailViewController

@synthesize appointment = _appointment;
@synthesize scrollView, participantsTableView, acceptButton, declineButton;
@synthesize locationMap;
@synthesize mapAnnotations, participantGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sectionGroups = [NSArray arrayWithObjects: @"Accepted", @"Undecided", @"Declined", nil];
    }
    return self;
}

- (AppointmentDetailViewController*) initWithDefaultNibAndAppointment:(id<Appointment>)appointment
{
    self = (AppointmentDetailViewController*)[self initWithNibName:kDefaultAppointmentDetailViewNibNameIPhone bundle:nil];
    self.appointment = appointment;
    [self updateParticipantGroups];
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
    self.navigationItem.title = self.appointment.message;
    
    CGSize size = ((UIView*)[self.scrollView.subviews objectAtIndex:0]).bounds.size;
    [self.scrollView setContentSize:size];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // If it's one of our appointments, change the button labels
    if ([self.appointment.creator isEqualToString:appDelegate.currentUser]) {
        self.acceptButton.titleLabel.text = @"Start";
        self.declineButton.titleLabel.text = @"Cancel";
    }
    
    [self updateMapAnnotations];
}

- (void)viewDidUnload
{
    [self setLocationMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions

- (IBAction)joinAppointment:(UIButton *)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserId user = appDelegate.currentUser;
    
    if ([self.appointment.creator isEqualToString:user]) {
        id<Response> response = [ServiceProxy finalizeAppointment:self.appointment.identifier];
        if (!response.success) {
            UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                              message:@"Something went wrong finalizing the appointment." 
                                                             delegate:nil 
                                                    cancelButtonTitle:@"Ok" 
                                                    otherButtonTitles:nil];
            [message show];
            return;
        }
    } else {
        id<Response> response = [ServiceProxy joinAppointment:self.appointment.identifier userId:user travelType:0 /*TODO*/location:appDelegate.currentLocation];
        if (!response.success) {
            UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                              message:@"Something went wrong joining the appointment." 
                                                             delegate:nil 
                                                    cancelButtonTitle:@"Ok" 
                                                    otherButtonTitles:nil];
            [message show];
            return;
        }
    }
    
    for (id<Participant> participant in self.appointment.participants) {
        if ([participant.userId isEqualToString:user]) {
            participant.status = JOINED;
            [self updateParticipantGroups];
            [self.participantsTableView reloadData];
            return;
        }
    }
}

- (IBAction)declineAppointment:(UIButton*)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserId user = appDelegate.currentUser;
    
    id<Response> response = [ServiceProxy declineAppointment:self.appointment.identifier userId:appDelegate.currentUser];
    if (!response.success) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                          message:@"Something went wrong declining the appointment." 
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok" 
                                                otherButtonTitles:nil];
        [message show];
        return;
    } else {
        for (id<Participant> participant in self.appointment.participants) {
            if ([participant.userId isEqualToString:user]) {
                participant.status = DECLINED;
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    cell = [tableView dequeueReusableCellWithIdentifier:kParticipantCellReusableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kParticipantCellReusableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    id<Participant> participant = [self getParticipantNr: indexPath.row ofGroup: indexPath.section ];
    
    cell.textLabel.text = participant.userId;
    switch (participant.status) {
        case PENDING:
            cell.backgroundColor = [UIColor grayColor];
            break;
        case JOINED:
            cell.backgroundColor = [UIColor greenColor];
            break;
        case DECLINED:
            cell.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return [sectionGroups count];
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [sectionGroups objectAtIndex: section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [[self.participantGroups objectForKey: [sectionGroups objectAtIndex: section]] count];
}

- (void) updateParticipantGroups{
    
    //Setup grouping fo participants
    self.participantGroups = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: [NSMutableArray new],[NSMutableArray new],[NSMutableArray new],nil ] forKeys: sectionGroups];
    
    NSEnumerator *participantE = [self.appointment.participants objectEnumerator];
    id<Participant> participant;
    while(participant = (id<Participant>)[participantE nextObject]){

        NSString* groupName;
              
        switch (participant.status) {
            case JOINED:
                groupName = [sectionGroups objectAtIndex: 0];
                break;
            case DECLINED:
                groupName = [sectionGroups objectAtIndex: 2];
                break;
            default:
                groupName = [sectionGroups objectAtIndex: 1];
                break;
        }
        
        NSMutableArray* group = [self.participantGroups objectForKey: (id)groupName];        
        [group addObject: participant];
    }
}

- (id<Participant>) getParticipantNr: (NSInteger) number ofGroup: (NSInteger) groupNumber{
    NSString* groupName = [sectionGroups objectAtIndex: groupNumber];
    NSArray* group = [self.participantGroups objectForKey: groupName];   
    id<Participant> participant = [group objectAtIndex: number];
    return participant;
}

#pragma mark - Map View

- (void) fetchMapAnnotations
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    id<Response> response = [ServiceProxy getTravelPlanForAppointmentId:self.appointment.identifier travelType:PUBLICTRANSPORT location:appDelegate.currentLocation];
    
    if (!response.success) {
        //TODO
    } else {
        self.mapAnnotations = [NSMutableArray array];
        id<TravelPlan> travelPlan = response.payload;
        NSArray* path = travelPlan.path;
        for (id<Location> location in path) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
            [self.mapAnnotations addObject:[[MapAnnotation alloc] initWithTitle:location.title 
                                                                       subtitle:location.description 
                                                                     coordinate:coord]];
        }
    }
}

- (void) updateMapAnnotations
{
    [self.locationMap removeAnnotations:self.mapAnnotations];
    [self fetchMapAnnotations];
    [self.locationMap addAnnotations:self.mapAnnotations];
    [self.locationMap zoomToFitMapAnnotationsAnimated:YES];
}

@end
