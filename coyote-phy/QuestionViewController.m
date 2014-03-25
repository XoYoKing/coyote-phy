//
//  QuestionViewController.m
//  StuentEvaluation
//
//  Created by admin  on 13-12-21.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import "QuestionViewController.h"
#import "UploadViewController.h"
#import "ProgressHUD.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"

#import "Toolkit.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface QuestionViewController ()


@end

@implementation QuestionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)dealloc
{
    [_numberLabel release];
    [_nextStep release];
    [_questionImageView release];
    [_dynamicImageView release];
    [_dynamicPictureArr release];
    [_audioView release];
    [_mulButtonView release];
    [_questionList release];
    [_uploadParma release];
    [_replies release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //必须在这里申明
    _questionList = [[NSMutableArray alloc]init];
    _uploadParma = [[NSMutableDictionary alloc]init];
    _count = 1;
    _isRecording = NO;
    
    //获取测试数据
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"plist"];
    NSArray *list = [NSMutableArray arrayWithContentsOfURL:url];
    [_questionList addObjectsFromArray:list];
    NSLog(@"list： %@", _questionList);
    _item = [NSMutableDictionary dictionaryWithDictionary:[_questionList objectAtIndex:0]];
    
    _replies = [[NSMutableArray alloc] init];
    for (int i=0; i<[_questionList count]; i++) {
        [_replies addObject:@"0"];
    }
    [self addImageView];
    [self addLabelView];
    [self addButtonView];
    
    //左划手势
    UISwipeGestureRecognizer *swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];
}

#pragma -mark first update view
//view添加labelView控件
-(void)addLabelView
{
    //答题时间显示
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 22, 250, 30)];
    _timeLabel.font = [UIFont boldSystemFontOfSize:25];
    _timeLabel.textColor = [UIColor redColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    
    //block实现倒计时
    NSLog(@"total = %@",[Toolkit getTotalTime]);
    __block int timeout = [[Toolkit getTotalTime] intValue]; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        //测试过程中时间结束，立即跳出。如果测试者答完也将跳出
        if(timeout < 0 || _endTestSign == YES){
            
            //倒计时结束，关闭，须立即提交，停止作答
            dispatch_source_cancel(_timer);
            dispatch_release(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
                
                //这里需要判断是否是时间用完才进行
                //强制提交
                //[_dynamicImageView stopAnimating];
                //[self zipFile];
                //[self uploadToServer];
                
            });
            
        }
        else{
            
            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%d:%.2d",minutes, seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //主线程显示
                [_timeLabel setText:strTime];
                
            });
            timeout--;
            
            //实时计算答题时间
            int cha = 3000 - timeout;
            [_uploadParma setValue:[NSString stringWithFormat:@"%d", cha] forKey:@"testTime"];
        }
    });
    dispatch_resume(_timer);
    
    //题数显示
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 50, 80, 60)];
    //_numberLabel.font = [UIFont fontWithName:@"wingdings2.ttf" size:10];
    //[_numberLabel setText:@"1/6"];
    [_numberLabel setText:[NSString stringWithFormat:@"%d/%lu",_count,(unsigned long)[_questionList count]]];
    _numberLabel.font = [UIFont boldSystemFontOfSize:23];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_numberLabel];
}

//view添加buttonView控件
-(void)addButtonView
{
    _nextStep = [[UIButton alloc]init];
    _nextStep.frame = CGRectMake(962, 310, 68, 140);
    [_nextStep setBackgroundImage:[UIImage imageNamed:@"BtnNext_1.jpg"] forState:UIControlStateNormal];
    [_nextStep setBackgroundImage:[UIImage imageNamed:@"BtnNext_2.jpg"] forState:UIControlStateHighlighted];
    [_nextStep addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_nextStep setTag:100];
    [self.view addSubview:_nextStep];
    
    //答题按钮 范围很重要！！！！！！！
    _mulButtonView = [[MulButtonView alloc]initWithDelegate:self];
    [_mulButtonView refreshButton];
    [self.view addSubview:_mulButtonView];
}

