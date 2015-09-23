//
//  E_ReaderView.h
//  E_Reader
//
//  Created by 阿虎 on 14-8-8.
//  Copyright (c) 2014年 tiger. All rights reserved.
//


#import <UIKit/UIKit.h>


/**
 *  显示文本类
 */

@protocol E_ReaderViewDelegate <NSObject>

- (void)shutOffGesture:(BOOL)yesOrNo;
- (void)hideSettingToolBar;
- (void)ciBa:(NSString *)ciBasString;

@end

@interface E_ReaderView : UIView

@property(unsafe_unretained, nonatomic)NSUInteger font;
@property(copy, nonatomic)NSString *text;

@property (assign, nonatomic) id<E_ReaderViewDelegate>delegate;
@property (strong, nonatomic) UIImage  *magnifiterImage;
@property (copy  , nonatomic) NSString *keyWord;

- (void)render;

@end
