//
//  AppointmentDetailViewController.m
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "AppointmentDetailViewController.h"
#import "AppDelegate.h"

NSString* kDefaultAppointmentDetailViewNibNameIPhone = @"AppointmentDetailView_iPhone";
NSString* kDefaultAppointmentDetailViewNibNameIPad = @"AppointmentDetailView_iPad";

NSString* kParticipantCellReusableIdentifier = @"ParticipantCell";

@implementation AppointmentDetailViewController

@synthesize appointment = _appointment;
@synthesize scrollView, acceptButton, declineButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AppointmentDetailViewController*) initWithDefaultNibAndAppointment:(id<Appointment>)appointment
{
    self = (AppointmentDetailViewController*)[self initWithNibName:kDefaultAppointmentDetailViewNibNameIPhone bundle:nil];
    self.appointment = appointment;
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
    id<Participant> participant = [self.appointment.participants objectAtIndex:indexPath.row];
    cell.textLabel.text = participant.userId;
    switch (participant.status) {
        case PENDING:
            cell.backgroundColor = [UIColor yellowColor];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appointment.participants.count;
}

@end
