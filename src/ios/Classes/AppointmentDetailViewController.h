//
//  AppointmentDetailViewController.h
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProtocols.h"

@interface AppointmentDetailViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) id<Appointment> appointment;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIButton* acceptButton;
@property (nonatomic, strong) IBOutlet UIButton* declineButton;
@property (nonatomic, strong) NSDictionary* participantGroups;

- (AppointmentDetailViewController*) initWithDefaultNibAndAppointment:(id<Appointment>)appointment;
- (void) updateParticipantGroups;
- (id<Participant>) getParticipantNr: (NSInteger) number ofGroup: (NSInteger) groupNumber;

@end
