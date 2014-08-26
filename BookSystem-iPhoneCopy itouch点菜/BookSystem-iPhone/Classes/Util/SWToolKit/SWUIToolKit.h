//
//  SWUIToolKit.h
//  Nurse
//
//  Created by Wu Stan on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark -
#pragma mark Definations
#define kNavBGName      @""


#pragma mark -  UILabel Category
@interface UILabel(SWUIToolKit)

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font;
+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color;

@end


#pragma mark -
#pragma mark SWTextView 
/**
 UITextView subclass that adds placeholder support like UITextField has.
 */
@interface SWTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, retain) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, retain) UIColor *placeholderColor;

@end



#pragma mark -
#pragma mark SWImageView
/*
 *
 *  SWImageView
 *
 */
@class SWImageView;

@protocol SWImageViewDelegate

- (void)swImageViewLoadFinished:(SWImageView *)swImageView;

@end

@interface SWImageView : UIImageView{
    id<SWImageViewDelegate> delegate;
}
@property (nonatomic,assign) id<SWImageViewDelegate> delegate;

- (void)loadURL:(NSString *)str;

@end


#pragma mark -
#pragma mark UIImage Category
@interface UIImage(SWUIToolKit)

- (UIImage *)resizedImage:(CGSize)newSize;
- (UIImage *)croppedImage:(CGRect)area;

@end


#pragma mark -
#pragma mark SWNavigationViewController

@interface SWNavigationViewController : UINavigationController<UINavigationControllerDelegate> {
    BOOL bShowTabBar;
}

@property BOOL bShowTabBar;

@end

@interface UINavigationBar (UINavigationBar_CustomBG)

@end

/*
#pragma mark -
#pragma mark SWLabel
@interface SWLabel : UIView{
    NSAttributedString *attString;
    NSString *strText;
    UIFont *fontLabel;
    UIColor *textColor;
    
    NSMutableArray *images;
    NSArray *imageInfos;
}
@property (nonatomic,retain) NSAttributedString *attString;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) NSMutableArray *images;
@property (nonatomic,retain) NSArray *imageInfos;


- (void)attachImagesWithFrame:(CTFrameRef)f;
- (void)sizeToFit;

@end


#pragma mark -  MarkupParser
@interface MarkupParser : NSObject {
    UIColor *color;
    UIColor *strokeColor;
    float strokeWidth;
    NSString *fontName;
    CGFloat pointSize;
    
    NSMutableArray *images;
}
@property (retain, nonatomic) UIColor *color;
@property (retain, nonatomic) UIColor *strokeColor;
@property (assign, readwrite) float strokeWidth;
@property (nonatomic,copy) NSString *fontName;
@property (nonatomic,assign) CGFloat pointSize;


@property (retain, nonatomic) NSMutableArray *images;

- (NSAttributedString *)attrStringFromMarkup:(NSString *)html;


@end
*/

#pragma mark -  UIAlertView Extensions
@interface UIAlertView(SWExtensions)

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel;
+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate;
@end


#pragma mark - UIImage Extensions
@interface UIImage(SWExtensions)

+ (UIImage *)image:(UIImage *)img forTintColor:(UIColor *)color;
- (UIImage *)tintColorImage:(UIColor *)color;

@end

@interface NSString(UIKitUtil)
- (NSString *)MD5;
@end



