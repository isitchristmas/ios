//
//  IICDynamicLabel.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import <UIKit/UIKit.h>

@interface IICDynamicLabel : UILabel

- (id)initText:(NSString *)text;
+ (UIFont *)font;
+ (UIColor *)textColor;
+ (UIColor *)backgroundColor;

@end
