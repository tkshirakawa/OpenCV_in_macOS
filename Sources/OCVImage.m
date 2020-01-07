//
//  OCVImage.m
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/06.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//


#import "OCVImage.h"

#import "OCV.h"
#import "OCVColorConversionCodes.h"




@implementation OCVImage


- (instancetype) init
{
    _bitmapData = NULL;
    _cvtype = -1;
    _pwidth = _pheight = 0;
    _samplesPerPixel = 0;
    _bytesPerRow = _totalBytes = 0;

    return [super init];
}




- (void) dealloc
{
    if (_bitmapData) free(_bitmapData);
}




- (id) copyWithZone:(NSZone*)zone
{
    OCVImage *newInstance = [[[self class] allocWithZone:zone] init];

    if (newInstance)
    {
        newInstance.bitmapData = NULL;      // Memory is NULL
        newInstance.cvtype = self.cvtype;
        newInstance.pwidth = self.pwidth;
        newInstance.pheight = self.pheight;
        newInstance.samplesPerPixel = self.samplesPerPixel;
        newInstance.bytesPerRow = self.bytesPerRow;
        newInstance.totalBytes = self.totalBytes;
    }

    return newInstance;
}




+ (instancetype) ocvImageFromNSBitmapImageRep:(NSBitmapImageRep*)imageRep;
{
    if (!imageRep) return nil;

    OCVImage* img = [[OCVImage alloc] init];
    if (!img) return nil;

    if ([img allocateOCVImageFrom:imageRep]) return img;
    else                                    return nil;
}




+ (instancetype) ocvImageFromCGImage:(CGImageRef)cgImage
{
    if (!cgImage) return nil;

    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    return [OCVImage ocvImageFromNSBitmapImageRep:imageRep];
}




+ (instancetype) ocvImageFromNSImage:(NSImage*)nsImage
{
    if (!nsImage) return nil;

    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage:[nsImage CGImageForProposedRect:nil context:nil hints:nil]];
    return [OCVImage ocvImageFromNSBitmapImageRep:imageRep];
}




+ (instancetype) ocvImageFromBitmap:(UInt8*)bitmap withParametersOf:(OCVImage*)ocvImage conversionCode:(int)conversionCode
{
    if (!ocvImage) return nil;

    OCVImage* img = ocvImage.copy;
    if (!img) return nil;

    if (!bitmap)
        bitmap = (UInt8*)malloc(img.totalBytes);
    else if (conversionCode >= 0)
        [OCV convertColor:bitmap destination:bitmap width:img.pwidth height:img.pheight type:img.cvtype cc:conversionCode];

    [img setBitmapData:bitmap];
    return img;
}




- (BOOL) allocateOCVImageFrom:(NSBitmapImageRep*)imageRep
{
    if (imageRep.bitmapFormat != 0) return NO;


    const UInt8* imagePtr = imageRep.bitmapData;
    if (!imagePtr) return NO;


    const NSUInteger pw = imageRep.pixelsWide;
    const NSUInteger ph = imageRep.pixelsHigh;
    const int spp = (int)MIN(imageRep.samplesPerPixel, 3);
    if (spp != 1 && spp != 3) return NO;

    
    const NSUInteger bytesPerPixel = imageRep.bitsPerPixel / 8;
    const NSUInteger bytesPerRow = imageRep.bytesPerRow;

    
    // Allocate memory for pixel data
    const NSUInteger pRowBytes = pw * spp;
    UInt8* retPtr = (UInt8*)malloc(ph * pRowBytes);
    if (!retPtr) return NO;


    // Transfer source pixel values in macOS to continuous raw pixel array for OpenCV
    // 1-channel grayscale or 3-channel BGR color
    if (spp == 1)   // Grayscale
    {
        for (NSUInteger row = 0; row < ph; ++row)
        {
            UInt8* source = (UInt8*)(imagePtr + row * bytesPerRow);
            UInt8* destination = (UInt8*)(retPtr + row * pRowBytes);
            NSUInteger i = 0, j = 0;
            for (; i < bytesPerRow; i += bytesPerPixel, ++j)
                destination[j] = source[i];     // Gray
        }
    }
    else    // if (spp == 3)    RGB -> BGR
    {
        for (NSUInteger row = 0; row < ph; ++row)
        {
            UInt8* source = (UInt8*)(imagePtr + row * bytesPerRow);
            UInt8* destination = (UInt8*)(retPtr + row * pRowBytes);
            NSUInteger i = 0, j = 0;
            for (; i < bytesPerRow; i += bytesPerPixel, j += 3)
            {
                // Bitmap data stored in OCVImage class is BGR order!
                destination[j + 2] = source[i + 0];     // R
                destination[j + 1] = source[i + 1];     // G
                destination[j + 0] = source[i + 2];     // B
            }
        }
    }


    // Success
    if (_bitmapData) free(_bitmapData);
    _bitmapData = retPtr;
    _cvtype = (spp == 1 ? CV_8UC1 : CV_8UC3);
    _pwidth = (int)pw;
    _pheight = (int)ph;
    _samplesPerPixel = spp;
    _bytesPerRow = pw * spp;
    _totalBytes = ph * _bytesPerRow;


    return YES;
}




- (NSImage*) nsImage
{
    if (!_bitmapData) return nil;

    @autoreleasepool
    {
        NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL
                                                                             pixelsWide: _pwidth    pixelsHigh: _pheight
                                                                          bitsPerSample: 8     samplesPerPixel: _samplesPerPixel
                                                                               hasAlpha: NO           isPlanar: NO
                                                                         colorSpaceName: NSDeviceRGBColorSpace
                                                                            bytesPerRow: _bytesPerRow
                                                                           bitsPerPixel: 0];
        // Bitmap data stored in OCVImage class is BGR order!
        if (_samplesPerPixel > 1)
            [OCV convertColor:_bitmapData destination:imageRep.bitmapData width:_pwidth height:_pheight type:_cvtype cc:COLOR_BGR2RGB];
        else
            memcpy(imageRep.bitmapData, _bitmapData, _totalBytes);

        return [[NSImage alloc] initWithCGImage:imageRep.CGImage size:NSZeroSize];
    }
}


@end

