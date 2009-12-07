//
//  IsItChristmasAppDelegate.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright Brandon Jones 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IsItChristmasViewController.h"

@interface IsItChristmasAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IsItChristmasViewController *iicController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) IsItChristmasViewController *iicController;

@end

