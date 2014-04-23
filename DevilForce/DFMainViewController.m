//
//  DFMainViewController.m
//  DevilForce
//
//  Created by jiajia on 14-4-23.
//  Copyright (c) 2014年 jiajia. All rights reserved.
//

#import "DFMainViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface DFMainViewController ()

@property UILabel *maxSpeedLabel;
@property UILabel *maxAddSpeedLabel;
@property UILabel *moveDistance;
@property UIButton *startButton;
@property CMMotionManager *motionManager;

@end

@implementation DFMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.motionManager = [[CMMotionManager alloc]init];
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
    
    self.maxAddSpeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 80, 100, 30)];
    self.maxAddSpeedLabel.textColor = [UIColor whiteColor];
    self.maxAddSpeedLabel.text = @"0.000";
    [self.view addSubview:self.maxAddSpeedLabel];
    
    self.moveDistance = [[UILabel alloc]initWithFrame:CGRectMake(100, 130, 100, 30)];
    self.moveDistance.textColor = [UIColor whiteColor];
    self.moveDistance.text = @"0.000";
    [self.view addSubview:self.moveDistance];
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.startButton.frame = CGRectMake(100, 200, 100, 50);
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
}

- (void)startMotionMonitor
{
    if (!self.motionManager.accelerometerAvailable) {
        return;
    }
    
    [self.motionManager startGyroUpdates];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
    {
        
    }];
}

- (void)stopMotionMonitor
{
    
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
