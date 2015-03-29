//
//  AGObjectDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef __objectdetect__AGObjectDetect__
#define __objectdetect__AGObjectDetect__

#include <iostream>


typedef struct shapeDef{
    int index;
    std::vector<cv::Point> centroids;
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    
} shapeDef;

typedef struct objectDef{
    cv::Mat image;
    bool match;
} objectDef;

class AGObjectDetect{
    
    public:
    
    static float approxValue;
    
    //algorithms
    static std::vector<std::vector<cv::Point> > getContoursFromImage(cv::Mat image, cv::Point center,int distance);
    static std::vector<std::vector<cv::Point> > getSampleFromImage(cv::Mat image);
    static cv::Mat matFromContours(std::vector<std::vector<cv::Point> > contours);
    static objectDef objectDetection(cv::Mat image, std::vector<std::vector<cv::Point> > contourImage,double result, double threshold);
    static double compare(std::vector<std::vector<cv::Point> > contourSample,std::vector<std::vector<cv::Point> > contourImage);
    
    static bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame, int const mode);
     
    static double euclideanDist(cv::Point p, cv::Point q);
    static void convertVectorToPoint(std::vector<cv::Point2f>& input, std::vector<cv::Point>& output);

    
    
    private:
 
    std::vector<shapeDef> imageSamples;
    cv::Mat optimizedShape(cv::Mat image);
    
    //YEAH!
    cv::Mat drawShapeAnotherWorld(cv::Mat image, shapeDef shape);
    
};
#endif /* defined(__objectdetect__AGObjectDetect__) */
