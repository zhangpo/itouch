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

#import "AnimatedGif.h"

@implementation AnimatedGif

+ (id) create
{
	return [[self alloc] init];
}

- (id) init
{
	self = [super init];
	if( self ) {
        
		GIF_buffer = [NSMutableData data];
		GIF_screen = [NSMutableData data];
		GIF_string = [NSMutableData data];
		GIF_global = [NSMutableData data];	
        
		GIF_delays = [NSMutableArray array];
		GIF_framesData = [NSMutableArray array];
		GIF_transparancies = [NSMutableArray array];
//        GIF_buffer = [NSMutableData data] ;
//		GIF_screen = [NSMutableData data] ;
//		GIF_string = [NSMutableData data] ;
//		GIF_global = [NSMutableData data] ;	
//        
//		GIF_delays = [NSMutableArray array] ;
//		GIF_framesData = [NSMutableArray array] ;
//		GIF_transparancies = [NSMutableArray array] ;
	}
    
	return self;
}

// the decoder
// decodes GIF image data into separate frames
// based on the Wikipedia Documentation at:
//
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Example_.gif_file
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Animated_.gif
//
- (void)decodeGIF:(NSData *)GIFData
{
	GIF_pointer = [NSData dataWithData:GIFData];
    
	[GIF_buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_delays removeAllObjects];
	[GIF_framesData removeAllObjects];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];
    
	dataPointer = 0;
	frameCounter = 0;
    
	[self GIFGetBytes:6]; // GIF89a
	[self GIFGetBytes:7]; // Logical Screen Descriptor
    
	[GIF_screen setData:GIF_buffer];
    
	size_t length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
    
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
    
	if (GIF_colorF == 1) {
		[self GIFGetBytes:(3 * GIF_colorS)];
		[GIF_global setData:GIF_buffer];
	}
    
	unsigned char bBuffer[1];
	for (bool notdone = true; notdone;) {
		if ([self GIFGetBytes:1] == 1) {
            
			[GIF_buffer getBytes:bBuffer length:1];
            
			switch (bBuffer[0]) {
				case 0x21:
					// Graphic Control Extension (#n of n)
					[self GIFReadExtensions];
					break;
				case 0x2C:
					// Image Descriptor (#n of n)
					[self GIFReadDescriptor];
					break;
				case 0x3B:
					notdone = false;
					break;
			}
		} else {
			break;
		}
	}
    
	// clean up stuff
	[GIF_buffer setData:[NSData data]];
	[GIF_screen setData:[NSData data]];
	[GIF_string setData:[NSData data]];
	[GIF_global setData:[NSData data]];
}

//
// Returns a subframe as NSMutableData.
// Returns nil when frame does not exist.
//
// Use this to write a subframe to the filesystems (cache etc);
- (NSMutableData*) getFrameAsDataAtIndex:(int)index
{
	if (index < [GIF_framesData count])
	{
		return [GIF_framesData objectAtIndex:index];
	}
	else
	{
		return nil;
	}
}

//
// Returns a subframe as an UIImage.
// Returns nil when frame does not exist.
//
// Use this to put a subframe on your GUI.
- (UIImage*) getFrameAsImageAtIndex:(int)index
{
	if (index < [GIF_framesData count])
	{
		UIImage *image = [UIImage imageWithData:[self getFrameAsDataAtIndex: index]];
        
		return image;
        
	}
	else
	{
		return nil;
	}
}

//
// This method converts the arrays of GIF data to an animation, counting
// up all the seperate frame delays, and setting that to the total duration
// since the iPhone Cocoa framework does not allow you to set per frame
// delays.
//
// Returns nil when there are no frames present in the GIF.
//
// This methods expects YOU to release the UIImageView, it is alloc'ed.
- (NSMutableArray *)GIF_framesData{
    return GIF_framesData;
}

- (NSMutableArray *)GIF_delays{
    return GIF_delays;
}

