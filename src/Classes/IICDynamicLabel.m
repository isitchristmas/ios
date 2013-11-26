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
        [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin];
        [self setFont:[IICDynamicLabel font]];
        [self setTextColor:[IICDynamicLabel textColor]];
        [self setBackgroundColor:[IICDynamicLabel backgroundColor]];
        [self setText:text];
        [self sizeToFit];
        
    }
    return self;
}

+ (UIFont *)font {
    static UIFont *font = nil;
    if (!font) font = [UIFont fontWithName:@"ArialMT" size:30.0f];
    return font;
}

+ (UIColor *)textColor {
    static UIColor *color = nil;
    if (!color) color = [UIColor colorWithWhite:0.8f alpha:1.0f];
    return color;
}

+ (UIColor *)backgroundColor {
    static UIColor *color = nil;
    if (!color) color = [UIColor whiteColor];
    return color;
}

@end
