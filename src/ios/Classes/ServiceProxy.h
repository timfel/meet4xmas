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
+ (BOOL)registerAccount:(UserId)userId withDeviceToken:(NSData*)token receiveAppointments:(NSArray*)appointments;

+ (BOOL)deleteAccount:(UserId)userId;

#pragma mark Appointment
+ (BOOL)createAppointment: (AppointmentId) appointmentId
                 WithUser:(UserId)userId
               travelType:(TravelType)travelType
                location:(id<Location>)location
                 invitees:(NSArray*)invitees
             locationType:(LocationType)locationType
              userMessage:(NSString*)userMessage;

+ (BOOL)getAppointment:(id<Appointment>) appointment forID: (AppointmentId)appointmentId;

+ (BOOL)finalizeAppointment:(AppointmentId)appointmentId;

+ (BOOL)joinAppointment:(AppointmentId)appointmentId
                 userId:(UserId)userId
             travelType:(TravelType)travelType
               location:(id<Location>)location;

+ (BOOL)declineAppointment:(AppointmentId)appointmentId
                    userId:(UserId)userId;

#pragma mark TravelPlan
+ (BOOL)getTravelPlan: (id<TravelPlan>)travelplan for:(AppointmentId)appointmentId
                     travelType:(TravelType)travelType
                       location:(id<Location>)location;

@end


