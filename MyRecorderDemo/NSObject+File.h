//
//  NSObject+File.h
//  MyRecorderDemo
//
//  Created by qq on 2017/4/25.
//  Copyright © 2017年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(File)

-(void)deleteFile:(NSString*)filePath;

-(void)moveFile:(NSString*)fromPath toFile:(NSString*)toPath error:(NSError**)error;
@end
