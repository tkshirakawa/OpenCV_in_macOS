//
//  OCVImageController.h
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/05.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "OCV.h"


NS_ASSUME_NONNULL_BEGIN


@interface OCVImageController : NSObject
{
    __weak IBOutlet NSWindow *window;
    __weak IBOutlet NSTextField *openCVVersion;

    // For Philadelphia.jpg
    OCVImage* sourceImage1;
    OCVImage* claheImage;
    OCVImage* gBlurImage;
    __weak IBOutlet NSTextField *sourceImageInfo1;
    __weak IBOutlet NSImageView *sourceImageView1;
    __weak IBOutlet NSImageView *claheImageView;
    __weak IBOutlet NSImageView *gBlurImageView;

    // For Gear.png
    OCVImage* sourceImage2;
//    OCVImage* contoursImage;
    __weak IBOutlet NSTextField *sourceImageInfo2;
    __weak IBOutlet NSImageView *sourceImageView2;
    __weak IBOutlet NSImageView *contoursImageView;
}

- (instancetype) init;

- (void) loadImageController:(NSNotification*)aNotification;
- (void) closeImageController:(NSNotification*)aNotification;

- (IBAction) showSourceImageInOCVWindow:(NSButton*)button;

- (IBAction) slideClipLimit:(NSSlider*)slider;
- (IBAction) slideKernelSize:(NSSlider*)slider;
- (IBAction) buttonFindContours:(id)sender;

@end


NS_ASSUME_NONNULL_END

