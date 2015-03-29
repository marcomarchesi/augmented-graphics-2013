//
//  AG_Quantize.cpp
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "AG_Quantize.h"

cv::Scalar getClusteredColor(cv::Mat image){
    
    cv::Scalar color = cv::Scalar(255,0,0);
    if (!image.empty()) {
        cv::Mat quantized_image;
        quantized_image = AG_Quantize::quantize(image);
        if(!quantized_image.empty()){
            cv::Vec3b pixel = quantized_image.at<cv::Vec3b>(quantized_image.rows/2, quantized_image.cols/2);
            color = cv::Scalar(pixel.val[0],pixel.val[1],pixel.val[2]);
        }
    }
    
    return color;
}

cv::Mat AG_Quantize::quantize(cv::Mat image){
    
    
    cv::Mat p = cv::Mat::zeros(image.cols*image.rows, 5, CV_32F);
//    cv::Mat bestLabels, centers, clustered;
//    cv::vector<cv::Mat> bgr;
//    cv::split(image, bgr);
//    // i think there is a better way to split pixel bgr color
//    for(int i=0; i<image.cols*image.rows; i++) {
//        p.at<float>(i,0) = (i/image.cols) / image.rows;
//        p.at<float>(i,1) = (i%image.cols) / image.cols;
//        p.at<float>(i,2) = bgr[0].data[i] / 255.0;
//        p.at<float>(i,3) = bgr[1].data[i] / 255.0;
//        p.at<float>(i,4) = bgr[2].data[i] / 255.0;
//    }
//    
//    int K = 10;
//    cv::kmeans(p, K, bestLabels,
//               cvTermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 10, 1.0),
//               1, cv::KMEANS_PP_CENTERS, centers);
//    
//    int colors[K];
//    for(int i=0; i<K; i++) {
//        colors[i] = 255/(i+1);
//    }
//    // i think there is a better way to do this mayebe some Mat::reshape?
//    clustered = cv::Mat(image.rows, image.cols, CV_32F);
//    for(int i=0; i<image.cols*image.rows; i++) {
//        clustered.at<float>(i/image.cols, i%image.cols) = (float)(colors[bestLabels.at<int>(0,i)]);
//        
//    }
//
//    //cv::cvtColor(clustered, clustered, CV_BGR2BGRA);
    
    return p;
    
}