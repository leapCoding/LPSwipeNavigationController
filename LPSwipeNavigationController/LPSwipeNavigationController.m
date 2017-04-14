//
//  LPSwipeNavigationController.m
//  LPSwipeNavigationController
//
//  Created by lipeng on 2017/4/13.
//  Copyright © 2017年 leap.com. All rights reserved.
//

#import "LPSwipeNavigationController.h"

static const CGFloat buttonHeight = 30.f;
static const CGFloat sliderViewHeight = 3.f;

@interface LPSwipeNavigationController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *itemsController;
@property (nonatomic, strong) NSMutableArray *itemsButton;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic) BOOL isPageScrollingFlag; //prevents scrolling / segment tap crash
@property (nonatomic) BOOL hasAppearedFlag; //prevents reloading (maintains state)
@end

@implementation LPSwipeNavigationController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers items:(NSArray *)items {
    self = [super initWithRootViewController:self.pageViewController];
    if (self) {
        _itemsController = viewControllers;
        [self.pageViewController setViewControllers:@[[viewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        _itemsTitle = items;
        [self syncScrollView];
        [self defaultUITheme];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    if (!self.hasAppearedFlag) {
        [self setupSegmentButtons];
        self.hasAppearedFlag = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
}

#pragma mark - 默认主题设置
- (void)defaultUITheme {
    _itemFont = [UIFont systemFontOfSize:15];
    _itemColor = [UIColor blackColor];
    _itemSelectedFont = [UIFont systemFontOfSize:20];
    _itemSelectedColor = [UIColor greenColor];
    _sliderColor = [UIColor greenColor];
    _titleViewWidth = self.view.frame.size.width-20;
}

#pragma mark - UI

- (void)setupSegmentButtons {
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0,0,_titleViewWidth,self.navigationBar.frame.size.height)];
    NSInteger numControllers = [_itemsController count];
    NSAssert(_itemsTitle, @"_items不能为空");
    _itemsButton = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSInteger i = 0; i < numControllers; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(i * (_titleViewWidth / numControllers), self.navigationBar.frame.size.height - buttonHeight, _titleViewWidth / numControllers, buttonHeight)];
        button.tag = i;
        [button setTitle:_itemsTitle[i] forState:UIControlStateNormal];
        [button setTitleColor:_itemColor forState:UIControlStateNormal];
        [button setTitleColor:_itemSelectedColor forState:UIControlStateSelected];
        button.titleLabel.font = _itemFont;
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:button];
        [_itemsButton addObject:button];
        if (i == 0) {
            button.selected = YES;
        }
    }
    self.pageViewController.navigationItem.titleView = titleView;
    
    //setupSliderView
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height - sliderViewHeight, _titleViewWidth / numControllers, sliderViewHeight)];
    _sliderView.backgroundColor = _sliderColor;
    _sliderView.alpha = 0.8;
    [titleView addSubview:_sliderView];
    
    [self updateCurrentPageIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_itemsController indexOfObject:viewController];
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    index--;
    return [_itemsController objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    NSInteger index = [_itemsController indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == _itemsController.count) {
        return nil;
    }
    return [_itemsController objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self updateCurrentPageIndex:[_itemsController indexOfObject:[pageViewController.viewControllers lastObject]]];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
}

#pragma mark - private method

-(void)tapSegmentButtonAction:(UIButton *)button {
    if (!self.isPageScrollingFlag) {
        NSInteger tempIndex = self.currentPageIndex;
        __weak typeof(self) weakSelf = self;
        if (button.tag > tempIndex) {
            for (NSInteger i = tempIndex + 1; i <= button.tag; i++) {
                [self.pageViewController setViewControllers:@[_itemsController[i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }else if (button.tag < tempIndex) {
            for (NSInteger i = tempIndex - 1; i >= button.tag; i--) {
                [self.pageViewController setViewControllers:@[_itemsController[i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
}

- (void)setupSelectButton {
    for (UIButton *button in _itemsButton) {
        if (button.tag == _currentPageIndex) {
            button.selected = YES;
            button.titleLabel.font = _itemSelectedFont;
        }else {
            button.selected = NO;
            button.titleLabel.font = _itemFont;
        }
    }
}

-(void)updateCurrentPageIndex:(NSInteger)newIndex {
    self.currentPageIndex = newIndex;
    [self setupSelectButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat xFromCenter = self.view.frame.size.width-scrollView.contentOffset.x;
    NSInteger xCoor = _titleViewWidth/_itemsController.count * self.currentPageIndex;
    
    _sliderView.frame = CGRectMake(xCoor - (xFromCenter/self.view.frame.size.width)*(_titleViewWidth/_itemsController.count), _sliderView.frame.origin.y, _sliderView.frame.size.width, _sliderView.frame.size.height);
}

//获取pageViewController上的UIScrollView
-(void)syncScrollView {
    for (UIView* view in self.pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

#pragma mark - property

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        pageController.delegate = self;
        pageController.dataSource = self;
        _pageViewController = pageController;
    }
    return _pageViewController;
}

@end
