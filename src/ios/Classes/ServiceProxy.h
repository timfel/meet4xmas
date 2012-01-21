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
+ (id<Response>)registerAccount:(UserId)userId withDeviceToken:(NSData*)token;

+ (id<Response>)deleteAccount:(UserId)userId;

#pragma mark Appointment
+ (id<Response>)createAppointmentWithUser:(UserId)userId
                               travelType:(TravelType)travelType
                                 location:(id<Location>)location
                                 invitees:(NSArray *)invitees
                             locationType:(LocationType)locationType
                              userMessage:(NSString *)userMessage;

+ (id<Response>)getAppointmentForID: (AppointmentId)appointmentId;

+ (id<Response>)finalizeAppointment:(AppointmentId)appointmentId;

+ (id<Response>)joinAppointment:(AppointmentId)appointmentId
                 userId:(UserId)userId
             travelType:(TravelType)travelType
               location:(id<Location>)location;

+ (id<Response>)declineAppointment:(AppointmentId)appointmentId
                    userId:(UserId)userId;

#pragma mark TravelPlan
+ (id<Response>)getTravelPlanForAppointmentId: (AppointmentId)appointmentId
                                   travelType:(TravelType)travelType
                                     location:(id<Location>)location;

@end


