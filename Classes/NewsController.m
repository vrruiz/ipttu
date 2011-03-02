//
//  NewsController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 21/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "WebViewController.h"
#import "PTTUFeedDownloader.h"
#import "NewsView.h"
#import "NewsController.h"
#import "PageControl.h"

@implementation NewsController

@synthesize scrollSuperview;
@synthesize scrollView;
@synthesize pageControl;
@synthesize labelDate;
@synthesize buttonSection;
@synthesize labelSection;
@synthesize webViewController;
@synthesize news;
@synthesize posts;
@synthesize postViewDict;

#define MAX_PAGES 6
#define POSTS_PER_PAGE 3

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (NewsView *)newsViewWithFrame:(CGRect)rect mode:(NewsViewMode)mode {
	// Create a news view with coordinate rect
	// Automatically fills the content with stories
	if (storyIndex >= [stories count]) return nil;
	// Get post at index
	NSMutableDictionary *post = [stories objectAtIndex:storyIndex];
	// Read image
	UIImage *image = [UIImage imageWithData:[post objectForKey:@"imageFile"]];
	// Create news view
	NewsView *newsView = [[[NewsView alloc] initWithFrame:rect
												   title:[post objectForKey:@"title"]
												 creator:[post objectForKey:@"dc:creator"]
												 summary:[post objectForKey:@"summary"]
													 url:[post objectForKey:@"link"]
												   image:image
													mode:mode] autorelease];
	if (newsView) {
		// Set delegate
		newsView.delegate = self;
		// Save post <-> view reference dictionary
		[postViewDict setObject:newsView forKey:[NSNumber numberWithInteger:storyIndex]];
	}
	// Autoincrement story index
	storyIndex++;
	return newsView;
}

- (CGRect)rectWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
	// Returns a CGRect based on two points
	return CGRectMake(point1.x, point1.y, point2.x - point1.x, point2.y - point1.y);
}

- (CGPoint)pointWithPoint:(CGPoint)point addPoint:(CGPoint)margin {
	// Returns a CGPoint 
	return CGPointMake(point.x + margin.x, point.y + margin.y);
}

- (CGPoint)pointWithPoint:(CGPoint)point subPoint:(CGPoint)margin {
	// Returns a CGPoint 
	return CGPointMake(point.x - margin.x, point.y - margin.y);
}

