//
//  IICDynamicView.h
//  IsItChristmas
//
//  Created by Brandon Jones on 11/28/13.
//
//

#import <UIKit/UIKit.h>

@protocol IICDynamicViewProtocol <NSObject>
@optional
- (void)viewDidShake;
@end

@interface IICDynamicView : UIView
@property (nonatomic, weak) NSObject <IICDynamicViewProtocol>*delegate;
@end
