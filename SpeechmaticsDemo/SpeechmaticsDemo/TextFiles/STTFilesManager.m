//
//  TextFilesManager.m
//  AgoraSTT_XF
//
//  Created by FanPengpeng on 2022/4/1.
//

#import "STTFilesManager.h"

static NSString * const kTextDir = @"ResultTexts";

@implementation STTFilesManager

+ (NSString *)rootDirPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = paths.firstObject;
    NSString *dir = [documentPath stringByAppendingPathComponent:kTextDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)createFileNameForChannel:(NSString *)channel {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd-HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",channel,dateStr];
    return  fileName;
}


+ (NSArray *)channelDirPaths {
    NSString *dir = [self rootDirPath];
    NSError *error = nil;
    NSArray *channels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
    NSLog(@"channels = %@,error = %@",channels,error.debugDescription);
    return channels;
}

+ (NSArray *)textFileNamesForChannel:(NSString *)channel {
    NSString *channelPath = [[self rootDirPath] stringByAppendingPathComponent:channel];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:channelPath error:nil];
    return  fileNames;
}

+ (NSString *)filePathWithFileName:(NSString *)fileName channel:(NSString *)channel {
    NSString *dir = [self rootDirPath];
    NSString *channelPath = [dir stringByAppendingPathComponent: channel];
    if (![[NSFileManager defaultManager] fileExistsAtPath:channelPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:channelPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [channelPath stringByAppendingPathComponent:fileName];
    return  filePath;
}


+ (void)appendTextToFileWithText:(NSString *)text channel:(NSString *)channel fileName:(NSString *)fileName
{
    NSString *filePath = [self filePathWithFileName:fileName channel:channel];
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSOutputStream *output = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:filePath] append:YES];
    [output open];
    [output write:data.bytes maxLength:data.length];
    [output close];
}

+ (void)writeToFileWithText:(NSString *)text channel:(NSString *)channel fileName:(NSString *)fileName {
    NSString *filePath = [self filePathWithFileName:fileName channel:channel];
    NSData *newData = [text dataUsingEncoding:NSUTF8StringEncoding];
    BOOL success = [newData writeToFile:filePath atomically:YES];
    NSLog(@"success == %d",success);
}

@end
