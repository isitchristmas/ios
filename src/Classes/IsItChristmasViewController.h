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
}

- (void)setResultLabel;

@property (nonatomic, strong) NSDictionary *languageYesDict;
@property (nonatomic, strong) NSDictionary *languageNoDict;
@property (nonatomic, strong) NSString *selectedLanguage;
@property (nonatomic, strong) NSString *selectedCountry;
@property (nonatomic, strong) UILabel *resultLabel;

@end
