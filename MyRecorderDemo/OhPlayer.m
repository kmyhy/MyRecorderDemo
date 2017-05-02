//
//  OhPlayer.m
//  Client
//
//  Created by qq on 2017/5/2.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "OhPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface OhPlayer()<AVAudioPlayerDelegate>

@property (strong,nonatomic) NSTimer* playingTimer;
@property (strong,nonatomic)AVAudioPlayer* player;

@end
@implementation OhPlayer

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static id _sInstance;
    dispatch_once(&onceToken, ^{
        _sInstance = [[self alloc] init];
    });
    
    return _sInstance;
}
// MARK: - Getter/Setter
-(void)setState:(OhPlayerState)state{
    _state= state;
    
    [_delegate player:self stateChanged:state];
}
// MARK: - Public
/// 试听
-(void)play:(NSURL*)url{
    _musicURL=url;
    if(_musicURL==nil){
        return;
    }
    NSError* error=nil;
    
    //开启接近监视(靠近耳朵的时候听筒播放,离开的时候扬声器播放)
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:_musicURL error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    _player.delegate=self;
    if(error ==nil){
        _player.delegate= self;
        [_player prepareToPlay];
        [_player play];
        self.state =OhPlayerStatePlaying;
        [_delegate player:self playingTimeChanged:0];
        self.playingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updatePlayingTime) userInfo:nil repeats:YES];
    }
}
-(void)stopPlay{
    if(self.state == OhPlayerStatePlaying && self.player != nil){
        [_player stop];
        
        [self.playingTimer invalidate];
        self.state=OhPlayerStateStopped;
    }
}
// MARK: - 定时器相关
-(void)updatePlayingTime{
    if(self.player){
        [_delegate player:self playingTimeChanged:self.player.currentTime];
    }
}
#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        //        NSLog(@"Device is close to user");
        // 通过听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//没黑屏幕
    {
        //        NSLog(@"Device is not close to user");
        // 用扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![self.player isPlaying]) {//没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}
// MARK: -//AVAudioPlayerDelegate
/// 播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.delegate player:self playingTimeChanged:self.player.duration];
    _state = OhPlayerStateStopped;
    [self.delegate player:self stateChanged:OhPlayerStateStopped];
    [self.playingTimer invalidate];
}
/// 解码错误
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    
}

@end
