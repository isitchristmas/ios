//
//  IICMainViewController.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/21/09.
//  Copyright 2009 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IICDynamicViewController.h"

@interface IICMainViewController : UIViewController

- (void)setResultLabel;
- (NSString *)isItChristmas;
- (NSString *)isItChristmas:(NSString *)language;

@property (nonatomic, strong) NSDictionary *languageYesDict;
@property (nonatomic, strong) NSDictionary *languageNoDict;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *selectedLanguage;
@property (nonatomic, strong) NSString *selectedCountry;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) IICDynamicViewController *dynamicViewController;

@end
