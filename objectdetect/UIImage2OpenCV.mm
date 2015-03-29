

#import "UIImage2OpenCV.h"
#import "AGObjectDetect.h"

@implementation UIImage (OpenCV)

-(cv::Mat) toMat
{
  CGImageRef imageRef = self.CGImage;
  
  const int srcWidth        = (int)CGImageGetWidth(imageRef);
  const int srcHeight       = (int)CGImageGetHeight(imageRef);
  //const int stride          = CGImageGetBytesPerRow(imageRef);
  //const int bitPerPixel     = CGImageGetBitsPerPixel(imageRef);
  //const int bitPerComponent = CGImageGetBitsPerComponent(imageRef);
  //const int numPixels       = bitPerPixel / bitPerComponent;
  
  CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
  CFDataRef rawData = CGDataProviderCopyData(dataProvider);
  
  //unsigned char * dataPtr = const_cast<unsigned char*>(CFDataGetBytePtr(rawData));

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  cv::Mat rgbaContainer(srcHeight, srcWidth, CV_8UC4);
  CGContextRef context = CGBitmapContextCreate(rgbaContainer.data,
                                               srcWidth,
                                               srcHeight,
                                               8,
                                               4 * srcWidth, 
                                               colorSpace,
                                               kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);

  CGContextDrawImage(context, CGRectMake(0, 0, srcWidth, srcHeight), imageRef);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
      
  CFRelease(rawData);
  
  cv::Mat t;
  cv::cvtColor(rgbaContainer, t, cv::COLOR_RGBA2BGRA);

  //cv::Vec4b a = rgbaContainer.at<cv::Vec4b>(0,0);
  //cv::Vec4b b = t.at<cv::Vec4b>(0,0);
  //std::cout << std::hex << (int)a[0] << " "<< (int)a[1] << " " << (int)a[2] << " "  << (int)a[3] << std::endl; 
  //std::cout << std::hex << (int)b[0] << " "<< (int)b[1] << " " << (int)b[2] << " "  << (int)b[3] << std::endl; 

  return t;
}

+(UIImage*) imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation) orientation
{ 
  UIImageOrientation imgOrientation = UIImageOrientationUp;
  
  switch (orientation) 
  {
    case UIDeviceOrientationLandscapeLeft:
      imgOrientation = UIImageOrientationUp; break;
      
    case UIDeviceOrientationLandscapeRight:
      imgOrientation = UIImageOrientationDown; break;
      
    case UIDeviceOrientationPortraitUpsideDown:
      imgOrientation = UIImageOrientationRightMirrored; break;
      
    default:
    case UIDeviceOrientationPortrait:
      imgOrientation = UIImageOrientationRight; break;
  };
  
  return [UIImage imageWithMat:image andImageOrientation:imgOrientation];
}

+(UIImage*) imageWithMat:(const cv::Mat&) image andImageOrientation: (UIImageOrientation) orientation;
{
  cv::Mat rgbaView;
  
  if (image.channels() == 3)
  {
    cv::cvtColor(image, rgbaView,  cv::COLOR_BGR2RGBA);
  }
  else if (image.channels() == 4)
  {
    cv::cvtColor(image, rgbaView, cv::COLOR_BGRA2RGBA);
  }
  else if (image.channels() == 1)
  {
    cv::cvtColor(image, rgbaView, cv::COLOR_GRAY2RGBA);
  }
  
  NSData *data = [NSData dataWithBytes:rgbaView.data length:rgbaView.elemSize() * rgbaView.total()];
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  
  CGBitmapInfo bmInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
  
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(image.cols,                                 //width
                                      image.rows,                                 //height
                                      8,                                          //bits per component
                                      8 * image.elemSize(),                       //bits per pixel
                                      image.step.p[0],                            //bytesPerRow
                                      colorSpace,                                 //colorspace
                                      bmInfo,// bitmap info
                                      provider,                                   //CGDataProviderRef
                                      NULL,                                       //decode
                                      false,                                      //should interpolate
                                      kCGRenderingIntentDefault                   //intent
                                      );
    
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:1 orientation:orientation];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  
  return finalImage;
}

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    cv::cvtColor(cvMat, cvMat, cv::COLOR_BGRA2RGBA);
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    bool alpha = cvMat.channels() == 4;
    CGBitmapInfo bitMapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        bitMapInfo,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}


+(UIImage*) imageDetectedFrom:(cv::Mat)image{
    
    UIImage *inputImage = [UIImage imageWithMat:image andDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    
    cv::Mat dst = cv::Mat::zeros(image.size(), image.type());
    
    image.copyTo(dst);
    //TODO
//    vector<vector<cv::Point>> contours = AGObjectDetect::getContoursFromImage(image,cv::Point(320,240),120);
//    cv::drawContours( dst, contours, 0, cvScalar(255,255,255), CV_FILLED,8);
    
    cv::Mat dst_inv;
    cv::subtract(cv::Scalar::all(255),dst,dst_inv);
    
    
    
    UIImage *mask = [UIImage imageWithMat:dst_inv andDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    
    CGImageRef imageReference = inputImage.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES // Should interpolate
                                             );
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
    
}


@end
