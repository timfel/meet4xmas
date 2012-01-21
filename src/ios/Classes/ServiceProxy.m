//
//  ServiceProxy.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 09.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "ServiceProxy.h"
#import "ServiceProtocols.h"
#import "CWValueObject.h"

#import "HessianKit.h"

@interface ServiceProxy()

@property (strong, nonatomic) CWHessianConnection* connection;
@property (strong, nonatomic) id<Service> serviceProxy;

@end


@implementation ServiceProxy

@synthesize connection = _connection;
@synthesize serviceProxy = _serviceProxy;

#pragma mark - Singleton

+ (ServiceProxy*)sharedInstance
{
    static ServiceProxy* _sharedInstance;
    
    @synchronized(self)
    {
        if (!_sharedInstance) {
            _sharedInstance = [[ServiceProxy alloc] init];
        }
        return _sharedInstance;
    }
}

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        NSString* urlString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"serviceUrl"];
        NSURL* serviceUrl = [NSURL URLWithString:urlString];
        
        self.connection = [[CWHessianConnection alloc] initWithServiceURL:serviceUrl];
        
        self.connection.translator = [CWHessianTranslator defaultHessianTranslator];
        [self.connection.translator setProtocol:@protocol(Appointment)  forDistantTypeName:getFullClassName(kAppointmentClassName)];
        [self.connection.translator setProtocol:@protocol(Participant)  forDistantTypeName:getFullClassName(kParticipantClassName)];
        [self.connection.translator setProtocol:@protocol(Location)     forDistantTypeName:getFullClassName(kLocationClassName)];
        [self.connection.translator setProtocol:@protocol(TravelPlan)   forDistantTypeName:getFullClassName(kAppointmentClassName)];
        [self.connection.translator setProtocol:@protocol(Response)     forDistantTypeName:getFullClassName(kResponseClassName)];
        [self.connection.translator setProtocol:@protocol(ErrorInfo)    forDistantTypeName:getFullClassName(kErrorInfoClassName)];
        [self.connection.translator setProtocol:@protocol(NotificationServiceInfo) forDistantTypeName:getFullClassName(kNotificationServiceInfoClassName)];
        
        self.serviceProxy = (id<Service>)[self.connection rootProxyWithProtocol:@protocol(Service)];
    }
    return self;
}

#pragma mark Account

+ (id<Response>)registerAccount:(UserId)userId withDeviceToken:(NSData *)token
{
    id<Response> response;
    if (token == nil) {
        response = [[self sharedInstance].serviceProxy registerAccount:userId :nil];
    } else {
        CWValueObject<NotificationServiceInfo>* serviceInfo = (CWValueObject<NotificationServiceInfo>*)[CWValueObject valueObjectWithProtocol:@protocol(NotificationServiceInfo)];
        serviceInfo.serviceType = APNS;
        serviceInfo.deviceId = token;
        response = [[self sharedInstance].serviceProxy registerAccount:userId :serviceInfo];
    }
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to register account: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

+ (id<Response>)deleteAccount:(UserId)userId
{
    id<Response> response = [[self sharedInstance].serviceProxy deleteAccount:userId];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to delete account: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

#pragma mark Appointment

+ (id<Response>)createAppointmentWithUser:(UserId)userId
                               travelType:(TravelType)travelType
                                 location:(id<Location>)location
                                 invitees:(NSArray *)invitees
                             locationType:(LocationType)locationType
                              userMessage:(NSString *)userMessage
{
    id<Response> response = [[self sharedInstance].serviceProxy createAppointment:userId :travelType :location :invitees :locationType :userMessage];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to create appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

+ (id<Response>)getAppointmentForID: (AppointmentId)appointmentId
{
    id<Response> response =  [[self sharedInstance].serviceProxy getAppointment:appointmentId];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to get appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

+ (id<Response>)finalizeAppointment:(AppointmentId)appointmentId
{
    id<Response> response = [[self sharedInstance].serviceProxy finalizeAppointment:appointmentId];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to finalize appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

+ (id<Response>)joinAppointment:(AppointmentId)appointmentId
                 userId:(UserId)userId
             travelType:(TravelType)travelType
               location:(id<Location>)location
{
    id<Response> response = [[self sharedInstance].serviceProxy joinAppointment:appointmentId :userId :travelType :location];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to join appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

+ (id<Response>)declineAppointment:(AppointmentId)appointmentId userId:(UserId)userId
{
    id<Response> response = [[self sharedInstance].serviceProxy declineAppointment:appointmentId :userId];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to decline appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

#pragma mark TravelPlan

+ (id<Response>)getTravelPlanForAppointmentId: (AppointmentId)appointmentId
                                   travelType:(TravelType)travelType
                                     location:(id<Location>)location
{
    id<Response> response = [[self sharedInstance].serviceProxy getTravelPlan:appointmentId :travelType :location];
    
    if (!response.success) {
        if (response.error) {
            NSLog(@"Failed to decline appointment: [%@]%@.", response.error.code, response.error.message);
        }
    }
    return response;
}

@end
