//
//  UploadViewController.m
//  coyote-bio
//
//  Created by apple on 14-3-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "UploadViewController.h"
#import "ProgressHUD.h"
#import "JSONKit.h"
#import "ZipArchive.h"

#import "Toolkit.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface UploadViewController ()

@end

@implementation UploadViewController

- (void)dealloc
{
    [_uploadParma release];  //其实不需要释放，因为未申请内存
    [_replies release];
    [_rightAnswers release];
    _request = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _rightAnswers = [[NSMutableArray alloc]init];
    
	//获取测试数据
    NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *plistPath = [path stringByAppendingPathComponent:@"answer.plist"];
    NSArray *list = [NSMutableArray arrayWithContentsOfFile:plistPath];
    //NSLog(@"%@",list);
    [_rightAnswers addObjectsFromArray:list];
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect viewFrame = CGRectZero;
    viewFrame.size = CGSizeMake(HEIGHT, WIDTH);
    self.view.frame = viewFrame;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:@"End_Background" ofType:@"jpg"];
    [imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView];
    [imageView release];

    
    //NSLog(@"access: %d",[Toolkit getLocalAccess]);
    //是否本地访问
    if ([Toolkit getLocalAccess] == YES) {
        [self addAnswersView];
    }
    else{
        [self simpleToServer];
    }
    
    //NSLog(@"reply: %@",_replies);

    
    
}

#pragma -mark 显示答案结果
-(void)addAnswersView
{
    for (int i=0; i<12; i++) {
        
        NSString *str = [[_rightAnswers objectAtIndex:i] objectForKey:@"reply"];
        //for (int i=0; i<[questionNumber count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        if ([[_replies objectAtIndex:i] isEqualToString:str]) {
            NSString *imagePath1 = [[NSBundle mainBundle]pathForResource:@"UI-Button-Result-True" ofType:@"png"];
            [imageView setImage:[UIImage imageWithContentsOfFile:imagePath1]];
        }
        else{
            NSString *imagePath2 = [[NSBundle mainBundle]pathForResource:@"UI-Button-Result-False" ofType:@"png"];
            [imageView setImage:[UIImage imageWithContentsOfFile:imagePath2]];
        }
        [imageView setFrame:CGRectMake(225, 180+35*i, 200, 30)];
        [self.view addSubview:imageView];
        [imageView release];
    
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(255, 180+35*i, 150, 30)];
        [label setText:[NSString stringWithFormat:@"第%d题",i+1]];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label release];
    }

    UIButton *reagainBtn = [[UIButton alloc]init];
    reagainBtn.frame = CGRectMake(241, 639, 140, 68);
    [reagainBtn setBackgroundImage:[UIImage imageNamed:@"BtnReset_1.jpg"] forState:UIControlStateNormal];
    [reagainBtn setBackgroundImage:[UIImage imageNamed:@"BtnReset_2.jpg"] forState:UIControlStateHighlighted];
    [reagainBtn addTarget:self action:@selector(reAgain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reagainBtn];
    [reagainBtn release];
}

//视图切换
-(void)reAgain
{
    [self performSegueWithIdentifier:@"UploadToLogin" sender:self];
}

#pragma -mark 显示重传视图
-(void)addReuploadView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(924, 317, 80, 270)];
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:@"UploadErrorView_Background" ofType:@"jpg"];
    [imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView];
    [imagePath release];
    
    UIButton *reuploadBtn = [[UIButton alloc]init];
    reuploadBtn.frame = CGRectMake(939, 602, 50, 50);
    [reuploadBtn setBackgroundImage:[UIImage imageNamed:@"BtnReupload_1.jpg"] forState:UIControlStateNormal];
    [reuploadBtn setBackgroundImage:[UIImage imageNamed:@"BtnReupload_2.jpg"] forState:UIControlStateHighlighted];
    [reuploadBtn addTarget:self action:@selector(reUpload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reuploadBtn];
    [reuploadBtn release];
    
}

//重传按钮事件
-(void)reUpload
{
    [self simpleToServer];
}

