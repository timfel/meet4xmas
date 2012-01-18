//
//  CreateAppointmentViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 13.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProxy.h"

@protocol CreateAppointmentViewControllerDelegate

- (void)createdAppointment:(AppointmentId)appointmentId;
- (void)creationCanceled;

@end

@interface CreateAppointmentViewController : UIViewController

@property (nonatomic, strong) id<CreateAppointmentViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField* descriptionTextField;

- (CreateAppointmentViewController*)initWithDefaultNib;

@end
