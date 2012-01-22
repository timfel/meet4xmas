//
//  CreateAppointmentViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 13.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "ServiceProxy.h"
#import "AddInviteeViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol CreateAppointmentViewControllerDelegate

- (void)createdAppointment:(AppointmentId)appointmentId;
- (void)creationCanceled;

@end

@interface CreateAppointmentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, AddInviteeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) id<CreateAppointmentViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField* descriptionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl* travelType;
@property (weak, nonatomic) IBOutlet UITableView* inviteeTableView;

- (CreateAppointmentViewController*)initWithDefaultNib;

@end
