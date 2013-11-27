//
//  IICDynamicViewController.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import "IICDynamicViewController.h"
#import "IICDynamicLabel.h"
#import "IICMainViewController.h"
#import "IICAppDelegate.h"

@implementation IICDynamicViewController

static const float _kElasticityDefault = 0.8f;
static const float _kElasticityMin = 0.009f;  //must be greater than zero
static const float _kElasticityMax = 1.0f;
static const float _kGravityAmount = 2.0f;
static const int _kMaxDynamicItems = 5;

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
    
    //setup array if needed
    if (!self.dynamicViews) {
        [self setDynamicViews:[[NSMutableArray alloc] initWithCapacity:_kMaxDynamicItems]];
    }
    
    //create dynamic items
    for (int index = 1; index <= _kMaxDynamicItems; index++) {
        
        //create the label
        IICDynamicLabel *dynamicLabel = [[IICDynamicLabel alloc] initText:[self randomAnswer]];
        [self.dynamicViews addObject:dynamicLabel];
        
        //add the views to the center of the view
        [dynamicLabel setCenter:self.view.center];
        [self.view addSubview:dynamicLabel];
        
    }
    
    //gravity
    [self setGravityBehavior:[[UIGravityBehavior alloc] initWithItems:self.dynamicViews]];
    
    //collisions
    [self setCollisionBehavior:[[UICollisionBehavior alloc] initWithItems:self.dynamicViews]];
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
    
    //item behavior
    [self setItemBehavior:[[UIDynamicItemBehavior alloc] initWithItems:self.dynamicViews]];
    [self.itemBehavior setElasticity:_kElasticityDefault];
    [self.itemBehavior setAngularResistance:0.1f];
    [self.itemBehavior setDensity:500.0f];
    [self.itemBehavior setFriction:0.0f];
    [self.itemBehavior setResistance:0.0f];
    
    //pinch recognizer for adjusting the elasticity
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    
}

//updates all of the dynamic views with a random answer
- (void)updateAnswers {
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //update the label text and size
                         for (IICDynamicLabel *label in self.dynamicViews) {
                             [label setText:[self randomAnswer]];
                             [label sizeToFit];
                         }
                         
                     }
                     completion:^(BOOL finished){
                         
                         //fix any out of control views
                         [self fixRogueViews];
                         
                     }];

}

//returns a yes/no answer for a random language
- (NSString *)randomAnswer {
    
    //grab the main controller
    IICMainViewController *mainController = (IICMainViewController *)self.parentViewController;
    
    //return a random answer
    int randomIndex = arc4random() % mainController.languages.count;
    NSString *language = [mainController.languages objectAtIndex:randomIndex];
    NSString *answer = [mainController isItChristmas:language];
    return answer;
    
}

//check to see if any of the dynamic views got pushed out of the main view
//if so, reset it
- (void)fixRogueViews {
    for (UIView *view in self.dynamicViews) {
        if (!CGRectContainsPoint(self.view.frame, view.center)) {
            [view setCenter:self.view.center];
        }
    }
}

#pragma mark - UIPinchGestureRecognizer

//update the dynamic item eleasticity
-(void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    
    //don't grow or shrink too fast
    float scale = gesture.scale;
    if (scale > 1.05f) {
        scale = 1.05f;
    } else if (scale < 0.95f) {
        scale = 0.95;
    }
    
    //calculate the new eleasticity
    float newElasticity = self.itemBehavior.elasticity * scale;
    
    //respect the min and max
    if (newElasticity > _kElasticityMax) {
        newElasticity = _kElasticityMax;
    } else if (newElasticity < _kElasticityMin) {
        newElasticity = _kElasticityMin;
    }
    
    //update the elasticity
    [self.itemBehavior setElasticity:newElasticity];
    NSLog(@"new elasticity: %i%%", (int)(newElasticity * 100));
    
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

//update gravity based in the new orientation
- (void)setGravityForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            [self setGravityX:_kGravityAmount];
            [self setGravityY:_kGravityAmount];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            [self setGravityX:-_kGravityAmount];
            [self setGravityY:-_kGravityAmount];
            break;
        
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setGravityX:-_kGravityAmount];
            [self setGravityY:_kGravityAmount];
            break;
            
        case UIInterfaceOrientationPortrait:
        default:
            [self setGravityX:_kGravityAmount];
            [self setGravityY:-_kGravityAmount];
            break;
            
    }
}

#pragma mark - rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    //hide the views when in portrait mode
    float opacity = (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) ? 0.0f : 1.0f;
    
    //update the gravity
    [self setGravityForOrientation:toInterfaceOrientation];
    
    //setup dynamic items if needed
    if (opacity > 0.0f && !self.animator) {
        [self setupDynamics];
    }
    
    //if the view will be visible after the animation, add the behaviors now
    if (opacity > 0.0f) {
        [self addBehaviors];
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
                         
                         //remove behaviors after setting the opacity to zero
                         if (opacity <= 0.0f) {
                             [self removeBehaviors];
                         }
                         
                         //fix any views that got pushed off the screen
                         [self fixRogueViews];
                         
                     }];
}

//add behaviors to the animator
- (void)addBehaviors {
    [self.animator addBehavior:self.gravityBehavior];
    [self.animator addBehavior:self.collisionBehavior];
    [self.animator addBehavior:self.itemBehavior];
}

//remove behaviors from the animator
- (void)removeBehaviors {
    [self.animator removeBehavior:self.gravityBehavior];
    [self.animator removeBehavior:self.collisionBehavior];
    [self.animator removeBehavior:self.itemBehavior];
}

#pragma mark - core motion

//returns the maain motion manager from the app delegate
- (CMMotionManager *)motionManager {
    IICAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.motionManager;
}

//updates the UIGravityBehavior based on the accelerometer
- (void)startMotionDetection {
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //reverse the acceleration when in landscape more
            BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
            float accelerationX = (isLandscape) ? data.acceleration.y : data.acceleration.x;
            float accelerationY = (isLandscape) ? data.acceleration.x : data.acceleration.y;
            
            //set the gravity direction
            CGVector gravityDirection = { accelerationX * self.gravityX, accelerationY * self.gravityY };
            [self.gravityBehavior setGravityDirection:gravityDirection];
            
        });
    }];
}

@end
