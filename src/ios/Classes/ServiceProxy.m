//
//  ServiceProxy.m
//  Meet4Xmas
//
//  Created by Frank Schlegel on 09.12.11.
//  Copyright (c) 2011 HPI. All rights reserved.
//

#import "ServiceProxy.h"
#import "ServiceProtocols.h"

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
        [self.connection.translator setProtocol:@protocol(Appointment) forDistantTypeName:getFullClassName(kAppointmentClassName)];
        [self.connection.translator setProtocol:@protocol(ResponseBody) forDistantTypeName:getFullClassName(kResponseBodyClassName)];
        [self.connection.translator setProtocol:@protocol(ErrorInfo) forDistantTypeName:getFullClassName(kErrorInfoClassName)];
        
        self.serviceProxy = (id<Service>)[self.connection rootProxyWithProtocol:@protocol(Service)];
    }
    return self;
}

#pragma mark - Account

+ (BOOL)registerAccount:(NSString*)userId
{
    [[self sharedInstance].serviceProxy registerAccount:userId];
    // TODO: Error handling
    return YES;
}

#pragma mark - Appointment

+ (id<Appointment>)getAppointment:(int)identifier
{
    id<Response> response = [[self sharedInstance].serviceProxy getAppointment:identifier];
    id<Appointment> appointment = [response payload];
    return appointment;
}

@end
