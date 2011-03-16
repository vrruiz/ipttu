//
//  PTTUFeedDownloader.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 23/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTTUFeedDownloader;

@protocol PTTUFeedDownloaderDelegate <NSObject>
@optional
- (void)feedDownloaderFeedDidFinish:(PTTUFeedDownloader *)feedDownloader;
- (void)feedDownloaderImageDidFinish:(PTTUFeedDownloader *)feedDownloader postIndex:(NSNumber *)index;
- (void)feedDownloaderDidFinish:(PTTUFeedDownloader *)feedDownloader;
@end

@interface PTTUFeedDownloader : NSObject {
	NSMutableArray *stories;
	NSString *feedUrl;
    NSDate *lastUpdated;
	id <PTTUFeedDownloaderDelegate> delegate;
}

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSString *feedUrl;
@property (nonatomic, assign) id <PTTUFeedDownloaderDelegate> delegate;

- (id)initWithUrl:(NSString *)url;
- (void)startDownloading;


@end
