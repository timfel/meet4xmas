//
//  MKMapView+FitAnnotations.h
//  Meet4Xmas
//
//  Created by Frank Schlegel on 04.02.12.
//  Copyright (c) 2012 HPI. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (FitAnnotations)

-(void)zoomToFitMapAnnotationsAnimated:(BOOL)animated;

@end
