//
//  MyRecorder.m
//  MyRecorderDemo
//
//  Created by qq on 2017/4/25.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "MyRecorder.h"
#import "NSTimer+Pause.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+ComposeM4a.h"
#import "NSObject+File.h"

@interface MyRecorder()<AVAudioRecorderDelegate>
@property (strong,nonatomic) NSTimer * timer;
@property (strong,nonatomic) NSTimer * volumeTimer;


//@property (strong,nonatomic) AVAudioSession* session;
@property (assign,nonatomic)NSInteger second;// 计时秒数
@property (strong,nonatomic) AVAudioRecorder* recorder;

@end

@implementation MyRecorder

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static id _sInstance;
    dispatch_once(&onceToken, ^{
        _sInstance = [[self alloc] init];
    });
    
    return _sInstance;
}
-(instancetype)init{
    self = [super init];
    // 因为录音文件比较大，所以我们把它存在Temp文件里，Temp文件里的文件在app重启的时候会自动删除
    self.recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"record.m4a"];
    self.recordUrl = [NSURL fileURLWithPath:_recordFilePath];
    
    // 合并的中间文件
    self.resultPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"intermediatePath.m4a"];
    self.resultURL = [NSURL fileURLWithPath:_resultPath];
    
    // 合并后的录音文件
    self.coalescentPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"coalescent.m4a"];
    self.coalescentURL = [NSURL fileURLWithPath:_coalescentPath];
    
    self.maxRecordSeconds = 180;
    
    self.state = MyRecorderStateIsReady;
    
    return self;
}

/// 获取麦克风权限
-(void)getPermission:(void(^)())success{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        
        __weak __typeof(self) weakSelf = self;
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                
                // 用户同意获取麦克风，一定要在主线程中执行UI操作！！！
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //在主线程中执行UI，这里主要是执行录音和计时的UI操作
                    if(success){success();}
                });
            } else {
                
                [weakSelf.delegate recorderGetPermissionFailed:weakSelf];
            }
        }];
    }
}
// MARK: - Getter/Setter
-(void)setState:(MyRecorderState)state{
    _state= state;
    
    [_delegate recorder:self stateChanged:state];
}
-(void)setSecond:(NSInteger)second{
    _second = second;
    [_delegate recorder:self secondChanged:second];
}


