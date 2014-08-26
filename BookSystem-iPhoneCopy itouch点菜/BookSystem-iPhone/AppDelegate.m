//
//  AppDelegate.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-17.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BSDataProvider.h"
#import "AnimatedGif.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "BSBookViewController.h"
#import "LeftMenuTypeViewController.h"
#import "LeftTableViewController.h"
#import "BSTableViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _initNSUserDefaults];
    [self copyFiles];
    [self initialConfig];
    [ZBarReaderView class];
//    [[NSUserDefaults standardUserDefaults] setObject:@"6950290624490" forKey:@"CommandString"];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    self.menuCtrl = [[UIViewController alloc] init];//菜品的DDMenu
     self.tableCtrl = [[UIViewController alloc] init]; //台位的DDMenu
    
    self.viewController = [[[ViewController alloc] init] autorelease];
    UINavigationController *vcnav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BSNavBG.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.window.rootViewController = vcnav;
    [vcnav release];
    [self.window makeKeyAndVisible];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
        imgvCover = [[UIImageView alloc] initWithFrame:self.window.bounds];
        imgvCover.userInteractionEnabled = YES;
        imgvCover.hidden = NO;
    }
    
    [self.window addSubview:imgvCover];
    [imgvCover release];
    if (imgvCover.frame.size.height==480)
        [imgvCover setImage:[UIImage imageNamed:@"Default.png"]];
    else
        [imgvCover setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    
    btnScan = [UIButton buttonWithType:UIButtonTypeCustom];
    btnScan.frame = CGRectMake(96, 64, 130, 130);
//    [btnScan setTitle:@"扫描" forState:UIControlStateNormal];
    [btnScan addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
//    btnScan.center = CGPointMake(imgvCover.frame.size.width/2, 40);
    [imgvCover addSubview:btnScan];
    
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 80, 30);
    [btn setTitle:[langSetting localizedString:@"ManualInput"] forState:UIControlStateNormal];
//    [btn setTitle:@"手动输入" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blackColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        btn.center = CGPointMake(160+20, 15+20);
    }else{
        btn.center = CGPointMake(160, 15);
    }
    [imgvCover addSubview:btn];
    [btn addTarget:self action:@selector(inputCode) forControlEvents:UIControlEventTouchUpInside];
    btn.hidden = YES;
    btnInput = [btn retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToScan) name:@"BackToScan" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFoodFinish) name:@"SendFoodFinish" object:nil];
    return YES;
}
//初始化NSUserDefaults
-(void)_initNSUserDefaults{
    NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *init = [[NSUserDefaults standardUserDefaults] objectForKey:@"init"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [myUserDefaults setObject:version forKey:@"version"];  //版本號
    if (init == nil) {
        [myUserDefaults setObject:@"init" forKey:@"init"];
        [myUserDefaults setBool:NO forKey:@"OrderLogin"];
        [myUserDefaults setObject:@"tn" forKey:@"language"];
        [myUserDefaults setBool:YES forKey:@"sound"];
        [myUserDefaults setBool:YES forKey:@"SkipSend"];
    }
    [myUserDefaults synchronize];
}
//手动输入事件
- (void)inputCode{
//       CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入账单号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]){
        UITextField *tf = [alertView textFieldAtIndex:0];
        
        if (tf.text.length>0){
            [[NSUserDefaults standardUserDefaults] setObject:tf.text forKey:@"CommandString"];
            AudioServicesPlayAlertSound(beepSound);
            
            [self.viewController showCommandString];
            [vZbarReader stop];
            vZbarReader.hidden = YES;
            imgvCover.hidden = YES;
            btnInput.hidden = YES;
        }
    }
    
    
}

- (void)sendFoodFinish{
    [SVProgressHUD dismiss];
    [self.viewController.navigationController popToRootViewControllerAnimated:YES];
    imgvCover.hidden = NO;
}

- (void)backToScan{
    imgvCover.hidden = NO;
}


