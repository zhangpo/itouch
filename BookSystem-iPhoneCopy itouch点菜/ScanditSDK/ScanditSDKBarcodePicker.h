//
//  Controls the barcode recognition process and informs registered delegates about the
//  barcode recognition state each time a new video frame has been analyzed.
//
//  Copyright 2010 Mirasense. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>


@class ScanditSDKBarcodePicker;
@class ScanditSDKOverlayController;


@protocol ScanditSDKNextFrameDelegate
- (void)scanditSDKBarcodePicker:(ScanditSDKBarcodePicker*)scanditSDKBarcodePicker 
				didCaptureImage:(NSData*) image 
					 withHeight:(int)height 
					  withWidth:(int)width;
@end


typedef enum {
    CAMERA_FACING_BACK,
    CAMERA_FACING_FRONT
} CameraFacingDirection;

typedef enum {
	NONE,
	CHECKSUM_MOD_10,
	CHECKSUM_MOD_1010,
	CHECKSUM_MOD_11,
	CHECKSUM_MOD_1110
} MsiPlesseyChecksumType;


@interface ScanditSDKBarcodePicker : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
	ScanditSDKOverlayController *overlayController;
    CGSize size;
    AVCaptureVideoOrientation cameraPreviewOrientation;
    CameraFacingDirection cameraFacingDirection;
}

@property (nonatomic, retain) ScanditSDKOverlayController *overlayController;

/**
 * The size of the picker and its preview. Change this if you want to scale the picker.
 * 
 * By default it is full screen.
 */
@property (nonatomic, assign) CGSize size;

/**
 * The orientation of the camera preview. In general the preview's orientation will be as wanted,
 * but there may be cases where it needs to be set individually. This also switches height and
 * width of the whole picker such that the preview fits again.
 *
 * Possible values are: 
 * AVCaptureVideoOrientationPortrait, AVCaptureVideoOrientationPortraitUpsideDown,
 * AVCaptureVideoOrientationLandscapeLeft, AVCaptureVideoOrientationLandscapeRight
 */
@property (nonatomic, assign) AVCaptureVideoOrientation cameraPreviewOrientation;

@property (readonly, nonatomic, assign) CameraFacingDirection cameraFacingDirection;


/**
 * Prepares a ScanditSDKBarcodePicker with the given parameters such that it will be available much
 * quicker when initializing it. The resources needed for this speed up are minimal and the speed
 * gain is very noticeable. It is adviced that you call this in the applicationDidFinishLaunching
 * function of your app delegate.
 */
+ (void)prepareWithAppKey:(NSString *)ScanditSDKAppKey;
+ (void)prepareWithAppKey:(NSString *)ScanditSDKAppKey 
   cameraFacingPreference:(CameraFacingDirection)facing;

/**
 * Initiate the barcode picker. To enable the analytics and location capabilities 
 * of the Scandit SDK, set the parameters accordingly. The app key is mandatory and is available
 * via the Scandit SDK website. 
 * The default facing is CAMERA_FACING_BACK.
 */
- (id)initWithAppKey:(NSString *)scanditSDKAppKey;
- (id)initWithAppKey:(NSString *)scanditSDKAppKey 
	  cameraFacingPreference:(CameraFacingDirection)facing;

/**
 * Releases the barcode picker and forces all attached objects to be released. This circumvents the
 * camera being held in standby mode and will free up resources (power, memory), but also increases the startup
 * time and time to successful scan for subsequent scans.
 */
- (void)forceRelease;

/**
 * Prevents the camera from entering a standby state after the picker is deallocated. This will
 * free up resources (power, memory) that would have been used by the camera, but also increases the startup
 * time and time to successful scan for subsequent scans.
 */
- (void)disableStandbyState;

/**
 * Sets a new (custom) overlay controller that received updates from the barcode engine.
 * 
 * Use this method to specify your own custom overlay that customizes the scan view. 
 *
 * Note: This feature is only available with the
 * Scandit SDK Enterprise Packages.
 * 
 */
- (void)setOverlayController:(ScanditSDKOverlayController *)overlay;

/**
 * Returns whether the specified camera facing is supported by the current device.
 */
- (BOOL)supportsCameraFacing:(CameraFacingDirection)facing;

/**
 * Changes to the specified camera facing if it is supported. Returns YES if it successfully changed.
 */
- (BOOL)changeToCameraFacing:(CameraFacingDirection)facing;

/**
 * Changes to the opposite camera facing if it is supported. Returns YES if it successfully changed.
 */
- (BOOL)switchCameraFacing;

/**
 * Returns YES if the scanning is in progress. 
 */
- (BOOL)isScanning;

/** 
 * Starts the scanning process, and triggers the loading and initialization of the recognition 
 * engine, in case this has not been done so far.
 */
- (void)startScanning;

/** 
 * Stops the scanning process. 
 */
- (void)stopScanning;

/**
 * Stops the scanning process but keeps the torch on if it is already turned on.
 */
- (void)stopScanningAndKeepTorchState;

/**
 * Resets the barcode scanner state. Can be used if a code has been recognized, the user is still 
 * close to the code, and the code should be recognized again, e.g. after the user pressed a button.
 */
- (void)reset;

/**
 * Enables or disables the recognition of 1D codes.
 *
 * By default it is enabled.
 */
