//
//  BookContentViewController.m
//  MyRead
//
//  Created by becky on 15/8/25.
//  Copyright (c) 2015年 becky. All rights reserved.
//

#import "BookContentViewController.h"

#import "SecBookContentViewController.h"

#define ContentHeight self.view.bounds.size.height-20

#define Contentwidth self.view.bounds.size.width-20



@interface BookContentViewController (){
    
    
    NSString *sChapterContent;
    
    int myTextLegth;
    
    int myTextStar;
}

@end

@implementation BookContentViewController

@synthesize sPageContent;

@synthesize currentIndex;

@synthesize BookContentPageView;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    //读取书本信息 初始化数据
    
    myTextLegth =  0;
    
    myTextStar = 0;
    
    [self createContentPages];
    
    [self addContentView];
    
}

-(void)createContentPages{
    
    NSError *error;
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯1-血字的研究" ofType:@"TXT"];
    
    sChapterContent = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *pageStrings = [[NSMutableArray alloc]init];
    
    pageStrings = [sChapterContent componentsSeparatedByString:@"\r\n"];
    
    int iCount = (int)pageStrings.count;
    
    NSMutableString * MyTemp = [[NSMutableString alloc] init];
    
    for(int i = myTextStar;i < iCount;i++)
    {
    
        NSString *buffer = [pageStrings objectAtIndex:i];
        
        [MyTemp appendString:buffer];
        
        buffer = nil;
    
        UITextView *myText = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, Contentwidth, ContentHeight)];

        myText.text = MyTemp;
        
        if(myText.contentSize.height > ContentHeight)
        {
            
            NSLog(@"屏幕%f,%f",(self.view.bounds.size.height-20),myText.contentSize.height);
        }
        
        //[pageStrings addObject:buffer];
        
    }
    
    self.sPageContent = [[NSMutableArray alloc]initWithArray:pageStrings];
    
}

- (NSString *)subStringWithRange:(NSRange)range
{
    if (range.location == NSNotFound) return @"";
    
    NSUInteger head = range.location;
    if (head >= sChapterContent.length) return @"";
    
    NSUInteger tail = (range.location + range.length);
    tail = tail > sChapterContent.length ? sChapterContent.length : tail;
    
    if ((NSUInteger)(tail - head) == 4294602370) {
        
        return @"";
    }
    
    return [sChapterContent substringWithRange:NSMakeRange(head, tail - head)];
}

-(void)addContentView{
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
    
    self.BookContentPageView = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    self.BookContentPageView.dataSource = self;
    
    [[BookContentPageView view] setFrame:[[self view] bounds]];
    
    SecBookContentViewController *initialViewController =[self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [BookContentPageView setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:BookContentPageView];
    
    [[self view] addSubview:[BookContentPageView view]];
}

-(SecBookContentViewController *)viewControllerAtIndex:(NSInteger)index{
    
    if(([self.sPageContent count] == 0)|| (index >= [self.sPageContent count])){
        
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    
    SecBookContentViewController *dataViewController =[[SecBookContentViewController alloc] init];
    
    dataViewController.dataObject =[self.sPageContent objectAtIndex:index];
    
    return dataViewController;
    
}

// 根据数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(SecBookContentViewController *)viewController {
    
    return [self.sPageContent indexOfObject:viewController.dataObject];
}

#pragma mark - UIPageViewDataSource And UIPageViewDelegate

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SecBookContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"这已是第一页" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alertView show];

  
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    return [self viewControllerAtIndex:index];

    
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SecBookContentViewController *)viewController];
    if (index == NSNotFound) {
        
        return nil;
    }
    index++;
    if (index == [self.sPageContent count]) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"这已是最后一页" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alertView show];
        
        return nil;
    }
    return [self viewControllerAtIndex:index];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
