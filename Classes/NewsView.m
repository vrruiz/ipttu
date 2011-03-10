//
//  NewsView.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 21/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//


#import "NewsView.h"

@implementation NewsView

#define PADDING 5.0

@synthesize delegate;
@synthesize mode;
@synthesize labelTitle;
@synthesize labelCreator;
@synthesize labelDate;
@synthesize labelSummary;
@synthesize imageView;
@synthesize activityIndicatorView;
@synthesize title;
@synthesize creator;
@synthesize date;
@synthesize summary;
@synthesize url;
@synthesize image;

// Snippet: http://stackoverflow.com/questions/603907/uiimage-resize-then-crop
- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
	// UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
        else 
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)_title creator:(NSString *)_creator date:(NSString*)_date summary:(NSString *)_summary url:(NSString *)_url image:(UIImage *)_image mode:(NewsViewMode)_mode {
	// Creates a news view (image, source, text, arranged with mode)
	
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.userInteractionEnabled = YES; // Detect touches

		// Set content
		self.mode = _mode;
		self.title = _title;
		self.creator = _creator;
		self.date = _date;
		self.summary = _summary;
		self.url = _url;
		self.image = _image;
		
		// Origin
		long padding = PADDING; 
		long orig_x = 0;
		long orig_y = 0;
		
		// Create view
		UIView *newsView = [[UIView alloc] init];
		newsView.userInteractionEnabled = YES;
		
		// Set size
		CGRect rectNews = CGRectMake(orig_x, orig_y, frame.size.width, frame.size.height);
		newsView.frame = rectNews;
		newsView.backgroundColor = [UIColor clearColor];
		[self addSubview:newsView];
		
		// Create image
		if (self.mode == NewsViewModeImageUpBig || self.mode == NewsViewModeImageUpSmall) {
			long height;
			switch (self.mode) {
				case NewsViewModeImageUpBig:
					// Image big
					height = newsView.frame.size.height / 2;
					break;
				case NewsViewModeImageUpSmall:
					// Image small
					NSLog(@"Small");
					height = newsView.frame.size.height / 3;
					break;
			}
			// If image is not nil, the create the view
			CGRect rectImage = CGRectMake(orig_x, orig_y, newsView.frame.size.width, height);
			self.imageView = [[UIImageView alloc] initWithFrame:rectImage];
			self.imageView.frame = rectImage;
			if (self.image) {
				// Set image
				self.imageView.image = [self imageByScalingAndCroppingForSize:self.image targetSize:rectImage.size];
			} else {
				// Show activity indicator
				self.imageView.image = [self imageByScalingAndCroppingForSize:[UIImage imageNamed:@"Default-Landscape.png"] targetSize:rectImage.size];
				self.imageView.alpha = 0.30;
				self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[self.activityIndicatorView setCenter:CGPointMake(rectImage.size.width / 2.0, rectImage.size.height / 2.0)];
				[self.imageView addSubview:self.activityIndicatorView];
				[self.activityIndicatorView startAnimating];
			}
			// Add subview
			[newsView addSubview:self.imageView];
			orig_y = self.imageView.frame.origin.x + self.imageView.frame.size.height + padding;
			// [imageView release];
		}
		
		// Create title
		CGRect rectLabel = CGRectMake(orig_x, orig_y, newsView.frame.size.width, 80);
		self.labelTitle = [[UILabel alloc] initWithFrame:rectLabel];
		self.labelTitle.font = [UIFont fontWithName:@"Helvetica" size:24.0];
		self.labelTitle.lineBreakMode = UILineBreakModeWordWrap;
		self.labelTitle.numberOfLines = 2;
		self.labelTitle.backgroundColor = [UIColor clearColor];
		self.labelTitle.text = self.title;
		// Calculate title size
		CGSize expectedLabelSize = [self.labelTitle.text sizeWithFont:self.labelTitle.font
											   constrainedToSize:self.labelTitle.frame.size
												   lineBreakMode:UILineBreakModeWordWrap];
		// Resize title
		CGRect newFrame = self.labelTitle.frame;
		newFrame.size.height = expectedLabelSize.height;
		self.labelTitle.frame = newFrame;
		self.labelTitle.numberOfLines = 0;
		[self.labelTitle sizeToFit];
		// Add subview
		[newsView addSubview:self.labelTitle];
		orig_y = self.labelTitle.frame.origin.y + self.labelTitle.frame.size.height + padding;
		
		// Create source label
		CGRect rectSource = CGRectMake(orig_x, orig_y, newsView.frame.size.width, 40);
		self.labelCreator = [[UILabel alloc] initWithFrame:rectSource];
		self.labelCreator.font = [UIFont fontWithName:@"Helvetica" size:14.0];
		self.labelCreator.lineBreakMode = UILineBreakModeWordWrap;
		self.labelCreator.numberOfLines = 0;
		self.labelCreator.backgroundColor = [UIColor clearColor];
		self.labelCreator.textColor = [UIColor colorWithRed:0.20 green:0.40 blue:0.60 alpha:1.0];;
		self.labelCreator.text = self.creator;
		// Calculate title size
		expectedLabelSize = [self.labelCreator.text sizeWithFont:self.labelCreator.font
											   constrainedToSize:self.labelCreator.frame.size
												   lineBreakMode:UILineBreakModeWordWrap];
		// Resize source
		newFrame = self.labelCreator.frame;
		newFrame.size.height = expectedLabelSize.height;
		self.labelCreator.frame = newFrame;
		self.labelCreator.numberOfLines = 0;
		[self.labelCreator sizeToFit];
		// Add subview
		[newsView addSubview:self.labelCreator];
		orig_y = self.labelCreator.frame.origin.y + self.labelCreator.frame.size.height + padding;
		
		// Create date label
		if (self.date) {
			CGRect rectSource = CGRectMake(orig_x, orig_y, newsView.frame.size.width, 40);
			self.labelDate = [[UILabel alloc] initWithFrame:rectSource];
			self.labelDate.font = [UIFont fontWithName:@"Helvetica" size:12.0];
			self.labelDate.lineBreakMode = UILineBreakModeWordWrap;
			self.labelDate.numberOfLines = 0;
			self.labelDate.backgroundColor = [UIColor clearColor];
			self.labelDate.textColor = [UIColor lightGrayColor];
			self.labelDate.text = self.date;
			// Calculate title size
			expectedLabelSize = [self.labelDate.text sizeWithFont:self.labelDate.font
												constrainedToSize:self.labelDate.frame.size
													lineBreakMode:UILineBreakModeWordWrap];
			// Resize source
			newFrame = self.labelDate.frame;
			newFrame.size.height = expectedLabelSize.height;
			self.labelDate.frame = newFrame;
			self.labelDate.numberOfLines = 0;
			[self.labelDate sizeToFit];
			// Add subview
			[newsView addSubview:self.labelDate];
			orig_y = self.labelDate.frame.origin.y + self.labelDate.frame.size.height + padding;
		}
		
		// Create image view if image next to text
		CGFloat source_width = newsView.frame.size.width;
		// Image next to text
		if (self.mode == NewsViewModeImageDown) {
			// Create image view
			CGRect rectImage = CGRectMake(newsView.frame.size.width / 2 + padding * 2, orig_y, newsView.frame.size.width - (newsView.frame.size.width / 2 + padding * 2), newsView.frame.size.height - orig_y);
			self.imageView = [[UIImageView alloc] initWithFrame:rectImage];
			self.imageView.frame = rectImage;
			if (self.image) {
				// Set image
				self.imageView.image = [self imageByScalingAndCroppingForSize:self.image targetSize:rectImage.size];
			} else {
				// Show activity indicator
				self.imageView.image = [self imageByScalingAndCroppingForSize:[UIImage imageNamed:@"Default-Landscape.png"]
																   targetSize:rectImage.size];
				self.imageView.alpha = 0.30;
				self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				self.activityIndicatorView.hidesWhenStopped = YES;
				[self.activityIndicatorView setCenter:CGPointMake(rectImage.size.width / 2.0, rectImage.size.height / 2.0)];
				[self.imageView addSubview:activityIndicatorView];
				[self.activityIndicatorView startAnimating];
			}
			// Add subview
			[newsView addSubview:self.imageView];
			// [imageView release];
			
			source_width = newsView.frame.size.width / 2 - padding * 2;
		}
		
		// Create text
		CGRect rectText = CGRectMake(orig_x, orig_y, source_width, newsView.frame.size.height - orig_y);
		self.labelSummary = [[UILabel alloc] initWithFrame:rectText];
		self.labelSummary.font = [UIFont fontWithName:@"Helvetica" size:16.0];
		self.labelSummary.lineBreakMode = UILineBreakModeTailTruncation;
		self.labelSummary.numberOfLines = 0;
		self.labelSummary.backgroundColor = [UIColor clearColor];
		self.labelSummary.text = self.summary;
		// Calculate text size
		expectedLabelSize = [self.labelSummary.text sizeWithFont:self.labelSummary.font
											   constrainedToSize:self.labelSummary.frame.size
												   lineBreakMode:UILineBreakModeTailTruncation];
		// Resize text
		newFrame = self.labelSummary.frame;
		newFrame.size.height = expectedLabelSize.height;
		self.labelSummary.frame = newFrame;
		self.labelSummary.numberOfLines = 0;
		// [labelText sizeToFit];
		// Add subview
		[newsView addSubview:self.labelSummary];
		
		[newsView release];
	}
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  {
	// Action through NewsScrollView 
	if (self.delegate && [self.delegate respondsToSelector:@selector(newsViewDidTouch:)]) {
		// Alert (NewsController)
		[self.delegate newsViewDidTouch:self];
	}
}

- (void)setImage:(UIImage*)_image {
	// Sets the image (usually updates the image after it is downloaded)
	if (self.activityIndicatorView) {
		// Stops the activity indicator
		[self.activityIndicatorView stopAnimating];
	}
	if (_image) {
		if (image) [image release];
		image = [_image retain];
		self.imageView.image = [self imageByScalingAndCroppingForSize:_image targetSize:self.imageView.frame.size];
		self.imageView.alpha = 1.00;
	}
}
 
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/

- (void)dealloc {
	[activityIndicatorView release];
	[imageView release];
	[labelCreator release];
	[labelDate release];
	[labelSummary release];
	[labelTitle release];
	[title release];
	[creator release];
	[summary release];
	[image release];
	[url release];
    [super dealloc];
}


@end
