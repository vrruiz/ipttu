//
//  PageControl.h
//
//  Replacement for UIPageControl because that one only supports white dots.
//
//  Created by Morten Heiberg <morten@heiberg.net> on November 1, 2010.
//
//  Snippet: http://stackoverflow.com/questions/2942636/how-i-change-the-color-of-pagination-dots-of-uipagecontrol

#import <UIKit/UIKit.h>

@protocol PageControlDelegate;

@interface PageControl : UIView {
@private
    NSInteger _currentPage;
    NSInteger _numberOfPages;
    UIColor *dotColorCurrentPage;
    UIColor *dotColorOtherPage;
    NSObject<PageControlDelegate> *delegate;
}

// Set these to control the PageControl.
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

// Customize these as well as the backgroundColor property.
@property (nonatomic, retain) UIColor *dotColorCurrentPage;
@property (nonatomic, retain) UIColor *dotColorOtherPage;

// Optional delegate for callbacks when user taps a page dot.
@property (nonatomic, assign) NSObject<PageControlDelegate> *delegate;

- (id)init;
- (id)initWithFrame:(CGRect)frame;

@end

@protocol PageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(PageControl *)pageControl;
@end