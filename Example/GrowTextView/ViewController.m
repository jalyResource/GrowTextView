//
//  ViewController.m
//  chatInputBar
//
//  Created by li’s Air on 2018/6/15.
//  Copyright © 2018年 li’s Air. All rights reserved.
/*
 输入框高度自适应方案
    1、控制器里设置高度 JSQ master 分支有bug
    2、自定义textView,在内部控制，JSQ dev 分支，没什么bug
*/

#import "ViewController.h"
#import "JLTextContentView.h"


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface ViewController ()<JLTextContentViewDatasource>

@property (weak, nonatomic) IBOutlet UIView *inputBar;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) JLTextContentView *textContentView;
@property (strong, nonatomic) NSLayoutConstraint *consInputBarBottom;

@property (assign, nonatomic) BOOL isAddKVO;
@property (assign, nonatomic) CGFloat heightSystemKeyboard;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _textContentView = [JLTextContentView inputWiewWithDatasource:self];
    [self.inputBar addSubview:_textContentView];
    
    __weak typeof(self) ws = self;
    NSLog(@"textView:%@", self.textContentView.textView);
//    
    self.textContentView.textView.heightChangeBlock = ^{
        [ws.view layoutIfNeeded];
    };
    
    
    [self addConstraints];
    [self addNotification:YES];
    
}

- (void)dealloc {
    [self addNotification:NO];
}

#pragma -mark event response

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    if (! self.textContentView.textView.isFirstResponder)  return;
    
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat offY = SCREEN_HEIGHT - endRect.origin.y;
    if (self.heightSystemKeyboard == offY)
        return;
    
    self.heightSystemKeyboard = offY;
    
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat animationCurveOption = (animationCurve << 16);
    
    self.consInputBarBottom.constant = -offY;
    [UIView animateWithDuration:duration delay:0 options:animationCurveOption animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma -mark JLInputViewDelegate

/**
 输入框字体，默认 18
 */
- (UIFont *)textFontOfTextContentView {
    return [UIFont systemFontOfSize:16];
}

/**
 无文本状态下输入框的高度，默认 50
 */
- (NSUInteger)preferredHeightOfTextContentView {
    return 32;
}
/**
 输入框最多显示行数，默认 4
 */
- (NSUInteger)maximumLineOfTextContentView {
    return 4;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    NSLog(@"contentSize:%@", NSStringFromCGSize(self.textContentView.textView.contentSize));
}


#pragma -mark private

- (void)addConstraints {
    self.textContentView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *txvSuper = self.textContentView.superview;
    
    [NSLayoutConstraint constraintWithItem:self.textContentView
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:txvSuper
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1
                                  constant:10].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textContentView
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:txvSuper
                                 attribute:NSLayoutAttributeRight
                                multiplier:1
                                  constant:-10].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textContentView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:txvSuper
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:-8].active = YES;
    [NSLayoutConstraint constraintWithItem:self.textContentView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:txvSuper
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:8].active = YES;
    
    
    self.inputBar.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.inputBar
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.inputBar.superview
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1
                                  constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.inputBar
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.inputBar.superview
                                 attribute:NSLayoutAttributeRight
                                multiplier:1
                                  constant:0].active = YES;
    self.consInputBarBottom = [NSLayoutConstraint constraintWithItem:self.inputBar
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.inputBar.superview
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:0];
    self.consInputBarBottom.active = YES;
}

- (void)addNotification:(BOOL)isAdd {
    if (isAdd) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}


@end
