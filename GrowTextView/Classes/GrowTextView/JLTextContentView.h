//
//  JLInputBar.h
//  chatInputBar
//
//  Created by li’s Air on 2018/6/15.
//  Copyright © 2018年 li’s Air. All rights reserved.
//

#import "JLTextView.h"

@protocol JLTextContentViewDatasource<NSObject>

/**
 输入框字体，默认 18
 */
- (UIFont *)textFontOfTextContentView ;

/**
 无文本状态下输入框的高度，默认 50
 */
- (NSUInteger)preferredHeightOfTextContentView ;

/**
 输入框最多显示行数，默认 4
 */
- (NSUInteger)maximumLineOfTextContentView ;

@end


@interface JLTextContentView : UIView

+ (instancetype)inputWiewWithDatasource:(id<JLTextContentViewDatasource>)datasource;

@property (strong, nonatomic, readonly) JLTextView *textView;


@end














