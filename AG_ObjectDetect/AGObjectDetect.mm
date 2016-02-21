//
//  AGObjectDetect.cpp
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "AGObjectDetect.h"
#include "AG_Quantize.h"
#import "AG_ColorDetect.h"
#include "UIImage2OpenCV.h"
#include "AGConstants.h"



float AGObjectDetect::approxValue = 0;
static std::vector<std::vector<std::vector<cv::Point> > > buffer;
static std::vector<std::vector<cv::Point> > buffer2;
static std::vector<std::vector<cv::Point> > buffer3;

static int matchCounter = 0;

bool AGObjectDetect::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame,int const mode){
    
    
    switch (mode) {
        case MODE_RGB:
        {
            outputFrame = inputFrame;
        }
            break;
        case MODE_SHAPE:
        {
            std::vector<std::vector<cv::Point> > newSample = getContoursFromImage(inputFrame,cv::Point(320,240),75);
            outputFrame = inputFrame;
            //outputFrame = cv::Mat::zeros(480, 640, inputFrame.type());
            for(int i=0;i<newSample.size();i++){
                drawContours(outputFrame, newSample, i, cv::Scalar(255,0,0));
                cv::Moments mu;
                mu = moments(newSample[i]);
                cv::Point2f centerOfMass = cv::Point2f(mu.m10/mu.m00, mu.m01/mu.m00);
                circle(outputFrame, centerOfMass, 3, cv::Scalar(0,255,0));
   
            }
            //outputFrame = AGObjectDetect::objectDetection(inputFrame);
            //cv::cvtColor(outputFrame, outputFrame, CV_BGR2BGRA);
        }
            break;
        case MODE_POSTER:
        {
            outputFrame = AG_Quantize::quantize(inputFrame);
        }
            
            break;
        default:
            break;
    }
    
    return true;
}



// NEW FUNCTION 22/10/13

