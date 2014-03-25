//
//  RecordAudioView.h
//  StuentEvaluation
//
//  Created by admin  on 13-12-23.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioViewDelegate <NSObject>

-(void)removeAudioView:(BOOL)isSaved;

@end

@interface RecordAudioView : UIView<AVAudioPlayerDelegate>

@property (nonatomic, retain) NSURL *recordedFile;
@property (nonatomic, retain) AVAudioPlayer *playerAudio;   //录音相关量
@property (nonatomic, retain) AVAudioRecorder *recorderAudio;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) BOOL isSaved;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIButton *saveFileBtn;
@property (nonatomic, retain) UIButton *cancelSaveBtn;
@property (nonatomic, retain) UIButton *playAudioBtn;

@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)delegate;
-(void)resetValue;
@end
