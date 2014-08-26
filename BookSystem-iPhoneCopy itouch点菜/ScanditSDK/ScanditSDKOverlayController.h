//
//  The ScanditSDKOverlayController is used to display the viewfinder and the location of the recognized
//  barcode. The overlay controller can be used to configure various scan screen UI elements such as
//  search bar, sound and text elements.
//
//  Copyright 2010 Mirasense AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioServices.h"
#import "ScanditSDKBarcodePicker.h"


@class ScanditSDKOverlayController;


@protocol ScanditSDKOverlayControllerDelegate
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController 
                 didScanBarcode:(NSDictionary *)barcode;
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController 
            didCancelWithStatus:(NSDictionary *)status;
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController 
                didManualSearch:(NSString *)text;
@end


typedef enum {
	CAMERA_SWITCH_NEVER,
	CAMERA_SWITCH_ON_TABLET,
	CAMERA_SWITCH_ALWAYS
	
} CameraSwitchVisibility;

@interface ScanditSDKOverlayController : UIViewController <UISearchBarDelegate> {
	id<ScanditSDKOverlayControllerDelegate> delegate;
	
    UISearchBar *searchBar;
    UIToolbar *toolBar;
	
}

@property (nonatomic, assign) id<ScanditSDKOverlayControllerDelegate> delegate;
@property (nonatomic, retain) UISearchBar *manualSearchBar;
@property (nonatomic, retain) UIToolbar *toolBar;


// UI elements configuration: toolbar, searchbar

/**
 * Adds (or removes) a search bar to the top of the scan screen.
 */
- (void)showSearchBar:(BOOL)show;

/**
 * Adds (or removes) a tool bar at the bottom of the scan screen.
 */
- (void)showToolBar:(BOOL)show;


/**
 * Resets the scan screen user interface to its initial state.
 */
- (void)resetUI;


// Sound configuration

/**
 * Enables (or disables) the sound when a barcode is recognized.
 * 
 * Enabled by default.
 */
- (void)setBeepEnabled:(BOOL)enabled;

/**
 * Enables or disables the vibration when a barcode is recognized.
 * 
 * Enabled by default.
 */
- (void)setVibrateEnabled:(BOOL)enabled;

/**
 * Sets the audio file used when a code has been recognized. Returns YES if the change was
 * successful.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages. 
 * 
 * The default is: "beep.wav"
 */
- (BOOL)setScanSoundResource:(NSString *)path ofType:(NSString *)extension;


// Torch configuration

/**
 * Enables or disables the torch toggle button for all devices that support a torch.
 *
 * By default it is enabled.
 */
- (void)setTorchEnabled:(BOOL)enabled;

/**
 * Sets the image which is being drawn on the left side when the torch is on. If you want this to
 * be displayed in proper resolution on high resolution screens you should provide a resource with
 * the same name but @2x appended (like flashlight-turn-on-icon@2x.png). This function sets the
 * specified image for both the normal and the pressed state.
 *
 * By default this is: "flashlight-turn-on-icon.png"
 */
- (BOOL)setTorchOnImageResource:(NSString *)fileName
                         ofType:(NSString *)extension;

/**
 * Sets the image which is being drawn on the left side when the torch is on. If you want this to
 * be displayed in proper resolution on high resolution screens you should provide a resource with
 * the same name but @2x appended (like flashlight-turn-on-icon@2x.png).
 *
 * By default this is: "flashlight-turn-on-icon.png" and "flashlight-turn-on-icon-pressed.png"
 */
- (BOOL)setTorchOnImageResource:(NSString *)fileName
                pressedResource:(NSString *)pressedFileName
                         ofType:(NSString *)extension;

/**
 * Sets the image which is being drawn when the torch is off. If you want this to be displayed in
 * proper resolution on high resolution screens you should provide a resource with the same name
 * but @2x appended (like flashlight-turn-off-icon@2x.png). This function sets the specified
 * image for both the normal and the pressed state.
 *
 * By default this is: "flashlight-turn-off-icon.png"
 */
- (BOOL)setTorchOffImageResource:(NSString *)fileName
                          ofType:(NSString *)extension;

/**
 * Sets the image which is being drawn when the torch is off. If you want this to be displayed in
 * proper resolution on high resolution screens you should provide a resource with the same name
 * but @2x appended (like flashlight-turn-off-icon@2x.png).
 *
 * By default this is: "flashlight-turn-off-icon.png" and "flashlight-turn-off-icon-pressed.png"
 */
- (BOOL)setTorchOffImageResource:(NSString *)fileName
                 pressedResource:(NSString *)pressedFileName
                          ofType:(NSString *)extension;

/**
 * Sets the position at which the button to enable the torch is drawn. The X and Y coordinates are
 * relative to the screen size, which means they have to be between 0 and 1.
 *
 * By default this is set to x = 0.05, y = 0.01, width = 67, height = 33.
 */
