//
//  LPSwipeNavigationController.h
//  LPSwipeNavigationController
//
//  Created by lipeng on 2017/4/13.
//  Copyright © 2017年 leap.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPSwipeNavigationController : UINavigationController

@property (nonatomic, strong) NSArray *itemsTitle;
@property (nonatomic, assign) CGFloat titleViewWidth;//导航栏titleview的宽度，默认屏幕宽度
// All the item's text color of the normal state
@property (strong, nonatomic) UIColor *itemColor;

@property (strong, nonatomic) UIFont *itemFont;

// The selected item's text color
@property (strong, nonatomic) UIColor *itemSelectedColor;

@property (strong, nonatomic) UIFont *itemSelectedFont;

@property (strong, nonatomic) UIColor *sliderColor;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers items:(NSArray *)items;

@end
