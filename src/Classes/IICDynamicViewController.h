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

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) NSMutableArray *dynamicViews;
@property (nonatomic) float gravityX;
@property (nonatomic) float gravityY;

- (void)updateAnswers;

@end
