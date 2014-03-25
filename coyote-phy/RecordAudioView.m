//
//  RecordAudioView.m
//  StuentEvaluation
//
//  Created by admin  on 13-12-23.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import "RecordAudioView.h"
#import "Toolkit.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation RecordAudioView

-(void)dealloc
{
    [_imageView release];
    [_timeLabel release];
    [_saveFileBtn release];
    [_playerAudio release];
    [super dealloc];
}

//- (id)initWithFrame:(CGRect)frame

- (id)initWithDelegate:(id)delegate;
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        CGRect viewFrame = CGRectZero;
        viewFrame.size = CGSizeMake(HEIGHT, WIDTH);
        self.frame = viewFrame;
        
        UIView *backgroundView = [[UIView alloc]init];
        backgroundView.frame = CGRectMake(0, 0, HEIGHT, WIDTH);
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.7;
        [self addSubview:backgroundView];
        [backgroundView release];
        
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Recorder-1.jpg"]];
        _imageView.frame = CGRectMake(0, 0, 600, 230);
        _imageView.center = CGPointMake(HEIGHT/2, WIDTH/2);
        [self addSubview:_imageView];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(278, 69, 50, 84)];
        [_timeLabel setText:@""];
        _timeLabel.font = [UIFont systemFontOfSize:24];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [_imageView addSubview:_timeLabel];
        
        //保存文件
        _saveFileBtn = [[UIButton alloc]initWithFrame:CGRectMake(218+105, 269+117, 45, 45)];
        [_saveFileBtn setBackgroundImage:[UIImage imageNamed:@"Yes1_1.jpg"]forState:UIControlStateNormal];
        [_saveFileBtn setBackgroundImage:[UIImage imageNamed:@"Yes1_2.jpg"]forState:UIControlStateHighlighted];
        [_saveFileBtn addTarget:self action:@selector(saveAudioFile:) forControlEvents:UIControlEventTouchUpInside];
        _saveFileBtn.hidden = YES;
        [_saveFileBtn setTag:200];
        [self addSubview:_saveFileBtn];
        
        //取消本次保存
        _cancelSaveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelSaveBtn.frame = CGRectMake(218+207, 269+117, 45, 45);
        [_cancelSaveBtn setBackgroundImage:[UIImage imageNamed:@"No_1.jpg"]forState:UIControlStateNormal];
        [_cancelSaveBtn setBackgroundImage:[UIImage imageNamed:@"No_2.jpg"]forState:UIControlStateHighlighted];
        [_cancelSaveBtn addTarget:self action:@selector(saveAudioFile:) forControlEvents:UIControlEventTouchUpInside];
        _cancelSaveBtn.hidden = YES;
        [_cancelSaveBtn setTag:201];
        [self addSubview:_cancelSaveBtn];
        
        _playAudioBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _playAudioBtn.frame = CGRectMake(218+495, 269+117, 45, 45);
        [_playAudioBtn setBackgroundImage:[UIImage imageNamed:@"Yes2_1.jpg"]forState:UIControlStateNormal];
        [_playAudioBtn setBackgroundImage:[UIImage imageNamed:@"Yes2_2.jpg"]forState:UIControlStateHighlighted];
        [_playAudioBtn addTarget:self action:@selector(player) forControlEvents:UIControlEventTouchUpInside];
        _playAudioBtn.hidden = YES;
        [self addSubview:_playAudioBtn];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    
    _isRecording = NO;

    }
    
    return self;
}

-(void)saveAudioFile:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 200:
            _isSaved = YES;
            //移除该view
            [_delegate removeAudioView:_isSaved];
            break;
         case 201:
            _isSaved = NO;
            [_delegate removeAudioView:_isSaved];
            break;
        default:
            break;
        }

}

//倒计时函数
-(void)countDownTest
{
    __block int timeout = [[Toolkit getRecordTime] intValue]; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout < 0){
        
            //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_release(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if (timeout < 0) {
                    
                    //录音后界面
                    [_timeLabel setText:@""];
                    _saveFileBtn.hidden = NO;
                    _cancelSaveBtn.hidden = NO;
                    _playAudioBtn.hidden = NO;
                    [_imageView setImage:[UIImage imageNamed:@"Recorder-3.jpg"]];
                    //此时相当于按动了停止键
                    [self recorder];
                }
            });
        }

        else{
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d",timeout];
            NSLog(@"strTime: %@",strTime);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_timeLabel setText:strTime];
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

//录音
-(void)recorder
{
    
    //如果app不在录音，此刻我们开始录音
    if(!self.isRecording)
    {

        __block int timeout = [[Toolkit getNoticeTime] intValue]; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            
            if(timeout < 0){
                //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_release(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    if (timeout < 0) {
                        
                        _isRecording = YES;
                        
                        if(_recorderAudio == nil){
                            //录音文件存放路径
                            _recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audio.wav"]];
                            _recorderAudio = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:nil error:nil];
                        }
                        
                        [_recorderAudio prepareToRecord];
                        [_recorderAudio record];
                        //_recorderAudio = nil;
                        
                        //录音中界面
                        [_imageView setImage:[UIImage imageNamed:@"Recorder-2.jpg"]];
                        //录音同时倒计时
                        [self countDownTest];
                    }
                });
            }
            
            else{
                
                NSString *strTime = [NSString stringWithFormat:@"%.2d",timeout];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_timeLabel setText:strTime];
                    
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
        
    }
    
    //如果app在录音，此刻我们停止录音
    else
    {
        _isRecording = NO;
        [_recorderAudio stop];
        
        NSError *playerError;
        
        //播放地址
        if(_playerAudio == nil){
            _playerAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
        }
        
        if (_playerAudio == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        
        _playerAudio.delegate = self;
    }
}

//播放
-(void)player
{
    if([_playerAudio isPlaying])
    {
        [_playerAudio pause];
        //[_playAudioBtn setTitle:@"回放" forState:UIControlStateNormal];
        
    }
    //如果播放器不在播放，那么播放后，播放button显示为“停止”
    else
    {
        [_playerAudio play];
    }
}


//每次答题重新设置原始界面
-(void)resetValue
{
    _saveFileBtn.hidden = YES;
    _cancelSaveBtn.hidden = YES;
    _playAudioBtn.hidden = YES;
    [_imageView setImage:[UIImage imageNamed:@"Recorder-1.jpg"]];
    [self recorder];
}

#pragma AVAudioPlayerDelegate method 播放结束后回调函数
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //[self.playAudioBtn setTitle:@"回放" forState:UIControlStateNormal];
    //[_removeBtn setEnabled:YES];  //返回键解锁
    
}

@end







