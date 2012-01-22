//
//  CreateAppointmentViewController.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 13.01.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "CreateAppointmentViewController.h"
#import "ServiceProxy.h"
#import "AppDelegate.h"
#import "AddInviteeViewController.h"
#import "CWValueObject.h"
#import <AddressBookUI/AddressBookUI.h>

NSString* kDefaultCreateAppointmentViewNibNameIPhone = @"CreateAppointmentView_iPhone";
NSString* kDefaultCreateAppointmentViewNibNameIPad = @"CreateAppointmentView_iPad";

NSString* kInviteeCellReusableIdentifier = @"InviteeCell";
NSString* kAddInviteeCellReusableIdentifier = @"AddInviteeCell";

typedef enum {
    ADDRESS_BOOK,
    EMAIL_ADDRESS
} ActionSheetButtonIndex;

@interface CreateAppointmentViewController()

@property (nonatomic, strong) NSMutableArray* invitees;

- (void)addInviteeWithMail:(NSString*)email;
- (void)enableBackButton;

- (void)done:(id)sender;
- (void)cancel:(id)sender;

@end

@implementation CreateAppointmentViewController

@synthesize delegate = _delegate;
@synthesize descriptionTextField = _descriptionTextField;
@synthesize travelType = _travelType;
@synthesize inviteeTableView = _inviteeTableView;

@synthesize invitees = _invitees;

- (CreateAppointmentViewController *)initWithDefaultNib
{
    //TODO: iPad
    return [self initWithNibName:kDefaultCreateAppointmentViewNibNameIPhone bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.invitees = [NSMutableArray array];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Create Appointment";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    [self.inviteeTableView setEditing:YES animated:NO];
}

- (void)viewDidUnload
{
    [self setTravelType:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addInviteeWithMail:(NSString*)email
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.invitees.count inSection:0];
    [self.invitees addObject:email];
    
    [self.inviteeTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self enableBackButton];
}

- (void)enableBackButton
{
    if (self.descriptionTextField.text == nil || self.invitees.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Actions

- (void)done:(id)sender
{
    UserId userId = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUser];
    TravelType travelType = [self.travelType selectedSegmentIndex];
    CWValueObject<Location>* location = (CWValueObject<Location>*)[CWValueObject valueObjectWithProtocol:@protocol(Location)];
    //TODO: Stub
    location.latitude = [NSNumber numberWithDouble:52.393957];
    location.longitude = [NSNumber numberWithDouble:13.132473];
    LocationType locationType = WEIHNACHTSMARKT;
    NSString* userMessage = self.descriptionTextField.text;
    
    id<Response> response = [ServiceProxy createAppointmentWithUser:userId
                                                travelType:travelType
                                                  location:location
                                                  invitees:self.invitees
                                              locationType:locationType
                                               userMessage:userMessage];
    if (!response.success) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Failed to create appointment." 
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok" 
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    
    if (self.delegate != nil) {
        AppointmentId newAppointment = (AppointmentId)response.payload;
        [self.delegate createdAppointment:newAppointment];
    }
}

- (void)cancel:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate creationCanceled];
    }
}

- (IBAction)desciptionChanged:(UITextField*)desciptionField {
    [self enableBackButton];
}

#pragma mark - UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.invitees.count) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    if (indexPath.row == self.invitees.count) {
        //This is the "Add invitee" row
        cell = [tableView dequeueReusableCellWithIdentifier:kAddInviteeCellReusableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAddInviteeCellReusableIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Add invitee";
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kInviteeCellReusableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInviteeCellReusableIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //cell.editing = YES;
        }
        cell.textLabel.text = [self.invitees objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // One more for the "Add invitee" row
    return self.invitees.count + 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.invitees removeObjectAtIndex:indexPath.row];
        [self.inviteeTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //TODO: Add invitee
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add invitee"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"From address book", @"By email address", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == ADDRESS_BOOK) {
        ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
        // Only show email addresses
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonEmailProperty]];
        
        picker.peoplePickerDelegate = self;
        [self presentModalViewController:picker animated:YES];        
    } else if (buttonIndex == EMAIL_ADDRESS) {
        AddInviteeViewController* addInviteeViewController = [[AddInviteeViewController alloc] initWithDefaultNib];
        addInviteeViewController.delegate = self;
        // Create a navigation controller and present it modally.
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:addInviteeViewController];
        [self presentModalViewController:navigationController animated:YES];
    }
}

#pragma mark - AddInviteeViewControllerDelegate methods

- (void)inviteeAddedWithEmail:(NSString *)email
{
    if ([self.invitees containsObject:email]) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"You already invited this person." 
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok" 
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    [self dismissModalViewControllerAnimated:YES];
    [self addInviteeWithMail:email];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef emails = ABRecordCopyValue(person, property);
    NSString* email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, identifier);
    
    if ([self.invitees containsObject:email]) {
        UIAlertView* message = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"You already invited this person." 
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok" 
                                                otherButtonTitles:nil];
        [message show];
        return NO;
    }
    
    [self addInviteeWithMail:email];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

@end
