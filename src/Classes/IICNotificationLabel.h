//
//  IICNotificationLabel.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/27/13.
//
//

#import <UIKit/UIKit.h>

@interface IICNotificationLabel : UILabel

- (id)initWithFrame:(CGRect)frame text:(NSString *)initialText;
- (void)setText:(NSString *)text animate:(BOOL)animate;

@end
