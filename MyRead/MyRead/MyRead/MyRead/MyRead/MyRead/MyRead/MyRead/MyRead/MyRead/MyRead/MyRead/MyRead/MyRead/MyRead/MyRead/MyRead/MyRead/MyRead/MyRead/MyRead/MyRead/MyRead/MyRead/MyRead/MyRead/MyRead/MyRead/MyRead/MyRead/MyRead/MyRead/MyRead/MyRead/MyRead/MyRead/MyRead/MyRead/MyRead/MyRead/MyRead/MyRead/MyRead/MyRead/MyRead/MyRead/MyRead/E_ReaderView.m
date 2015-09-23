//
//  E_ReaderView.m
//  E_Reader
//
//  Created by 阿虎 on 14-8-8.
//  Copyright (c) 2014年 tiger. All rights reserved.
//

#import "E_ReaderView.h"
#import <CoreText/CoreText.h>
#import <AVFoundation/AVSpeechSynthesis.h>


#define kEpubView_H self.frame.size.height
#define kItemCopy           @"复制"
//#define kItemHighLight      @"高亮"
#define kItemCiBa           @"词霸"
#define kItemRead           @"朗读"

@implementation E_ReaderView
{
    CTFrameRef _ctFrame;
    NSRange selectedRange;//选择区域
  //  CGSize suggestedSize;
    
    UIGestureRecognizer *panRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    UILongPressGestureRecognizer *longRecognizer;
    
    NSMutableArray *highLightRangeArray;//高亮区域 注：翻页后高亮便不存在，若需让其存在，请本地化该数组
    NSMutableString *_totalString;
   
}

- (void)dealloc
{
    if (_ctFrame != NULL) {
        CFRelease(_ctFrame);
    }
}

#pragma mark - 初始化一些手势等
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
       
        highLightRangeArray = [[NSMutableArray alloc] initWithCapacity:0];
        
       /* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressAction:)];
        longRecognizer.enabled = YES;
        [self addGestureRecognizer:longRecognizer];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapAction:)];
        tapRecognizer.enabled = NO;
        [self addGestureRecognizer:tapRecognizer];
        

        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(PanAction:)];
        [self addGestureRecognizer:panRecognizer];
        panRecognizer.enabled = NO;*/
    
    }
    return self;
}



#pragma mark - 绘制相关方法

- (void)drawRect:(CGRect)rect
{
    if (!_ctFrame) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGAffineTransform transform = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
    CGContextConcatCTM(context, transform);
    
    if (_keyWord == nil || [_keyWord isEqualToString:@""]) {
        
    }else{
       
        [self showSearchResultRect:[self calculateRangeArrayWithKeyWord:_keyWord]];
    }
    
    
   // [self showHighLightRect:highLightRangeArray];
    [self showSelectRect:selectedRange];
    
    CTFrameDraw(_ctFrame, context);
}


- (NSMutableArray *)calculateRangeArrayWithKeyWord:(NSString *)searchWord{
    
    NSMutableString *blankWord = [NSMutableString string];
    for (int i = 0; i < searchWord.length; i ++) {
        
        [blankWord appendString:@" "];
    }
    NSMutableArray *feedBackArray = [NSMutableArray array];
    
    for (int i = 0; i < INT_MAX; i++){
        if ([_totalString rangeOfString:searchWord options:1].location != NSNotFound){
            
            NSRange newRange = [_totalString rangeOfString:searchWord options:1];
            
            [feedBackArray addObject:NSStringFromRange(newRange)];
            [_totalString replaceCharactersInRange:newRange withString:blankWord];
        
        }else{
            break;
        }
    
    }
    return feedBackArray;

}


- (NSDictionary *)coreTextAttributes
{
    UIFont *font_ = [UIFont systemFontOfSize:self.font];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = font_.pointSize / 2;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_};
    return dic;
}


- (void)render
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString  alloc] initWithString:self.text];
    _totalString = [NSMutableString stringWithString:self.text];
    
    [attrString setAttributes:self.coreTextAttributes range:NSMakeRange(0, attrString.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    if (_ctFrame != NULL) {
        CFRelease(_ctFrame), _ctFrame = NULL;
    }
    _ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    
    
//计算高度的方法****************************
//    suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT), NULL);
//    suggestedSize = CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
//    
//    NSLog(@"height == %f",suggestedSize.height);
//****************************************
    
    CFRelease(path);
    CFRelease(frameSetter);
}

- (CTFrameRef)getCTFrame
{
    return _ctFrame;
}

#pragma mark - 搜索结果
- (void)showSearchResultRect:(NSMutableArray *)resultArray{
    
    for (int i = 0; i < resultArray.count; i ++) {
        [self drawHighLightRect:NSRangeFromString([resultArray objectAtIndex:i])];
    }
}

#pragma mark -高亮区域
- (void)showHighLightRect:(NSMutableArray *)highArray{

    for (int i = 0; i < highArray.count; i ++) {
        [self drawHighLightRect:NSRangeFromString([highArray objectAtIndex:i])];
    }

}

#pragma mark - 计算高亮区域 （懒得写枚举区分，就直接复制下面得 选择区域了）
- (void)drawHighLightRect:(NSRange)selectRect{
    
    if (selectRect.length == 0 || selectRect.location == NSNotFound) {
        return;
    }
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];
    NSArray *lines = (NSArray*)CTFrameGetLines([self getCTFrame]);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins([self getCTFrame], CFRangeMake(0,0), origins);
    
    for (int i = 0; i < lines.count; i ++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
        NSRange intersection = [self rangeIntersection:range withSecond:selectRect];
        if (intersection.length > 0) {
            
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);//获取整段文字中charIndex位置的字符相对line的原点的x值
            
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGRect selectionRect = CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            [pathRects addObject:NSStringFromCGRect(selectionRect)];//放入数组
        }
    }
    free(origins);
    [self drawHighLightPathFromRects:pathRects];//画选择框
    
}

