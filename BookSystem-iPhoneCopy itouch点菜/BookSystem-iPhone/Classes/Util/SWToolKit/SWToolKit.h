//
//  SWToolKit.h
//  SWToolKit
//
//  Created by Wu Stan on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "SWUIToolKit.h"
#import "SWDataToolKit.h"

#ifndef SWThreadUtil_h
#define SWThreadUtil_h

#define kScreenSize     [[UIScreen mainScreen] bounds]
//#define kScreenHeight   [[[UIScreen mainScreen] bounds] height]

static void sw_dispatch_sync_on_main_thread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#endif



