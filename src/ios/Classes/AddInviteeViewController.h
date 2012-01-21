//
//  AddInviteeViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 19.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

@protocol AddInviteeViewControllerDelegate <NSObject>

- (void)inviteeAddedWithEmail:(NSString*)email;
@optional
- (void)addingInviteeByEmailCanceled;

@end

@interface AddInviteeViewController : UIViewController

@property (strong, nonatomic) NSObject<AddInviteeViewControllerDelegate>* delegate;

@property (strong, nonatomic) IBOutlet UITextField* emailTextField;

- (AddInviteeViewController*)initWithDefaultNib;

@end
