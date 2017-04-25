//
//  NSObject+ComposeM4a.h
//  MyRecorderDemo
//
//  Created by qq on 2017/4/25.
//  Copyright © 2017年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(ComposeM4a)

/// 将多个 m4a 文件前后拼接成 1 个
-(void) sourceURLs:(NSArray *) sourceURLs composeToURL:(NSURL *) toURL completed:(void (^)(NSError *error)) completed;
@end
