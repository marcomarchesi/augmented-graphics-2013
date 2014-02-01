//
//  ShapeDetect.m
//  objectdetect
//
//  Created by Marco Marchesi on 7/23/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "ShapeDetect.h"
#include "UIImage2OpenCV.h"

#include "AG_ColorDetect.h"


ShapeDetect::ShapeDetect(){

    image_to_process = cv::Mat(640,480,CV_8UC1);
    //old_frame = cv::Mat(480,640,CV_8UC3);
    picked_color = cv::Scalar(255,255,255);
    imageSamples = loadImageSample();
    
}


std::vector<ShapeDetect::shapeDef> ShapeDetect::loadImageSample(){
    
    std::vector<ShapeDetect::shapeDef> samples;
    
    UIImage *image_sample1 = [UIImage imageNamed:@"bottle03.jpg"];
    cv::Mat image1 =  [image_sample1 toMat];
    samples.push_back(shape(image1));
    UIImage *image_sample2 = [UIImage imageNamed:@"bottle04.jpg"];
    cv::Mat image2 = [image_sample2 toMat];
    shapeDef shape2 = shape(image2);
    samples.push_back(shape2);
    
    return  samples;
    
}

void setLabel(cv::Mat& im, const std::string label, std::vector<cv::Point>& contour)
{
	int fontface = cv::FONT_HERSHEY_SIMPLEX;
	double scale = 0.4;
	int thickness = 1;
	int baseline = 0;
    
	cv::Size text = cv::getTextSize(label, fontface, scale, thickness, &baseline);
	cv::Rect r = cv::boundingRect(contour);
    
	cv::Point pt(r.x + ((r.width - text.width) / 2), r.y + ((r.height + text.height) / 2));
	cv::rectangle(im, pt + cv::Point(0, baseline), pt + cv::Point(text.width, -text.height), CV_RGB(255,255,255), CV_FILLED);
	cv::putText(im, label, pt, fontface, scale, CV_RGB(0,0,0), thickness, 8);
}

