//
//  NewsView.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 21/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//


#import <UIKit/UIKit.h>

@class NewsView;

@protocol NewsViewDelegate <NSObject>
@optional
- (void)newsViewDidTouch:(NewsView *)newsView;
@end

typedef enum {		
    NewsViewModeImageUpBig = 0, // Image up, half of frame height
    NewsViewModeImageUpSmall,  // Image up, third of frame height
    NewsViewModeImageDown, // Image next to text, half of frame width
} NewsViewMode;

@interface NewsView : UIView {
	id <NewsViewDelegate> delegate;
	NewsViewMode mode;
	UILabel *labelTitle;
	UILabel *labelCreator;
	UILabel *labelDate;
	UILabel *labelSummary;
	UIImageView *imageView;
	UIActivityIndicatorView *activityIndicatorView;
	NSString *title;
	NSString *creator;
	NSString *date;
	NSString *summary;
	NSString *url;
	UIImage *image;
}

@property (nonatomic, assign) id <NewsViewDelegate> delegate;
@property (nonatomic, assign) NewsViewMode mode;
@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UILabel *labelCreator;
@property (nonatomic, retain) UILabel *labelDate;
@property (nonatomic, retain) UILabel *labelSummary;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *creator;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame title:(NSString *)_title creator:(NSString *)_creator date:(NSString*)_date summary:(NSString *)_summary url:(NSString *)_url image:(UIImage *)_image mode:(NewsViewMode)_mode;
- (void)setImage:(UIImage*)_image;

@end
