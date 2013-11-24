//
//  IICDynamicViewController.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import "IICDynamicViewController.h"
#import "IICDynamicLabel.h"
#import "IsItChristmasViewController.h"
#import "IsItChristmasAppDelegate.h"

@implementation IICDynamicViewController

static const float _kDampenAmount = 0.2f;
static const float _kGravityAmount = 2.0f;
static const int _kMaxDynamicItems = 5;
static const int _kDynamicItemPadding = 50;

- (void)loadView {
    [super loadView];
    
    //start hidden
    [self.view setAlpha:0.0f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //start detecting motion
    [self startMotionDetection];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //stop detecting motion
    [self.motionManager stopAccelerometerUpdates];
}

- (void)setupDynamics {
    
    //setup the animator
    [self setAnimator:[[UIDynamicAnimator alloc] initWithReferenceView:self.view]];
    
    //grab the main controller
    IsItChristmasViewController *mainController = (IsItChristmasViewController *)self.parentViewController;
    
    //setup array if needed
    if (!self.dynamicViews) {
        [self setDynamicViews:[[NSMutableArray alloc] initWithCapacity:_kMaxDynamicItems]];
    }
    
    //create a dynamic view for each language
    int index = 1;
    int count = (mainController.languages.count > _kMaxDynamicItems) ? _kMaxDynamicItems : mainController.languages.count;
    for (NSString *language in mainController.languages) {
        
        //create the label
        IICDynamicLabel *dynamicLabel = [[IICDynamicLabel alloc] initText:[mainController isItChristmas:language]];
        [self.dynamicViews addObject:dynamicLabel];
        
        //add the view with a semi-random starting point
        float randomX = (arc4random() % ((int)self.view.frame.size.width - _kDynamicItemPadding)) + _kDynamicItemPadding;
        [dynamicLabel setCenter:CGPointMake(randomX, _kDynamicItemPadding)];
        [self.view insertSubview:dynamicLabel atIndex:0];
        
        //limit the total number of views for now
        if (++index > count) {
            break;
        }
    }
    
    //gravity
    [self setGravityBehavior:[[UIGravityBehavior alloc] initWithItems:self.dynamicViews]];
    
    //collisions
    [self setCollisionBehavior:[[UICollisionBehavior alloc] initWithItems:self.dynamicViews]];
    [self.collisionBehavior setCollisionDelegate:self];
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
}

#pragma mark - rotation

- (NSUInteger)supportedInterfaceOrientations {
    
    //if the interface is not currently upside down, allow any rotations
    if (self.view.alpha == 0.0f || self.interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown);
    }

    //orientation is currently upside down
    //don't allow landscape
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    //update gravity and opacity based in the new orientation
    float opacity = 0.0f;
    switch (toInterfaceOrientation) {
            
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setGravityAmount:-_kGravityAmount];
            opacity = 1.0f;
            break;
            
        case UIInterfaceOrientationPortrait:
        default:
            [self setGravityAmount:_kGravityAmount];
            break;
            
    }
    
    //setup dynamic items if needed
    if (opacity > 0.0f && !self.animator) {
        [self setupDynamics];
    }
    
    //animate the view opacity
    //remove the behaviors if needed
    [UIView animateWithDuration:duration
                          delay:duration
                        options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //animate the opacity
                         [self.view setAlpha:opacity];
                         
                     }
                     completion:^(BOOL finished){
                         
                         //add or remote remove behaviors after animating the opacity
                         if (opacity > 0.0f) {
                             
                             //add behaviors
                             [self.animator addBehavior:self.gravityBehavior];
                             [self.animator addBehavior:self.collisionBehavior];
                             [self.animator addBehavior:self.pushBehavior];
                             
                         } else {

                             //remove behaviors
                             [self.animator removeBehavior:self.gravityBehavior];
                             [self.animator removeBehavior:self.collisionBehavior];
                             [self.animator removeBehavior:self.pushBehavior];
                             
                         }
                         
                     }];
}

#pragma mark - core motion

//returns the maain motion manager from the app delegate
- (CMMotionManager *)motionManager {
    IsItChristmasAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.motionManager;
}

//updates the UIGravityBehavior based on the accelerometer
- (void)startMotionDetection {
    [self setGravityAmount:_kGravityAmount];
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGVector gravityDirection = { data.acceleration.x * self.gravityAmount, -data.acceleration.y * self.gravityAmount };
            [self.gravityBehavior setGravityDirection:gravityDirection];
        });
    }];
}

#pragma mark - UICollisionBehaviorDelegate

//bounce items off of each other
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p {
    [self pushItem:item1];
}

//bounce items off of the wall
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    [self pushItem:item];
}

//item collision ended, remove the bounce effect
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    [self.pushBehavior removeItem:item1];
}

//wall collision ended, remove the bounce effect
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    [self.pushBehavior removeItem:item];
}

//push an item the opposite direction of gravity to simulate a bounce effect
- (void)pushItem:(id<UIDynamicItem>)item {
    
    //setup the push behavior if needed
    if (!self.pushBehavior) {
        [self setPushBehavior:[[UIPushBehavior alloc] initWithItems:nil mode:UIPushBehaviorModeInstantaneous]];
    }
    [self.pushBehavior setPushDirection:CGVectorMake(-self.gravityBehavior.gravityDirection.dx * _kDampenAmount, -self.gravityBehavior.gravityDirection.dy * _kDampenAmount)];
    [self.pushBehavior addItem:item];
    [self.pushBehavior setActive:YES];
    [self.animator addBehavior:self.pushBehavior];
}

@end
