//
//  AboutViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 08/10/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutViewController;

@protocol AboutViewControllerDelegate <NSObject>
@optional
- (void)aboutViewControllerDidTouch:(AboutViewController *)aboutView;
@end

@interface AboutViewController : UIViewController <UIWebViewDelegate> {
	id <AboutViewControllerDelegate> delegate;
	UIWebView *webView;
	UIBarButtonItem *buttonClose;
}

@property (nonatomic, assign) id <AboutViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonClose;

- (IBAction)buttonCloseDidTouch:(id)sender;

@end
