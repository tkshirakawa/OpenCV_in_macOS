//
//  OCVImage.h
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/06.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//


#ifndef OCVIMAGE_h
#define OCVIMAGE_h


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import <opencv2/core/hal/interface.h>




@interface OCVImage : NSObject <NSCopying>
{
}

@property (readwrite) UInt8*        bitmapData;     // 1-channel grayscale or 3-channel BGR color
@property (readwrite) int           cvtype;         // CV_8UC1 or CV_8UC3
@property (readwrite) int           pwidth, pheight;
@property (readwrite) int           samplesPerPixel;
@property (readwrite) NSUInteger    bytesPerRow, totalBytes;

- (instancetype) init;

+ (instancetype) ocvImageFromNSBitmapImageRep:(NSBitmapImageRep*)imageRep;
+ (instancetype) ocvImageFromCGImage:(CGImageRef)cgImage;
+ (instancetype) ocvImageFromNSImage:(NSImage*)nsImage;
+ (instancetype) ocvImageFromBitmap:(UInt8*)bitmap withParametersOf:(OCVImage*)ocvImage conversionCode:(int)cc;

- (BOOL) allocateOCVImageFrom:(NSBitmapImageRep*)imageRep;
- (NSImage*) nsImage;

@end


#endif /* OCVIMAGE_h */

