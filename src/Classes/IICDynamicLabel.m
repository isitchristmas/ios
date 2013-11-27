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
        [self setAutoresizingMask:UIViewAutoresizingNone];
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
    if (!font) {
        //adjust font size based on the device
        float fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0f : 30.0f;
        font = [UIFont fontWithName:@"ArialMT" size:fontSize];
    }
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
