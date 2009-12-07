//
//  IsItChristmasViewController.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright 2009 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IsItChristmasViewController : UIViewController {
	NSDictionary *languageYesDict;
	NSDictionary *languageNoDict;
	NSString *selectedLanguage;
	NSString *selectedCountry;
	UILabel *resultLabel;
	CGRect portraitFrame;
	CGRect landscapeFrame;
}

- (void)setResultLabel;

@property (nonatomic, retain) NSDictionary *languageYesDict;
@property (nonatomic, retain) NSDictionary *languageNoDict;
@property (nonatomic, retain) NSString *selectedLanguage;
@property (nonatomic, retain) NSString *selectedCountry;
@property (nonatomic, retain) UILabel *resultLabel;
@property (nonatomic) CGRect portraitFrame;
@property (nonatomic) CGRect landscapeFrame;

@end
