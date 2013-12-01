//
//  IICNotificationLabel.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/27/13.
//
//

#import "IICNotificationLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation IICNotificationLabel

static float _kPadding = 10.0f;
static float _kFontSize = 25.0f;

- (id)initWithFrame:(CGRect)frame text:(NSString *)initialText
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //adjust the font size and padding for the iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _kFontSize = 30.0f;
            _kPadding = 20.0f;
        }

        //setup the label
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
        [self setFont:[UIFont fontWithName:@"ArialMT" size:_kFontSize]];
        [self setAdjustsFontSizeToFitWidth:YES];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setTextColor:[UIColor colorWithWhite:0.6f alpha:0.5f]];
        [self setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:0.5f]];
        [self setAlpha:0.0f];
        [self setText:initialText animate:NO];
        [self sizeToFit];
        [self setFrame:CGRectMake(self.frame.origin.x - (_kPadding * 4) , self.frame.origin.y - _kPadding, self.frame.size.width + (_kPadding * 4), self.frame.size.height + (_kPadding * 2))];
        [self.layer setCornerRadius:roundf(self.frame.size.height / 6)];
        
    }
    return self;
}

//animate the updating of text by default
- (void)setText:(NSString *)text {
    [self setText:text animate:YES];
}

- (void)setText:(NSString *)text animate:(BOOL)animate {
    [super setText:[text uppercaseString]];
    
    //quit here if not animating
    if (!animate) {
        return;
    }
    
    //fade the label in / out
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         //fade in
                         [self setAlpha:1.0f];
                         
                     }
                     completion:^(BOOL finished){
                         
                         //fade out
                         if (finished) {
                             [UIView animateWithDuration:0.3f
                                                   delay:1.0f
                                                 options: UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  
                                                  //fade out
                                                  [self setAlpha:0.0f];
                                                  
                                              }
                                              completion:nil];
                         }
                         
                     }];
}

@end
