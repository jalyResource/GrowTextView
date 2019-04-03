//
//  JLTextView.m
//  chatInputBar
//
//  Created by li’s Air on 2018/6/15.
//  Copyright © 2018年 li’s Air. All rights reserved.
//

#import "JLTextView.h"


@interface JLTextView ()

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;

@end

@implementation JLTextView

#pragma mark - Initialization

- (void)jl_configureTextView
{
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    _placeHolder = nil;
    _placeHolderTextColor = [UIColor lightGrayColor];
    UIEdgeInsets textContainerInset = self.textContainerInset;
    textContainerInset.left += 3;
    _placeHolderInsets = textContainerInset;
    
    
    [self jl_addTextViewNotificationObservers];
    
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self jl_configureTextView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self jl_configureTextView];
}

- (void)dealloc
{
    [self jl_removeTextViewNotificationObservers];
}

// TODO: we should just set these from the xib
- (void)associateConstraints
{
    // iterate through all text view's constraints and identify
    // height, max height and min height constraints.
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
                self.maxHeightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
                self.minHeightConstraint = constraint;
            }
        }
    }
}



- (void)autoAdjustContentHeight {
    //    [super layoutSubviews];
    
    // calculate size needed for the text to be visible without scrolling
    CGSize sizeThatFits = [self sizeThatFits:self.frame.size];
    CGFloat newHeight = sizeThatFits.height;
    
    // if there is any minimal height constraint set, make sure we consider that
    if (self.maxHeightConstraint) {
        newHeight = MIN(newHeight, self.maxHeightConstraint.constant);
    }
    
    // if there is any maximal height constraint set, make sure we consider that
    if (self.minHeightConstraint) {
        newHeight = MAX(newHeight, self.minHeightConstraint.constant);
    }
    //    NSLog(@"newHeight:%lf", newHeight);
    // update the height constraint
    if ((NSInteger)(newHeight * 1000) != (NSInteger)(self.heightConstraint.constant * 1000)) {
        self.heightConstraint.constant = newHeight;
        
        if (self.heightChangeBlock) {
            [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:self.heightChangeBlock completion:nil];
        }
    }
}

#pragma mark - Composer text view

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder
{
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderInsets:(UIEdgeInsets)placeHolderInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(placeHolderInsets, _placeHolderInsets)) {
        return;
    }
    
    _placeHolderInsets = placeHolderInsets;
    [self setNeedsDisplay];
}
- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    
    textContainerInset.left += 3;
    _placeHolderInsets = textContainerInset;
}

#pragma mark - UITextView overrides


- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    //    NSLog(@"bounds:%@", NSStringFromCGRect(bounds));
    if (self.contentSize.height <= self.bounds.size.height + 1){
        self.contentOffset = CGPointZero; // Fix wrong contentOfset
    } else if (!self.tracking) {
        CGPoint offset = self.contentOffset;
        if (offset.y  > self.contentSize.height - bounds.size.height) {
            offset.y = self.contentSize.height - bounds.size.height;
            if (!self.decelerating && !self.tracking && !self.dragging) {
                self.contentOffset = offset;
            }
            // Fix wrong contentOfset when past huge text
        }
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];
        
        [self.placeHolder drawInRect:UIEdgeInsetsInsetRect(rect, self.placeHolderInsets)
                      withAttributes:[self jl_placeholderTextAttributes]];
    }
}

#pragma mark - Notifications

- (void)jl_addTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jl_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jl_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jl_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)jl_removeTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)jl_didReceiveTextViewNotification:(NSNotification *)notification
{   
    [self setNeedsDisplay];
    [self autoAdjustContentHeight];
}

#pragma mark - Utilities

- (NSDictionary *)jl_placeholderTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder
{
    return [super canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [UIMenuController sharedMenuController].menuItems = nil;
    return [super canPerformAction:action withSender:sender];
}

@end
