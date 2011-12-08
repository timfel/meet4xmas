//
//  RegisterViewController.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegistrationViewControllerDelegate <NSObject>

- (void)userRegisteredWithEmail:(NSString*)email;

@end


@interface RegistrationViewController : UIViewController

@property (strong, nonatomic) id<RegistrationViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField* emailTextField;

@end
