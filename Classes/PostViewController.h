//
//  PostViewController.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 01/09/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostViewController : UIViewController {
	IBOutlet UILabel *labelTitle;
	IBOutlet UILabel *labelDate;
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *textView;
	IBOutlet UIButton *button;
	NSMutableDictionary *item;
	UIBarButtonItem *buttonLink;
	UIBarButtonItem *buttonPlay;
}

@property (nonatomic, retain) IBOutlet UILabel *labelTitle;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableDictionary *item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(NSMutableDictionary *)_item;
- (IBAction) openSafari:(id)sender;
- (void) openBrowser;

@end
