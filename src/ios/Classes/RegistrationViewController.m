//
//  RegisterViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "RegistrationViewController.h"

#import "HessianKit.h"
#import "Appointment.h"

@interface RegistrationViewController()

- (IBAction) registrationDone:(id)sender;

@end

@implementation RegistrationViewController

@synthesize delegate = _delegate;
@synthesize emailTextField = _emailTextField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Register";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(registrationDone:)];
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
	return YES;
}

#pragma mark - Navigation bar callbacks

- (IBAction)registrationDone:(id)sender
{
//    NSURL* url = [NSURL URLWithString:@"http://172.16.18.55:4567/1/"];
//    CWHessianConnection* connection = [[CWHessianConnection alloc] initWithServiceURL:url];
//    
//    connection.translator = [CWHessianTranslator defaultHessianTranslator];
//    [connection.translator setProtocol:@protocol(Appointment) forDistantTypeName:@"lib.java.Appointment"];
//    [connection.translator setProtocol:@protocol(ResponseBody) forDistantTypeName:@"lib.java.ResponseBody"];
//    [connection.translator setProtocol:@protocol(ErrorInfo) forDistantTypeName:@"lib.java.ResponseBody$ErrorInfo"];
//    
//    id<Service> proxy = (id<Service>)[connection rootProxyWithProtocol:@protocol(Service)];
//
//    id<ResponseBody> response = [proxy createAppointment:@"foo@example.com" :0 :nil :[NSArray array] :0 :@"Hallo!"];
//    id<ErrorInfo> error = [response error];
//    NSLog(@"error: %d", error.code);
//    
//    response = [proxy getAppointment:42];
//    id<Appointment> appointment = [response payload];
//    NSLog(@"appointment: %d", appointment.identifier);
    
    if (self.delegate != nil) {
        [self.delegate userRegisteredWithEmail:self.emailTextField.text];
    }
}

@end
