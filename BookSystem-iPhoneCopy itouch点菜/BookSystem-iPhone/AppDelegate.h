//
//  AppDelegate.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-17.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ScanditSDKOverlayController.h"
//#import "ScanditSDKBarcodePicker.h"
#import "ZBarReaderView.h"
#import <AudioToolbox/AudioToolbox.h>

#define kScanditSDKAppKey    @"GT8noMIvEeKaFKF9edzMUsneZESl9+twOFzE4V9NzRA"
@class ViewController;



@interface AppDelegate : UIResponder <UIApplicationDelegate,ZBarReaderViewDelegate,UIAlertViewDelegate>{
    UIButton *btnScan;
    UIImageView *imgvCover;
//    ScanditSDKBarcodePicker *scanditSDKBarcodePicker;
    ZBarReaderView *vZbarReader;
    SystemSoundID beepSound;
    UIButton *btnInput;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UIViewController *menuCtrl;
@property (strong, nonatomic) UIViewController *tableCtrl;

@end
