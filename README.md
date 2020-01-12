# OpenCV in macOS GUI Apps
A sample Xcode project using OpenCV library in macOS GUI apps. 
 
<img width="942" alt="window" src="https://user-images.githubusercontent.com/52600509/71859174-4b9d9b00-3131-11ea-816e-ae7cf78d976b.png"> 
*The picture : The house of American Philosophical Society, taken from the backyard of Independence Hall in Philadelphia, USA.*
  
## Description 
I had been looking for sample codes of OpenCV used in GUI apps of macOS (not for iOS or iPadOS, etc). But I couldn't. 
So, I made a simple sample app of macOS using OpenCV library. I also built ‘opencv2.framework’ of version 4.2.0, and used it in this Xcode project. 
The sample app shows results of CLAHE (Contrast Limited Adaptive Histogram Equalization) and Gaussian blur filters. 
 
OpenCV site : https://opencv.org/ 
Source of the framework : https://opencv.org/opencv-4-2-0/ 
 
**NOTE:** The file 'opencv2.framework' is too large to upload into GitHub. Please download it from 
https://www.icloud.com/iclouddrive/0l0nK8HIE8oXmQdRe_C1KyuaQ#opencv2.framework 
 
 
## About Files
OCV.mm / OCV.h 
A wrapper class written in objective C++ (.mm file). They connect other objective C codes to OpenCV framework (opencv2.framework) written in C++11. 
 
OCVImage.m / OCVImage.h 
An objective C class to munipulate bitmap data for OpenCV based on macOS images (NSImage, CGImage and NSBitmapImageRep). If the bitmap is color data with multiple channels, the color order stored in this class is BGR (Blue-Green-Red), default in OpenCV. 
 
OCVImageController.m / OCVImageController.h 
Codes to maintain window and other GUIs for this sample app. 
