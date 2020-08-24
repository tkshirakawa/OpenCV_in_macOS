//
//  OCV.mm
//  OpenCV_macOS
//
//  Created by Takashi Shirakawa on 2020/01/04.
//  Copyright © 2020 Takashi Shirakawa. All rights reserved.
//


#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/photo.hpp>
#import <opencv2/highgui.hpp>

#import "OCV.h"


#define LOG_OCV_START()         { NSLog(@"OpenCV for macOS > Start %s", __FUNCTION__); }
#define CATCH_OCV_EXCEPTION(X)  { NSLog(@"OpenCV for macOS > Exception in %s : %@ : %@", __FUNCTION__, (X ? X.name : @"-"), (X ? X.reason : @"-")); }




// Wrapper written in objective C++ (.mm file) to connect other objective C codes to OpenCV framework written in C++11.
@implementation OCV


+ (NSString*) openCVVersion
{
//    Show version of OpenCV in opencv2.framework

    return [NSString stringWithCString:CV_VERSION encoding:NSUTF8StringEncoding];
}




#pragma mark === Show image ===


+ (void) showImage:(OCVImage*)srcImage title:(NSString*)title
{
    if (srcImage)
        [OCV showImage:srcImage.bitmapData width:srcImage.pwidth height:srcImage.pheight type:srcImage.cvtype title:title cc:-1];
}




+ (void) showImage:(uchar*)srcData width:(int)width height:(int)height type:(int)type title:(NSString*)title cc:(int)conversionCode
{
/*
 Set cc (= conversion code) to convert your srcData into BGR order, default order in OpenCV, required for cv::imshow().
 If your srcData is grayscale (one channel image) or cc is set to COLOR_NoConversion (= -1), no conversion will be applied.
 */

    if (!srcData || width <= 0 || height <= 0) return;

    @try
    {
        cv::Mat src(height, width, type, srcData);

        if (conversionCode >= 0 && src.channels() > 1)
            cv::cvtColor(src, src, conversionCode);

        cv::imshow([title cStringUsingEncoding:NSUTF8StringEncoding], src);
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return;
    }
}




#pragma mark === Miscs ===


