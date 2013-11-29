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
#import <QuartzCore/QuartzCore.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation IICDynamicViewController

static const float _kElasticityDefault = 0.8f;
static const float _kElasticityMin = 0.009f;  //must be greater than zero
static const float _kElasticityMax = 1.0f;
static const float _kGravityAmount = 2.0f;
static const int _kItemCountMin = 0;
static const int _kItemCountDefault = 5;
static const int _kItemCountMax = 10;
static NSString *_kElasticityFormat = @"Elasticity: %i%%";

- (void)loadView {
    [super loadView];
    
    //use the custom view class
    if (![self.view isKindOfClass:[IICDynamicView class]]) {
        [self setView:[[IICDynamicView alloc] initWithFrame:self.view.frame]];
        [(IICDynamicView *)self.view setDelegate:self];
    }
    
    //start hidden
    [self.view setAlpha:0.0f];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //setup the interface for the initial orientation
    //if the user starts upside down, the dynamic labels will appear
    [self updateInterfaceForCurrentOrientation];
    
    //swipe gestures for adjusting the number of items
    //unfortunately, a gesture must be added for each supported direction instead of a single recognizer for all directions
    //add these to the superview do that they work even when the dynamic interface is disabled
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view.superview addGestureRecognizer:swipeGestureUp];
    [self.view.superview addGestureRecognizer:swipeGestureDown];
    [self.view.superview addGestureRecognizer:swipeGestureLeft];
    [self.view.superview addGestureRecognizer:swipeGestureRight];
    
    //toggle the dynamic interface when the user taps the screen
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDynamicInterface)];
    [self.view.superview addGestureRecognizer:tapGesture];
    
    //toggle the dynamic interface when the user long presses the screen
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view.superview addGestureRecognizer:longPressGesture];
    
    //track view with analytics
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Dynamic View"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

#pragma mark - answers

//updates all of the dynamic views with a random answer
- (void)updateAnswers {
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //update the label text and size
                         for (IICDynamicLabel *label in self.dynamicItems) {
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

#pragma mark - dynamic interface

//toggles the dynamic interface on/off
- (void)toggleDynamicInterface {
    [self enableDynamicInterface:(self.view.alpha == 0.0f)];
}

- (void)setupDynamics {
    
    //setup the elasticity label if needed
    if (!self.elasticityLabel) {
        [self setElasticityLabel:[[IICNotificationLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.5f) text:[NSString stringWithFormat:_kElasticityFormat, 100]]];
        [self.elasticityLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y - (self.view.center.y * 0.5f))];
        [self.view addSubview:self.elasticityLabel];
    }
    
    //setup the animator
    [self setAnimator:[[UIDynamicAnimator alloc] initWithReferenceView:self.view]];
    
    //gravity
    [self setGravityBehavior:[[UIGravityBehavior alloc] init]];
    
    //collisions
    [self setCollisionBehavior:[[UICollisionBehavior alloc] init]];
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundary:YES];
    
    //item behavior
    [self setItemBehavior:[[UIDynamicItemBehavior alloc] init]];
    [self.itemBehavior setElasticity:_kElasticityDefault];
    [self.itemBehavior setAngularResistance:0.1f];
    [self.itemBehavior setDensity:500.0f];
    [self.itemBehavior setFriction:0.0f];
    [self.itemBehavior setResistance:0.0f];
    
    //pinch recognizer for adjusting the elasticity
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    
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

- (void)enableDynamicInterface:(BOOL)enable {
    
    //setup dynamic items if needed
    if (enable && !self.animator) {
        [self setupDynamics];
    }
    
    //if the animator doesn't exist, quit now
    if (!self.animator) {
        return;
    }
    
    //show the view when enabled
    float opacity = (enable) ? 1.0f : 0.0f;
    
    //update the gravity
    [self setGravityForOrientation:self.interfaceOrientation];
    
    //create dynamic items if none currently exist
    if (enable && (!self.dynamicItems || self.dynamicItems.count == 0)) {
        for (int index = 1; index <= _kItemCountDefault; index++) {
            [self addItem];
        }
    }
    
    //if the view will be visible after the animation
    //add the behaviors
    //start detecting motion
    if (enable) {
        [self addBehaviors];
        [self startMotionDetection];
    }
    
    //animate the view opacity
    //remove the behaviors if needed
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //animate the opacity
                         [self.view setAlpha:opacity];
                         
                     }
                     completion:^(BOOL finished){
                         
                         //view will be invisible
                         //remove behaviors
                         //stop detecting motion
                         if (!enable) {
                             [self removeBehaviors];
                             [self.motionManager stopAccelerometerUpdates];
                         }
                         
                         //fix any views that got pushed off the screen
                         [self fixRogueViews];
                         
                     }];
    
    //track when dynamic interface is enabled or disabled with analytics
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"  // Event category (required)
                                                          action:@"enableDynamicInterface"          // Event action (required)
                                                           label:(enable) ? @"true" : @"false"      // Event label
                                                           value:nil] build]];                      // Event value
    
}

