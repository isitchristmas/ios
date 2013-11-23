//
//  IsItChristmasViewController.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright 2009 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface IsItChristmasViewController : UIViewController <UICollisionBehaviorDelegate> {
    BOOL _dynamicsAvailable;
}

- (void)setResultLabel;

@property (nonatomic, strong) NSDictionary *languageYesDict;
@property (nonatomic, strong) NSDictionary *languageNoDict;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *selectedLanguage;
@property (nonatomic, strong) NSString *selectedCountry;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

@end
