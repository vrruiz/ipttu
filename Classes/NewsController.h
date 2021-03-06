//
//  NewsController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 21/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTTUFeedDownloader.h"
#import "NewsView.h"
#import "AboutViewController.h"

@class PageControl;
@class WebViewController;

@interface NewsController : UIViewController <UIScrollViewDelegate, PTTUFeedDownloaderDelegate,
NewsViewDelegate, UIActionSheetDelegate, AboutViewControllerDelegate> {
	UIView *scrollSuperview;
	UIScrollView *scrollView;
	WebViewController *webViewController;
	AboutViewController *aboutViewController;
	PageControl *pageControl;
	UIImageView *viewButtonSection;
	UILabel *labelDate;
	UILabel *labelSection;
	UIButton *buttonSection;
	NSInteger storyIndex;
	NSString *activeSection;
	NSMutableArray *stories;
	PTTUFeedDownloader *news;
	PTTUFeedDownloader *posts;
	PTTUFeedDownloader *feedActive;
	NSMutableDictionary *postViewDict;
    NSInteger finishedDownloadsCount;
}

@property (nonatomic, retain) IBOutlet UIView *scrollSuperview;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet PageControl *pageControl;
@property (nonatomic, retain) IBOutlet UIImageView *viewButtonSection;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UILabel *labelSection;
@property (nonatomic, retain) IBOutlet UIButton *buttonSection;
@property (nonatomic, retain) WebViewController *webViewController;
@property (nonatomic, retain) AboutViewController *aboutViewController;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) PTTUFeedDownloader *news;
@property (nonatomic, retain) PTTUFeedDownloader *posts;
@property (nonatomic, retain) NSMutableDictionary *postViewDict;

- (IBAction)sectionDidClick:(id)sender;
- (IBAction)refreshDidClick:(id)sender;

@end