- (UIImageView*) getAnimation
{
	if ([GIF_framesData count] > 0)
	{
		// This sets up the frame etc for the UIImageView by using the first frame.
		UIImageView *uiv = [[UIImageView alloc] initWithImage:[self getFrameAsImageAtIndex:0]];
        
		// Add all subframes to the animation
		NSMutableArray *array = [NSMutableArray array];
		for (int i =0; i < [GIF_framesData count]; i++)
		{
			[array addObject: [self getFrameAsImageAtIndex:i]];
            
		}
        
		[uiv setAnimationImages:array];
        
		// Count up the total delay, since Cocoa doesn't do per frame delays.
		NSTimeInterval total = 0;
		for (int i = 0; i < [GIF_delays count]; i++)
		{
			total += [[GIF_delays objectAtIndex:i] doubleValue];
		}
        
		// GIFs store the delays as 1/100th of a second.
		[uiv setAnimationDuration:total/100];
        
		// Repeat infinite
		[uiv setAnimationRepeatCount:0];
        
		return uiv;
	}
	else
	{
		return nil;
	}
}

- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
	for ( ; ; ) {
		[self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
        
		if (cur[0] == 0x00) {
			break;
		}	
        
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
			unsigned char bBuffer[5];
			[GIF_buffer getBytes:bBuffer length:5];
            
			// We save the delays for easy access.
			[GIF_delays addObject:[NSNumber numberWithInt:(bBuffer[1] | bBuffer[2] << 8)]];
            
			// We save the transparent color for easy access.
			[GIF_transparancies addObject:[NSNumber numberWithInt:bBuffer[3]]];
            
			if (GIF_frameHeader == nil)
			{
			    unsigned char board[8];
				board[0] = 0x21;
				board[1] = 0xF9;
				board[2] = 0x04;
                
				for(int i = 3, a = 0; a < 5; i++, a++)
				{
					board[i] = bBuffer[a];
				}
				GIF_frameHeader = [NSMutableData dataWithBytesNoCopy:board length:8 freeWhenDone:NO];
			}
			break;
		}
        
		prev[0] = cur[0];
	}
}

- (void)GIFReadDescriptor
{
	[self GIFGetBytes:9];
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
    
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
    
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
    
	unsigned char GIF_code, GIF_sort;
    
	if (GIF_colorF == 1) {
		GIF_code = (aBuffer[8] & 0x07);
		if (aBuffer[8] & 0x20) GIF_sort = 1; else GIF_sort = 0;
	} else {
		GIF_code = GIF_colorC;
		GIF_sort = GIF_sorted;
	}
    
	int GIF_size = (2 << GIF_code);
    
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
    
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
    
	if (GIF_sort) {
		bBuffer[4] |= 0x08;
	}
    
	[GIF_string setData:[@"GIF89a" dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
	[self GIFPutBytes:GIF_screen];
    
	if (GIF_colorF == 1) {
		[self GIFGetBytes:(3 * GIF_size)];
		[self GIFPutBytes:GIF_buffer];
	} else {
		[self GIFPutBytes:GIF_global];
	}
    
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:GIF_frameHeader];
    
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
    
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
    
	cBuffer[8] &= 0x40;
    
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
    
	[self GIFPutBytes:GIF_screenTmp];
	[self GIFGetBytes:1];
	[self GIFPutBytes:GIF_buffer];
    
	for ( ; ; ) {
		[self GIFGetBytes:1];
		[self GIFPutBytes:GIF_buffer];
        
		size_t dlength = [GIF_buffer length];
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:dlength];
        
		long u = (int)dBuffer[0];
		if (u == 0x00) {
			break;
		}
		[self GIFGetBytes:u];
		[self GIFPutBytes:GIF_buffer];
	}
    
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
    
	// save the frame into the array of frames
	[GIF_framesData addObject:[GIF_string copy]];
}

- (int)GIFGetBytes:(int)length
{
	[GIF_buffer setData:[NSData data]];
	if ([GIF_pointer length] >= dataPointer + length) {
		[GIF_buffer setData:[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)]];
		dataPointer += length;
		return 1;
	} else {
		return 0;
	}
}

- (void)GIFPutBytes:(NSData *)bytes
{
	[GIF_string appendData:bytes];
}

@end