//
//  ServiceProxy.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 09.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "ServiceProtocols.h"

@interface ServiceProxy : NSObject

#pragma mark Account
+ (NSArray*)registerAccount:(UserId)userId;

+ (BOOL)deleteAccount:(UserId)userId;

#pragma mark Appointment
+ (AppointmentId)createAppointmentWithUser:(UserId)userId
                                travelType:(TravelType)travelType
                                  location:(id<Location>)location
                                  invitees:(NSArray*)invitees
                              locationType:(LocationType)locationType
                               userMessage:(NSString*)userMessage;

+ (id<Appointment>)getAppointment:(AppointmentId)appointmentId;

+ (BOOL)finalizeAppointment:(AppointmentId)appointmentId;

+ (BOOL)joinAppointment:(AppointmentId)appointmentId
                 userId:(UserId)userId
             travelType:(TravelType)travelType
               location:(id<Location>)location;

+ (BOOL)declineAppointment:(AppointmentId)appointmentId
                    userId:(UserId)userId;

#pragma mark TravelPlan
+ (id<TravelPlan>)getTravelPlan:(AppointmentId)appointmentId
                     travelType:(TravelType)travelType
                       location:(id<Location>)location;

@end


