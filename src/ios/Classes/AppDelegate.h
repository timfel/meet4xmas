//
//  AppDelegate.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ServiceProtocols.h"

OBJC_EXPORT NSString* const kLocationSetNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) UserId currentUser;
@property (strong, nonatomic) NSData* deviceToken;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, atomic) CLLocation* currentLocation;

@end
