//
//  AnimatedGif.m
//
//  Created by Stijn Spijker (http://www.stijnspijker.nl/) on 2009-07-03.
//  Based on gifdecode written april 2009 by Martin van Spanje, P-Edge media.
//
//  Changes on gifdecode:
//  - Small optimizations (mainly arrays)
//  - Object Orientated Approach
//  - Added the Graphic Control Extension Frame for transparancy
//  - Changed header to GIF89a
//  - Added methods for ease-of-use
//  - Added animations with transparancy
//  - No need to save frames to the filesystem anymore
//
//  Changelog:
//
//  2010-01-15: Fixe memory problems, by Jose Miguel Gomez
//  2009-10-08: Added dealloc method, and removed leaks, by Pedro Silva
//  2009-08-10: Fixed double release for array, by Christian Garbers
//  2009-06-05: Initial Version
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//  

#import <UIKit/UIKit.h>

@interface AnimatedGif : NSObject {
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableData *GIF_string;
	NSMutableData *GIF_frameHeader;
    
	NSMutableArray *GIF_delays;
	NSMutableArray *GIF_framesData;
	NSMutableArray *GIF_transparancies;
    
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
    
	int dataPointer;
	int frameCounter;
}
+ (id)create;
- (id)init;
- (void)decodeGIF:(NSData *)GIF_Data;
- (void)GIFReadExtensions;
- (void)GIFReadDescriptor;
- (int)GIFGetBytes:(int)length;
- (void)GIFPutBytes:(NSData *)bytes;
- (NSMutableData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;
- (UIImageView*) getAnimation;
- (NSMutableArray *)GIF_framesData;
- (NSMutableArray *)GIF_delays;
@end
