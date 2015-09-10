/**
 *
 *                 Created by 洪峰 on 15/9/7.
 *                 Copyright (c) 2015年 洪峰. All rights reserved.
 *
 *                 新浪微博:http://weibo.com/hongfenglt
 *                 博客地址:http://blog.csdn.net/hongfengkt
 */
//                 HFDownLoad
//                 HFSession.m
//

#import "HFSession.h"

@interface HFSession () <NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pgLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *myPregress;
/**
 *  下载任务
 */
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;
/**
 *  session
 */
@property (nonatomic, strong) NSURLSession* session;

@end

@implementation HFSession
/**
 *  session的懒加载
 */
- (NSURLSession *)session
{
    if (nil == _session) {
        
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}
/**
 *  从0开始下载
 */
- (void)startDownload
{
#warning 使用我们自己服务器的地址执行断点下载没问题，但是百度软件的下载链接不成功，应该是百度服务器做了限制吧，或者我写的不完美，有想法欢迎交流
//    NSURL* url = [NSURL URLWithString:@"http://localhost:8080/shudai99/resources/The_Fixer.mp4"];
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    
    // 创建任务
    self.downloadTask = [self.session downloadTaskWithURL:url];

    // 开始任务
    [self.downloadTask resume];
}

/**
 *  恢复下载
 */

- (void)resume
{
     // 传入上次暂停下载返回的数据，就可以恢复下载
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    
    [self.downloadTask resume]; // 开始任务
    
    self.resumeData = nil;
}

/**
 *  暂停
 */
- (void)pause
{
    __weak typeof(self) selfVc = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        //  resumeData : 包含了继续下载的开始位置\下载的url
        selfVc.resumeData = resumeData;
        selfVc.downloadTask = nil;
    }];
}

#pragma mark -- NSURLSessionDownloadDelegate
/**
 *  下载完毕会调用
 *
 *  @param location     文件临时地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    // 将临时文件剪切或者复制Caches文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    [mgr moveItemAtPath:location.path toPath:file error:nil];
    
    // 提示下载完成
    [[[UIAlertView alloc] initWithTitle:@"下载完成" message:downloadTask.response.suggestedFilename delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil] show];
}

/**
 *  每次写入沙盒完毕调用
 *  在这里面监听下载进度，totalBytesWritten/totalBytesExpectedToWrite
 *
 *  @param bytesWritten              这次写入的大小
 *  @param totalBytesWritten         已经写入沙盒的大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.myPregress.progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    self.pgLabel.text = [NSString stringWithFormat:@"下载进度:%f",(double)totalBytesWritten/totalBytesExpectedToWrite];
}

/**
 *  恢复下载后调用，
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark --按钮点击事件

- (IBAction)btnClicked:(UIButton *)sender {
    
    // 按钮状态取反
    sender.selected = !sender.isSelected;
    
    if (nil == self.downloadTask) { // 开始（继续）下载
        if (self.resumeData) { // 继续下载
            [self resume];
        }else{ // 从0开始下载
            [self startDownload];
        }
        
    }else{ // 暂停
        [self pause];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Sesstion 简单执行下载
 */
- (void)SesstionDownLoad
{
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    
    // 得到session对象
    NSURLSession* session = [NSURLSession sharedSession];
    
    // 创建任务
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // location : 临时文件的路径（下载好的文件）
        
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
        NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
        
        // 将临时文件剪切或者复制Caches文件夹
        NSFileManager *mgr = [NSFileManager defaultManager];
        
        // AtPath : 剪切前的文件路径
        // ToPath : 剪切后的文件路径
        [mgr moveItemAtPath:location.path toPath:file error:nil];
    }];
    
    // 开始任务
    [downloadTask resume];
}

/**
 *  NSURLSession简单使用
 */
- (void)sessiondemo
{
    // 1.得到session对象
    NSURLSession* session = [NSURLSession sharedSession];
    NSURL* url = [NSURL URLWithString:@""];
    
    // 2.创建一个task，任务
    NSURLSessionDataTask* dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // data 为返回数据
    }];
    
    // 发送POST
//    [session dataTaskWithRequest:<#(NSURLRequest *)#> completionHandler:<#^(NSData *data, NSURLResponse *response, NSError *error)completionHandler#>]
    
    // 3.开始任务
    [dataTask resume];
}

@end