// MARK: - 录音控制
// 开始/继续录音
-(void)beginOrResumeRecord{
    
    __weak __typeof(self) weakSelf = self;
    [self getPermission:^{
        AVAudioSession* session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        //判断后台有没有播放
        if (session == nil) {
            
            NSLog(@"Error creating sessing:%@", [sessionError description]);
        } else {
            //关闭其他音频播放，把自己设为活跃状态
            [session setActive:YES error:nil];
        }
        
        if (![weakSelf.timer isValid]) {// 定时器为空
            
            [weakSelf startTimer];
            
        } else {
            
            //这个方法是写了一个NSTimer的拓展类 Category,具体方法在下面附上代码
            [weakSelf.timer continueTimer];
            [weakSelf.volumeTimer continueTimer];
        }
        
        //设置AVAudioRecorder
        if (!weakSelf.recorder) {
            
            if([[NSFileManager defaultManager]fileExistsAtPath:_coalescentPath]){
                [[NSFileManager defaultManager] removeItemAtPath:_coalescentPath error:nil];
            }
            
            //            NSDictionary *settings = @{AVFormatIDKey  :  @(kAudioFormatLinearPCM), AVSampleRateKey : @(11025.0), AVNumberOfChannelsKey :@2, AVEncoderBitDepthHintKey : @16, AVEncoderAudioQualityKey : @(AVAudioQualityHigh)};
            
            NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
            
            //开始录音,将所获取到得录音存到文件里 _recordUrl 是存放录音的文件路径
            weakSelf.recorder = [[AVAudioRecorder alloc] initWithURL:weakSelf.recordUrl settings:settings error:nil];
            weakSelf.recorder.delegate = self;
            
            /*
             * settings 参数
             1.AVNumberOfChannelsKey 通道数 通常为双声道 值2
             2.AVSampleRateKey 采样率 单位HZ 通常设置成44100 也就是44.1k,采样率必须要设为11025才能使转化成mp3格式后不会失真
             3.AVLinearPCMBitDepthKey 比特率 8 16 24 32
             4.AVEncoderAudioQualityKey 声音质量
             ① AVAudioQualityMin  = 0, 最小的质量
             ② AVAudioQualityLow  = 0x20, 比较低的质量
             ③ AVAudioQualityMedium = 0x40, 中间的质量
             ④ AVAudioQualityHigh  = 0x60,高的质量
             ⑤ AVAudioQualityMax  = 0x7F 最好的质量
             5.AVEncoderBitRateKey 音频编码的比特率 单位Kbps 传输的速率 一般设置128000 也就是128kbps
             
             */
        }
        
        //准备记录录音
        [weakSelf.recorder prepareToRecord];
        
        //开启仪表计数功能,必须开启这个功能，才能检测音频值
        [weakSelf.recorder setMeteringEnabled:YES];
        //启动或者恢复记录的录音文件
        [weakSelf.recorder record];
        // 更新麦克风电压值
        [weakSelf.recorder updateMeters];
        weakSelf.state = MyRecorderStateRecording;
    }];
}
/// 暂停
-(void)pauseRecord{// 暂停的时候会进行录音文件合并
    [self.timer pauseTimer];
    [self.volumeTimer pauseTimer];
    
    [self.recorder stop];// 实际上暂停也是结束录音，只是录音数据被合并到之前的录音内容里
    
    self.state = MyRecorderStatePaused;
    
    if([[NSFileManager defaultManager]fileExistsAtPath:_coalescentPath isDirectory:nil]){
        // 如果之前有合并过，合并文件+当前录音
        __weak __typeof(self) weakSelf = self;
        [self sourceURLs:@[_coalescentURL,_recordUrl] composeToURL:_resultURL completed:^(NSError *err) {
            NSError* error;

            [self moveFile:weakSelf.resultPath toFile:weakSelf.coalescentPath error:&error];
            if(error){
                NSLog(@"%@",error);
            }else{
                [weakSelf deleteFile:weakSelf.resultPath];
            }
        }];
        
    }else{// 如果以前没合并过，直接将录音文件拷贝到合并文件
        
        [[NSFileManager defaultManager] copyItemAtURL:_recordUrl toURL:_coalescentURL error:nil];
    }
    
}
/// 停止
-(void)stopRecord{
    
    [self.timer invalidate];
    [self.volumeTimer invalidate];
    [self.recorder stop];
        
    [self deleteFile:_resultPath];// 删除合并中间文件
    [self deleteFile:_coalescentPath];// 删除合并文件
    [self deleteFile:_recordFilePath];// 删除录音文件
    self.recorder= nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    int flags = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    [session setActive:NO withOptions:flags error:nil];
}
/// 重录
- (void)redoRecord{
    [self stopRecord];
    [self.recorder deleteRecording];
    self.second = 0;
    self.state = MyRecorderStateIsReady;
    [self beginOrResumeRecord];
}
/// MARK: - 定时器相关
- (void)startTimer {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSecond:) userInfo:nil repeats:YES];
    _volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateVolume) userInfo:nil repeats:YES];
}
- (void)updateSecond:(NSTimer *)timer {
    
    _second ++;
    if (_second >= _maxRecordSeconds) {
        
        [self pauseRecord];
    }
    [_delegate recorder:self secondChanged:_second];
}
- (void)updateVolume{
    [self.recorder updateMeters];
    double avgPowerForChannel = pow(10, (0.05 * [self.recorder averagePowerForChannel:0]));
    [_delegate recorder:self powerChanged:avgPowerForChannel];
}

// MARK: - AVAudioRecorderDelegate
/// 录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}
/// 编码发生错误
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"%@",error);
}

@end
