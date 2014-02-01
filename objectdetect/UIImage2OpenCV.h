

// This interface extension allows convert UIImage to cv::Mat representation and
// vice versa using full data copy in both directions.
@interface UIImage (OpenCV)

-(cv::Mat) toMat;

+(UIImage*) imageWithMat:(const cv::Mat&) image andImageOrientation: (UIImageOrientation) orientation;
+(UIImage*) imageWithMat:(const cv::Mat&) image andDeviceOrientation: (UIDeviceOrientation) orientation;
+(UIImage*) imageDetectedFrom:(cv::Mat)image;
+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;

@end
