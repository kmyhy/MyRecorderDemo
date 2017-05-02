//
//  MyRecorder.h
//  MyRecorderDemo
//
//  Created by qq on 2017/4/25.
//  Copyright © 2017年 qq. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,MyRecorderState){
    MyRecorderStateIsReady=0,// 初始状态
    MyRecorderStateRecording, // 开始
    MyRecorderStatePaused,// 暂停录音
};

@class MyRecorder;
@protocol MyRecorderDelegate <NSObject>

@required
-(void)recorder:(MyRecorder*)recorder stateChanged:(MyRecorderState)state;
-(void)recorderGetPermissionFailed:(MyRecorder*)recorder;
-(void)recorder:(MyRecorder*)recorder secondChanged:(NSInteger)second;
-(void)recorder:(MyRecorder *)recorder powerChanged:(double)power;

@end


@interface MyRecorder : NSObject
@property(weak,nonatomic)id<MyRecorderDelegate> delegate;
@property (assign,nonatomic)MyRecorderState state;
@property (copy,nonatomic)NSString* recordFilePath; // 录音文件路径
@property (strong,nonatomic)NSURL* recordUrl;
@property (strong,nonatomic)NSURL* resultURL;       // 最后合成的录音文件路径
@property (copy,nonatomic)NSString* resultPath;
@property (strong,nonatomic)NSURL* coalescentURL;   // 合成时的临时文件
@property (copy,nonatomic)NSString* coalescentPath;

@property (assign,nonatomic)NSInteger maxRecordSeconds; // 最大允许录制多少秒

+ (instancetype)sharedInstance;

-(instancetype)init;

/// 重录
-(void)redoRecord;
// 开始/继续录音
-(void)beginOrResumeRecord;
/// 暂停
-(void)pauseRecord;
/// 停止
-(void)stopRecord;

@end
