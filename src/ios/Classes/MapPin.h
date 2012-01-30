//
//  MapPin.h
//  Meet4Xmas
//
//  Created by dev on 1/30/12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface MapPin : NSObject<MKAnnotation> {
  
    @property(nonatomic, strong) (CLLocationCoordinate2D) coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
    
}