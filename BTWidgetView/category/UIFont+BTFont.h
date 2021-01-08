//
//  UIFont+BTFont.h
//  mingZhong
//
//  Created by apple on 2021/1/8.
//  当xib中UIButton、UILabel、UITextField、UITextView控件tag不为0的时候，控件字体大小将根据屏幕宽度缩放
//  基于BTAutoFontSize方法进行字体大小的计算，xib中支持UIFontWeight的设置

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (BTFont)
//根据屏幕宽度缩放后的字体大小，基于375宽度缩放
+ (CGFloat)BTAutoFontSize:(CGFloat)size;

//根据屏幕宽度缩放后生成字体，传入大小为基于375宽度设计的字体大小
+ (UIFont*)BTAutoFontSizeWithName:(NSString*)fontName size:(CGFloat)fontSize;
+ (UIFont*)BTAutoFontWithSize:(CGFloat)size weight:(UIFontWeight)weight;
+ (UIFont*)BTAutoFontWithSize:(CGFloat)size;

@end


@interface UIButton (BTFont)

@end


@interface UILabel(BTFont)

@end


@interface UITextField(BTFont)

@end

@interface UITextView(BTFont)

@end


NS_ASSUME_NONNULL_END
