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
    NSImage* img1 = [NSImage imageNamed:@"Philadelphia.jpg"];
    [sourceImageView1 setImage:img1];
    [claheImageView setImage:img1];
    [gBlurImageView setImage:img1];

    NSImage* img2 = [NSImage imageNamed:@"Gear.png"];
    [sourceImageView2 setImage:img2];
    [contoursImageView setImage:img2];

    // Bitmap data
    sourceImage1 = [OCVImage ocvImageFromNSImage:img1];
    claheImage   = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage1 conversionCode:-1];
    gBlurImage   = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage1 conversionCode:-1];
    sourceImage2 = [OCVImage ocvImageFromNSImage:img2];     // Type of source image must be CV_8UC1 to find countours
//    OCVImage* tempImg = [OCVImage ocvImageFromNSImage:img2];
//    sourceImage2 = [OCVImage ocvImageFromBitmap:NULL withParametersOf:tempImg conversionCode:-1];
//    [OCV convertColor:tempImg destination:sourceImage2 cc:COLOR_BGR2GRAY];

    // Show image data
    [sourceImageInfo1 setStringValue:[NSString stringWithFormat:@"Image name : %@\nImage size : %dx%d\nSamples per pixel : %d\nObject class : %@", img1.name, sourceImage1.pwidth, sourceImage1.pheight, sourceImage1.samplesPerPixel, sourceImage1.className]];
    [sourceImageInfo2 setStringValue:[NSString stringWithFormat:@"Image name : %@\nImage size : %dx%d\nSamples per pixel : %d\nObject class : %@", img2.name, sourceImage2.pwidth, sourceImage2.pheight, sourceImage2.samplesPerPixel, sourceImage2.className]];
}




- (void) closeImageController:(NSNotification*)aNotification
{
    // Codes required when closed.
}




- (IBAction) showSourceImageInOCVWindow:(NSButton*)button
{
    @autoreleasepool
    {
        OCVImage* grayImage = [OCVImage ocvImageFromBitmap:NULL withParametersOf:sourceImage1 conversionCode:-1];
        [OCV convertColor:sourceImage1 destination:grayImage cc:COLOR_BGR2GRAY];

        [OCV showImage:sourceImage1 title:@"Source image 1 in OpenCV window"];
        [OCV showImage:grayImage title:@"Grayscale image in OpenCV window"];
    }

    [window orderFront:NULL];
}




- (IBAction) slideClipLimit:(NSSlider*)slider
{
    // Apply CLAHE for saturation channel
    [OCV convertColor:sourceImage1 destination:claheImage cc:COLOR_BGR2HSV];
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
    [OCV applyGaussianBlur:sourceImage1 destination:gBlurImage kernelSize:slider.intValue sigmaX:20.0 sigmaY:20.0];

    // Set image
    [gBlurImageView setImage:gBlurImage.nsImage];
}




- (IBAction) buttonFindContours:(id)sender
{
    [contoursImageView setImage:sourceImage2.nsImage];


    // Find countours, type of the source image must be CV_8UC1
    // Method = 1 means CHAIN_APPROX_NONE
    NSArray<NSArray<NSData*>*>* contours = [OCV findContours:sourceImage2 method:1 scale:NSMakePoint(1.0,1.0) offset:NSZeroPoint epsilon:1e-3];

    if (contours && contours.count > 0)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, sourceImage2.pwidth, sourceImage2.pheight, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        if (context)
        {
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextAddRect(context, CGRectMake(0.0 , 0.0, sourceImage2.pwidth, sourceImage2.pheight));
            CGContextFillPath(context);

            // Draw contour lines
            CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
            CGContextSetLineWidth(context, (sourceImage2.pwidth+sourceImage2.pheight)/250.0);
            for (NSArray<NSData*>* points in contours)
            {
                NSPoint p;
                [points[points.count-1] getBytes:&p length:sizeof(NSPoint)];
                CGContextMoveToPoint(context, p.x, sourceImage2.pheight - p.y);
                for (int i = 0; i < points.count; ++i)
                {
                    [points[i] getBytes:&p length:sizeof(NSPoint)];
                    CGContextAddLineToPoint(context, p.x, sourceImage2.pheight - p.y);
                }
            }
            CGContextStrokePath(context);

            // Set image
            CGImageRef imageRef = CGBitmapContextCreateImage(context);
            NSImage* img = imageRef ? [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize] : nil;
            if (img) [contoursImageView setImage:img];

            CGContextRelease(context);
        }
        CGColorSpaceRelease(colorSpace);
    }
}


@end
