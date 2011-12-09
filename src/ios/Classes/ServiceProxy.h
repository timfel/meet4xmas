//
//  ServiceProxy.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 09.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "ServiceProtocols.h"

@interface ServiceProxy : NSObject

+ (id<Appointment>)getAppointment:(int)identifier;

@end
