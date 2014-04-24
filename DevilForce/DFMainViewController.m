//
//  DFMainViewController.m
//  DevilForce
//
//  Created by jiajia on 14-4-23.
//  Copyright (c) 2014年 jiajia. All rights reserved.
//

#import "DFMainViewController.h"
#import <CoreMotion/CoreMotion.h>

#define DFMotionMonitorInterval   0.1f

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
    
    double ax;
    double ay;
    double az;
}

@property UILabel *maxSpeedLabel;
@property UILabel *latestRealSpeedLabal;
@property UILabel *moveDistance;
@property UIButton *startButton;
@property CMMotionManager *motionManager;

@property UILabel *zuobiaoX;
@property UILabel *zuobiaoY;
@property UILabel *zuobiaoZ;

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
    
    self.maxSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 100, 30)];
    self.maxSpeedLabel.textColor = [UIColor whiteColor];
    self.maxSpeedLabel.text = @"0.000";
    [self.view addSubview:self.maxSpeedLabel];
    
    self.latestRealSpeedLabal = [[UILabel alloc]initWithFrame:CGRectMake(100, 80, 100, 30)];
    self.latestRealSpeedLabal.textColor = [UIColor whiteColor];
    self.latestRealSpeedLabal.text = @"0.000";
    [self.view addSubview:self.latestRealSpeedLabal];
    
    self.moveDistance = [[UILabel alloc]initWithFrame:CGRectMake(100, 130, 100, 30)];
    self.moveDistance.textColor = [UIColor whiteColor];
    self.moveDistance.text = @"0.000";
    [self.view addSubview:self.moveDistance];
    
    
    self.zuobiaoX = [[UILabel alloc]initWithFrame:CGRectMake(100, 180, 100, 20)];
    self.zuobiaoX.textColor = [UIColor whiteColor];
    self.zuobiaoX.text = @"x= 0";
    [self.view addSubview:self.zuobiaoX];
    
    self.zuobiaoY = [[UILabel alloc]initWithFrame:CGRectMake(100, 210, 100, 20)];
    self.zuobiaoY.textColor = [UIColor whiteColor];
    self.zuobiaoY.text = @"y= 0";
    [self.view addSubview:self.zuobiaoY];
    
    self.zuobiaoZ = [[UILabel alloc]initWithFrame:CGRectMake(100, 240, 100, 20)];
    self.zuobiaoZ.textColor = [UIColor whiteColor];
    self.zuobiaoZ.text = @"z= 0";
    [self.view addSubview:self.zuobiaoZ];
    
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startButton.frame = CGRectMake(100, 280, 100, 50);
    [self startButtonInit];
    [self.view addSubview:self.startButton];
}

- (void)startButtonPressed:(id)obj
{
    [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.startButton removeTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.startButton addTarget:self action:@selector(startButtonInit) forControlEvents:UIControlEventTouchDown];
    
    [self startMotionMonitor];
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
         double tempx = motion.userAcceleration.x;
         
         if (0 == intervalTimes) {
             refAttitude = motion.attitude;
         }
         else
         {
             [motion.attitude multiplyByInverseOfAttitude:refAttitude];
         }
         
         double tempx2 = motion.userAcceleration.x;
         
         vx += motion.userAcceleration.x * DFMotionMonitorInterval;
         vy += motion.userAcceleration.y * DFMotionMonitorInterval;
         vz += motion.userAcceleration.z * DFMotionMonitorInterval;
         v_real = hypot(vz, hypot(vx, vy));
         
         intervalTimes++;
         move_distance += v_real * DFMotionMonitorInterval;
         if (v_real > v_max) {
             v_max =v_real;
         }
         
         if (motion.userAcceleration.x > ax) {
             ax = motion.userAcceleration.x;
             weekSelf.zuobiaoX.text = [NSString stringWithFormat:@"x= %f", motion.userAcceleration.x];
         }
         if (motion.userAcceleration.y > ay) {
             ay = motion.userAcceleration.y;
             weekSelf.zuobiaoY.text = [NSString stringWithFormat:@"y= %f", motion.userAcceleration.y];
         }
         if (motion.userAcceleration.z > az) {
             az = motion.userAcceleration.z;
             weekSelf.zuobiaoZ.text = [NSString stringWithFormat:@"z= %f", motion.userAcceleration.z];
         }
         
         
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
    self.maxSpeedLabel.text = [NSString stringWithFormat:@"%f" , v_max];
    self.latestRealSpeedLabal.text = [NSString stringWithFormat:@"%f" , v_real];
    self.moveDistance.text = [NSString stringWithFormat:@"%f" , move_distance];
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
