//
//  AG_Quantize.h
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef __objectdetect__AG_Quantize__
#define __objectdetect__AG_Quantize__

#include <iostream>

class AG_Quantize{
    
public:
cv::Scalar getClusteredColor(cv::Mat image);
static cv::Mat quantize(cv::Mat image);
private:

};
#endif /* defined(__objectdetect__AG_Quantize__) */
