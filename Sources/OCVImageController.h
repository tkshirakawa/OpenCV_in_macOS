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
    OCVImage* sourceImage;
    OCVImage* claheImage;
    OCVImage* gBlurImage;


    __weak IBOutlet NSWindow *window;

    __weak IBOutlet NSTextField *openCVVersion;
    
    __weak IBOutlet NSTextField *sourceImageInfo;
    __weak IBOutlet NSImageView *sourceImageView;
    __weak IBOutlet NSImageView *claheImageView;
    __weak IBOutlet NSImageView *gBlurImageView;
    
}

- (instancetype) init;

- (void) loadImageController:(NSNotification*)aNotification;
- (void) closeImageController:(NSNotification*)aNotification;

- (IBAction) showSourceImageInOCVWindow:(NSButton*)button;

- (IBAction) slideClipLimit:(NSSlider*)slider;
- (IBAction) slideKernelSize:(NSSlider*)slider;

@end


NS_ASSUME_NONNULL_END

