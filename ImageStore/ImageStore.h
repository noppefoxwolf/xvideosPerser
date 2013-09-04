// Created by Satoshi Nakagawa.
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>


@interface ImageStore : NSObject
{
    id delegate;
    NSMutableDictionary* images;
    NSMutableDictionary* conns;
}

@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)aDelegate;

- (UIImage*)getImage:(NSString*)url;

- (void)cancelAllConnections;
- (void)cancelConnectionForUrl:(NSString*)url;

- (void)setImage:(UIImage*)image forUrl:(NSString*)url;
- (void)clearAllImages;
- (void)clearImageForUrl:(NSString*)url;

@end


@interface NSObject (ImageStoreDelegate)
- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url;
- (void)imageStoreDidFailDownload:(ImageStore*)sender error:(NSError*)error statusCode:(int)statusCode;
@end
