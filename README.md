iOS 一个比较完美的 Growing TextView（高度自适应输入框）

<img src="https://upload-images.jianshu.io/upload_images/2591472-5a95c3f4c6e81e37.gif?imageMogr2/auto-orient/strip" width="250"/><img src="https://upload-images.jianshu.io/upload_images/2591472-754d34bb3c0c126c.gif?imageMogr2/auto-orient/strip" width="250/>


-

# GrowTextView

[![CI Status](https://img.shields.io/travis/wuzhenli/GrowTextView.svg?style=flat)](https://travis-ci.org/wuzhenli/GrowTextView)
[![Version](https://img.shields.io/cocoapods/v/GrowTextView.svg?style=flat)](https://cocoapods.org/pods/GrowTextView)
[![License](https://img.shields.io/cocoapods/l/GrowTextView.svg?style=flat)](https://cocoapods.org/pods/GrowTextView)
[![Platform](https://img.shields.io/cocoapods/p/GrowTextView.svg?style=flat)](https://cocoapods.org/pods/GrowTextView)

## 缘由
现在都 2019 年了，App 中使用自动增高的输入框已经很常见了，即时通讯的 Chat 界面、社交类 App 的评论功能都可以看到自增高输入框。但写出一个自增高输入框容易，写好难。现在市面上一些主流 App 的输入框依然会有一些瑕疵，例如：文字挡住一部分、粘贴大量文字时出现偏移，具体问题下面详细分析。

现在 iOS 开发已经过了搭建 UI 和普通业务功能的初级阶段，App 要想赢得用户的青睐，除了 App 的功能、UI 设计，交互体验的细节处理至关重要。一般用户只要使用输入框能正常输入即可，90% 的用户不会察觉输入框的一些细节，但作为开发人员应该知道这些细节(bug)并做出处理。

## 主流 App 的输入框之痛
#### 粘贴文本出现文字偏移
这个问题严格来说算 bug，毕竟粘贴还是一个很常见的操作。

![粘贴文本出现文字偏移](http://upload-images.jianshu.io/upload_images/2591472-068f8d87dd118f55.gif?imageMogr2/auto-orient/strip)
#### 挡住部分文字
这个问题对 App 功能没有任何影响，但这么多 App 竟然都有这个问题而且非常普遍，是我始料未及的。测试了多个 App 后，只有QQ的输入框做的最好，粘贴、遮挡文字等问题根本不存在。

![1_zhiHu_cover.PNG](https://upload-images.jianshu.io/upload_images/2591472-1db755cd275d8263.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![weiBo_cover.PNG](https://upload-images.jianshu.io/upload_images/2591472-82b1d4fafda8a002.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![touTiao_cover.PNG](https://upload-images.jianshu.io/upload_images/2591472-ff9addae3cd858a4.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![jd_cover.PNG](https://upload-images.jianshu.io/upload_images/2591472-aafd0be911463ca2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![weixin_cover.png](https://upload-images.jianshu.io/upload_images/2591472-8f427b3e846c78c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 比较完美的输入框
写出一个自增高的输入框还是比较容易的，大致过程就是给 textView 添加左、右、下/上、高度四个约束，然后监听文字变化的通知，进而修改输入框的高度。我接下来主要说一下大家可能遇到的一些细节问题。

#### 1、粘贴文本，文字偏移
我的做法是继承 `UITextView` 重写 `setBounds` 方法，重新调整`contentOffset`

```
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
            // Fix wrong contentOfset when paster huge text
        }
    }
}
```

#### 2、文字离输入框顶部间隙时大时小
正常情况下滚动输入框的文字，文字可以滚动到控件顶部。而 QQ 的输入框，不管怎么滑动文字，文字和输入框顶部都有一段固定间隔。

![QQ_Top_margin](http://upload-images.jianshu.io/upload_images/2591472-05b0b4781b0f2d93.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

先了解输入框的一个属性`textContainerInset`，这个值默认是 (8, 0, 8, 0)，就是说默认情况下文字和输入框顶部有 8pt 的偏移，所以当文字输入较多的时候文字向上滚动，那么文字和控件顶部间隙会减小到 0。

实现QQ输入框的效果，我能想到的方案是把`textContainerInset`全设置为 0（或者top/bottom为0），这样文字就紧挨着输入框，文字和输入框顶部的固定间距就是 0 了。接着要给`UITextView
`添加一个 `containerView` ，`containerView` 竖向比 `UITextView
` 高出一部分，从而实现 顶部/底部 的固定间距。

#### 3、挡住部分文字
这个问题是因为 `单行文字高度 * 最大行数  != 输入框的最大高度`，输入框的最大高度可不是随便设置的，先确定输入框的`font`和最大行数，`font.lineHeight * 行数`就是输入框的最大高度。这样就不会出现文字挡住一部分的问题了


## GrowTextView
接下来就是我自己写的自增高输入框了，目前没发现什么问题，至少没有上面涉及的问题。


- [GrowTextView](https://github.com/jalyResource/GrowTextView)


[Reference]
- [JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController)
- [袁峥-textView自适应文字高度](https://www.jianshu.com/p/55d98e8f3e61)

## Requirements
- ARC

## Installation
#### Manual
Add `JLTextContentView.h/m` and `JLTextView.h/m` to your project.

#### Cocoapods. [Recommand]
Base is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GrowTextView', '~> 1.0'
```

## Author

wuzhenli, zhenli@6.cn

## License

GrowTextView is available under the MIT license. See the LICENSE file for more info.
