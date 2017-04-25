//
//  NSObject+File.m
//  MyRecorderDemo
//
//  Created by qq on 2017/4/25.
//  Copyright © 2017年 qq. All rights reserved.
//

#import "NSObject+File.h"

@implementation NSObject(File)

-(void)deleteFile:(NSString*)filePath{
    if([[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
}

-(void)moveFile:(NSString *)fromPath toFile:(NSString *)toPath error:(NSError *__autoreleasing *)error{
    [self deleteFile:toPath];// 先删除目标文件，否则后面的 move 方法会失败
    [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:fromPath] toURL:[NSURL fileURLWithPath:toPath] error:error];
}
@end
