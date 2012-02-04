//
//  AppointmentDetailViewController.h
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProtocols.h"
#import <MapKit/MapKit.h>

@interface AppointmentDetailViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) id<Appointment> appointment;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UITableView* participantsTableView;
@property (nonatomic, strong) IBOutlet UIButton* acceptButton;
@property (nonatomic, strong) IBOutlet UIButton* declineButton;
@property (nonatomic, strong) IBOutlet MKMapView* locationMap;

@property (nonatomic, strong) NSDictionary* participantGroups;
@property (nonatomic, strong) NSMutableArray* mapAnnotations;

- (AppointmentDetailViewController*) initWithDefaultNibAndAppointment:(id<Appointment>)appointment;

- (IBAction)joinAppointment:(UIButton*)sender;
- (IBAction)declineAppointment:(UIButton*)sender;

- (void) updateParticipantGroups;
- (id<Participant>) getParticipantNr: (NSInteger) number ofGroup: (NSInteger) groupNumber;

- (void) fetchMapAnnotations;
- (void) updateMapAnnotations;
@end
