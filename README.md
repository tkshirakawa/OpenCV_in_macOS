# OpenCV in macOS GUI Apps
An Xcode project using OpenCV library in macOS GUI apps.  
The sample app shows results of **CLAHE (Contrast Limited Adaptive Histogram Equalization)** / **Gaussian blur** filters and **Find contours** operation.  
<img width="1210" alt="Screen Shot 2020-08-24 at 22 36 39" src="https://user-images.githubusercontent.com/52600509/91050925-56725500-e65a-11ea-9770-5a3e405bf23e.png">  
*The picture is the house of American Philosophical Society in Philadelphia, USA.  
(Taken from the backyard of Independence Hall)*  
  
  
## Description
I had been looking for sample codes of OpenCV used in macOS GUI apps (not for iOS, iPadOS or command line tools). But I couldn't.  
So, I made a simple sample app of macOS using OpenCV library. I also built ‘opencv2.framework’ of version 4.3.0, and used it in this Xcode project.  
  
OpenCV site : <https://opencv.org/>  
Source of the framework : <https://opencv.org/releases/>  
I follow [the license of OpenCV](https://github.com/tkshirakawa/OpenCV_in_macOS/blob/master/LICENSE%20of%20OpenCV) for OpenCV library and opencv2.framework.  
  
Download 'opencv2.framework' that I built for my macOS apps and this sample code, from [HERE](https://1drv.ms/u/s!AjXH_7BsMKXajpd9CWN2SouiYQzz5w?e=KTcRLl). And put it in your Xcode project as following:
<img width="1680" alt="Screen Shot 2020-08-24 at 12 35 05" src="https://user-images.githubusercontent.com/52600509/91002071-8db81600-e608-11ea-9e89-b4713a58d33c.png">
  
  
## About Files
**OCV.mm / OCV.h**  
A wrapper class written in objective C++ (.mm file). They connect other objective C codes for macOS to OpenCV framework (opencv2.framework) written in C++11.  
  
**OCVImage.m / OCVImage.h**  
An objective C class to munipulate bitmap data for OpenCV based on macOS images (NSImage, CGImage and NSBitmapImageRep). If the bitmap is color data with multiple channels, the color order stored in this class is BGR (Blue-Green-Red), default in OpenCV.  
  
**OCVImageController.m / OCVImageController.h**  
Codes to maintain window and other GUIs for this sample app.  
  
