//
//  AppointmentDetailViewController.m
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "AppointmentDetailViewController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

NSString* kDefaultAppointmentDetailViewNibNameIPhone = @"AppointmentDetailView_iPhone";
NSString* kDefaultAppointmentDetailViewNibNameIPad = @"AppointmentDetailView_iPad";

NSString* kParticipantCellReusableIdentifier = @"ParticipantCell";

NSArray *sectionGroups;

@implementation AppointmentDetailViewController

@synthesize appointment = _appointment;
@synthesize scrollView, acceptButton, declineButton;
@synthesize locationMap;
@synthesize participantGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sectionGroups = [NSArray arrayWithObjects: @"Accepted", @"Undecided", @"Declined", nil];
        // Custom initialization
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
    
    [self adjustMapView];
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
    //id<Participant> participant = [self.appointment.participants objectAtIndex:indexPath.row];
    id<Participant> participant = [self getParticipantNr: indexPath.row ofGroup: indexPath.section ];
    //indexPath.section
    
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

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointment.participants.count;
}*/

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


- (void) adjustMapView{
        
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.appointment.location.latitude doubleValue];
    zoomLocation.longitude = [self.appointment.location.longitude doubleValue];
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*1000, 0.5*1000);
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.locationMap dequeueReusableAnnotationViewWithIdentifier: @"Super"];
   
    // 3
    MKCoordinateRegion adjustedRegion = [self.locationMap regionThatFits:viewRegion];                
    // 4
    [self.locationMap setRegion:adjustedRegion animated:YES];        

    NSLog(@"hier %@", self.appointment.location.longitude);
}
@end