std::vector<std::vector<cv::Point> > AGObjectDetect::getSampleFromImage(cv::Mat image){
    
    if(!image.empty()){
        // resize image
        //    double scaleFactor = image.cols/640;
        //    resize(image, image, cv::Size(round(image.cols/scaleFactor),round(image.rows/scaleFactor)));
        //    image = image(Range(1,480), Range(1,640));
        
        resize(image,image, cv::Size(640,480));
        image = image(cv::Range(1,480), cv::Range(1,640));
        
        
        // setup image
        
        
        
        // Apply the erosion operation
        cv::Mat erosion;
        cv::Mat element = getStructuringElement( cv::MORPH_ELLIPSE, cv::Size(1,1), cv::Point(0, 0) );
        erode(image, image, element);
        
        // frame filtering
        cvtColor(image, image, cv::COLOR_BGRA2GRAY);
        GaussianBlur(image, image, cv::Size(21,21), 1.5, 1.5);
        Canny(image, image, 20,30, 3, true);
        
        
        // Apply the dilation operation
        cv::Mat dilation;
        element = getStructuringElement( cv::MORPH_ELLIPSE , cv::Size(1, 1), cv::Point(0, 0) );
        dilate(image, image, element);
        
        
        
        //get contours
        std::vector<std::vector<cv::Point> > contours;
        std::vector<cv::Vec4i> hierarchy;
        cv::findContours( image, contours, hierarchy, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
        
        //    // find the contour of the largest area
        //    double area_max=0;
        //    int area_max_idx=0;
        //    for(unsigned i=0; i<contours.size(); i++)
        //        if( contourArea(Mat(contours[i])) > area_max )
        //        {
        //            area_max=contourArea(Mat(contours[i]));
        //            area_max_idx=i;
        //        }
        
        std::vector<std::vector<cv::Point> > rootContours;
        cv::Mat newImage = cv::Mat::zeros(480, 640, CV_8UC3);
        
        if(contours.size()>0){
            //        Moments mu;
            //        mu = moments(contours[area_max_idx]);
            //Point2f centerOfMass0 = Point2f(image.cols/2, image.rows/2);
            //Point2f centerOfMass0 = Point2f(mu.m10/mu.m00, mu.m01/mu.m00); //centerOfMass of biggest contour
            //vector<int> color = getDominantHSVColor(matFromContours(contours));
            //NSLog(@"hue is %i",color[0]);
            
            
            for (int i = 0; i<hierarchy.size(); i++) {
                if(hierarchy[i][3] == -1)
                {
                    
                    rootContours.push_back(contours[i]);
                }
            }
        }
        
        //NSLog(@"contour size is %lu",rootContours.size());
        return rootContours;
        //return contours;

    }else{
        std::vector<std::vector<cv::Point> > rootContours;
        return rootContours;
    }
}

std::vector<std::vector<cv::Point> > AGObjectDetect::getContoursFromImage(cv::Mat image, cv::Point center,int distance){
    
    if(!image.empty()){
        // resize image
        //float scaleFactor = float(image.rows)/480;
        //NSLog(@"scale factor %f",scaleFactor);
        
        
        // TODO fix FORCE RESIZE
        //resize(image, image, cv::Size(round(image.rows/scaleFactor),round(image.cols/scaleFactor)));
        resize(image,image, cv::Size(640,480));
        image = image(cv::Range(1,480), cv::Range(1,640));
        
        //NSLog(@"Image is %i %i",image.cols,image.rows);
        
        // setup image
        
        
        
        // Apply the erosion operation
        cv::Mat erosion;
        cv::Mat element = getStructuringElement( cv::MORPH_ELLIPSE, cv::Size(1,1), cv::Point(0, 0) );
        erode(image, image, element);
        
        // frame filtering
        cvtColor(image, image, cv::COLOR_BGRA2GRAY);
        GaussianBlur(image, image, cv::Size(21,21), 1.5, 1.5);
        Canny(image, image, 20,30, 3, true);
        
        
        // Apply the dilation operation
        cv::Mat dilation;
        element = getStructuringElement( cv::MORPH_ELLIPSE , cv::Size(1, 1), cv::Point(0, 0) );
        dilate(image, image, element);
        
        
        
        //get contours
        std::vector<std::vector<cv::Point> > contours;
        std::vector<cv::Vec4i> hierarchy;
        cv::findContours( image, contours, hierarchy, cv::RETR_TREE,cv::CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
        
        //    // find the contour of the largest area
        //    double area_max=0;
        //    int area_max_idx=0;
        //    for(unsigned i=0; i<contours.size(); i++)
        //        if( contourArea(Mat(contours[i])) > area_max )
        //        {
        //            area_max=contourArea(Mat(contours[i]));
        //            area_max_idx=i;
        //        }
        
        std::vector<std::vector<cv::Point> > rootContours;
        cv::Mat newImage = cv::Mat::zeros(480, 640, CV_8UC3);
        
        if(contours.size()>0){
            //        Moments mu;
            //        mu = moments(contours[area_max_idx]);
            //Point2f centerOfMass0 = Point2f(image.cols/2, image.rows/2);
            //Point2f centerOfMass0 = Point2f(mu.m10/mu.m00, mu.m01/mu.m00); //centerOfMass of biggest contour
            //vector<int> color = getDominantHSVColor(matFromContours(contours));
            //NSLog(@"hue is %i",color[0]);
            
            
            for (int i = 0; i<hierarchy.size(); i++) {
                if(hierarchy[i][3] == -1)
                {
                    cv::Point2f centerOfMass0 = cv::Point2f(center.x, center.y);
                    cv::Moments mu;
                    mu = moments(contours[i]);
                    //double area = contourArea(contours[i]);
                    cv::Point2f centerOfMass = cv::Point2f(mu.m10/mu.m00, mu.m01/mu.m00);
                    double dist = AGObjectDetect::euclideanDist(centerOfMass, centerOfMass0);
                    if( dist< distance)
                        //if(( pointPolygonTest(contours[i], centerOfMass, true)< 200)&&pointPolygonTest(contours[i], centerOfMass, true)>0)
                        rootContours.push_back(contours[i]);
                }
            }
        }
        
        //NSLog(@"contour size is %lu",rootContours.size());
        return rootContours;
        //return contours;

    }
    else{
        std::vector<std::vector<cv::Point>> rootContours;
        return rootContours;
    }
        
    
}

cv::Mat AGObjectDetect::matFromContours(std::vector<std::vector<cv::Point> > contours){
    
    cv::Mat image = cv::Mat::zeros(480,640,CV_8UC3);
    
    for(unsigned i=0; i<contours.size(); i++){
        drawContours(image, contours, i, cv::Scalar(0,255,255), 1, 8);
    }
    
    cv::cvtColor(image, image, cv::COLOR_BGR2BGRA);
    return image;
    
}

double AGObjectDetect::compare(std::vector<std::vector<cv::Point> > contourSample,std::vector<std::vector<cv::Point> > contourImage){
    
    std::vector<cv::Point> contour1,contour2;
    
    if((contourSample.size()>0)&&(contourImage.size()>0)){
        
//            // find the contour of the largest area
//        double area_max=0;
//        int area_max_idx=0;
//        for(unsigned i=0; i<contourSample.size(); i++)
//            if( contourArea(Mat(contourSample[i])) > area_max )
//            {
//                area_max=contourArea(Mat(contourSample[i]));
//                area_max_idx=i;
//            }
//        contour1 = contourSample[area_max_idx];
//        
//        area_max=0;
//        area_max_idx=0;
//        for(unsigned i=0; i<contourImage.size(); i++)
//            if( contourArea(Mat(contourImage[i])) > area_max )
//            {
//                area_max=contourArea(Mat(contourImage[i]));
//                area_max_idx=i;
//            }
//        contour2 = contourImage[area_max_idx];
        
      
            for(int i=0;i<contourSample.size();i++)
                for(int j=0;j<contourSample[i].size();j++)
                    contour1.push_back(contourSample[i][j]);
        //
            for(int i=0;i<contourImage.size();i++)
                for(int j=0;j<contourImage[i].size();j++)
                    contour2.push_back(contourImage[i][j]);
    }
    double matchRate = 100;
    
    
    // TODO uncomment for comparison
    if((contour1.size()>0)&&(contour2.size()>0))
        matchRate = matchShapes(contour1,contour2, 1, 0); //method = CV_CONTOUR_MATCH_I1
    return matchRate;
}

objectDef AGObjectDetect::objectDetection(cv::Mat image, std::vector<std::vector<cv::Point> > contourImage,double result, double threshold){
    
    objectDef newObject;
    bool match = false;
    cv::Mat dst = cv::Mat::zeros(image.size(), image.type());
        
    std::vector<std::vector<cv::Point> > bufferTemp;
    std::vector<std::vector<cv::Point> > bufferSource;
    
    if(buffer.size()>0){
        
            bufferSource = buffer[buffer.size()-1];
        
        cv::Point2f centerOfMassOfContourTotal= cv::Point2f(dst.cols/2, dst.rows/2);
        
        for(int a=0;a<contourImage.size();a++){
//            
            cv::Moments mu;
            mu = moments(contourImage[a]);
            cv::Point2f centerOfMassOfContour;
            if(mu.m00>0)
                centerOfMassOfContour = cv::Point2f(mu.m10/mu.m00, mu.m01/mu.m00);
            else
                centerOfMassOfContour = centerOfMassOfContourTotal;
           
                bufferTemp.push_back(contourImage[a]);
        }
        
        //accumulate four frames
        if(buffer.size()<5){
            buffer.push_back(bufferTemp);
        }
        else if(buffer.size()==5){
            for(int b=1;b<5;b++){
                buffer[b-1] = buffer[b];
            }
            buffer.pop_back();
            buffer.push_back(bufferTemp);
        }
        
        std::vector<std::vector<cv::Point> > hullContour;
        std::vector<cv::Point> objectPoints;
        
        //draw all the buffered and current contours
        for(int j=0;j<buffer.size();j++){
            int currentBufferSize = (int)buffer[j].size();
            for(int i=0;i<currentBufferSize;i++){
                
                std::vector<int> hull;
                std::vector<cv::Point> hullPoints;
                
                convexHull(cv::Mat(buffer[j][i]), hull);
                int hullcount = (int)hull.size();
                cv::Point pt0 = buffer[j][i][hull[hullcount-1]];
                hullPoints.push_back(pt0);
                for( int jj = 0; jj < hullcount; jj++ )
                {
                    cv::Point pt = buffer[j][i][hull[jj]];
                    hullPoints.push_back(pt);
                    objectPoints.push_back(pt);
                    
                }
                
                hullContour.push_back(hullPoints);
                //draw Hull curves
                //cv::drawContours( dst, hullContour, i, cvScalar(255,255,255), CV_FILLED,8);
                //draw contour curves
                cv::drawContours( dst, buffer[j], i, cv::Scalar(255,0,0), 1,8);
                
            }
        }
        
        std::vector<int> hull;
        convexHull(cv::Mat(objectPoints), hull);
        std::vector<cv::Point> hullPoints;
        int hullcount = (int)hull.size();
        if(hullcount>0){
            cv::Point pt0 = objectPoints[hull[hullcount-1]];
            hullPoints.push_back(pt0);
            for( int jj = 0; jj < hullcount; jj++ )
            {
                cv::Point pt = objectPoints[hull[jj]];
                hullPoints.push_back(pt);
                //                //
            }
            
            if(result<threshold){
                if(matchCounter>1){
                    fillConvexPoly(dst, hullPoints, cv::Scalar(0,255,0));
                    matchCounter++;
                    match = true;
                }else {
                    fillConvexPoly(dst, hullPoints, cv::Scalar(0,0,255));
                    matchCounter++;
                    match = false;
                }
                
            }else{
                fillConvexPoly(dst, hullPoints, cv::Scalar(0,0,255));
                matchCounter = 0;
                match = false;
                
            }
        }
        dst &= image;
        
        newObject.image = dst;
        newObject.match = match;
        
        return newObject;
    }
    else{
        
        buffer.push_back(contourImage);
        newObject.image = image;
        newObject.match = match;
        return newObject;
    }
    
}


/*** FUNCTION -> distance (Euclidean) between these two points ***/

void AGObjectDetect::convertVectorToPoint(std::vector<cv::Point2f>& input, std::vector<cv::Point>& output)
{
    output.clear();
    
    for (unsigned int i = 0; i < input.size(); i++)
    {
        output.push_back(cv::Point((int)input.at(i).x, (int)input.at(i).y));
    }
}

double AGObjectDetect::euclideanDist(cv::Point p, cv::Point q)
{
    cv::Point diff = p - q;
    return sqrt(diff.x*diff.x + diff.y*diff.y);
}



