//
//  JLInputBar.m
//  chatInputBar
//
//  Created by li’s Air on 2018/6/15.
//  Copyright © 2018年 li’s Air. All rights reserved.
//

#import "JLTextContentView.h"

@interface JLTextContentView ()

@property (weak, nonatomic) id<JLTextContentViewDatasource> datasource;

@property (strong, nonatomic) JLTextView *textView;

@end

@implementation JLTextContentView

+ (instancetype)inputWiewWithDatasource:(id<JLTextContentViewDatasource>)datasource {
    JLTextContentView *v = [[JLTextContentView alloc] initWithFrame:CGRectZero];
    v.datasource = datasource;
    [v setup];
    return v;
}

- (void)setup {
    CGFloat oneLineHeight = [self textViewSingleLineHeight];
    NSUInteger lineNumber = 4;
    if (self.datasource && [self.datasource maximumLineOfTextContentView]) {
        lineNumber = [self.datasource maximumLineOfTextContentView];
    }
    CGFloat maxHeight = oneLineHeight * lineNumber;    
    
    CGFloat cornerRadius = 5;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5;
    self.backgroundColor = self.textView.backgroundColor;
    
    NSUInteger preferredHeight = 50;
    if (self.datasource && [self.datasource preferredHeightOfTextContentView]) {
        preferredHeight = [self.datasource preferredHeightOfTextContentView];
    }
    CGFloat topMargin = (preferredHeight - oneLineHeight) * 0.5;
    
    [self addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    // left
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0] setActive:YES];
    // right
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0] setActive:YES];
    // top
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:topMargin] setActive:YES];
    // bottom
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-topMargin] setActive:YES];
    // height
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:oneLineHeight] setActive:YES];
    // height great than
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:oneLineHeight] setActive:YES];
    // height less than
    [[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:maxHeight] setActive:YES];
    
    [self.textView associateConstraints];
}

- (CGFloat)textViewSingleLineHeight {
    UITextView *txv = self.textView;
    
    return (NSUInteger)(txv.font.lineHeight * 1000) / 1000.f;
}

- (JLTextView *)textView {
    if (!_textView) {
        JLTextView *txv = [[JLTextView alloc] init];
        UIFont *font = [UIFont systemFontOfSize:18];
        if (self.datasource && 
            [self.datasource respondsToSelector:@selector(textFontOfTextContentView)]) {
            font = [self.datasource textFontOfTextContentView];
        }
        txv.font = font;
        txv.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        txv.placeHolder = @"请输入内容";
        
        txv.textColor = [UIColor blackColor];
        txv.backgroundColor = [UIColor whiteColor];
        _textView = txv;
    }
    return _textView;
}

@end












