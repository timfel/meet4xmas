//
//  Appointment.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

OBJC_EXPORT NSString* const kClassPrefix;

#define getFullClassName(name) [NSString stringWithFormat:@"%@.%@", kClassPrefix, name]

OBJC_EXPORT NSString* const kAppointmentClassName;
@protocol Appointment 

@property(nonatomic) int identifier;
@property(nonatomic) int locationType;
@property(strong, nonatomic) id location;
@property(strong, nonatomic) NSArray* invitees;
@property(strong, nonatomic) NSArray* participants;

@end

OBJC_EXPORT NSString* const kLocationClassName;
@protocol Location

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;
@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* desciption;

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


OBJC_EXPORT NSString* const kResponseBodyClassName;
@protocol ResponseBody

@property(nonatomic) BOOL success;
@property(strong, nonatomic) id<ErrorInfo> error;
@property(strong, nonatomic) id payload;

@end


@protocol Service

- (void)registerAccount:(NSString*)userId;

- (id<ResponseBody>)createAppointment:(NSString*)userId :(int)travelType :(id)location :(NSArray*)invitees :(int)locationType :(NSString*)userMessage;
- (id<ResponseBody>)getAppointment:(int)aid;

@end
