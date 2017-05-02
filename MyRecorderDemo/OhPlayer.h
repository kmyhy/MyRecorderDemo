//
//  OhPlayer.h
//  Client
//
//  Created by qq on 2017/5/2.
//  Copyright © 2017年 qq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,OhPlayerState){
    OhPlayerStateIsReady=0,// 初始状态
    OhPlayerStatePlaying,// 试听
    OhPlayerStatePause,// 暂停
    OhPlayerStateStopped,// 停止
};

@class OhPlayer;
@protocol OhPlayerDelegate <NSObject>

@required
-(void)player:(OhPlayer*)player stateChanged:(OhPlayerState)state;
-(void)player:(OhPlayer *)player playingTimeChanged:(double)second;

@end



@interface OhPlayer : NSObject
@property (assign,nonatomic)OhPlayerState state;
@property (strong,nonatomic)NSURL* musicURL;
@property(weak,nonatomic)id<OhPlayerDelegate> delegate;

+ (instancetype)sharedInstance;
/// 试听
-(void)play:(NSURL*)url;
/// 停止
-(void)stopPlay;

@end
