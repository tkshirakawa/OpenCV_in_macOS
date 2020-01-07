# OpenCV in macOS GUI Apps
<b>Description</b><br>
I had been looking for sample codes of OpenCV used in GUI apps of macOS (not for iOS or iPadOS, etc).<br>
But I couldn't.<br>
I made a simple sample app of macOS using OpenCV library. I also built ‘opencv2.framework’ of version 4.2.0, and used it in this Xcode project. The sample app shows results of CLAHE (Contrast Limited Adaptive Histogram Equalization) and Gaussian blur filters.<br>
<br>
OpenCV site : https://opencv.org/<br>
Source of the framework : https://opencv.org/opencv-4-2-0/<br>
<br>
<b>NOTE:</b> The file 'opencv2.framework' is too large to upload into GitHub. Please download it from https://www.icloud.com/iclouddrive/0EIN-yCPcwjrx0fzdAA6Z9DkA#opencv2.framework<br>
<br>
<br>
<b>About Files</b><br>
OCV.mm / OCV.h<br>
A wrapper class written in objective C++ (.mm file). They connect other objective C codes to OpenCV framework (opencv2.framework) written in C++11.<br>
<br>
OCVImage.m / OCVImage.h<br>
An objective C class to munipulate bitmap data for OpenCV based on macOS images (NSImage, CGImage and NSBitmapImageRep). If the bitmap is color data with multiple channels, the color order stored in this class is BGR (Blue-Green-Red), default in OpenCV.<br>
<br>
OCVImageController.m / OCVImageController.h<br>
Codes to maintain window and other GUIs for this sample app.<br>
<br>
<br>
<img width="942" alt="window" src="https://user-images.githubusercontent.com/52600509/71859174-4b9d9b00-3131-11ea-816e-ae7cf78d976b.png">
<br>
<i>*The picture : The house of American Philosophical Society, taken from the backyard of Independence Hall in Philadelphia, USA.</i>
