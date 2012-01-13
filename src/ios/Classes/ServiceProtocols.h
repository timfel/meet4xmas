//
//  Appointment.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

OBJC_EXPORT NSString* const kClassPrefix;

#define getFullClassName(name) [NSString stringWithFormat:@"%@.%@", kClassPrefix, name]

typedef enum {
    WEIHNACHTSMARKT
} LocationType;

typedef enum {
    CAR,
    WALK,
    PUBLICTRANSPORT
} TravelType;

typedef enum {
    PENDING,
    JOINED,
    DECLINED
} ParticipationStatus;

typedef NSString* UserId;
typedef int AppointmentId;

OBJC_EXPORT NSString* const kParticipantClassName;
@protocol Participant

@property(strong, nonatomic) UserId userId;
@property(nonatomic) ParticipationStatus status;

@end

OBJC_EXPORT NSString* const kLocationClassName;
@protocol Location

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;
@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* desciption;

@end

OBJC_EXPORT NSString* const kAppointmentClassName;
@protocol Appointment 

@property(nonatomic) int AppointmentId;
@property(strong, nonatomic) UserId creator;
@property(nonatomic) LocationType locationType;
@property(strong, nonatomic) id<Location> location;
@property(strong, nonatomic) NSArray* participants;
@property(strong, nonatomic) NSString* message;
@property(nonatomic) BOOL isFinal;

@end

OBJC_EXPORT NSString* const kTravelPlanClassName;
@protocol TravelPlan

@property(strong, nonatomic) NSArray* path;

@end

OBJC_EXPORT NSString* const kErrorInfoClassName;
@protocol ErrorInfo

@property(nonatomic) int code;
@property(strong, nonatomic) NSString* message;

@end


OBJC_EXPORT NSString* const kResponseClassName;
@protocol Response

@property(nonatomic) BOOL success;
@property(strong, nonatomic) id<ErrorInfo> error;
@property(strong, nonatomic) id payload;

@end


@protocol Service

- (id<Response>)registerAccount:(UserId)userId;
- (id<Response>)deleteAccount:(UserId)userId;

- (id<Response>)createAppointment:(UserId)userId :(TravelType)travelType :(id<Location>)location :(NSArray*)invitees :(LocationType)locationType :(NSString*)userMessage;
- (id<Response>)getAppointment:(AppointmentId)appointmentId;
- (id<Response>)finalizeAppointment:(AppointmentId)appointmentId;
- (id<Response>)joinAppointment:(AppointmentId)appointmentId :(UserId)userId :(TravelType)travelType :(id<Location>)location;
- (id<Response>)declineAppointment:(AppointmentId)appointmentId :(UserId)userId;

- (id<Response>)getTravelPlan:(AppointmentId)appointmentId :(TravelType)travelType :(id<Location>)location;



@end
