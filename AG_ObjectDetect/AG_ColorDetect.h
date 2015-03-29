//
//  AG_ColorDetect.h
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef __objectdetect__AG_ColorDetect__
#define __objectdetect__AG_ColorDetect__

#include <iostream>

#import "AGConstants.h"


    
cv::Scalar getBGRColor(int color);
int getDominantColor(cv::Mat image);
std::vector<int> getDominantHSVColor(cv::Mat image);
int getPixelColorType(int H, int S, int V);

#endif /* defined(__objectdetect__AG_ColorDetect__) */
