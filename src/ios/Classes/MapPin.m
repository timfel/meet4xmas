//
//  MapPin.m
//  Meet4Xmas
//
//  Created by dev on 1/30/12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import "MapPin.h"
#import <MapKit/MapKit.h>


@implementation MapPin

@synthesize title = _title;
@synthesize subtitle = _subtile;
@synthesize coordinate = _coordinate;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    
    if (self) {
        _title = [title copy];
        _subtitle = [subtitle copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtile;
}

@end