- (void)setTorchButtonRelativeX:(float)x relativeY:(float)y width:(float)width height:(float)height;


// Camera selection configuration

/**
 Sets when the camera switch button is visible for all devices that have more than one camera.
 *
 * By default it is CAMERA_SWITCH_NEVER.
 */
- (void)setCameraSwitchVisibility:(CameraSwitchVisibility)visibility;

/**
 * Sets the image which is being drawn when the device has more than one camera. If you want this to
 * be displayed in proper resolution on high resolution screens you should provide a resource with
 * the same name but @2x appended (like camera-switch-icon@2x.png). This function sets the specified
 * image for both the normal and the pressed state.
 *
 * By default this is: "camera-swap-icon.png"
 */
- (BOOL)setCameraSwitchImageResource:(NSString *)fileName
                              ofType:(NSString *)extension;

/**
 * Sets the image which is being drawn as the button to switch the camera from back to front and
 * vice versa. If you want this to be displayed in proper resolution on high resolution screens you
 * should provide a resource with the same name but @2x appended (like camera-swap-icon@2x.png).
 *
 * By default this is: "camera-swap-icon.png" and "camera-swap-icon-pressed.png"
 */
- (BOOL)setCameraSwitchImageResource:(NSString *)fileName
                     pressedResource:(NSString *)pressedFileName
                              ofType:(NSString *)extension;

/**
 * Sets the position at which the button to switch the camera is drawn. The X and Y coordinates are
 * relative to the screen size, which means they have to be between 0 and 1. Be aware that the x
 * coordinate is calculated from the right side of the screen and not the left like with the torch
 * button.
 *
 * By default this is set to x = 0.05, y = 0.01, width = 67 and height = 33.
 */
- (void)setCameraSwitchButtonRelativeInverseX:(float)x
									relativeY:(float)y
										width:(float)width
									   height:(float)height;



// Text configuration

/**
 * Sets the caption of the manual entry at the top when a barcode of valid length has been entered.
 *
 * By default this is: "Go"
 */
- (void)setSearchBarActionButtonCaption:(NSString *)caption;

/**
 * Sets the caption of the manual entry at the top when no barcode of valid length has been entered.
 * 
 * By default this is: "Cancel"
 */
- (void)setSearchBarCancelButtonCaption:(NSString *)caption;

/**
 * Sets the text shown in the manual entry field when nothing has been entered yet.
 * 
 * By default this is: "Scan barcode or enter it here"
 */
- (void)setSearchBarPlaceholderText:(NSString *)text;

/**
 * Sets the type of keyboard that is shown to enter characters into the search bar.
 *
 * By default this is: UIKeyboardTypeNumberPad
 */
- (void)setSearchBarKeyboardType:(UIKeyboardType)keyboardType;

/**
 * Sets the caption of the toolbar button.
 *
 * By default this is: "Cancel"
 */
- (void)setToolBarButtonCaption:(NSString *)caption;

/**
 * Sets the text that will be displayed while non-autofocusing cameras are initialized.
 *
 * By default this is: "Initializing camera..."
 */
- (void)setTextForInitializingCamera:(NSString *)text;




// Viewfinder Configuration

/**
 * Sets the font of all text displayed in the UI.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is: "Helvetica"
 */
- (void)setUIFont:(NSString *)font;

/**
 * Sets the color of the viewfinder before and while tracking a barcode (which has not yet been recognized).
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is: white (1.0, 1.0, 1.0)
 */
- (void)setViewfinderColor:(float)r green:(float)g blue:(float)b;

/**
 * Sets the color of the viewfinder once the bar code has been recognized.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is: light blue (0.222, 0.753, 0.8)
 */
- (void)setViewfinderDecodedColor:(float)r green:(float)g blue:(float)b;

/**
 * Sets the size of the viewfinder relative to the size of the screen size.
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen.
 *
 * By default the width is 0.8, height is 0.4, landscapeWidth is 0.6, landscapeHeight is 0.4
 */
- (void)setViewfinderHeight:(float)h
                      width:(float)w
            landscapeHeight:(float)lH
             landscapeWidth:(float)lW;

/**
 * Sets the font size of the text in the view finder. 
 * 
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is font size 16
 */
- (void)setViewfinderFontSize:(float)fontSize;

/**
 * Sets whether the overlay controller draws the viewfinder (i.e. white rectangle 
 * followed by rectangle highlighting the successfully decoded barcode. 
 * If this is set to NO the static viewfinder will not
 * be drawn either.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is YES.
 */
- (void)drawViewfinder:(BOOL)draw;

/**
 * Enables (or disables) the "flash" when a barcode is successfully scanned. 
 * 
 * By default, it is enabled
 */