+ (BOOL) convertColor:(OCVImage*)srcImage destination:(OCVImage*)dstImage cc:(int)conversionCode
{
    if (!srcImage || !dstImage || conversionCode < 0) return NO;

    @try
    {
        cv::Mat src(srcImage.pheight, srcImage.pwidth, srcImage.cvtype, srcImage.bitmapData);
        cv::Mat dst;

        cv::cvtColor(src, dst, conversionCode);

        uchar* dstPtr = dst.ptr(0);
        if (dstPtr)
        {
            if (src.elemSize() != dst.elemSize())
            {
                [dstImage setCvtype:dst.type()];
                [dstImage setPwidth:dst.size().width];
                [dstImage setPheight:dst.size().height];
                [dstImage setSamplesPerPixel:dst.channels()];
                [dstImage setBytesPerRow:(dstImage.pwidth * dstImage.samplesPerPixel)];
                [dstImage setTotalBytes:(dstImage.pheight * dstImage.bytesPerRow)];

                if (dstImage.bitmapData) free(dstImage.bitmapData);
                [dstImage setBitmapData:(uchar*)malloc(dstImage.totalBytes)];
            }
            memcpy(dstImage.bitmapData, dstPtr, dstImage.totalBytes);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) convertColor:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height type:(int)type cc:(int)conversionCode
{
/*
    Only for the same elemSize();
 */

    if (!srcData || width <= 0 || height <= 0 || conversionCode < 0) return NO;

    @try
    {
        cv::Mat src(height, width, type, srcData);
        cv::Mat dst;

        cv::cvtColor(src, dst, conversionCode);

        if (src.elemSize() != dst.elemSize()) return NO;

        uchar* dstPtr = dst.ptr(0);
        if (dstPtr)
        {
            memcpy(dstData, dstPtr, width * height * dst.elemSize());
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) split:(OCVImage*)srcImage forIndex:(int)index toData:(uchar*)dstData
{
    if (!srcImage || !dstData || index < 0) return NO;

    @try
    {
        cv::Mat src(srcImage.pheight, srcImage.pwidth, srcImage.cvtype, srcImage.bitmapData);
        std::vector<cv::Mat> dstVec;

        cv::split(src, dstVec);

        uchar* dstPtr = dstVec[index].ptr(0);
        if (dstPtr)
        {
            memcpy(dstData, dstPtr, srcImage.pwidth * srcImage.pheight);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) replaceChannelIn:(OCVImage*)srcImage atIndex:(int)index by:(UInt8*)byteData
{
    if (!srcImage || index < 0 || !byteData) return NO;

    @try
    {
        cv::Mat src(srcImage.pheight, srcImage.pwidth, srcImage.cvtype, srcImage.bitmapData);
        cv::Mat byteMat(srcImage.pheight, srcImage.pwidth, CV_8UC1, byteData);

        std::vector<cv::Mat> srcVec;
        cv::split(src, srcVec);
        
        std::vector<cv::Mat> dstVec;
        for (int i = 0; i < src.channels(); ++i)
        {
            if (i == index) dstVec.push_back(byteMat);
            else            dstVec.push_back(srcVec[i]);
        }

        cv::Mat merged;
        cv::merge(dstVec, merged);

        uchar* mergedPtr = merged.ptr(0);
        if (mergedPtr)
        {
            memcpy(srcImage.bitmapData, mergedPtr, srcImage.totalBytes);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




#pragma mark === CLAHE ===


+ (BOOL) applyCLAHE:(OCVImage*)srcImage destination:(OCVImage*)dstImage tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit
{
    if (srcImage && dstImage && srcImage.cvtype == CV_8UC1)
        return [OCV applyCLAHE:srcImage.bitmapData destination:dstImage.bitmapData width:srcImage.pwidth height:srcImage.pheight tileRow:tileRow tileCol:tileCol clipLimit:clipLimit cc:-1];
    else
        return NO;
}




+ (BOOL) applyCLAHE:(OCVImage*)srcImage tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit
{
    if (srcImage && srcImage.cvtype == CV_8UC1)
        return [OCV applyCLAHE:srcImage.bitmapData destination:srcImage.bitmapData width:srcImage.pwidth height:srcImage.pheight tileRow:tileRow tileCol:tileCol clipLimit:clipLimit cc:-1];
    else
        return NO;
}




+ (BOOL) applyCLAHE:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit cc:(int)conversionCode
{
/*
 Equalizes the histogram of a grayscale image using Contrast Limited Adaptive Histogram Equalization.
 Source image of type CV_8UC1 or CV_16UC1.
 Take care, no check for tile size and clip limit
 */

    if (!srcData || width <= 0 || height <= 0) return NO;

    @try
    {
        cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
        if (!clahe) return NO;

        clahe->setTilesGridSize(cv::Size(tileRow, tileCol));    // tileGridSize defines the number of tiles in row and column.
        clahe->setClipLimit(clipLimit);

        cv::Mat src(height, width, CV_8UC1, srcData, width);
        cv::Mat dst;
        clahe->apply(src, dst);
        clahe->collectGarbage();

        if (conversionCode >= 0 && dst.channels() > 1)
            cv::cvtColor(dst, dst, conversionCode);

        uchar* dstPtr = dst.ptr<uchar>(0);
        if (dstPtr)
        {
            memcpy(dstData, dstPtr, width * height * dst.elemSize());
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) applyCLAHE:(uchar*)srcData width:(int)width height:(int)height tileRow:(int)tileRow tileCol:(int)tileCol clipLimit:(double)clipLimit cc:(int)conversionCode
{
    return [OCV applyCLAHE:srcData destination:srcData width:width height:height tileRow:tileRow tileCol:tileCol clipLimit:clipLimit cc:conversionCode];
}




#pragma mark === Gaussian blur ===


+ (BOOL) applyGaussianBlur:(OCVImage*)srcImage destination:(OCVImage*)dstImage kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY
{
    if (srcImage && dstImage)
        return [OCV applyGaussianBlur:srcImage.bitmapData destination:dstImage.bitmapData width:srcImage.pwidth height:srcImage.pheight type:srcImage.cvtype kernelSize:kernelSize sigmaX:sigmaX sigmaY:sigmaY cc:-1];
    else
        return NO;
}




+ (BOOL) applyGaussianBlur:(OCVImage*)srcImage kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY
{
    if (srcImage)
        return [OCV applyGaussianBlur:srcImage.bitmapData destination:srcImage.bitmapData width:srcImage.pwidth height:srcImage.pheight type:srcImage.cvtype kernelSize:kernelSize sigmaX:sigmaX sigmaY:sigmaY cc:-1];
    else
        return NO;
}




+ (BOOL) applyGaussianBlur:(uchar*)srcData destination:(uchar*)dstData width:(int)width height:(int)height type:(int)type kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY cc:(int)conversionCode
{
    if (!srcData || width <= 0 || height <= 0) return NO;

    // Gaussian kernel size. kernelSize must be positive and odd.
    if (kernelSize % 2 == 0) ++kernelSize;
    kernelSize = MAX(1, kernelSize);

    @try
    {
        cv::Mat src(height, width, type, srcData);
        cv::Mat dst;

        cv::GaussianBlur(src, dst, cv::Size(kernelSize, kernelSize), sigmaX, sigmaY, cv::BORDER_DEFAULT);
        
        if (conversionCode >= 0 && dst.channels() > 1)
            cv::cvtColor(dst, dst, conversionCode);

        uchar* dstPtr = dst.ptr<uchar>(0);
        if (dstPtr)
        {
            memcpy(dstData, dstPtr, width * height * dst.elemSize());
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) applyGaussianBlur:(uchar*)srcData width:(int)width height:(int)height type:(int)type kernelSize:(int)kernelSize sigmaX:(double)sigmaX sigmaY:(double)sigmaY cc:(int)conversionCode
{
    return [OCV applyGaussianBlur:srcData destination:srcData width:width height:height type:type kernelSize:kernelSize sigmaX:sigmaX sigmaY:sigmaY cc:conversionCode];
}




#pragma mark === Find contours ===


+ (NSArray<NSArray<NSData*>*>*) findContours:(OCVImage*)srcImage scale:(NSPoint)scale offset:(NSPoint)offset epsilon:(double)epsilon
{
    if (srcImage)
        return [OCV findContours:srcImage.bitmapData width:srcImage.pwidth height:srcImage.pheight scale:scale offset:offset epsilon:epsilon];
    else
        return nil;
}


+ (NSArray<NSArray<NSData*>*>*) findContours:(uchar*)srcData width:(int)width height:(int)height scale:(NSPoint)scale offset:(NSPoint)offset epsilon:(double)epsilon
{
    if (!srcData || width <= 0 || height <= 0) return nil;

    @try
    {
        cv::Mat src(height, width, CV_8UC1, srcData, width);
        std::vector<std::vector<cv::Point>> contours;
        cv::findContours(src, contours, cv::RETR_LIST, cv::CHAIN_APPROX_NONE);
//        cv::findContours(src, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
//        cv::findContours(src, contours, cv::RETR_LIST, cv::CHAIN_APPROX_TC89_L1);
//        cv::findContours(src, contours, cv::RETR_LIST, cv::CHAIN_APPROX_TC89_KCOS);

        if (contours.size() == 0) return nil;

        NSMutableArray<NSArray<NSData*>*>* contoursArray = [NSMutableArray arrayWithCapacity:contours.size()];
        std::vector<cv::Point> cont_approx;

        for (auto &cont:contours)
        {
            cv::approxPolyDP(cv::Mat(cont), cont_approx, epsilon, true);    // Allow distance of epsilon

            NSMutableArray<NSData*>* contArray = [NSMutableArray arrayWithCapacity:cont_approx.size()];
            for (auto &point:cont_approx)
            {
                const NSPoint p = NSMakePoint(scale.x * point.x + offset.x, scale.y * point.y + offset.y);
                [contArray addObject:[NSData dataWithBytes:&p length:sizeof(NSPoint)]];
            }
            [contoursArray addObject:(NSArray<NSData*>*)contArray];
        }

        return (NSArray<NSArray<NSData*>*>*)contoursArray;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return nil;
    }
}




#pragma mark === Other filters... ===


+ (BOOL) applyMedianBlur:(uchar*)srcData width:(int)width height:(int)height kernelSize:(int)kernelSize
{
    if (!srcData || width <= 0 || height <= 0) return NO;

    // kernelSize must be odd and greater than 1, for example: 3, 5, 7 ...
    if (kernelSize % 2 == 0) ++kernelSize;
    kernelSize = MAX(3, kernelSize);

    @try
    {
        cv::Mat src(height, width, CV_8UC1, srcData, width);
        cv::Mat dst;

        cv::medianBlur(src, dst, kernelSize);

        uchar* dstPtr = dst.ptr<uchar>(0);
        if (dstPtr)
        {
            memcpy(srcData, dstPtr, width*height);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) applyBilateralFilter:(uchar*)srcData width:(int)width height:(int)height d:(int)d sigma:(double)sigma
{
/*
Sigma values: For simplicity, you can set the 2 sigma values to be the same. If they are small (< 10), the filter will not have much effect, whereas if they are large (> 150), they will have a very strong effect, making the image look "cartoonish".

Filter size: Large filters (d > 5) are very slow, so it is recommended to use d=5 for real-time applications, and perhaps d=9 for offline applications that need heavy noise filtering.
*/

    if (!srcData || width <= 0 || height <= 0) return NO;

    @try
    {
        cv::Mat src(height, width, CV_8UC1, srcData, width);
        cv::Mat dst;

        cv::bilateralFilter(src, dst, d, sigma, sigma);

        uchar* dstPtr = dst.ptr<uchar>(0);
        if (dstPtr)
        {
            memcpy(srcData, dstPtr, width*height);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




+ (BOOL) applyNlMeansDenoising:(uchar*)srcData width:(int)width height:(int)height h:(float)h
{
    if (!srcData || width <= 0 || height <= 0) return NO;

    @try
    {
        cv::Mat src(height, width, CV_8UC1, srcData, width);
        cv::Mat dst;

        cv::fastNlMeansDenoising(src, dst, h, 7, 21);

        uchar* dstPtr = dst.ptr<uchar>(0);
        if (dstPtr)
        {
            memcpy(srcData, dstPtr, width*height);
            return YES;
        }
        else
            return NO;
    }

    @catch (NSException *exception)
    {
        CATCH_OCV_EXCEPTION(exception);
        return NO;
    }
}




//+ (some_type) OCV_yourFunction:(some_type)some_data ...
//{
//    LOG_OCV_START();
//
//
//    @try
//    {
//        Code here...
//        Do something for some_data
//    }
//
//    @catch (NSException *exception)
//    {
//        CATCH_OCV_EXCEPTION(exception);
//        return NO;
//    }
//}


@end

