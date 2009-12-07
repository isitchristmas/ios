//
//  IsItChristmasAppDelegate.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright Brandon Jones 2009. All rights reserved.
//

#import "IsItChristmasAppDelegate.h"

@implementation IsItChristmasAppDelegate
@synthesize window, iicController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {   
	
	//setup the main view controller
	IsItChristmasViewController *tmpController = [[IsItChristmasViewController alloc] init];
	self.iicController = tmpController;
	[tmpController release];
	
	//add the view controller to the window
	[self.window addSubview:self.iicController.view];

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)dealloc {
	[self.iicController release];
    [self.window release];
    [super dealloc];
}

@end