- (void)set1DScanningEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of 2D codes. (Note: 2D scanning is not
 * supported by all Scandit SDK versions)
 *
 * By default it is enabled.
 */
- (void)set2DScanningEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of EAN13 and UPC12/UPCA codes.
 *
 * By default it is enabled.
 */
- (void)setEan13AndUpc12Enabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of EAN8 codes.
 *
 * By default it is enabled.
 */
- (void)setEan8Enabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of UPCE codes.
 *
 * By default it is enabled.
 */
- (void)setUpceEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of CODE39 codes.
 * 
 * Note: CODE39 scanning is only available with the 
 * Scandit SDK Enterprise Basic or Enterprise Premium Package
 *
 * By default it is enabled.
 */
- (void)setCode39Enabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of CODE128 codes.
 *
 * Note: CODE128 scanning is only available with the 
 * Scandit SDK Enterprise Basic or Enterprise Premium Package
 *
 * By default it is enabled.
 */
- (void)setCode128Enabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of ITF codes.
 *
 * Note: ITF scanning is only available with the 
 * Scandit SDK Enterprise Basic or Enterprise Premium Package
 *
 * By default it is enabled.
 */
- (void)setItfEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of QR codes.
 *
 * By default it is enabled.
 */
- (void)setQrEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of Data Matrix codes.
 *
 * Note: Datamatrix scanning is only available with the 
 * Scandit SDK Enterprise Premium Package.
 *
 * By default it is enabled.
 */
- (void)setDataMatrixEnabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of PDF417 codes.
 *
 * Note: PDF417 scanning is only available with the 
 * Scandit SDK Enterprise Premium Package.
 * 
 * By default it is enabled.
 */
- (void)setPdf417Enabled:(BOOL)enabled;

/**
 * Enables or disables the recognition of MSI Plessey codes.
 *
 * Note: MSI Plessey scanning is only available with the
 * Scandit SDK Enterprise Basic or Enterprise Premium Package
 *
 * By default it is disabled.
 */
- (void)setMsiPlesseyEnabled:(BOOL)enabled;

/**
 * Sets the type of checksum that is expected of the MSI Plessey codes.
 *
 * By default it is set to CHECKSUM_MOD_10
 */
- (void)setMsiPlesseyChecksumType:(MsiPlesseyChecksumType)type;

/**
 * Enables special settings to allow the recognition of very small Data Matrix codes. If this is
 * not specifically needed, do not enable it as it uses considerable processing power. This setting
 * automatically forces 2d recognition on every frame.
 *
 * By default it is disabled.
 */
- (void)setMicroDataMatrixEnabled:(BOOL)enabled;

/**
 * Enables the detection of white on black codes. This option currently only 
 * works for Data Matrix codes.
 *
 * By default it is disabled.
 */
- (void)setInverseDetectionEnabled:(BOOL)enabled;

/**
 * Forces the barcode scanner to always run the 2D decoders (QR,Datamatrix, etc.), 
 * even when the 2D detector did not detect the presence of a 2D code. 
 * This slows down the overall scanning speed, but is useful for very small 
 * Datamatrix codes which are sometimes not detected by the 2D detector. 
 *
 * By default the recognition is not forced.
 */
- (void)force2dRecognition:(BOOL)force;

/**
 * Reduces the area in which barcodes are detected and decoded to an
 * area defined by setScanningHotSpotHeight and setScanningHotSpotToX andY.
 * If this method is set to disabled, barcodes in the full camera image
 * are detected and decoded.
 *
 * By default restrictActiveScanningArea is not enabled.
 */
- (void)restrictActiveScanningArea:(BOOL)enabled;

/**
 * Switches the torch on or off. If the torch button is enabled on the overlay,
 * users can change this by clicking it.
 *
 * By default the torch is off.
 */
- (void)switchTorchOn:(BOOL)on;

/**
 * this method has two different methods depending whether the full screen barcode detection is
 * enabled (default) or the area in which barcodes are scanned is limited (by calling 
 * setAreaRecognitionEnabled(YES).
 * 
 * Full screen scanning mode:
 * 
 * Sets the location in the image which get the highest priority when multiple barcodes are in the 
 * image. 
 *
 * Area recognition mode:
 * 
 * Changes the location of the spot where the recognition actively scans for barcodes. 
 *
 * X and Y can be between 0 and 1, where 0/0 corresponds to the top left corner and 1/1 to the bottom right
 * corner.
 *
 * The default is 0.5/0.5
 */
- (void)setScanningHotSpotToX:(float)x andY:(float)y;

/**
 * Changes the height of the spot where the recognition actively scans for barcodes. The height of
 * the hot spot is given relative to the height of the screen and has to be between 0.0 and 0.5.
 * Be aware that if the hot spot height is very large, the engine is forced to decrease the quality
 * of the recognition to keep the speed at an acceptable level.
 *
 * This only applies if the area recognition is enabled.
 *
 * The default is 0.25
 */
- (void)setScanningHotSpotHeight:(float)height;

/**
 * Sets the delegate to which the next frame should be sent. The next frame from the camera is
 * then converted to a JPEG image and the ScanditSDKBarcodePicker will pass the jpg image, width and height
 * to the delegate. Do not call this method repeatedly while the barcode scanner is running,
 * since the JPG conversion of the camera frame is slow.
 */
- (void)sendNextFrameToDelegate:(id<ScanditSDKNextFrameDelegate>)delegate;



@end