ShapeDetect::shapeDef ShapeDetect::shape(cv::Mat image){
    
    shapeDef shape1;
    
    cv::resize(image, image, cv::Size(640,480));
    
    image.copyTo(image_to_process);


    int thresh = 100;
    
    cv::cvtColor(image, image, CV_BGRA2GRAY);
    cv::blur( image, image, cv::Size(3,3) );
    
    cv::Canny( image, image, thresh, thresh*2, 3 );
    
    cv::erode(image, image, cv::Mat(cv::Size(1, 1), CV_8UC1));
    cv::dilate(image, image, cv::Mat(cv::Size(1, 1), CV_8UC1));

    cv::vector<cv::vector<cv::Point> > contours;
    cv::vector<cv::Vec4i> hierarchy;
    
    //finding all contours in the image
    cv::findContours( image, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    std::vector<std::vector<cv::Point> > contours_poly;
    for( int i = 0; i < contours.size(); i++ ) {
        
        cv::Mat output;
        cv::approxPolyDP(cv::Mat(contours[i]),output,1,false);
        double area0 = contourArea(output);
        if(area0 >0)
            contours_poly.push_back(output);
        
    }

    shape1.contours = contours_poly;
    shape1.hierarchy = hierarchy;
    cv::Point offset1;
    
    //cv::Mat image_to_object = getROI(image,&shape1,getMaxContour(&shape1), &offset1);
//    cv::Rect rect = cv::Rect(offset1.x,offset1.y,image_to_object.cols,image_to_object.rows);
//    cv::Mat image_to_get = image_to_process(rect);
//    picked_color = getBGRColor(getDominantColor(image_to_get));
    
    //getCentroid(image_to_object,&shape1,offset1);
    return shape1;
}

cv::Mat ShapeDetect::getROI(cv::Mat image,ShapeDetect::shapeDef *shape,int index,cv::Point *offset){
    //int max_contour_index = getMaxContour(shape);
    std::vector<cv::Point> contour;
    cv::Mat image0;
    
    if (shape->contours.size()>0){
        
        contour = shape->contours[index];
        cv::Rect bRect = cv::boundingRect(contour);
        image0 = image(bRect);
        offset->x = bRect.x;
        offset->y = bRect.y;
    }
    else{
        image0 = image;
        offset->x = 0;
        offset->y = 0;
    }
    return image0;
}

int ShapeDetect::getMaxContour(ShapeDetect::shapeDef *shape){
    
    int max_index = 0;
    double area,max_area = 0;
    
    for (int i=0; i< shape->contours.size(); i++) {
        area = cv::contourArea(shape->contours[i]);
        if (area >max_area) {
            max_area = area;
            max_index = i;
        }
        
    }
    
    return max_index;
    
}

void ShapeDetect::getCentroid(cv::Mat image,ShapeDetect::shapeDef *shape,cv::Point offset){
    
    
    cv::Point centroid = cv::Point(0,0);
    std::vector<std::vector<cv::Point> > contours_poly;
    for( int i = 0; i < shape->contours.size(); i++ ) {
        
        //cv::Mat output;
        //cv::approxPolyDP(cv::Mat(contours[i]), output, 1, false );
        double area0 = contourArea(shape->contours[i]);
        if(area0 >0){
            contours_poly.push_back(shape->contours[i]);
            cv::Rect bRect = cv::boundingRect(shape->contours[i]);
            centroid.x = bRect.x + (bRect.width / 2);
            centroid.y = bRect.y + (bRect.height / 2);
            shape->centroids.push_back(centroid);
        }
        
    }
    
}


double ShapeDetect::compareShapes(ShapeDetect::shapeDef *shape1,ShapeDetect::shapeDef *shape2){
    
    int max_index_1 = getMaxContour(shape1);
    int max_index_2 = getMaxContour(shape2);
    
    if((shape1->contours.size()>0) && (shape2->contours.size()>0)){
        double compare = cv::matchShapes(shape1->contours[max_index_1], shape2->contours[max_index_2],CV_CONTOURS_MATCH_I1,0);
        return compare;
    }else
        return 0;
    
    
}

cv::Mat ShapeDetect::compareAndShow(ShapeDetect::shapeDef *shape1,ShapeDetect::shapeDef *shape2){
    
    cv::Mat frame;
    
    return frame;
    
}


cv::Mat ShapeDetect::drawShape(ShapeDetect::shapeDef shape,bool draw_centroids,bool maxContour){
    
    cv::Mat image = cv::Mat::zeros(480, 640, CV_8UC3);
    
    if(maxContour)
        
    cv::RNG rng(12345);
    cv::Point offset1;
    cv::Scalar centroid_color;
    //if(!shape.contours.empty())
        //NSLog(@" Contour is convex %i",cv::isContourConvex(cv::Mat(shape.contours[max_index])));
    
    if(maxContour){
        int max_index = getMaxContour(&shape);
        cv::drawContours( image, shape.contours, max_index, picked_color,1,8);

    }
    else{
    for( int i = 0; i< shape.contours.size(); i++ )
    {
        
        //cv::Mat image_to_object = getROI(image,&shape,i,&offset1);
        //cv::Rect rect = cv::Rect(0,offset1.y,image_to_object.cols,image_to_object.rows);
        //cv::Mat image_to_get = image_to_process(rect);
        //picked_color = getBGRColor(getDominantColor(image_to_get));
        //cv::drawContours( image, shape.contours, i, picked_color, CV_FILLED,8);
        cv::drawContours( image, shape.contours, i, picked_color,1,8);
  
    }
    
    for ( int j = 0; j< shape.centroids.size(); j++ ){
        if(draw_centroids){
        
            centroid_color = cvScalar( 0, 255, 0 );
            cv::circle(image,shape.centroids[j],10, centroid_color);
        
        }

    }
    }
        return image;
}



bool ShapeDetect::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame,int const mode){
    
    
    
    inputFrame.copyTo(old_frame);
    
    switch (mode) {
        case MODE_RGB:
        {
            outputFrame = inputFrame;
        }
            break;
        case MODE_SHAPE:
        {
            shapeDef shape1 = shape(inputFrame);
            outputFrame = drawShape(shape1,false,false);
            cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
        }
            break;
        case MODE_POSTER:
        {
            outputFrame = quantize(inputFrame);
        }
            
            break;
        case MODE_ROBUST_EDGE:
        {
            if (!old_frame.empty()) {
                
                shapeDef shape1 = shape(old_frame);
                if (!inputFrame.empty()) {
                    inputFrame.copyTo(old_frame);
                    cv::Mat newFrame = drawShape(shape1,false,false);
                    if (!newFrame.empty()){
                        shapeDef shape2 = shape(newFrame);
                        outputFrame = drawShape(shape2,false,false);
                        cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
                    }
                }
            }
        }
            break;
        case MODE_COLOR:
        {
            shapeDef shape1 = shape(inputFrame);
            outputFrame = drawShape(shape1,false,false);
            cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
        }
            break;
        case MODE_SEGMENTATION:
        {
            outputFrame = imageSegmentation(inputFrame);
        }
            break;
        case MODE_COMPARE:
        {
            
            
            double compare;
            shapeDef shapeFrame = shape(inputFrame);
            
            for(int i=0;i<imageSamples.size();i++){
                compare = compareShapes(&shapeFrame, &imageSamples[i]);
                if(compare < 0.05){
                    NSLog(@"it's an iphone4! %f",compare);
                    outputFrame = drawShape(shapeFrame,false,true);
                    //setLabel(outputFrame, "ciao", shapeFrame.contours[0]);
                    cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
                    
                }else{
                    NSLog(@"it's not an iphone4 %f",compare);
                    outputFrame = drawShape(shapeFrame,false,true);
                    cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
                }
            }
            
        }
            break;
        default:
            break;
    }
    
    
    
    return true;
}

cv::Mat ShapeDetect::imageSegmentation(cv::Mat image){
    
    cv::Mat dst = cv::Mat::zeros(image.size(), image.type());
    shapeDef shape1 = shape(image);
    int max_index = getMaxContour(&shape1);
    cv::drawContours( dst, shape1.contours, max_index, cvScalar(255,255,255), CV_FILLED,8);
    
    dst &= image;
    return dst;
}