- (UIView *)createNewsPage {
	// Create news page view. Returns an UIView with the content of the page.
	
	CGFloat margin = 20.0; // Margin between news
	
	// Set size
	CGRect rectNewsPage = scrollView.frame;
	rectNewsPage.origin.x = 0;
	rectNewsPage.origin.y = 0;

	// Create page view
	UIView *newsPage = [[[UIView alloc] initWithFrame:rectNewsPage] autorelease];
	
	// Create news view
	CGFloat w = scrollView.frame.size.width;
	CGFloat h = scrollView.frame.size.height;
	
	// Random seed
	int static style = 0; // arc4random() % 2;
	
	// Points
	// 1--2--3
	// |  |  |
	// 4--5--6
	// |  |  |
	// 7--8--9
	CGPoint pointTopLeft = CGPointMake(margin, 0.0);
	CGPoint pointTopCenter = CGPointMake(w / 2.0, 0.0);
	CGPoint pointTopRight = CGPointMake(w - margin, 0.0);
	CGPoint pointMiddleLeft = CGPointMake(margin, h / 2.0);
	CGPoint pointMiddleCenter = CGPointMake(w / 2.0, h / 2.0);
	CGPoint pointMiddleRight = CGPointMake(w - margin, h / 2.0);
	CGPoint pointBottomLeft = CGPointMake(margin, h - margin);
	CGPoint pointBottomCenter = CGPointMake(w / 2.0, h - margin);
	CGPoint pointBottomRight = CGPointMake(w - margin, h - margin);

	// Points with half margin
	// +----1-+-2----+
	// |      |      |
	// |    3 | 4    5
	// +------+------+
	// 6    7 | 8    9
	// |      |      |
	// +---10-+-11--12
	CGPoint marginX = CGPointMake(margin, 0.0);
	CGPoint marginY = CGPointMake(0.0, margin);
	CGPoint marginXY = CGPointMake(margin, margin);
	CGPoint marginHalfX = CGPointMake(margin / 2.0, 0.0);
	CGPoint marginHalfY = CGPointMake(0.0, margin / 2.0);
	CGPoint marginHalfXY = CGPointMake(margin / 2.0, margin / 2.0); 
	
	if (style == 0) {
		// | 1       |
		// |         |
		// +----+----+
		// | 2  | 3  |
		// |    |    |
		
		CGRect rectNews = CGRectMake(margin, 0, w - margin * 2, h / 2 - margin / 2);
		NewsView *newsView = [self newsViewWithFrame:rectNews mode:NewsViewModeImageDown];
		[newsPage addSubview:newsView];
		
		// Horizontal separator
		CGRect rectHSeparator = CGRectMake(margin, h / 2, w - margin * 2, 1);
		UIView *viewHSep = [[[UIView alloc] initWithFrame:rectHSeparator] autorelease];
		viewHSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewHSep];
		
		// Vertical separator
		CGRect rectVSeparator = CGRectMake(w / 2, h / 2 + margin, 1, h / 2 - margin);
		UIView *viewVSep = [[[UIView alloc] initWithFrame:rectVSeparator] autorelease];
		viewVSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewVSep];
		
		// Create news view
		CGRect rectNews2 = CGRectMake(margin, h / 2 + margin / 2, w / 2 - margin * 1.5, h / 2 - margin / 2);
		NewsView *newsView2 = [self newsViewWithFrame:rectNews2 mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView2];
		
		// Create news view
		CGRect rectNews3 = CGRectMake(w / 2 + margin / 2, h / 2 + margin / 2, w / 2 - margin * 1.5, h / 2 - margin / 2);
		NewsView *newsView3 = [self newsViewWithFrame:rectNews3 mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView3];
	} else if (style == 2) {
		// | 1  | 2  |
		// |    |    |
		// +----+----+
		// | 3       |
		// |         |
		
		// Create news view
		CGRect rectNews = [self rectWithPoint:pointTopLeft
									 andPoint:[self pointWithPoint:pointMiddleCenter
														  subPoint:marginHalfXY]];
		NewsView *newsView = [self newsViewWithFrame:rectNews mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView];
		
		// Create news view
		CGRect rectNews2 = [self rectWithPoint:[self pointWithPoint:pointTopCenter
														   addPoint:marginHalfX]
									  andPoint:[self pointWithPoint:pointMiddleRight
														   subPoint:marginHalfY]];
		NewsView *newsView2 = [self newsViewWithFrame:rectNews2 mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView2];
		
		// Vertical separator
		CGRect rectVSeparator = [self rectWithPoint:pointTopCenter
										   andPoint:[self pointWithPoint:pointMiddleCenter
																addPoint:CGPointMake(1.0, 0.0)]];
		UIView *viewVSep = [[[UIView alloc] initWithFrame:rectVSeparator] autorelease];
		viewVSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewVSep];
		
		// Horizontal separator
		CGRect rectHSeparator = [self rectWithPoint:pointMiddleLeft
										   andPoint:[self pointWithPoint:pointMiddleRight
																addPoint:CGPointMake(0.0, 1.0)]];
		UIView *viewHSep = [[[UIView alloc] initWithFrame:rectHSeparator] autorelease];
		viewHSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewHSep];
		
		// Create news view
		CGRect rectNews3 = [self rectWithPoint:[self pointWithPoint:pointMiddleLeft
														   addPoint:marginHalfY]
									  andPoint:pointBottomRight];
		NewsView *newsView3 = [self newsViewWithFrame:rectNews3 mode:NewsViewModeImageDown];
		[newsPage addSubview:newsView3];

	} else if (style == 1) {
		// | 1  | 2  |
		// |    |    |
		// |    +----+
		// |    | 3  |
		// |    |    |
		
		// Create news view
		CGRect rectNews = [self rectWithPoint:pointTopLeft
									 andPoint:[self pointWithPoint:pointBottomCenter
														  subPoint:marginHalfX]];
		NewsView *newsView = [self newsViewWithFrame:rectNews mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView];
		
		// Create news view
		CGRect rectNews2 = [self rectWithPoint:[self pointWithPoint:pointTopCenter
														   addPoint:marginHalfX]
									  andPoint:[self pointWithPoint:pointMiddleRight
														   subPoint:marginHalfY]];
		NewsView *newsView2 = [self newsViewWithFrame:rectNews2 mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView2];
		
		// Create news view
		CGRect rectNews3 = [self rectWithPoint:[self pointWithPoint:pointMiddleCenter
														   addPoint:marginHalfXY]
									  andPoint:pointBottomRight];
		NewsView *newsView3 = [self newsViewWithFrame:rectNews3 mode:NewsViewModeImageDown];
		[newsPage addSubview:newsView3];
		
		// Vertical separator
		CGRect rectVSeparator = [self rectWithPoint:pointMiddleCenter
										   andPoint:[self pointWithPoint:pointMiddleRight
																addPoint:CGPointMake(0.0, 1.0)]];
		UIView *viewVSep = [[[UIView alloc] initWithFrame:rectVSeparator] autorelease];
		viewVSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewVSep];
		
		// Horizontal separator
		CGRect rectHSeparator = [self rectWithPoint:pointTopCenter
										   andPoint:[self pointWithPoint:pointBottomCenter
																addPoint:CGPointMake(1.0, 0.0)]];
		UIView *viewHSep = [[[UIView alloc] initWithFrame:rectHSeparator] autorelease];
		viewHSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewHSep];
		
	} else {
		// | 1  | 2  |
		// |    |    |
		// +----+    |
		// | 3  |    |
		// |    |    |
		
		// Create news view
		CGRect rectNews = [self rectWithPoint:pointTopLeft
									 andPoint:[self pointWithPoint:pointMiddleCenter
														  subPoint:marginHalfXY]];
		NewsView *newsView = [self newsViewWithFrame:rectNews mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView];
		
		// Create news view
		CGRect rectNews2 = [self rectWithPoint:[self pointWithPoint:pointTopCenter
														   addPoint:marginHalfX]
									  andPoint:pointBottomRight];
		NewsView *newsView2 = [self newsViewWithFrame:rectNews2 mode:NewsViewModeImageUpBig];
		[newsPage addSubview:newsView2];
		
		// Create news view
		CGRect rectNews3 = [self rectWithPoint:[self pointWithPoint:pointMiddleLeft
														   addPoint:marginHalfY]
									  andPoint:[self pointWithPoint:pointBottomCenter
														   subPoint:marginHalfX]];
		NewsView *newsView3 = [self newsViewWithFrame:rectNews3 mode:NewsViewModeImageDown];
		[newsPage addSubview:newsView3];
		
		// Vertical separator
		CGRect rectVSeparator = [self rectWithPoint:pointMiddleLeft
										   andPoint:[self pointWithPoint:pointMiddleCenter
																addPoint:CGPointMake(0.0, 1.0)]];
		UIView *viewVSep = [[[UIView alloc] initWithFrame:rectVSeparator] autorelease];
		viewVSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewVSep];
		
		// Horizontal separator
		CGRect rectHSeparator = [self rectWithPoint:pointTopCenter
										   andPoint:[self pointWithPoint:pointBottomCenter
																addPoint:CGPointMake(1.0, 0.0)]];
		UIView *viewHSep = [[[UIView alloc] initWithFrame:rectHSeparator] autorelease];
		viewHSep.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		[newsPage addSubview:viewHSep];
		
	}
	
	// Next style
	style++;
	if (style == 3) {
		style = 0;
	}
	
	return newsPage;
}

