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

- (void)registerAccount:(NSString*)userId;

- (id<Response>)createAppointment:(NSString*)userId :(int)travelType :(id)location :(NSArray*)invitees :(int)locationType :(NSString*)userMessage;
- (id<Response>)getAppointment:(int)aid;

@end
