//
//  IICDynamicViewController.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "IICNotificationLabel.h"
#import "IICDynamicView.h"

@interface IICDynamicViewController : UIViewController <IICDynamicViewProtocol>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) NSMutableArray *dynamicItems;
@property (nonatomic, strong) IICNotificationLabel *elasticityLabel;
@property float gravityX;
@property float gravityY;
@property float itemCount;

- (void)updateAnswers;
- (void)enableDynamicInterface:(BOOL)enable;

@end
