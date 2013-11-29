//
//  IICAppDelegate.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright Brandon Jones 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "IICMainViewController.h"
#import "GAI.h"

@interface IICAppDelegate : NSObject <UIApplicationDelegate>

- (void)setupNotifications;
- (void)setupDefaults;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IICMainViewController *iicController;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) id<GAITracker> tracker;

@end