//adds a new item to the view and to the array of dynamic items
- (void)addItem {
    
    //setup array if needed
    if (!self.dynamicItems) {
        [self setDynamicItems:[[NSMutableArray alloc] initWithCapacity:_kItemCountMax]];
    }
    
    //don't exceed the max
    if (self.dynamicItems.count >= _kItemCountMax) {
        return;
    }
    
    //create the label
    IICDynamicLabel *dynamicLabel = [[IICDynamicLabel alloc] initText:[self randomAnswer]];
    [self.dynamicItems addObject:dynamicLabel];
    
    //add the views to the center of the view
    [dynamicLabel setCenter:self.view.center];
    [self.view insertSubview:dynamicLabel belowSubview:self.elasticityLabel];
    
    //add dynamic behaviors
    [self.gravityBehavior addItem:dynamicLabel];
    [self.collisionBehavior addItem:dynamicLabel];
    [self.itemBehavior addItem:dynamicLabel];
    
}

//removes a dynamic item from the view and the array of items
- (void)removeItem {
    
    //don't drop below the minimum
    if (!self.dynamicItems || self.dynamicItems.count <= _kItemCountMin) {
        return;
    }
    
    //remove the last view
    UIView *lastView = [self.dynamicItems lastObject];
    if (lastView) {
        
        //animate the opacity then remove the item
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             //fade away
                             [lastView setAlpha:0.0f];
                             
                         }
                         completion:^(BOOL finished){
                             
                             //remove dynamic behaviors
                             [self.gravityBehavior removeItem:lastView];
                             [self.collisionBehavior removeItem:lastView];
                             [self.itemBehavior removeItem:lastView];
                             
                             //remove from the view and the array
                             [lastView removeFromSuperview];
                             [self.dynamicItems removeObject:lastView];
                             
                         }];
        
    }
    
}

//check to see if any of the dynamic views got pushed out of the main view
//if so, reset it
- (void)fixRogueViews {
    for (UIView *view in self.dynamicItems) {
        if (!CGRectContainsPoint(self.view.frame, view.center)) {
            [view setCenter:self.view.center];
        }
    }
}

#pragma mark - UIPinchGestureRecognizer

//update the dynamic item eleasticity
- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    
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
    //update the item
    [self.itemBehavior setElasticity:newElasticity];
    [self.elasticityLabel setText:[NSString stringWithFormat:_kElasticityFormat, (int)(newElasticity * 100)]];
    
}

#pragma mark - UISwipeGestureRecognizer

//increase or descrease the number of dynamic items
- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    
    //if the dynamic interface is not currently enabled, enable it
    if (self.view.alpha <= 0.0f) {
        [self enableDynamicInterface:YES];
        return;
    }
    
    switch (gesture.direction) {
            
        //add item
        case UISwipeGestureRecognizerDirectionUp:
        case UISwipeGestureRecognizerDirectionRight:
            [self addItem];
            break;
            
        //remove item
        case UISwipeGestureRecognizerDirectionDown:
        case UISwipeGestureRecognizerDirectionLeft:
            [self removeItem];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UILongPressGestureRecognizer

//toggle the dynamic interface for a long press
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self toggleDynamicInterface];
    }
}

#pragma mark - rotation

- (NSUInteger)supportedInterfaceOrientations {
    
    //if dynamic interface is already enabled or orientation is upside down
    //don't allow landscape
    if ((self.view.alpha >= 1.0f || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    //the dynamic interface is not enabled
    //allow any rotations
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown);
    
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateInterfaceForCurrentOrientation];
}

- (void)updateInterfaceForCurrentOrientation {
    
    //enable the dynamic interface when upside down
    [self enableDynamicInterface:(self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)];

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

#pragma mark - IICDynamicViewProtocol

//toggle the dynamic interface when the user shakes the device
- (void)viewDidShake {
    [self toggleDynamicInterface];
}

@end
