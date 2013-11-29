//
//  IICDynamicView.m
//  IsItChristmas
//
//  Created by Brandon Jones on 11/28/13.
//
//

#import "IICDynamicView.h"

@implementation IICDynamicView

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    //notify the delegate of the shake
    if (event.subtype == UIEventSubtypeMotionShake) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewDidShake)]) {
            [self.delegate viewDidShake];
        }
    }

    //call super
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