#pragma -mark zip all files
-(void)zipFile
{
    //建立json数据文件 _uploadParma字典即将转化为json文件
    [_uploadParma setObject:_replies forKey:@"replies"];
    [_uploadParma setObject:[Toolkit getUserName] forKey:@"userName"];
    
    //获取文件夹路径docspath
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docspath = [paths objectAtIndex:0];
    
    //文件夹下建立一个json文件
    NSString *json =[NSString stringWithFormat:@"%@.json",[Toolkit getUserName]];
    NSString *jsonFile = [docspath stringByAppendingPathComponent:json];
    NSString *jsonStr = [_uploadParma JSONString];
    NSLog(@"jsonData: %@", jsonStr);
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [jsonData writeToFile:jsonFile options:0 error:nil];
    
    NSString *date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    date = [df stringFromDate:[NSData data]];
    NSLog(@"date: %@", date);
    [df release];
    
    //获取文件夹路径docspath
    NSString *str = [NSString stringWithFormat:@"%@%@.zip",[Toolkit getUserName],date];
    [Toolkit saveUploadFileName:str];   //保存是为了便于找到
    NSLog(@"str: %@, %@",str, [Toolkit getUploadFileName]);
    
    NSString *zipFile = [docspath stringByAppendingPathComponent:str];
    
    //申请压缩
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipFile];
    
    //文件夹后缀匹配遍历
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [[fileManager contentsOfDirectoryAtPath:docspath error:&error]
                         pathsMatchingExtensions:[NSArray arrayWithObjects:@"wav",@"json",nil]];
    NSLog(@"fileList = %@", fileList);
    
    //遍历文件夹下文件数组
    for (NSString *object in fileList) {
        
        NSString *recorded = [docspath stringByAppendingString:object];
        [za addFileToZip:recorded newname:object];
        NSLog(@"快速的遍历数组对象为: %@",object);
        
    }
    
    //输出是否压缩成功
    BOOL success = [za CloseZipFile2];
    NSLog(@"Zipped file with result %d",success);
    //最后置空
    [za release];
    za = nil;
}

-(void)deleteFiles
{
    //注释掉的是指删除指定文件
    //NSString *extension = @"m4r";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        //if ([[filename pathExtension] isEqualToString:extension]) {
        
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        //}
    }
    
}

#pragma -mark upload information to server
//上传实现的函数
-(void)uploadToServer
{
    [ProgressHUD show:@"正在上传中..."];
    
    //打包
    [self zipFile];
    
    //文档路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *str = [NSString stringWithFormat:@"%@",[Toolkit getUploadFileName]];
    NSString *path = [documentPath stringByAppendingPathComponent:str];
    
#pragma mark 使用ASIHttpRequest 上传图片和数据
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://42.96.169.81/underworld/upload_file.php"]];
    [request addFile:path forKey:@"file"];
    //[request addPostValue:@"asihttp" forKey:@"name"];
    
    [request buildRequestHeaders];
    NSLog(@"header: %@", request.requestHeaders);
    
    [request setCompletionBlock:^{
        NSLog(@"responseString = %@",request.responseString);
        [ProgressHUD showSuccess:@"上传成功！"];
        //删除文件夹下相关文件
        [self deleteFiles];
        
    }];
    [request setFailedBlock:^{
        
        //将这个量设为之前翻页时的量 两种情况，一种上传失败，一种是取消
        [ProgressHUD showError:@"上传失败，请重传！"];
        //这边设置不能是这样的
   
        NSLog(@"asi error: %@",request.error.debugDescription);
    }];
    [request startAsynchronous];
    
}

#pragma -mark 下面两个函数仅仅用来测试
-(NSString*) getValidURL
{
    if (false) {
        //TODO: 从系统的配置文件中读取，然后自动将可以用的url返回给所需函数
    }
    
    return [NSString stringWithFormat:@"http://%@/apps/coyotes/post_answer1.php?",[Toolkit getTestUrl]];
    //return [NSString stringWithFormat:@"http://%@:8080/coyotes/post_answer1.php?",[Toolkit getTestUrl]];
}

-(void) simpleToServer
{
    [ProgressHUD show:@"正在上传中..." Interacton:NO];
    
    NSString *urlstr = [self getValidURL];
    NSLog(@"url = %@",urlstr);
    
    
    NSURL *myurl = [NSURL URLWithString:urlstr];
    _request = [ASIFormDataRequest requestWithURL:myurl];
    //设置表单提交项
    [_request setPostValue:@"1" forKey:@"uc"];
    [_request setPostValue:@"20140201" forKey:@"qgc"];
    [_request setPostValue:[self arrToString:_replies] forKey:@"ans"];
    
    NSLog(@"request = %@",_request);
    
    [_request setCompletionBlock:^{
        
        NSLog(@"responseString = %@",_request.responseString);
        
        NSDictionary *dic = [_request.responseString objectFromJSONString];
        NSLog(@"dic %@",dic);
        if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
            
            [ProgressHUD showSuccess:@"上传成功"];
            
            [self addAnswersView];
            
        }
        else{
            [ProgressHUD showError:@"上传失败"];
            
            //显示重传按钮
            [self addReuploadView];

        }
        
    }];
    [_request setFailedBlock:^{
        
        [ProgressHUD showError:@"上传失败"];
        
        NSLog(@"asi error: %@",_request.error.debugDescription);
        
        //显示重传按钮
        [self addReuploadView];
        
    }];
    
    [_request startAsynchronous];
}

//数组转字符串
-(NSString *) arrToString:(NSMutableArray *)array
{
    NSString *str = [[[NSString alloc]init]autorelease];
    for (int i=0; i<[array count]; i++) {
        str = [str stringByAppendingFormat:@"%@_", [array objectAtIndex:i]];
    }
    
    return str;
}

#pragma -mark 视图切换函数
- (void)transitionAwayFrom {
}

- (void)beginTransition:(id)sender {
}

- (void)finishedTransition:(id)sender {
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
