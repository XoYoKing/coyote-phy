//
//  QuestionViewController.h
//  StuentEvaluation
//
//  Created by admin  on 13-12-21.
//  Copyright (c) 2013年 com.seuli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegueStatusListener.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordAudioView.h"
#import "MulButtonView.h"

@interface QuestionViewController : UIViewController<AudioViewDelegate,MulButtonDelegate,SegueStatusListener>

@property (nonatomic) int count;
@property (nonatomic, retain) NSMutableArray *questionList;
@property (nonatomic, retain) NSMutableDictionary *item;
@property (nonatomic, retain) NSMutableArray *replies;
@property (nonatomic, retain) NSMutableArray *dynamicPictureArr;
@property (nonatomic, retain) NSMutableDictionary *uploadParma;

@property (nonatomic) BOOL endTestSign;  //判断是否答题完毕
@property (nonatomic) BOOL isRecording;  //判断是否录音完毕

@property (nonatomic, retain) UILabel *numberLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UIImageView *questionImageView;
@property (nonatomic, retain) UIImageView *dynamicImageView;
@property (nonatomic, retain) UIButton *nextStep;
@property (nonatomic, retain) RecordAudioView *audioView;
@property (nonatomic, retain) MulButtonView *mulButtonView;


@end