//view添加imageView控件
-(void)addImageView
{
    NSString *path = [[NSBundle mainBundle] bundlePath];  //获取路径
    
    //题目图片view
    _questionImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    //异步下载图片
    //NSString *imageStr = [_item objectForKey:@"picture"];
    //[_questionImageView setImageWithURL:[NSURL URLWithString:imageStr]];
    
    NSString *imagePath = [path stringByAppendingPathComponent:[_item objectForKey:@"test_picture"]];
    [_questionImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    _questionImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_questionImageView];
    
    //动态材料图片view
    _dynamicImageView = [[UIImageView alloc] init];
    [_dynamicImageView setFrame:CGRectMake(639, 77, 300, 300)];
    [self.view addSubview:_dynamicImageView];
    
    _dynamicPictureArr = [[NSMutableArray alloc]init];
    
    NSArray *tmpPicture = [_item objectForKey:@"picture"];
    if ([tmpPicture count] == 0) {
        [_dynamicImageView stopAnimating];
        //NSString *imagesPath = [path stringByAppendingPathComponent:[tmpPicture objectAtIndex:0]];
        //[_dynamicImageView setImage:[UIImage imageWithContentsOfFile:imagesPath]];
    }
    else{
        for (int i = 0; i < [tmpPicture count]; i++) {
            NSString *imagesPath = [path stringByAppendingPathComponent:[tmpPicture objectAtIndex:i]];
            [_dynamicPictureArr addObject:[UIImage imageWithContentsOfFile:imagesPath]];
        }
        
        [_dynamicImageView setAnimationImages:_dynamicPictureArr];
        
        //变化幅度
        float animationDuration = [_dynamicImageView.animationImages count] * 0.100; // 100ms per frame
        //动态效果设置
        [_dynamicImageView setAnimationRepeatCount:0];
        [_dynamicImageView setAnimationDuration:animationDuration];
        [_dynamicImageView startAnimating];
    }
}

//划动手势
-(void)handleSwipeGesture:(UIGestureRecognizer*)sender{
    //划动的方向
    UISwipeGestureRecognizerDirection direction=[(UISwipeGestureRecognizer*) sender direction];
    //判断是上下左右
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp:
            NSLog(@"up");
            break;
        case UISwipeGestureRecognizerDirectionDown:
            NSLog(@"down");
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            NSLog(@"left");
            if (_isRecording == NO) {
                [self refreshView];  //滑动后切换视图
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            NSLog(@"right");
            break;
        default:
            break;
    }
    
}

#pragma -mark 按钮触发事件，涉及以下三个函数
-(void)btnClicked:(id)sender
{
    UIButton *btn =(UIButton *)sender;
    switch (btn.tag) {
        case 100:
            [self refreshView];
            break;
        default:
            break;
    }
}

#pragma -mark view change
//更新界面
-(void)refreshView
{
    //考虑是否该题已答，这里需要判断处理
    if ([[_replies objectAtIndex:_count-1] isEqualToString:@"0"]) {
        [ProgressHUD showError:@"本题还未答！"];
        return;
    }
    
    //数据变化
    _count++;

    //UI变化
    //最后一次题特殊处理，即需要提交
    if(_count <= [_questionList count]){
        
        NSString *path = [[NSBundle mainBundle] bundlePath];  //获取路径
        
        //界面数据
        _item = [_questionList objectAtIndex:_count-1];
        
        //重置按钮
        [_mulButtonView refreshButton];
        
        //题目数量显示
        [_numberLabel setText:[NSString stringWithFormat:@"%d/%lu",_count,(unsigned long)[_questionList count]]];
        
        //题目显示
        NSString *imagePath = [path stringByAppendingPathComponent:[_item objectForKey:@"test_picture"]];
        [_questionImageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        
        
        //更新动态图
        [_dynamicPictureArr removeAllObjects];
        NSArray *tmpPicture = [_item objectForKey:@"picture"];
        if ([tmpPicture count] == 1) {
            [_dynamicImageView stopAnimating];
            NSString *imagesPath = [path stringByAppendingPathComponent:[tmpPicture objectAtIndex:0]];
            [_dynamicImageView setImage:[UIImage imageWithContentsOfFile:imagesPath]];
        }
        else{
            for (int i = 0; i < [tmpPicture count]; i++) {
                NSString *imagesPath = [path stringByAppendingPathComponent:[tmpPicture objectAtIndex:i]];
                [_dynamicPictureArr addObject:[UIImage imageWithContentsOfFile:imagesPath]];
            }
        
            [_dynamicImageView setAnimationImages:_dynamicPictureArr];

            //变化幅度
            float animationDuration = [_dynamicImageView.animationImages count] * 0.100; // 100ms per frame
            //动态效果设置
            [_dynamicImageView setAnimationRepeatCount:0];
            [_dynamicImageView setAnimationDuration:animationDuration];
            [_dynamicImageView startAnimating];
        }
        
        //重新置为0
        _audioView.isSaved = NO;
        
        //如果是最后一题，出现的是提交按钮
        if (_count == [_questionList count]) {
            
            //提交按钮显示

        }
    }
    
    else{
        
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此刻是否完成提交！！！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertview show];
        [alertview release];
        
    }
}

