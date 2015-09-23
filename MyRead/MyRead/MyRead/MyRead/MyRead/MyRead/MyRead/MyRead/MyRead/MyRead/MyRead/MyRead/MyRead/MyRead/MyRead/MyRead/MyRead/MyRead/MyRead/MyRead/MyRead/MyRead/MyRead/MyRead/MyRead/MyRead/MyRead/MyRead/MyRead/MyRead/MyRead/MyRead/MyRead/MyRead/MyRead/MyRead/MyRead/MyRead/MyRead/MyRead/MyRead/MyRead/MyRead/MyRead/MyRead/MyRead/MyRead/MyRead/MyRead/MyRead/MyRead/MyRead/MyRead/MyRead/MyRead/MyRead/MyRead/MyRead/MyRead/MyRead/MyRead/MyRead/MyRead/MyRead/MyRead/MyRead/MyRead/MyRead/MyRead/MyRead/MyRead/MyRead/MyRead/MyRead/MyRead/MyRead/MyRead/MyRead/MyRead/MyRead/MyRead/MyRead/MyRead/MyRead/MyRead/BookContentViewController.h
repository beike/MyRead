//
//  BookContentViewController.h
//  MyRead
//
//  Created by becky on 15/8/25.
//  Copyright (c) 2015年 becky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookContentViewController : UIViewController<UIPageViewControllerDataSource>

@property (nonatomic,strong)  NSMutableArray *sPageContent;

@property (unsafe_unretained, nonatomic) int currentIndex;

@property (strong,nonatomic) UIPageViewController *BookContentPageView;

@property (strong,nonatomic) NSString *sChapterContent;


@end
