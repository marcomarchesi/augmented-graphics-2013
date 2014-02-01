//
//  ShapeDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 7/23/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


class ShapeDetect{
    
public:
    
    ShapeDetect();

    typedef struct shapeDef{
        int index;
        std::vector<cv::Point> centroids;
        std::vector<std::vector<cv::Point> > contours;
        cv::vector<cv::Vec4i> hierarchy;
        
    } shapeDef;
    
    float approxValue;
    std::vector<ShapeDetect::shapeDef> imageSamples;
    
    
    std::vector<ShapeDetect::shapeDef> loadImageSample();
    
    cv::Mat show(ShapeDetect::shapeDef shape1,ShapeDetect::shapeDef shape2);
    ShapeDetect::shapeDef shape(cv::Mat image);
    double compareShapes(ShapeDetect::shapeDef *shape1,ShapeDetect::shapeDef *shape2);
    
    //TODO
    cv::Mat compareAndShow(ShapeDetect::shapeDef *shape1,ShapeDetect::shapeDef *shape2);
    
    
    void getCentroid(cv::Mat image,ShapeDetect::shapeDef *shape,cv::Point offset);
    
    cv::Mat drawShape(ShapeDetect::shapeDef shape, bool draw_centroids, bool maxContour);
    
    int getMaxContour(ShapeDetect::shapeDef *shape);
    cv::Mat getROI(cv::Mat image, ShapeDetect::shapeDef *shape,int index,cv::Point *offset);
    bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame, int const mode);
    cv::Scalar getClusteredColor(cv::Mat image);

    cv::Mat quantize(cv::Mat image);
    
    cv::Mat imageSegmentation(cv::Mat image);
    
    cv::Mat drawShapeAnotherWorld(cv::Mat image, ShapeDetect::shapeDef shape);

private:
    
    
    cv::Mat image_to_process;
    cv::Mat old_frame;
    cv::Scalar picked_color;

};