//针对alertView的事件处理 alertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSString *msg = [[NSString alloc] initWithFormat:@"您点击的是第%d个按钮!",buttonIndex];
    //NSLog(@"msg:%@",msg);
    if (buttonIndex == 0)
    {
        //将这个量设为之前翻页时的量 两种情况，一种上传失败，一种是取消
        _count = (int)[_questionList count];
        return;
    }
    else if(buttonIndex == 1)
    {
        _endTestSign = YES;
        
        //[_uploadParma setValue:[self arrToString:_replies] forKey:@"ans"];
        
        //切换到上传页
        [self performSegueWithIdentifier:@"QuestionToUpload" sender:self];
   
    }
}


//添加录制视图
-(void)addRecordView
{
    //首次进入需要申请分配内存
    if (_audioView == nil) {
        //音频视图
        _audioView = [[RecordAudioView alloc]initWithDelegate:self];
    }
    [_audioView resetValue];
    [self.view addSubview:_audioView];
}


#pragma -mark RemoveAudioView delegate 委托
-(void)removeAudioView:(BOOL)isSaved
{
    _isRecording = NO;  //不在录音界面
    
    //如果是录音就保存
    if(isSaved == YES){
        
        [self saveFileToDocument];   //音频文件保存
    }
    else{
        [_mulButtonView refreshButton];
        [_replies replaceObjectAtIndex:_count-1 withObject:@"0"];
    }
    
    [_audioView removeFromSuperview];
}

//从临时文档下将文件保存到文档下
-(void)saveFileToDocument
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //临时文件目录
        NSString *tmpPath = nil;
        //不同情况下，文件不一样！！！！ 音频文件
        tmpPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"audio.wav"];

        NSURL *tmpFileURL = [NSURL fileURLWithPath:tmpPath];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:tmpFileURL options:0 error:&error];
        
        if (!error) {
            //文档路径
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentPath = [paths objectAtIndex:0];
            NSString *filename = nil;
            //不同情况下，文件不一样！！！！ 音频文件
            filename = [NSString stringWithFormat:@"question%d.wav",_count];
            
            NSString *outFilePath = [documentPath stringByAppendingPathComponent:filename];
            [data writeToFile:outFilePath options:0 error:&error];
            
            //转到主线程
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *title;
                    NSString *message;
                    
                    if (error != nil) {
                        
                        title = @"保存失败！";
                        message = [error localizedDescription];
                    }
                    else {
                        title = @"答案已保存！";
                        message = nil;
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    alert = nil;
                });
            }
        }
    });
}

#pragma -mark MulButtonViewDelegate 委托
//gaiAPP只用到这个
-(void)clickSingleButtonValue:(int)btnNumber
{
    NSArray *ansABC = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F", nil];
    [_replies replaceObjectAtIndex:_count-1 withObject:[ansABC objectAtIndex:btnNumber]];
    if (btnNumber == 5) {
        _isRecording = YES;
        [self addRecordView];
    }
    //输出回答问题答案
    NSLog(@"%@",_replies);
}

-(void)clickButtonValue:(int)btnNumber
{
    //未实现
}

#pragma -mark RemoveVideoViewDelegate 委托
-(void)back
{

    //[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -Prepare for Segue 传递参数
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"QuestionToUpload"]) {
        // To Last View
        
        UploadViewController * dstViewController = (UploadViewController*)segue.destinationViewController;
        
        //传值
        [dstViewController setReplies:_replies];
        
        dstViewController = nil;
    }
}

#pragma -mark 视图切换函数
- (void)transitionAwayFrom {
}

- (void)beginTransition:(id)sender {
}

- (void)finishedTransition:(id)sender {
}

#pragma -mark 不需要管
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
