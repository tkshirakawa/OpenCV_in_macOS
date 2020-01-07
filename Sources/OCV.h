//
//  OCV.h
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/04.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//


#ifndef OCV_h
#define OCV_h


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import <opencv2/core/hal/interface.h>

#import "OCVImage.h"




// Wrapper written in objective C++ (.mm file) to connect other objective C codes to OpenCV framework written in C++11.
@interface OCV : NSObject

+ (NSString*) openCVVersion;


// Show image in OpenCV window
#pragma mark === Show image ===

+ (void) showImage:(OCVImage*)srcImage title:(NSString*)title;
+ (void) showImage:(uchar*)srcData width:(int)width height:(int)height type:(int)type title:(NSString*)title cc:(int)conversionCode;


#pragma mark === Miscs ===

+ (BOOL) convertColor:(OCVImage*)srcImage destination:(OCVImage*)dstImage cc:(int)conversionCode;
+ (BOOL) convertColor:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height type:(int)type cc:(int)conversionCode;

+ (BOOL) split:(OCVImage*)srcImage forIndex:(int)index toData:(uchar*)dstData;
+ (BOOL) replaceChannelIn:(OCVImage*)srcImage atIndex:(int)index by:(UInt8*)byteData;


// CLAHE
// The result will be written into dstImage/dstData. If without them, the result will be written into its input: srcImage/srcData.
#pragma mark === CLAHE ===

+ (BOOL) applyCLAHE:(OCVImage*)srcImage destination:(OCVImage*)dstImage tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit;
+ (BOOL) applyCLAHE:(OCVImage*)srcImage tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit;

+ (BOOL) applyCLAHE:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit cc:(int)conversionCode;
+ (BOOL) applyCLAHE:(uchar*)srcData width:(int)width height:(int)height tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit cc:(int)conversionCode;


// Gaussian blur
// The result will be written into dstImage/dstData. If without them, the result will be written into input: srcImage/srcData.
#pragma mark === Gaussian blur ===

+ (BOOL) applyGaussianBlur:(OCVImage*)srcImage destination:(OCVImage*)dstImage kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY;
+ (BOOL) applyGaussianBlur:(OCVImage*)srcImage kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY;

+ (BOOL) applyGaussianBlur:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height type:(int)type kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY cc:(int)conversionCode;
+ (BOOL) applyGaussianBlur:(uchar*)srcData width:(int)width height:(int)height type:(int)type kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY cc:(int)conversionCode;


// Find contours, a little bit complicated
#pragma mark === Find contours ===

+ (NSArray<NSArray<NSData*>*>*) findContours:(uchar*)srcData width:(int)width height:(int)height scale:(NSPoint)scale offset:(NSPoint)offset epsilon:(double)epsilon;


// Other filters... as sample codes
#pragma mark === Other filters... ===

+ (BOOL) applyMedianBlur:(uchar*)srcData width:(int)width height:(int)height kernelSize:(int)kernelSize;
+ (BOOL) applyBilateralFilter:(uchar*)srcData width:(int)width height:(int)height d:(int)d sigma:(double)sigma;
+ (BOOL) applyNlMeansDenoising:(uchar*)srcData width:(int)width height:(int)height h:(float)h;


//+ (some_type) OCV_yourFunction:(some_type)some_data ...;

@end


#endif /* OCV_h */

