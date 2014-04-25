//
//  DFMainViewController.m
//  DevilForce
//
//  Created by jiajia on 14-4-23.
//  Copyright (c) 2014年 jiajia. All rights reserved.
//

#import "DFMainViewController.h"
#import "CMDeviceMotion+TransformToReferenceFrame.h"
#import <CoreMotion/CoreMotion.h>

#define DFMotionMonitorInterval   0.1f
#define DFGravityAcceleration       0.98f

@interface DFMainViewController ()
{
    double vx;  //X轴速度
    double vy;  //Y轴速度
    double vz;  //Z轴速度
    
    double v_max;   //最大速度
    double v_real;  //当前实际速度
    double move_distance;   //总移动路程
    
    int intervalTimes;  //获取数据次数
    
    CMAttitude *refAttitude; //第一次获取的手机摆放方式，用来作参考坐标系
    
    NSTimer *timer;
    
    double ax;
    double ay;
    double az;
}

@property UILabel *maxSpeedLabel;
@property UILabel *latestRealSpeedLabal;
@property UILabel *moveDistance;
@property UIButton *startButton;
@property CMMotionManager *motionManager;

@property UILabel *jiasuduX;
@property UILabel *jiasuduY;
@property UILabel *jiasuduZ;
@property UILabel *gLabel;

@end

@implementation DFMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self resetMonitorData];
        ax = ay = az = 0.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.maxSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 30)];
    self.maxSpeedLabel.textColor = [UIColor whiteColor];
    self.maxSpeedLabel.text = @"maxSpeedLabel = 0.000";
    [self.view addSubview:self.maxSpeedLabel];
    
    self.latestRealSpeedLabal = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 300, 30)];
    self.latestRealSpeedLabal.textColor = [UIColor whiteColor];
    self.latestRealSpeedLabal.text = @"latestRealSpeedLabal = 0.000";
    [self.view addSubview:self.latestRealSpeedLabal];
    
    self.moveDistance = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 300, 30)];
    self.moveDistance.textColor = [UIColor whiteColor];
    self.moveDistance.text = @"moveDistance = 0.000";
    [self.view addSubview:self.moveDistance];
    
    
    self.jiasuduX = [[UILabel alloc]initWithFrame:CGRectMake(10, 180, 300, 20)];
    self.jiasuduX.textColor = [UIColor whiteColor];
    self.jiasuduX.text = @"ax= 0";
    [self.view addSubview:self.jiasuduX];
    
    self.jiasuduY = [[UILabel alloc]initWithFrame:CGRectMake(10, 210, 300, 20)];
    self.jiasuduY.textColor = [UIColor whiteColor];
    self.jiasuduY.text = @"ay= 0";
    [self.view addSubview:self.jiasuduY];
    
    self.jiasuduZ = [[UILabel alloc]initWithFrame:CGRectMake(10, 240, 300, 20)];
    self.jiasuduZ.textColor = [UIColor whiteColor];
    self.jiasuduZ.text = @"az= 0";
    [self.view addSubview:self.jiasuduZ];
    
    self.gLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 270, 300, 20)];
    self.gLabel.textColor = [UIColor whiteColor];
    self.gLabel.text = @"g= 0";
    [self.view addSubview:self.gLabel];
    
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startButton.frame = CGRectMake(100, 330, 100, 50);
    [self startButtonInit];
    [self.view addSubview:self.startButton];
}

- (void)startButtonPressed:(id)obj
{
    [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.startButton removeTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.startButton addTarget:self action:@selector(startButtonInit) forControlEvents:UIControlEventTouchDown];
    
    [self startMotionMonitor];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(startButtonInit) userInfo:nil repeats:NO];
}

- (void)startButtonInit
{
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton removeTarget:self action:@selector(startButtonInit) forControlEvents:UIControlEventTouchDown];
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    if (!self.motionManager)
    {
        self.motionManager = [[CMMotionManager alloc]init];
    }
    else
    {
        [self stopMotionMonitor];
    }
    
    if (timer && [timer isValid])
    {
        [timer invalidate];
    }
}

- (void)startMotionMonitor
{
    if (!self.motionManager.accelerometerAvailable) {
        return;
    }
    
    [self resetMonitorData];
    [self resetLabel];
    
    __weak DFMainViewController *weekSelf = self;
    
    [self.motionManager setDeviceMotionUpdateInterval:DFMotionMonitorInterval];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
         if (0 == intervalTimes)
         {
             refAttitude = motion.attitude;
         }
         
         CMAcceleration userAcceleration;
         userAcceleration = [motion userAccelerationInReferenceAttitude:refAttitude];
         
         if (fabs(userAcceleration.x) > 0.02 ) {
             vx += userAcceleration.x * DFGravityAcceleration * DFMotionMonitorInterval;
         }
         if (fabs(userAcceleration.y) > 0.02 ) {
             vy += userAcceleration.y * DFGravityAcceleration * DFMotionMonitorInterval;
         }
         if (fabs(userAcceleration.z) > 0.02 ) {
             vz += userAcceleration.z * DFGravityAcceleration * DFMotionMonitorInterval;
         }
         v_real = hypot(vz, hypot(vx, vy));
         
         intervalTimes++;
         move_distance += v_real * DFMotionMonitorInterval;
         if (v_real > v_max) {
             v_max =v_real;
         }
         
         if (fabs(userAcceleration.x) > ax)
         {
             ax = userAcceleration.x;
             weekSelf.jiasuduX.text = [NSString stringWithFormat:@"ax= %f", ax];
         }
         if (fabs(userAcceleration.y) > ay)
         {
             ay = userAcceleration.y;
             weekSelf.jiasuduY.text = [NSString stringWithFormat:@"ay= %f", ay];
         }
         if (fabs(userAcceleration.z) > az)
         {
             az = userAcceleration.z;
             weekSelf.jiasuduZ.text = [NSString stringWithFormat:@"az= %f", az];
         }
         
         weekSelf.gLabel.text = [NSString stringWithFormat:@"g= %f", motion.gravity.z];
         
         [weekSelf resetLabel];
    }];
}

- (void)stopMotionMonitor
{
    [self.motionManager stopDeviceMotionUpdates];
    
    [self resetLabel];
}

- (void)resetMonitorData
{
    vx = 0.0f;
    vy = 0.0f;
    vz = 0.0f;
    intervalTimes = 0;
    v_max = 0.000f;
    v_real = 0.000f;
    move_distance = 0.000f;
}

- (void)resetLabel
{
    self.maxSpeedLabel.text = [NSString stringWithFormat:@"maxSpeedLabel = %f" , v_max];
    self.latestRealSpeedLabal.text = [NSString stringWithFormat:@"latestRealSpeedLabal = %f" , v_real];
    self.moveDistance.text = [NSString stringWithFormat:@"moveDistance = %f" , move_distance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
