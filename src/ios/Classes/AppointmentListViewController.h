//
//  AppointmentListViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RegistrationViewController.h"
#import "CreateAppointmentViewController.h"

@interface AppointmentListViewController : UITableViewController <RegistrationViewControllerDelegate, CreateAppointmentViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

- (IBAction)createAppointment:(id)sender;
- (IBAction)logoutUser:(id)sender;

@end
