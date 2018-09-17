//
//  CYNavigationController.m
//
//  Created by Candy on 2018/9/17.
//  Copyright © 2018年 Candy. All rights reserved.
//

#import "CYNavigationController.h"

#define S_WIDTH [UIScreen mainScreen].bounds.size.width
#define S_HEIGHT [UIScreen mainScreen].bounds.size.height
#define K_WINDOW [[UIApplication sharedApplication] keyWindow]

#define TOUCH_DISTANCE  150

@interface CYNavigationController ()

@property (nonatomic , strong) NSMutableArray * snapArray;
@property (nonatomic , assign) CGPoint  startPoint;
@property (nonatomic , strong) UIView * backgroundView;
@property (nonatomic , strong) UIView *blackMask;
@property (nonatomic , strong) UIImageView * lastScreenShotImageView;
@property (nonatomic , assign) BOOL isMoving;

@property (nonatomic, strong) UIView *lastView;

@end

@implementation CYNavigationController

- (UIView *)lastView
{
    if (!_lastView) {
        NSArray *theViewSubviews = [UIApplication sharedApplication].keyWindow.subviews;
        
        UIView *tmpView = nil;
        for (UIView *theView in theViewSubviews) {
            if ([theView isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
                tmpView = theView;
                break;
            } else if ([theView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
                tmpView = [theView.subviews lastObject];
                break;
            }
        }
        
        _lastView = tmpView;
    }

    return _lastView;
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        self.snapArray = [NSMutableArray arrayWithCapacity:2];
        self.canDragBack = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanGestureRecognizer:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    if (self.snapArray.count == 0) {
        UIImage *capturedImage = [self capture];
        [self.snapArray addObject:capturedImage];
    }
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIImage *snapImage = [self capture];
    if (snapImage) {
        [self.snapArray addObject:snapImage];
    }
    if (self.viewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController* )popViewControllerAnimated:(BOOL)animated{
    [self.snapArray removeLastObject];
    return [super popViewControllerAnimated:animated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.viewControllers.count <= 1
        || !self.canDragBack) {
        return NO;
    }

    return self.canDragBack;
}

-(void)didPanGestureRecognizer:(UIPanGestureRecognizer*)pan
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    CGPoint touchPoint = [pan locationInView:K_WINDOW];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.startPoint = touchPoint;
        _isMoving = YES;
        [self addSnapView];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        if (touchPoint.x - self.startPoint.x>TOUCH_DISTANCE) {
            [UIView animateWithDuration:0.3 animations:^{
                [self doMoveViewWithX:S_WIDTH];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                [self popViewControllerAnimated:NO];
                CGRect frame = [self lastView].frame;
                frame.origin.x = 0;
                [self lastView].frame = frame;
                self.backgroundView.hidden = YES;
            }];
        }else {
            [UIView animateWithDuration:0.3 animations:^{
                [self doMoveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;
    }else if (pan.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.3 animations:^{
            [self doMoveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        return;
    }
    if (_isMoving) {
        [self doMoveViewWithX:touchPoint.x - self.startPoint.x];
    }
}

-(void)addSnapView
{
    if (!self.backgroundView)
    {
        self.backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        
        [[self lastView].superview insertSubview:self.backgroundView belowSubview:[self lastView]];
        self.blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, S_WIDTH , S_HEIGHT)];
        self.blackMask.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:self.blackMask];
    }
    
    self.backgroundView.hidden = NO;
    if (self.lastScreenShotImageView) { [self.lastScreenShotImageView removeFromSuperview]; }
    UIImage *lastScreenShot = [self.snapArray lastObject];
    self.lastScreenShotImageView = [[UIImageView alloc] initWithImage:lastScreenShot];
    self.lastScreenShotImageView.frame = CGRectMake(0, 0, S_WIDTH,S_HEIGHT);
    [self.backgroundView insertSubview:self.lastScreenShotImageView belowSubview:self.blackMask];
}

- (UIImage *)capture
{
    UIWindow* screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage =UIGraphicsGetImageFromCurrentImageContext();
    
    return viewImage;
}

-(void)doMoveViewWithX:(CGFloat)x
{
    x = x > S_WIDTH ? S_WIDTH : x;
    x = x< 0 ? 0 : x;
    CGRect frame = [self lastView].frame;
    frame.origin.x = x;
    [self lastView].frame = frame;
    switch (_popAnimationType) {
        case 0:
            [self animateionFromBehind:x];
            break;
        case 1:
            [self animationLiner:x];
            break;
        default:
            break;
    }
}

-(void)animateionFromBehind:(CGFloat)x
{
    float coefficient = S_WIDTH * 25;
    float scale = (x/coefficient) + 0.96;
    float alpha = 0.4 - (x / 800);
    _lastScreenShotImageView.transform = CGAffineTransformMakeScale(scale, scale);
    _blackMask.alpha = alpha;
}

-(void)animationLiner:(CGFloat)x
{
    float coefficient = x/2;
    CGRect screenShotImageViewFrame = _lastScreenShotImageView.frame;
    screenShotImageViewFrame.origin.x = - S_WIDTH / 2 + coefficient;
    _lastScreenShotImageView.frame = screenShotImageViewFrame;
    _blackMask.alpha = 0.3;
}

- (void)dealloc
{
    self.snapArray = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

@end
