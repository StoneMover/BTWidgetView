//
//  BTTextInputView.m
//  word
//
//  Created by stonemover on 2019/3/17.
//  Copyright © 2019 stonemover. All rights reserved.
//

#import "BTTextInputView.h"
#import "UIView+BTViewTool.h"
#import <BTHelp/BTUtils.h>
#import "BTWidgetView.h"
#import "UIView+BTEasyDialog.h"

@interface BTTextInputView()

@property (nonatomic, assign) CGFloat basicHeight;

@property (nonatomic, assign) CGFloat keyboardH;

@end

@implementation BTTextInputView

- (instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    [self initSelf];
    return self;
}

- (void)initSelf{
    self.basicHeight=56;
    [self addKeyBoardNofication];
    self.toolView=[[BTTextInputToolView alloc] initWithFrame:CGRectMake(0, self.height-self.basicHeight, self.width, self.basicHeight) type:BTTextInputViewTypeNoVoice];
    self.toolView.backgroundColor=[UIColor whiteColor];
    [self addSubview:self.toolView];
    
    __weak BTTextInputView * weakSelf=self;
    self.toolView.textView.blockHeightChange = ^(CGFloat height) {
        CGFloat h=height+20;
        if (h<weakSelf.basicHeight) {
            h=weakSelf.basicHeight;
        }
        if (h>120) {
            h=120;
        }
        weakSelf.toolView.height=h;
        [weakSelf.toolView layoutSubviews];
        weakSelf.toolView.bottom=[UIScreen mainScreen].bounds.size.height-weakSelf.keyboardH;
    };
    self.toolView.textView.blockContentChange = ^{
        if (weakSelf.toolView.textView.text.length==0||![weakSelf.toolView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length) {
            [weakSelf.toolView.btnCommit setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }else{
            [weakSelf.toolView.btnCommit setTitleColor:weakSelf.commitColor?weakSelf.commitColor:UIColor.redColor forState:UIControlStateNormal];
        }
    };
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.toolView.textView endEditing:YES];
}

- (void)show:(UIView*)view{
    if ([self superview]) {
        [self removeFromSuperview];
    }
    
    [view addSubview:self];
    [self.toolView.textView becomeFirstResponder];
}




#pragma mark 键盘广播
//添加键盘监听通知
-(void)addKeyBoardNofication{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


//当键盘消失的时候调用
- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:.2 animations:^{
        self.toolView.bottom=[UIScreen mainScreen].bounds.size.height+self.toolView.height;
        //        self.rootView.alpha=0;
    } completion:^(BOOL finished) {
        self.toolView.hidden=YES;
        self.toolView.alpha=1;
        [self removeFromSuperview];
    }];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardH= keyboardRect.size.height;
    
    self.toolView.hidden=NO;
    [UIView animateWithDuration:.25 animations:^{
        self.toolView.bottom=[UIScreen mainScreen].bounds.size.height-self.keyboardH;
    } completion:^(BOOL finished) {
    }];
}

- (void)saveClick{
    if (self.toolView.textView.text.length==0) {
        return;
    }
    
    
    //全部为空格
    if(![self.toolView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length) {
        return;
    }
    
    
    if (self.block) {
        self.block();
    }
}


@end



@interface BTTextInputToolView()

@property (nonatomic, assign) CGFloat basicHeight;

@property (nonatomic, assign) BTTextInputToolType type;

//0:键盘，1:语音
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, assign) CGFloat startY;

@property (nonatomic, assign) BOOL isCancel;

@end



@implementation BTTextInputToolView

- (instancetype)initWithFrame:(CGRect)frame type:(BTTextInputToolType)type{
    self = [super initWithFrame:frame];
    self.type = type;
    self.basicHeight = frame.size.height;
    [self initSelf];
    return self;
}


