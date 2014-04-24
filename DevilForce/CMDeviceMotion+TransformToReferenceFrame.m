//
//  CMDeviceMotion+TransformToReferenceFrame.m
//  DevilForce
//
//  Created by lijiajia on 14-4-24.
//  Copyright (c) 2014年 jiajia. All rights reserved.
//

#import "CMDeviceMotion+TransformToReferenceFrame.h"

@implementation CMDeviceMotion (TransformToReferenceFrame)

- (CMAcceleration)userAccelerationInReferenceFrame
{
    CMAcceleration acc = [self userAcceleration];
    CMRotationMatrix rot = [self attitude].rotationMatrix;
    
    CMAcceleration accRef;
    accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
    accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
    accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
    
    return accRef;
}

@end