- (void)newsShowWithFeed:(PTTUFeedDownloader *)feed page:(NSInteger)page {
	// Create scroll view
	
	// Remove current scroll view
	CGRect rectScroll = scrollView.frame;
	UIViewAutoresizing autoresizingMask = scrollView.autoresizingMask;
	[scrollView removeFromSuperview];
	
	// Create new scroll view
	scrollView = [[UIScrollView alloc] initWithFrame:rectScroll];
	scrollView.delegate = self;
	scrollView.pagingEnabled = YES;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.alpha = 0.0;
	scrollView.autoresizingMask = autoresizingMask;
	[self.view addSubview:scrollView];
	
	stories = feed.stories;
	storyIndex = 0;
	
	if ([stories count] == 0) return;
	NSMutableDictionary *post = [stories objectAtIndex:0];
	labelDate.text = [post objectForKey:@"date"];
	
	int numPages = [stories count] / POSTS_PER_PAGE;
	if (numPages > MAX_PAGES) numPages = MAX_PAGES; // Limit the number of pages
	
	// Create pages
	CGSize sizeScroll = scrollView.frame.size;
	sizeScroll.width *= numPages;
	scrollView.contentSize = sizeScroll;
	
	for (int i = 0; i < numPages; i++) {
		UIView *page = [self createNewsPage];
		CGRect rect = page.frame;
		rect.origin.x = scrollView.frame.size.width * i;
		page.frame = rect;
		[scrollView addSubview:page];
	}
	
	// Page control settings
	pageControl.alpha = 0.0;
	pageControl.numberOfPages = numPages;
	pageControl.currentPage = 0;
	
	// Move to current page
	if (page > 0 && page < numPages) {
		pageControl.currentPage = page;
		CGPoint scrollOffset = scrollView.contentOffset;
		scrollOffset.x = scrollView.frame.size.width * page;
		scrollView.contentOffset = scrollOffset;
	}

	// Scroll view transition from alpha 0.0 to 1.0
	[UIView animateWithDuration:0.75 animations:^{
		scrollView.alpha = 1.0;
		pageControl.alpha = 1.0;
	}
					 completion:^(BOOL finished){}];

}

