//
//  AppDelegate.m
//  MyRead
//
//  Created by becky on 15/8/24.
//  Copyright (c) 2015年 becky. All rights reserved.
//

#import "AppDelegate.h"
#import "BookListViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];

    self.window.backgroundColor = [UIColor whiteColor];
    
    BookListViewController *booklistViewColler = [[BookListViewController alloc]init];
    
    //booklistViewColler.title = @"书架";
    
    
    self.navigationController = [[UINavigationController alloc]init];
    
    [self.navigationController pushViewController:booklistViewColler animated:YES];
    
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
