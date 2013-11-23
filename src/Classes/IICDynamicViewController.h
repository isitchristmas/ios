//
//  IICDynamicViewController.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface IICDynamicViewController : UIViewController <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

@end
