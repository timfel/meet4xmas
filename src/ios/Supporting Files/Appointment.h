//
//  Appointment.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 08.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

@protocol Appointment 

@property(nonatomic) int identifier;
@property(nonatomic) int locationType;
@property(strong, nonatomic) id location;
@property(strong, nonatomic) NSArray* invitees;
@property(strong, nonatomic) NSArray* participants;

@end

@protocol ErrorInfo

@property(nonatomic) int code;
@property(strong, nonatomic) NSString* message;

@end

@protocol ResponseBody

@property(nonatomic) BOOL success;
@property(strong, nonatomic) id<ErrorInfo> error;
@property(strong, nonatomic) id payload;

@end

@protocol Service

- (id<ResponseBody>) createAppointment:(NSString*)userId :(int)travelType :(id)location :(NSArray*)invitees :(int)locationType :(NSString*)userMessage;
- (id<ResponseBody>) getAppointment:(int)aid;

@end
