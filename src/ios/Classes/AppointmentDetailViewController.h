//
//  AppointmentDetailViewController.h
//  Meet4Xmas
//
//  Created by Tobias on 25.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProtocols.h"

@interface AppointmentDetailViewController : UIViewController

@property (nonatomic, strong) id<Appointment> appointment;

- (AppointmentDetailViewController*) initWithDefaultNibAndAppointment:(id<Appointment>)appointment;

@end
