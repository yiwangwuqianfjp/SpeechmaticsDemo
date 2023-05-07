//
//  TextFilesManager.h
//  AgoraSTT_XF
//
//  Created by FanPengpeng on 2022/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STTFilesManager : NSObject

/// 获取所有的频道名称
+ (NSArray *)channelDirPaths;

/// 创建文本文件名称
/// @param channel 指定的频道
+ (NSString *)createFileNameForChannel:(NSString *)channel;

/// 获取指定频道名下的所有文件
/// @param channel 频道名称
+ (NSArray *)textFileNamesForChannel:(NSString *)channel;

/// 获取指定的文件路径
/// @param fileName 文件名称
/// @param channel 文件所属的频道名
+ (NSString *)filePathWithFileName:(NSString *)fileName channel:(NSString *)channel;

/// 将文字追加到文件中文本的后面
/// @param text 要写入的文本
/// @param channel 频道
/// @param fileName 文件名称
+ (void)appendTextToFileWithText:(NSString *)text channel:(NSString *)channel fileName:(NSString *)fileName ;

/// 将文字写入指定的频道和指定名称的文件路径
/// @param text 要写入的文本
/// @param channel 频道
/// @param fileName 文件名称
+ (void)writeToFileWithText:(NSString *)text channel:(NSString *)channel fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
