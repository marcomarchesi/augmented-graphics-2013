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

using namespace cv;


typedef struct shapeDef{
    int index;
    std::vector<cv::Point> centroids;
    std::vector<std::vector<cv::Point> > contours;
    cv::vector<cv::Vec4i> hierarchy;
    
} shapeDef;

typedef struct objectDef{
    Mat image;
    bool match;
} objectDef;

class AGObjectDetect{
    
    public:
    
    static float approxValue;
    
    //algorithms
    static vector<vector<cv::Point> > getContoursFromImage(Mat image, cv::Point center,int distance);
    static vector<vector<cv::Point> > getSampleFromImage(Mat image);
    static cv::Mat matFromContours(vector<vector<cv::Point> > contours);
    static objectDef objectDetection(cv::Mat image, vector<vector<cv::Point> > contourImage,double result, double threshold);
    static double compare(vector<vector<cv::Point> > contourSample,vector<vector<cv::Point> > contourImage);
    
    static bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame, int const mode);
     
    static double euclideanDist(cv::Point p, cv::Point q);
    static void convertVectorToPoint(vector<Point2f>& input, vector<cv::Point>& output);

    
    
    private:
 
    std::vector<shapeDef> imageSamples;
    cv::Mat optimizedShape(cv::Mat image);
    
    //YEAH!
    cv::Mat drawShapeAnotherWorld(cv::Mat image, shapeDef shape);
    
};
#endif /* defined(__objectdetect__AGObjectDetect__) */
