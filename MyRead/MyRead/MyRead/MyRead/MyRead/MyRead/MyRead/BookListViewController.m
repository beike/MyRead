//
//  ViewController.m
//  MyRead
//
//  Created by becky on 15/8/24.
//  Copyright (c) 2015年 becky. All rights reserved.
//

#import "BookListViewController.h"

#import "BookContentViewController.h"

@interface BookListViewController ()
{
    UIView* aView;
}

@end

@implementation BookListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    navBar.barStyle = UIBarStyleBlackTranslucent;
    
    aView = [navBar.subviews objectAtIndex:0];
    
    //aView.hidden = YES;
    
    //hidden 下方toolbar
    [self.navigationController setToolbarHidden:YES animated:TRUE];
    
    CGRect rect = CGRectMake(140, 0, 40, 44);
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:rect];
    
    titleView.opaque = YES;
    
    titleView.backgroundColor = [UIColor clearColor];
    
    titleView.text = @"书架";
    
    titleView.textColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleView;
    
    
    CGRect frame_1= CGRectMake(0, 0, 80, 30);
    
    UIButton* leftButton= [[UIButton alloc] initWithFrame:frame_1];
    
    //[leftButton setBackgroundImage:image forState:UIControlStateNormal];
    
    [leftButton setTitle:@"管理" forState:UIControlStateNormal];
    
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    leftButton.titleLabel.font=[UIFont systemFontOfSize:16];
    
    [leftButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStylePlain target:self action:nil];
    
    leftItem.customView = leftButton;
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton* rightButton= [[UIButton alloc] initWithFrame:frame_1];
    
    //[rightButton setBackgroundImage:image forState:UIControlStateNormal];
    
    [rightButton setTitle:@"推荐" forState:UIControlStateNormal];
    
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    rightButton.titleLabel.font=[UIFont systemFontOfSize:16];
    
    [rightButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"推荐" style:UIBarButtonItemStyleDone target:self action:nil];
    
    rightItem.customView = rightButton;

    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self addBookPicView];

    
}
- (void)LoadBookList {
    
    BookContent = [[NSMutableArray alloc]init];
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯1-血字的研究" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯2-四签名" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯3-冒险史" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯4-回忆录" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯5-归来录" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯6-巴斯克维尔的猎犬" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯7-恐怖谷" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯8-新探索" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
    filePath = [[NSBundle mainBundle]pathForResource:@"福尔摩斯9-最后致意" ofType:@"TXT"];
    
    [BookContent addObject:filePath];
    
    filePath = nil;
    
}
-(void)addBookPicView{
    
    BookPicView = [[UIView alloc]initWithFrame:CGRectMake(10,60, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    for(int i=0;i < BookContent.count;i++)
    {
        rect = CGRectMake(20+(i%3*100), 35+(i/3)*138, 65, 85);
        
        //RJSingleBook* singleBook = [bookData.books objectAtIndex:i];
        
        UIButton* button= [[UIButton alloc]initWithFrame:rect];
        
        button.tag = i;
        
        imageNameList = [[NSMutableArray alloc]initWithObjects:@"红楼1", @"红楼2",@"红楼3",@"红楼4",@"红楼5",@"红楼6",@"红楼7",@"红楼8",@"红楼9",nil];
        
        
        //[button setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"红楼4" ofType:nil]] forState:UIControlStateNormal];
        
        [button setImage:[UIImage imageNamed:[imageNameList objectAtIndex:i%BookContent.count]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(doReadBook:) forControlEvents:UIControlEventTouchUpInside];
        
        [BookPicView addSubview:button];
        
        [BookPicView bringSubviewToFront:button];
    }
    
    [self.view addSubview:BookPicView];
    
}

-(void) doReadBook:(id)sender
{
    UIButton* but = (UIButton*)sender;
    NSInteger i = but.tag;
    [self readBook:i];
}

-(void) readBook:(NSInteger)i
{
    BookContentViewController *bookVC = [[BookContentViewController alloc]init];
    
    bookVC.sChapterContent
    
    [self.navigationController pushViewController:bookVC animated:YES];
    
    //[self pushViewController:bookVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