- (void)setScanFlashEnabled:(BOOL)enabled;

/**
 * Sets the y offset at which the Scandit logo should be drawn. Be aware that the standard Scandit
 * SDK licenses do not allow you to hide the logo.
 *
 * DEPRECATED - This function was replaced by setLogoXOffset:yOffset:
 *
 * By default this is: 0
 */
- (void)setInfoBannerOffset:(int)offset;

/**
 * Sets the x and y offset at which the Scandit logo should be drawn for both portrait and landscape
 * orientation. Be aware that the standard Scandit SDK licenses do not allow you to hide the logo.
 *
 * By default this is set to xOffset = 0, yOffset = 0, landscapeXOffset = 0, landscapeYOffset = 0.
 */
- (void)setLogoXOffset:(int)xOffset
			   yOffset:(int)yOffset
	  landscapeXOffset:(int)landscapeXOffset
	  landscapeYOffset:(int)landscapeYOffset;

/**
 * Sets the banner image which is being drawn at the bottom of the scan screen. If you want this to
 * be displayed in proper resolution on high resolution screens you should provide a resource with
 * the same name but @2x appended (like poweredby@2x.png).
 * 
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is: "poweredby.png"
 */
- (BOOL)setBannerImageWithResource:(NSString *)fileName ofType:(NSString *)extension;

// Searchbar Configuration


/**
 * Sets the minimum size that a barcode entered in the manual searchbar has to have to possibly be valid.
 * 
 * By default this is: 8
 */
- (void)setMinSearchBarBarcodeLength:(NSInteger)length;

/**
 * Sets the maximum sizethat a barcode entered in the manual searchbar can have to possibly be valid.
 * 
 * By default this is: 100
 */
- (void)setMaxSearchBarBarcodeLength:(NSInteger)length;


// deprecated methods

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Add the 'most likely barcode' UI element. This element is displayed
 * below the viewfinder when the barcode engine is not 100% confident
 * in its result and asks for user confirmation. This element is
 * seldom displayed - typically only when decoding challenging barcodes
 * with fixed focus cameras.
 *
 * By default this is disabled (see comment above).
 */
- (void)showMostLikelyBarcodeUIElement:(BOOL)show;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that will be displayed above the viewfinder to tell the user to align it with the
 * barcode that should be recognized.
 *
 * By default this is: "Align code with box"
 */
- (void)setTextForInitialScanScreenState:(NSString *)text;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that will be displayed above the viewfinder to tell the user to align it with the
 * barcode and hold still because a potential code seems to be on the screen.
 *
 * By default this is: "Align code and hold still"
 */
- (void)setTextForBarcodePresenceDetected:(NSString *)text;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that will be displayed above the viewfinder to tell the user to hold still because
 * a barcode is aligned with the box and the recognition is trying to recognize it.
 *
 * By default this is: "Decoding ..."
 */
- (void)setTextForBarcodeDecodingInProgress:(NSString *)text;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that will be displayed if the engine was unable to recognize the barcode.
 *
 * By default this is: "No barcode recognized"
 */
- (void)setTextWhenNoBarcodeWasRecognized:(NSString *)text;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that will be displayed if the engine was unable to recognize the barcode and it is
 * suggested to enter the barcode manually.
 *
 * By default this is: "Touch to enter"
 */
- (void)setTextToSuggestManualEntry:(NSString *)text;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets the text that is displayed alongside the 'most likely barcode' UI element that
 * is displayed when the barcode engine is not 100% confident in its result and asks for user
 * confirmation.
 *
 * By default this is: "Tap to use"
 */
- (void)setTextForMostLikelyBarcodeUIElement:(NSString *)text;

/**
 * DEPRECATED - Replaced by setViewfinderHeight:width:landscapeHeight:landscapeWidth:
 *              If you are using a rotating BarcodePicker, migrate to the new function if possible
 *              since it will allow you to properly adjust the viewfinder for each screen dimension
 *              individually.
 *
 * Sets the size of the viewfinder relative to the size of the screen size.
 * Changing this value does not(!) affect the area in which barcodes are successfully recognized.
 * It only changes the size of the box drawn onto the scan screen.
 *
 * By default the width is 0.6 and the height is 0.25
 */
- (void)setViewfinderHeight:(float)h width:(float)w;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated.
 * Use method drawViewfinder instead. 
 *
 * Sets whether the overlay controller draws the static viewfinder (i.e. white rectangle)
 * when no code was detected yet.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is YES.
 */
- (void)drawStaticViewfinder:(BOOL)draw;

/**
 * DEPRECATED - This method serves no purpose any more and is deprecated. 
 *
 * Sets whether to draw the hook at the top of the viewfinder that displays text.
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 *
 * By default this is YES.
 */
- (void)drawViewfinderTextHook:(BOOL)draw;


@end
