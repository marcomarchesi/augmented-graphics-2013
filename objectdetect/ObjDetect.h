//
//  ObjDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 7/23/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


class ObjDetect{
    
public:
    
    ObjDetect();

    typedef struct shapeDef{
        int index;
        std::vector<cv::Point> centroids;
        std::vector<std::vector<cv::Point> > contours;
        cv::vector<cv::Vec4i> hierarchy;
        
    } shapeDef;
    
    float approxValue;
    std::vector<ObjDetect::shapeDef> imageSamples;
    
    
    std::vector<ObjDetect::shapeDef> loadImageSample();
    
    cv::Mat show(ObjDetect::shapeDef shape1,ObjDetect::shapeDef shape2);
    ObjDetect::shapeDef shape(cv::Mat image);
    double compareShapes(ObjDetect::shapeDef *shape1,ObjDetect::shapeDef *shape2);
    
    //TODO
    cv::Mat compareAndShow(ObjDetect::shapeDef *shape1,ObjDetect::shapeDef *shape2);
    
    
    void getCentroid(cv::Mat image,ObjDetect::shapeDef *shape,cv::Point offset);
    
    cv::Mat drawShape(ObjDetect::shapeDef shape, bool draw_centroids, bool maxContour);
    
    int getMaxContour(ObjDetect::shapeDef *shape);
    cv::Mat getROI(cv::Mat image, ObjDetect::shapeDef *shape,int index,cv::Point *offset);
    bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame, int const mode);
    cv::Scalar getClusteredColor(cv::Mat image);

    cv::Mat quantize(cv::Mat image);
    
    cv::Mat imageSegmentation(cv::Mat image);
    
    cv::Mat drawShapeAnotherWorld(cv::Mat image, ObjDetect::shapeDef shape);

private:
    
    
    cv::Mat image_to_process;
    cv::Mat old_frame;
    cv::Scalar picked_color;

};

