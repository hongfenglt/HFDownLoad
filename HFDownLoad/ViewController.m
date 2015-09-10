//
//  ViewController.m
//  HFDownLoad
//
//  Created by 洪峰 on 15/9/7.
//  Copyright (c) 2015年 洪峰. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"sandbox:%@",NSHomeDirectory());
   
    // 小文件下载方式
    // 1.NSData dataWithContentsOfURL
    // 2.NSURLConnection

    NSURL* url = [NSURL URLWithString:@"https://picjumbo.imgix.net/HNCK8461.jpg?q=40&w=1650&sharp=30"];
    
//    [self downloadImageWithUrl:url];
    [self downloadImage2WithUrl:url];
}

/**
 *  NSData dataWithContentsOfURL 下载文件
 */
- (void)downloadImageWithUrl:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 其实是发送一个Get 请求
        NSData* data = [NSData dataWithContentsOfURL:url];
        
        // 回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imageView.image = [UIImage imageWithData:data];
        });
    });
}

/**
 *  NSURLConnection 下载文件
 */
- (void)downloadImage2WithUrl:(NSURL *)url
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        self.imageView.image = [UIImage imageWithData:data];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
