//
//  EmObjectDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 10/17/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef __objectdetect__EmObjectDetect__
#define __objectdetect__EmObjectDetect__

#define NumberOfFrames 5
#include <iostream>

using namespace cv;
using namespace std;


typedef struct contourStruct{
    std::vector<std::vector<cv::Point> > contours;
    cv::vector<cv::Vec4i> hierarchy;
    
} contourStruct;

class EmObjectDetect {
    
   
    
public:
    
    EmObjectDetect();
    
    vector<vector<cv::Point> > image_load_elaboration(Mat sample);
    Mat matFromContours(vector<vector<cv::Point> > contours);
    Mat camera_acquisition_elaboration(Mat inputFrame, vector<vector<cv::Point> > contour_unique_load, int mode);
    
    
    void Features2D_Homography();
    
    Mat sampleImage;
    
    double result;
    
    //double angle(cv::Point pt1, cv::Point pt2, cv::Point pt0);
    double euclideanDist(cv::Point p, cv::Point q);
    double euclideanDistInt(int p, int q);
    double euclideanDistPixel(Vec3b p, Vec3b q);
    double euclideanDistance(cv::Point, cv::Point);
    
private:
    
    // Dichiarazioni Globali
    
//    // Parameters
        RNG rng;
        Scalar color;
//    
//    
//    // Enable Flags
//     int trackbar_enable;
//    
//    // Trackbars Parameters
    int ksize_width, ksize_height, max_ksize_width, max_ksize_height;
     int threshold1, max_threshold1, threshold2, max_threshold2;
     int epsilon_factor, max_epsilon_factor;
    int dilation_size, max_dilation_size;
    int erosion_size,max_erosion_size;
    int center_dist, max_center_dist;
    int x, max_x, y, max_y;
    int maxNumberOfPoint, maxNumberOfPoint_limit;
    int PointPercentage, maxPointPercentage;
    int PixelDist, maxPixelDist;
    int minimum_dist, max_minimum_dist,minimum_dist_bis, max_minimum_dist_bis;
    
    // Images Buffer
    Mat img[NumberOfFrames];
    int img_idx;
//    
//    // "Focus" size
     cv::Rect rect;
	
//    // "image_load_elaboration" function variables
     vector< vector<cv::Point> > contours_load;
     vector<Vec4i> hierarchy_load;
//    
//    // "camera_acquisition_elaboration" function variables
    vector< vector<cv::Point> > contours;
     vector<Vec4i> hierarchy;
    

    
};


#endif /* defined(__objectdetect__EmObjectDetect__) */
