//
//  CreateAppointmentViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 13.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "ServiceProxy.h"
#import "AddInviteeViewController.h"

@protocol CreateAppointmentViewControllerDelegate

- (void)createdAppointment:(AppointmentId)appointmentId;
- (void)creationCanceled;

@end

@interface CreateAppointmentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, AddInviteeViewControllerDelegate>

@property (nonatomic, strong) id<CreateAppointmentViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField* descriptionTextField;
@property (nonatomic, strong) IBOutlet UITableView* inviteeTableView;

- (CreateAppointmentViewController*)initWithDefaultNib;

@end
