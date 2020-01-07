# OpenCV in macOS GUI Apps
<b>Description</b>
I had been looking for sample codes of OpenCV used in GUI apps of macOS (not for iOS or iPadOS, etc).
But I couldn't.
I made a simple sample app of macOS using OpenCV library. I also built ‘opencv2.framework’ of version 4.2.0, and used it in this Xcode project.

OpenCV site : https://opencv.org/<br>
Source of the framework : https://opencv.org/opencv-4-2-0/

<u>NOTE: The file 'opencv2.framework' is too large to upload into GitHub. Please download it from here .</u>

<b>About Files</b>
CV.mm / CV.h
A wrapper class written in objective C++ (.mm file). They connect other objective C codes to OpenCV framework (opencv2.framework) written in C++11.

OCVImage.m / OCVImage.h
An objective C class to munipulate bitmap data for OpenCV based on macOS images (NSImage, CGImage and NSBitmapImageRep). If the bitmap is color data with multiple channels, the color order stored in this class is BGR (Blue-Green-Red), default in OpenCV.

OCVImageController.m / OCVImageController.h
Codes to maintain window and other GUIs for this sample app.


<img width="942" alt="window" src="https://user-images.githubusercontent.com/52600509/71859174-4b9d9b00-3131-11ea-816e-ae7cf78d976b.png">
