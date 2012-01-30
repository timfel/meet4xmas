//
//  MapPin.h
//  Meet4Xmas
//
//  Created by dev on 1/30/12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapPin : NSObject<MKAnnotation> {
    NSString *_title;
    NSString *_subtitle;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle coordinate:(CLLocationCoordinate2D)coordinate;

@end