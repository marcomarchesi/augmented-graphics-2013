//
//  ImageDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 9/2/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef __objectdetect__ImageDetect__
#define __objectdetect__ImageDetect__

#include <iostream>
class ImageDetect{
private:
    
    
public:
    // pointer to the feature point detector object
    cv::Ptr<cv::FeatureDetector> detector;
    // pointer to the feature descriptor extractor object
    cv::Ptr<cv::DescriptorExtractor> extractor;
    // pointer to the matcher object
    cv::Ptr<cv::DescriptorMatcher > matcher;
    
    float ratio; // max ratio between 1st and 2nd NN
    bool refineF; // if true will refine the F matrix
    double distance; // min distance to epipolar
    double confidence; // confidence level (probability)
    
    ImageDetect():ratio(0.65f), refineF(true), confidence(0.99), distance(3.0) {
        
    }
    
    
    
    
    cv::Mat match(cv::Mat& image1,cv::Mat& image2, // input scene image
                  std::vector<cv::KeyPoint>& keypoints1, // input computed object keypoints
                  std::vector<cv::KeyPoint>& keypoints2,
                  cv::Mat& descriptors1, // input computed object descriptors
                  cv::Mat& descriptors2,
                  std::vector<cv::DMatch>& matches, // output matches
                  std::vector<cv::Point2f>& points1, // output object keypoints (Point2f)
                  std::vector<cv::Point2f>& points2);
    int ratioTest(std::vector<std::vector<cv::DMatch> >
                  &matches);
    
    // Insert symmetrical matches in symMatches vector
    void symmetryTest(const std::vector<std::vector<cv::DMatch> >& matches1,
                      const std::vector<std::vector<cv::DMatch> >& matches2,
                      std::vector<cv::DMatch>& symMatches);
    
    // Identify good matches using RANSAC
    // Return fundamental matrix
    cv::Mat ransacTest(const std::vector<cv::DMatch>& matches,
                       const std::vector<cv::KeyPoint>& keypoints1,
                       const std::vector<cv::KeyPoint>& keypoints2,
                       std::vector<cv::DMatch>& outMatches,
                       std::vector<cv::Point2f>& points1,
                       std::vector<cv::Point2f>& points2);
    void drawMatches(cv::Mat& image, // output image
                     int matches, // matches
                     std::vector<cv::Point2f>& points); // keypoints
    
    cv::Mat compare(cv::Mat image1,cv::Mat img2);

};

#endif /* defined(__objectdetect__ImageDetect__) */