#pragma mark - 画高亮部分
- (void)drawHighLightPathFromRects:(NSMutableArray*)array
{
    if (array==nil || [array count] == 0)
    {
        return;
    }
    
    
    // 创建一个Path句柄
    CGMutablePathRef _path = CGPathCreateMutable();
    
    [[UIColor orangeColor]setFill];
    
    
    for (int i = 0; i < [array count]; i++) {
        
        CGRect firstRect = CGRectFromString([array objectAtIndex:i]);
        CGPathAddRect(_path, NULL, firstRect);//向path路径添加一个矩形
        
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);//用当前的填充颜色或样式填充路径线段包围的区域。
    CGPathRelease(_path);
}



#pragma mark - 计算选择区域
- (void)showSelectRect:(NSRange)selectRect{
    
    if (selectRect.length == 0 || selectRect.location == NSNotFound) {
        return;
    }
    
    NSMutableArray *pathRects = [[NSMutableArray alloc] init];
    NSArray *lines = (NSArray*)CTFrameGetLines([self getCTFrame]);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins([self getCTFrame], CFRangeMake(0,0), origins);
    
    for (int i = 0; i < lines.count; i ++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location==kCFNotFound ? NSNotFound : lineRange.location, lineRange.length);
        NSRange intersection = [self rangeIntersection:range withSecond:selectRect];
        if (intersection.length > 0) {
           
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);//获取整段文字中charIndex位置的字符相对line的原点的x值
            
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin = origins[i];
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CGRect selectionRect = CGRectMake(origin.x + xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            [pathRects addObject:NSStringFromCGRect(selectionRect)];//放入数组
        }
    }
    free(origins);
    [self drawPathFromRects:pathRects];//画选择框
    
}

#pragma mark- 画背景色
- (void)drawPathFromRects:(NSMutableArray*)array
{
    if (array==nil || [array count] == 0)
    {
        return;
    }
    
    
    // 创建一个Path句柄
    CGMutablePathRef _path = CGPathCreateMutable();
    
    [[UIColor colorWithRed:228/255.0 green:100/255.0 blue:166/255.0 alpha:0.6]setFill];
    

    for (int i = 0; i < [array count]; i++) {
        
        CGRect firstRect = CGRectFromString([array objectAtIndex:i]);
        CGPathAddRect(_path, NULL, firstRect);//向path路径添加一个矩形
        
    }
   
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);//用当前的填充颜色或样式填充路径线段包围的区域。
    CGPathRelease(_path);
}


/*- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
   //|| action == @selector(highLight:)
    if (action == @selector(copyword:) || action == @selector(ciBa:) || action == @selector(readText:)) {
        return YES;
    }
    return NO;
}*/





- (BOOL)canBecomeFirstResponder {
    return YES;
}





#pragma mark -根据用户手指的坐标获得 手指下面文字在整页文字中的index
- (CFIndex)getTouchIndexWithTouchPoint:(CGPoint)touchPoint{
    
    CTFrameRef textFrame = [self getCTFrame];
    NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex index = -1;
    NSInteger lineCount = [lines count];
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    if (lineCount != 0) {
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), origins);
        
        for (int i = 0; i < lineCount; i++){
            
            CGPoint baselineOrigin = origins[i];
            baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
            
            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            CGFloat ascent, descent;
            CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
            if (CGRectContainsPoint(lineFrame, touchPoint)){
                index = CTLineGetStringIndexForPosition(line, touchPoint);
            
            }
        }
    
    }
    free(origins);
    return index;

}

#pragma mark - 中文字典串
- (NSRange)characterRangeAtIndex:(NSInteger)index doFrame:(CTFrameRef)frame
{
    __block NSArray *lines = (NSArray*)CTFrameGetLines(_ctFrame);
    NSInteger count = [lines count];
    __block NSRange returnRange = NSMakeRange(NSNotFound, 0);
    
    for (int i=0; i < count; i++) {
        
        __block CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CFRange cfRange = CTLineGetStringRange(line);
        CFRange cfRange_Next = CFRangeMake(0, 0);
        if (i < count - 1) {
            __block CTLineRef line_Next = (__bridge CTLineRef)[lines objectAtIndex:i+1];
            cfRange_Next = CTLineGetStringRange(line_Next);
        }
        
        NSRange range = NSMakeRange(cfRange.location == kCFNotFound ? NSNotFound : cfRange.location, cfRange.length == kCFNotFound ? 0 : cfRange.length);
       
        if (index >= range.location && index <= range.location+range.length) {
            
            if (range.length > 1) {
                NSRange newRange = NSMakeRange(range.location, range.length + cfRange_Next.length);
                [self.text enumerateSubstringsInRange:newRange options:NSStringEnumerationByWords usingBlock:^(NSString *subString, NSRange subStringRange, NSRange enclosingRange, BOOL *stop){
                   
                    if (index - subStringRange.location <= subStringRange.length&&index - subStringRange.location!=0) {
                        returnRange = subStringRange;
                       
                        if (returnRange.length <= 2 && self.text.length > 1) {//为的是长按选择的文字永远大于或等于2个，方便拖动
                            returnRange.length = 2;
                        }
                        *stop = YES;
                    
                    }
                    
                }];
                
            }
            
        }
    }
    
    return returnRange;
}


#pragma mark- Range区域
- (NSRange)rangeIntersection:(NSRange)first withSecond:(NSRange)second
{
    NSRange result = NSMakeRange(NSNotFound, 0);
    if (first.location > second.location)
    {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    if (second.location < first.location + first.length)
    {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }
    return result;
}

@end
