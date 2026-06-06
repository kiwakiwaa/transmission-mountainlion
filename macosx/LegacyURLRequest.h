// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Foundation/Foundation.h>

typedef void (^TRURLDataCompletionHandler)(NSData* data, NSURLResponse* response, NSError* error);
typedef void (^TRURLDownloadProgressHandler)(long long bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^TRURLDownloadCompletionHandler)(NSURL* location, NSURLResponse* response, NSError* error);

@interface TRURLRequestTask : NSObject

+ (TRURLRequestTask*)dataTaskWithRequest:(NSURLRequest*)request completionHandler:(TRURLDataCompletionHandler)completionHandler;
+ (TRURLRequestTask*)downloadTaskWithRequest:(NSURLRequest*)request
                             progressHandler:(TRURLDownloadProgressHandler)progressHandler
                           completionHandler:(TRURLDownloadCompletionHandler)completionHandler;

- (void)resume;
- (void)cancel;

@end
