//
//  IsItChristmasViewController.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright 2009 Brandon Jones. All rights reserved.
//

#import "IsItChristmasViewController.h"
#import "IsItChristmasAppDelegate.h"
#import "IICDynamicLabel.h"

@implementation IsItChristmasViewController
static const int _kPadding = 10;
static const float _kGravity = 2.0f;
static const int _kMaxDynamicItems = 5;
static const int _kDynamicItemPadding = 50;

//load the view
- (void)loadView {
	
	[super loadView];
	
	//load the language dictionaries
	NSBundle *mainBundle = [NSBundle mainBundle];
	[self setLanguageYesDict:[mainBundle objectForInfoDictionaryKey:@"LANGUAGE_YES"]];
	[self setLanguageNoDict:[mainBundle objectForInfoDictionaryKey:@"LANGUAGE_NO"]];
	
	//get the languages array and get the selected language
	//the preferred language code is always the first item in the array
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self setLanguages:[defaults objectForKey:@"AppleLanguages"]];
	[self setSelectedLanguage:[self.languages objectAtIndex:0]];
	
	//get the country code
	NSString *currentLocale = [defaults objectForKey:@"AppleLocale"];
	[self setSelectedCountry:[currentLocale substringFromIndex:[currentLocale rangeOfString:@"_"].location+1]];
	
	//if the country code is canada, use the special language code
	if ([[self.selectedCountry uppercaseString] isEqualToString:@"CA"]) {
		[self setSelectedLanguage:@"ca"];
	}
}

//returns YES/NO as a string in the localized language
- (NSString *)isItChristmas {
    return [self isItChristmas:self.selectedLanguage];
}

//returns YES/NO as a string in the language requested
- (NSString *)isItChristmas:(NSString *)language {
	
	//we default to no
	BOOL isChristmas = NO;
	
	//get the current date
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
	
	//check to see if it is christmas
	if ([dateComponents month] == 12 && [dateComponents day] == 25) {
		isChristmas = YES;
	}
	
	//if the preferred language is in our list, return yes/no
	NSString *answer = (isChristmas) ? [self.languageYesDict objectForKey:language] : [self.languageNoDict objectForKey:language];
	if (answer) {
		return answer;
	}
	
	//if the selected language isn't in our list, return english
	return (isChristmas) ? @"YES" : @"NO";
}

//additional setup after loading the view
- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    //view background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
	
	//initialize the resultLabel and use the whole screen
	[self setResultLabel:[[UILabel alloc] initWithFrame:CGRectMake(_kPadding, _kPadding, self.view.frame.size.width - (_kPadding * 2), self.view.frame.size.height - (_kPadding * 2))]];
	
	//set the font, etc
	[self.resultLabel setFont:[UIFont fontWithName:@"ArialMT" size:180.0]];
	[self.resultLabel setAdjustsFontSizeToFitWidth:YES];
    [self.resultLabel setBackgroundColor:[UIColor clearColor]];
	[self.resultLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
	[self.resultLabel setTextAlignment:UITextAlignmentCenter];
	
	//add the results label to the screen
	[self.view addSubview:self.resultLabel];
	
	//set the result label for the first time
	//then every 5 seconds check to see if it is christmas
	[self setResultLabel];
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(setResultLabel) userInfo:nil repeats:YES];
    
    //uidynamics test
    [self setupDynamics];
}

- (void)setupDynamics {
    
    //check to see if UIDynamics is available (iOS 7+)
    //if it is not available, quit now
    if (!NSClassFromString(@"UIDynamicAnimator")) {
        return;
    }
    _dynamicsAvailable = YES;
    
    //setup the animator
    [self setAnimator:[[UIDynamicAnimator alloc] initWithReferenceView:self.view]];
    
    //create a dynamic view for each language
    NSMutableArray *dynamicViews = [[NSMutableArray alloc] initWithCapacity:self.languages.count];
    int test = 1;
    for (NSString *language in self.languages) {
        
        //create the label
        IICDynamicLabel *dynamicLabel = [[IICDynamicLabel alloc] initText:[self isItChristmas:language]];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //start detecting motion
    if (_dynamicsAvailable) {
        [self startMyMotionDetect];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //stop detecting motion
    if (_dynamicsAvailable) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

//this just sets the label test by calling isItChristmas
//this is in its own method so we can call in a timer every five seconds
- (void)setResultLabel {
	[self.resultLabel setText:[[self isItChristmas] uppercaseString]];
}

//allow all orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

//allow all orientations iOS 6+
- (NSUInteger)supportedInterfaceOrientations {
    //don't allow rotation for now while testing uidynamics
    return UIInterfaceOrientationMaskPortrait;
//    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown);
}

#pragma mark - core motion

//returns the maain motion manager from the app delegate
- (CMMotionManager *)motionManager {
    IsItChristmasAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.motionManager;
}

//updates the UIGravityBehavior based on the accelerometer
- (void)startMyMotionDetect {
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGVector gravityDirection = { data.acceleration.x * _kGravity, -data.acceleration.y * _kGravity };
            [self.gravity setGravityDirection:gravityDirection];
        });
    }];
    
}

@end
