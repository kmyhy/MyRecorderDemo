//
//  NSTimer+Pause.m
//  MyRecorderDemo
//
//  Created by qq on 2017/4/24.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "NSTimer+Pause.h"

@implementation NSTimer(Pause)

- (void)pauseTimer {
    
    //如果已被释放则return！isValid对应invalidate
    if (![self isValid]) return;
    //启动时间为很久以后
    [self setFireDate:[NSDate distantFuture]];
}

- (void)continueTimer {
    
    if (![self isValid]) return;
    //启动时间为现在
    [self setFireDate:[NSDate date]];
}

@end
