//
//  IICDynamicLabel.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/23/13.
//
//

#import "IICDynamicLabel.h"

@implementation IICDynamicLabel

- (id)initText:(NSString *)text {
    self = [super init];
    if (self) {
        
        //setup the label with some defaults, set the text, and auto resize
        [self setFont:[IICDynamicLabel font]];
        [self setTextColor:[IICDynamicLabel textColor]];
        [self setBackgroundColor:[IICDynamicLabel backgroundColor]];
        [self setAdjustsFontSizeToFitWidth:YES];
        [self setText:text];
        [self sizeToFit];
        
    }
    return self;
}

+ (UIFont *)font {
    static UIFont *font = nil;
    if (!font) font = [UIFont fontWithName:@"ArialMT" size:20.0f];
    return font;
}

+ (UIColor *)textColor {
    static UIColor *color = nil;
    if (!color) color = [UIColor lightGrayColor];
    return color;
}

+ (UIColor *)backgroundColor {
    static UIColor *color = nil;
    if (!color) color = [UIColor whiteColor];
    return color;
}

@end