- (void)newsShowWithFeed:(PTTUFeedDownloader *)feed {
	[self newsShowWithFeed:feed page:0];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Init
	postViewDict = [[NSMutableDictionary alloc] init];
	
	// Sets page control dot colors
	pageControl.backgroundColor = [UIColor clearColor];
	pageControl.dotColorCurrentPage = [UIColor blackColor];
	pageControl.dotColorOtherPage = [UIColor lightGrayColor];
	
	// Download the feeds
	news = [[PTTUFeedDownloader alloc] initWithUrl:@"http://www.portaltotheuniverse.org/rss/news/featured/"];
	news.delegate = self;
	[news startDownloading];
	
	posts = [[PTTUFeedDownloader alloc] initWithUrl:@"http://www.portaltotheuniverse.org/rss/blogs/posts/featured/"];
	posts.delegate = self;
	[posts startDownloading];
	
	// Active section = Featured news
	feedActive = news;
}


#pragma mark -
#pragma mark Rotation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// Resize scroll view content size
	[self newsShowWithFeed:feedActive page:pageControl.currentPage];
}


#pragma mark -
#pragma mark PTTUFeedDownloaderDelegate methods

- (void)feedDownloaderDidFinish:(PTTUFeedDownloader *)feedDownloader {
	// Feeds and images downloaded
	NSLog(@"feedDownloaderDidFinish");
	
	if (feedActive != feedDownloader) return; // Feed downloaded, but not active
	
	// Show stories
	[self newsShowWithFeed:feedDownloader];
}

- (void)feedDownloaderImageDidFinish:(PTTUFeedDownloader *)feedDownloader postIndex:(NSNumber *)index {
	// Image downloaded. Update view.
	if (feedActive != feedDownloader) return; // No need to refresh the view.
	NewsView *newsView = [postViewDict objectForKey:index];
	if (newsView) {
		// Read image data from dictionary
		NSData *data = [[stories objectAtIndex:[index intValue]] objectForKey:@"imageFile"];
		// Set image
		newsView.image = [UIImage imageWithData:data];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	// Scrolled to new page. Update PageControl
    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	// NSInteger upperNumber = lowerNumber + 1;
	pageControl.currentPage = lowerNumber;
}


#pragma mark -
#pragma mark NewsViewDelegate methods

- (void)dismissWebView:(id)sender {
	// Back from WebViewController. Close and release memory.
	[webViewController dismissModalViewControllerAnimated:YES];
	[webViewController release];
	webViewController = nil;
}

- (void)newsViewDidTouch:(NewsView *)newsView {
	// NewsView touched. Open WebViewController;
	webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController-iPad" bundle:nil url:newsView.url];
	[self presentModalViewController:webViewController animated:YES];
	// Hook "back" button to dismissWebView action
	[webViewController.buttonDismiss addTarget:self action:@selector(dismissWebView:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark -
#pragma mark Actions

- (IBAction)sectionDidClick:(id)sender {
	// Click on section name. Show section list.
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Sections"
															 delegate:self
													cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													otherButtonTitles:@"Featured News", @"Featured Blogs", nil] autorelease];
	[actionSheet showFromRect:labelSection.frame inView:self.view animated:YES];
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Load other section
	PTTUFeedDownloader *switchTo = nil;
	switch (buttonIndex) {
		case 0:
			// Featured News
			switchTo = news;
			break;
		case 1:
			// Featured Posts
			switchTo = posts;
			break;
		default:
			// Cancel
			return;
			break;
	}
	
	if (feedActive == switchTo) return; // Current section
	
	// Switch to new section
	feedActive = switchTo;
	labelSection.text = [actionSheet buttonTitleAtIndex:buttonIndex];
	// Update scroll view. Lengthy proccess, so perform after closing the action sheet.
	[self performSelector:@selector(newsShowWithFeed:) withObject:feedActive afterDelay:0.01];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (webViewController) [webViewController release];
	[postViewDict release];
	[news release];
	[posts release];
	[buttonSection release];
	[labelSection release];
	[labelDate release];
	[stories release];
	[scrollView release];
	[scrollSuperview release];
	[pageControl release];
    [super dealloc];
}


@end
