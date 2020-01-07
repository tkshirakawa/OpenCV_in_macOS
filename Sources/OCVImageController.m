//
//  OCVImageController.m
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/05.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//

#import "OCVImageController.h"
#import "OCVColorConversionCodes.h"




@implementation OCVImageController


- (instancetype) init
{
    self = [super init];

    if (self)
    {
        const NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver: self
               selector: @selector(loadImageController:)
                   name: NSApplicationDidFinishLaunchingNotification
                 object: nil];
        [nc addObserver: self
               selector: @selector(closeImageController:)
                   name: NSApplicationWillTerminateNotification
                 object: nil];
    }

    return self;
}




- (void) loadImageController:(NSNotification*)aNotification
{
    // Show version of OpenCV in opencv2.framework
    [openCVVersion setStringValue:[OCV openCVVersion]];

    // Show source image
    NSImage* img = [NSImage imageNamed:@"Philadelphia.jpg"];
    [sourceImageView setImage:img];
    [claheImageView setImage:img];
    [gBlurImageView setImage:img];

    // Bitmap data
    sourceImage = [OCVImage ocvImageFromNSImage:img];
    claheImage = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage conversionCode:-1];
    gBlurImage = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage conversionCode:-1];

    // Show image data
    [sourceImageInfo setStringValue:[NSString stringWithFormat:@"Image name : %@\nImage size : %dx%d\nSamples per pixel : %d\nObject class : %@", img.name, sourceImage.pwidth, sourceImage.pwidth, sourceImage.samplesPerPixel, sourceImage.className]];
}




- (void) closeImageController:(NSNotification*)aNotification
{
    // Codes required when closed.
}




- (IBAction) showSourceImageInOCVWindow:(NSButton*)button
{
    @autoreleasepool
    {
        OCVImage* grayImage = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage conversionCode:-1];
        [OCV convertColor:sourceImage destination:grayImage cc:COLOR_BGR2GRAY];

        [OCV showImage:sourceImage title:@"Source image in OpenCV window"];
        [OCV showImage:grayImage title:@"Grayscale image in OpenCV window"];
    }

    [window orderFront:NULL];
}




- (IBAction) slideClipLimit:(NSSlider*)slider
{
    // Apply CLAHE for saturation channel
    [OCV convertColor:sourceImage destination:claheImage cc:COLOR_BGR2HSV];
    UInt8* S = (UInt8*)malloc(claheImage.pwidth * claheImage.pheight);

    [OCV split:claheImage forIndex:1 toData:S];
    [OCV applyCLAHE:S width:claheImage.pwidth height:claheImage.pheight tileRow:8 tileCol:8 clipLimit:(slider.intValue/10.0) cc:-1];
    [OCV replaceChannelIn:claheImage atIndex:1 by:S];

    free(S);
    [OCV convertColor:claheImage destination:claheImage cc:COLOR_HSV2BGR];

    // Set image
    [claheImageView setImage:claheImage.nsImage];
}




- (IBAction) slideKernelSize:(NSSlider*)slider
{
    // Apply Gaussian blur filter
    [OCV applyGaussianBlur:sourceImage destination:gBlurImage kernelSize:slider.intValue sigmaX:20.0 sigmaY:20.0];

    // Set image
    [gBlurImageView setImage:gBlurImage.nsImage];
}


@end