- (void)initSelf{
    UIView * viewLine=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, .5)];
    viewLine.backgroundColor=[BTUtils RGB:235 G:235 B:235];
    [self addSubview:viewLine];
    
    self.btnVoice = [[UIButton alloc] initWithSize:CGSizeMake(55, 55)];
    [self addSubview:self.btnVoice];
    [self.btnVoice addTarget:self action:@selector(statusClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnCommit=[[UIButton alloc] initWithSize:CGSizeMake(55, 55)];
    [self.btnCommit addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCommit setTitle:@"发布" forState:UIControlStateNormal];
    [self.btnCommit setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.btnCommit.titleLabel.font=[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self addSubview:self.btnCommit];
    
    
    self.textView=[[BTTextView alloc] initWithSize:CGSizeMake(100, self.basicHeight-20)];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(8, 5, 8, 5)];
    self.textView.font=[UIFont systemFontOfSize:16];
    self.textView.textColor=[BTUtils RGB:74 G:76 B:95];
    self.textView.corner=5;
    self.textView.borderColor=[BTUtils RGB:234 G:234 B:234];
    self.textView.borderWidth=.5;
    self.textView.placeHolderColor=[BTUtils RGB:198 G:198 B:198];
    self.textView.placeHolder=@"请输入评论";
    self.textView.maxStrNum=140;
    self.textView.blockMax = ^{
        
    };
    
    self.btnPressVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPressVoice.frame = self.textView.frame;
    self.btnPressVoice.borderWidth = 0.5;
    self.btnPressVoice.borderColor = [UIColor lightGrayColor];
    self.btnPressVoice.corner = 5;
    [self.btnPressVoice setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.btnPressVoice setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    self.btnPressVoice.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.btnPressVoice.enabled = NO;
    
    [self addSubview:self.textView];
    [self addSubview:self.btnPressVoice];
}

- (void)layoutSubviews{
    switch (self.type) {
        case BTTextInputViewTypeNoVoice:
            self.btnVoice.hidden = YES;
            self.btnPressVoice.hidden = YES;
            self.textView.frame=CGRectMake(15, 10, self.width-15-self.btnCommit.width, self.height-20);
            self.btnCommit.frame=CGRectMake(self.textView.right, 0, self.btnCommit.width, self.height);
            break;
        case BTTextInputViewTypeAll:
            self.btnVoice.frame = CGRectMake(0, 0, self.btnVoice.width, self.height);
            self.textView.frame = CGRectMake(self.btnVoice.right, 10, self.width-self.btnVoice.right-self.btnCommit.width, self.height-20);
            self.btnCommit.frame = CGRectMake(self.textView.right, 0, self.btnCommit.width, self.height);
            self.btnPressVoice.frame = self.textView.frame;
            break;
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.status == 0) {
        return;
    }
    [self.btnPressVoice setTitle:@"松开发送" forState:UIControlStateNormal];
    self.isCancel = NO;
    self.startY=0;
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.startY = point.y;
    if (self.delegate && [self.delegate respondsToSelector:@selector(BTTextInputToolViewStart:)]) {
        [self.delegate BTTextInputToolViewStart:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.status == 0) {
        return;
    }
    
    UITouch * touch=[touches anyObject];
    CGPoint point = [touch  locationInView:self];
    BOOL isCancel = NO;
    if (self.startY - point.y > 100) {
        isCancel = YES;
    }
    
    if (self.isCancel != isCancel) {
        self.isCancel = isCancel;
        if (self.isCancel) {
            [self.btnPressVoice setTitle:@"松开取消" forState:UIControlStateNormal];
        }else{
            [self.btnPressVoice setTitle:@"松开发送" forState:UIControlStateNormal];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(BTTextInputToolViewStatus:isCancel:)]) {
            [self.delegate BTTextInputToolViewStatus:self isCancel:isCancel];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.btnPressVoice setTitle:@"按住说话" forState:UIControlStateNormal];
    if (self.status == 1 && self.delegate && [self.delegate respondsToSelector:@selector(BTTextInputToolViewEnd:)]) {
        [self.delegate BTTextInputToolViewEnd:self];
    }
    
}

- (void)statusClick{
    if (self.status == 0) {
        self.status = 1;
    }else{
        self.status = 0;
    }
    
    if (self.status == 0) {
        [self.btnVoice setImage:self.voiceImg forState:UIControlStateNormal];
        self.btnPressVoice.hidden = YES;
        self.textView.hidden = NO;
    }else{
        [self.btnVoice setImage:self.keyboardImg forState:UIControlStateNormal];
        self.btnPressVoice.hidden = NO;
        self.textView.hidden = YES;
    }
}

- (void)speakClick{
    
}

- (void)setDefaultStatus{
    self.status = 1;
    [self statusClick];
}

@end
