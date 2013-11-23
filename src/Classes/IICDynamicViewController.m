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
static const float _kGravity = 2.0f;
static const int _kMaxDynamicItems = 5;
static const int _kDynamicItemPadding = 50;

//additional setup after loading the view
- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    //setup dynamic views
    [self setupDynamics];
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
    
    //create a dynamic view for each language
    NSMutableArray *dynamicViews = [[NSMutableArray alloc] initWithCapacity:mainController.languages.count];
    int test = 1;
    for (NSString *language in mainController.languages) {
        
        //create the label
        IICDynamicLabel *dynamicLabel = [[IICDynamicLabel alloc] initText:[mainController isItChristmas:language]];
        [dynamicViews addObject:dynamicLabel];
        
        //add the view with a semi-random starting point
        float randomX = (arc4random() % ((int)self.view.frame.size.width - _kDynamicItemPadding)) + _kDynamicItemPadding;
        [dynamicLabel setCenter:CGPointMake(randomX, _kDynamicItemPadding)];
        [self.view insertSubview:dynamicLabel atIndex:0];
        NSLog(@"randomX: %f", randomX);
        
        //limit the total number of views for now
        if (++test > _kMaxDynamicItems) {
            break;
        }
    }
    
    //gravity
    [self setGravity:[[UIGravityBehavior alloc] initWithItems:dynamicViews]];
    [self.animator addBehavior:self.gravity];
    
    //collisions
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:dynamicViews];
    [collision setCollisionDelegate:self];
    [collision setTranslatesReferenceBoundsIntoBoundary:YES];
    [self.animator addBehavior:collision];
}

#pragma mark - core motion

//returns the maain motion manager from the app delegate
- (CMMotionManager *)motionManager {
    IsItChristmasAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.motionManager;
}

//updates the UIGravityBehavior based on the accelerometer
- (void)startMotionDetection {
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGVector gravityDirection = { data.acceleration.x * _kGravity, -data.acceleration.y * _kGravity };
            [self.gravity setGravityDirection:gravityDirection];
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
    [self.pushBehavior setPushDirection:CGVectorMake(-self.gravity.gravityDirection.dx * _kDampenAmount, -self.gravity.gravityDirection.dy * _kDampenAmount)];
    [self.pushBehavior addItem:item];
    [self.pushBehavior setActive:YES];
    [self.animator addBehavior:self.pushBehavior];
}

@end
