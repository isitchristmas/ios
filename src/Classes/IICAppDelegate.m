//
//  IICAppDelegate.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright Brandon Jones 2009. All rights reserved.
//

#import "IICAppDelegate.h"

@implementation IICAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //setup analytics
    [self setupAnalytics];
    
    //setup the window
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [self.window makeKeyAndVisible];
    
    //setup the main view controller
	[self setIicController:[[IICMainViewController alloc] init]];
    [self.window setRootViewController:self.iicController];
	
	//make sure defaults are set
	[self setupDefaults];
    
    return YES;
}

- (void)setupAnalytics {
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    [[GAI sharedInstance] setDispatchInterval:20];
    #if DEBUG
    [[GAI sharedInstance] setDryRun:YES];
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    #endif
    [self setTracker:[[GAI sharedInstance] trackerWithTrackingId:@"UA-252618-15"]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
	//setup the local notifications in the background
	[[NSUserDefaults standardUserDefaults] synchronize];
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(scheduleLocalNotification:)]) {
		[self performSelectorInBackground:@selector(setupNotifications) withObject:nil];
	}
    
}

- (void)setupNotifications {
	
	//this is running on a background thread so it needs its own autorelease pool
	@autoreleasepool {
	
        //cancel all previously scheduled notifications
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		
		//get user settings
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL notifyDecember = [defaults boolForKey:@"notify_december"];
		BOOL notifyChristmas = [defaults boolForKey:@"notify_christmas"];
		int timeDecember = [defaults integerForKey:@"notify_december_time"];
		int timeChristmas = [defaults integerForKey:@"notify_christmas_time"];
		
		//if no notifications are enabled, return now
		if (!notifyChristmas && !notifyDecember) {
			return;
		}

		//setup the calendar and get the current year
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDate *now = [NSDate date];
		NSDateComponents *currentComponents = [calendar components:NSYearCalendarUnit fromDate:now];
		NSInteger currentYear = [currentComponents year];
		
		//schedule daily notifications
		for (int day = 1; day <= 31; day++) {
			
			//if notifications are off for this day, skip it
			if (day == 25 && !notifyChristmas) {
				continue;
			} else if (day != 25 && !notifyDecember) {
				continue;
			}
			
			//set the date/time for the notification
			NSDateComponents *components = [[NSDateComponents alloc] init];
			[components setDay:day];
			[components setMonth:12];
			[components setYear:currentYear];
			[components setHour:(day == 25) ? timeChristmas : timeDecember];
			[components setMinute:0];
			NSDate *fireDate = [calendar dateFromComponents:components];
			
			//setup the notification
			UILocalNotification *notification = [[NSClassFromString(@"UILocalNotification") alloc] init];
			[notification setFireDate:fireDate];
			[notification setTimeZone:[NSTimeZone defaultTimeZone]];
			[notification setAlertAction:@"View"];
			[notification setSoundName:UILocalNotificationDefaultSoundName];
			[notification setApplicationIconBadgeNumber:0];
			[notification setAlertBody:(day == 25) ? @"YES" : @"NO"];

			//schedule notification for this year if it is in the future
			if (fireDate == [fireDate laterDate:now]) {
				[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			}
			
			//schedule notification for next year
			[components setYear:currentYear+1];
			fireDate = [calendar dateFromComponents:components];
			[notification setFireDate:fireDate];
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
		}
        
	}
    
}

//make sure that the default settings are actually set
- (void)setupDefaults {
	
    //get the plist location from the settings bundle
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistPath = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
	
    //get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
	
    //use the shared defaults object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
    //for each preference item, set its default if there is no value set
    for(NSDictionary *item in preferencesArray) {
		
        //get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key) {
			
            //check to see if the value and default value are set
            //if a default value exists and the value is not set, use the default
            id value = [defaults objectForKey:key];
            id defaultValue = [item objectForKey:@"DefaultValue"];
            if(defaultValue && !value) {
                [defaults setObject:defaultValue forKey:key];
            }
        }
    }
	
    //write the changes to disk
    [defaults synchronize];
}

#pragma mark - core motion

//shared motion manager
- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

@end
