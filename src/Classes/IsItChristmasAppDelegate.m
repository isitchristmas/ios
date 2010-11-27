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
	
	//make sure defaults are set
	[self setupDefaults];
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
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
	NSDateComponents *currentComponents = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
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
		[components setMinute:00];
		NSDate *itemDate = [calendar dateFromComponents:components];
		
		//setup the notification
		UILocalNotification *notification = [[NSClassFromString(@"UILocalNotification") alloc] init];
		notification.fireDate = itemDate;
		notification.timeZone = [NSTimeZone defaultTimeZone];
		notification.alertAction = @"View";
		notification.soundName = UILocalNotificationDefaultSoundName;
		notification.applicationIconBadgeNumber = 0;
		notification.alertBody = (day == 25) ? @"YES" : @"NO";

		//schedule notification for this year
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
		//schedule notification for next year
		[components setYear:currentYear+1];
		itemDate = [calendar dateFromComponents:components];
		notification.fireDate = itemDate;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
		//clean up
		[notification release];
		[components release];
	}

	//clean up
	[calendar release];
	[pool release];
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

- (void)dealloc {
	[self.iicController release];
	[self.window release];
	[super dealloc];
}

@end