- (void)scan{
    if (!vZbarReader){
        vZbarReader = [ZBarReaderView new];
        vZbarReader.frame = CGRectMake((320-304)/2, imgvCover.frame.size.height/2+10, 304, 228);
//        [[ZBarReaderView alloc] initWithFrame:CGRectMake((320-304)/2, imgvCover.frame.size.height/2+10, 304, 228)];
        vZbarReader.backgroundColor = [UIColor blackColor];
        vZbarReader.readerDelegate = self;
        [imgvCover addSubview:vZbarReader];
        
        [vZbarReader.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
        [vZbarReader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:0];
        
        [vZbarReader start];
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 114, 304, .5f)];
        line.backgroundColor = [UIColor greenColor];
        [vZbarReader addSubview:line];
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        AudioSessionSetActive(TRUE);
        

        
        // Load up the beep sound
        UInt32 flag = 0;
        float aBufferLength = 1.0; // In seconds
        NSURL *soundFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                      pathForResource:@"beep" ofType:@"wav"] isDirectory:NO];
        AudioServicesCreateSystemSoundID((CFURLRef) soundFileURL, &beepSound);
        OSStatus error = AudioServicesSetProperty(kAudioServicesPropertyIsUISound,
                                                  sizeof(UInt32), &beepSound, sizeof(UInt32), &flag);
        error = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
                                        sizeof(aBufferLength), &aBufferLength);
    }
    
    
    vZbarReader.hidden = NO;
    btnInput.hidden = NO;
    [vZbarReader start];
    /*
    if (!scanditSDKBarcodePicker) {
		// Instantiate the barcode picker.
		scanditSDKBarcodePicker = [[ScanditSDKBarcodePicker alloc]
                                   initWithAppKey:kScanditSDKAppKey];
        [scanditSDKBarcodePicker setCode39Enabled:YES];
        [scanditSDKBarcodePicker setQrEnabled:NO];
        scanditSDKBarcodePicker.overlayController.delegate = self;
        scanditSDKBarcodePicker.size = CGSizeMake(304, 228);
        [scanditSDKBarcodePicker setScanningHotSpotToX:0.5 andY:0.5];
        scanditSDKBarcodePicker.view.frame = CGRectMake((320-304)/2, imgvCover.frame.size.height/2+10, 304, 228);
        [scanditSDKBarcodePicker setMsiPlesseyEnabled:YES];
        
        // Don't vibrate when a code is recognized, beep
        [scanditSDKBarcodePicker.overlayController setBeepEnabled:YES];
        [scanditSDKBarcodePicker.overlayController setVibrateEnabled:NO];
        
        [scanditSDKBarcodePicker.overlayController setTorchEnabled:NO];
        [imgvCover addSubview:scanditSDKBarcodePicker.view];
	}
    
    // Add a button behind the subview to close it.
    
    
	// Set the center of the area where barcodes are detected successfully.
    // The default is the center of the screen (0.5, 0.5)
    
    
    // Enable(disable) symbologies your app will (not) support.
    // Disabling symbologies that your app will not support increases scanning
    // performance.
    // MSI Plessey barcodes are not enabled by default (symbology not available in
    // free community edition) - we are enabling the format here for demo purposes.
   
    

    // Update the UI such that it fits the new dimension.
//    [self adjustPickerToOrientation:AVCaptureVideoOrientationPortrait];
    if (scanditSDKBarcodePicker.isScanning){
        [scanditSDKBarcodePicker stopScanning];
        scanditSDKBarcodePicker.view.hidden = YES;
    }else{
        scanditSDKBarcodePicker.view.hidden = NO;
        [scanditSDKBarcodePicker startScanning];
    }
     */
}

- (void)initialConfig{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ServerSettings"]){
         NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:[NSDictionary dictionaryWithObjectsAndKeys:[[kPathHeader account] objectForKey:@"username"],@"username",[[kPathHeader account] objectForKey:@"password"],@"password",[kPathHeader hostName],@"ip", nil]
                    forKey:@"ftp"];
        [dicInfo setObject:[NSDictionary dictionaryWithObjectsAndKeys:[[kSocketServer componentsSeparatedByString:@":"] objectAtIndex:0],@"ip",[[kSocketServer componentsSeparatedByString:@":"] objectAtIndex:1],@"port", nil]
                    forKey:@"api"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dicInfo forKey:@"ServerSettings"];
    }
}

- (void)copyFiles{
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docPath = [docPaths objectAtIndex:0];
    
    NSString *sqlpath = [docPath stringByAppendingPathComponent:@"BookSystem.sqlite"];
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:sqlpath]){
        NSArray *ary = [NSBundle pathsForResourcesOfType:@"jpg" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"JPG" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"PNG" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"plist" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
        
        ary = [NSBundle pathsForResourcesOfType:@"sqlite" inDirectory:[[NSBundle mainBundle] bundlePath]];
        for (NSString *path in ary){
            [fileManager copyItemAtPath:path toPath:[docPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    [scanditSDKBarcodePicker stopScanning];
//    scanditSDKBarcodePicker.view.hidden = YES;
    [vZbarReader stop];
    vZbarReader.hidden = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [vZbarReader stop];
    vZbarReader.hidden = YES;
    btnInput.hidden = YES;
//    [scanditSDKBarcodePicker stopScanning];
//    scanditSDKBarcodePicker.view.hidden = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [vZbarReader stop];
    vZbarReader.hidden = YES;
    btnInput.hidden = YES;
//    [scanditSDKBarcodePicker stopScanning];
//    scanditSDKBarcodePicker.view.hidden = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notification Handler & Command Hanlder

- (void)handleRequest:(NSObject *)command {
//    NSString *str = [command receiveString];
//    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"CommandString"];
//    
//    [self.viewController showCommandString];
//    
//    [imgvGIF stopAnimating];
//    imgvGIF.hidden = YES;
//    imgvCover.hidden = YES;
//    
//    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];


}


- (void)handleInformationUpdate{
    
}

#pragma mark - Zbar Delegate
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image{
    for(ZBarSymbol *sym in symbols) {
        NSString *str = sym.data;
        
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"CommandString"];
        AudioServicesPlayAlertSound(beepSound);  //播放声音
        
        [self.viewController showCommandString];
        [vZbarReader stop];
        vZbarReader.hidden = YES;
        imgvCover.hidden = YES;
        btnInput.hidden = YES;
        break;
    }
}
/*
#pragma mark - ScanditSDK Delegate
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didCancelWithStatus:(NSDictionary *)status{
    NSLog(@"Cancel With Status:%@",status);
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didManualSearch:(NSString *)text{
    
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController didScanBarcode:(NSDictionary *)barcode{
    NSLog(@"Bar Code:%@",barcode);
    NSString *str = [barcode objectForKey:@"barcode"];
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"CommandString"];
    
    [self.viewController showCommandString];
    
    [scanditSDKBarcodePicker stopScanning];
    scanditSDKBarcodePicker.view.hidden = YES;
    imgvCover.hidden = YES;
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
*/


@end
