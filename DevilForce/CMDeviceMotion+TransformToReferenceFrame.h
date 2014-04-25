//
//  CMDeviceMotion+TransformToReferenceFrame.h
//  DevilForce
//
//  Created by lijiajia on 14-4-24.
//  Copyright (c) 2014年 jiajia. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMDeviceMotion (TransformToReferenceFrame)

-(CMAcceleration)userAccelerationInReferenceAttitude:(CMAttitude*)refAttitude;

@end
