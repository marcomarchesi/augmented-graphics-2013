//
//  AG_ColorDetect.cpp
//  objectdetect
//
//  Created by Marco Marchesi on 9/27/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "AG_ColorDetect.h"


cv::Scalar getBGRColor(int color){
    
    
    cv::Scalar bgrColor;
    
    switch (color) {
        case 0:
            bgrColor = cv::Scalar(0,0,0); //black
            break;
        case 1:
            bgrColor = cv::Scalar(255,255,255); //white
            break;
        case 2:
            bgrColor = cv::Scalar(127,127,127); //grey
            break;
        case 3:
            bgrColor = cv::Scalar(0,127,255); //orange
            break;
        case 4:
            bgrColor = cv::Scalar(0,255,255); //yellow
            break;
        case 5:
            bgrColor = cv::Scalar(0,255,0); //green
            break;
        case 6:
            bgrColor = cv::Scalar(255,255,0); //aqua
            break;
        case 7:
            bgrColor = cv::Scalar(255,0,0); //blue
            break;
        case 8:
            bgrColor = cv::Scalar(255,0,255); //purple
            break;
        case 9:
            bgrColor = cv::Scalar(255,127,255); //pink
            break;
        default:
            break;
    }
    
    return bgrColor;
    
}

int getDominantColor(cv::Mat image){
    
    cv::Scalar color;
    cv::Mat hsv;
    cvtColor(image, hsv, CV_BGR2HSV);
    
    int hbins = 36, sbins = 10,vbins = 10;
    int histSize[] = {hbins, sbins,vbins};
    // hue varies from 0 to 179, see cvtColor
    float hranges[] = { 0, 179 };
    // saturation varies from 0 (black-gray-white) to
    // 255 (pure spectrum color)
    float sranges[] = { 0, 255 };
    float vranges[] = { 0, 255 };
    const float* ranges[] = { hranges, sranges,vranges };
    cv::MatND hist;
    // we compute the histogram from the 0-th and 1-st channels
    int channels[] = {0,1,2};
    
    calcHist( &hsv, 1, channels, cv::Mat(), // do not use mask
             hist, 3, histSize, ranges,
             true, // the histogram is uniform
             false );
    //double maxVal=0;
    //minMaxLoc(hist, 0, &maxVal, 0, 0);
    
    int h_max,s_max,v_max,intensity_max;
    h_max = 0;
    s_max = 0;
    v_max = 0;
    intensity_max = 0;
    
    
    for( int h = 0; h < hbins; h++ ){
        for( int s = 0; s < sbins; s++ )
        {
            for( int v = 0; v < vbins; v++ )
            {
                float binVal = hist.at<float>(h,s,v);
                int intensity = binVal;
                if(intensity>intensity_max){
                    intensity_max=intensity;
                    h_max=h;
                    s_max=s;
                    v_max=v;
                }
            }
        }
    }
    
    int hsvColor = getPixelColorType(h_max, s_max, v_max);
    return hsvColor;
    
}

int getPixelColorType(int H, int S, int V)
{
    
    
	int color;
	if (V < 3)
		color = cBLACK;
	else if (V > 7 && S < 1)
		color = cWHITE;
	else if (S < 3 && V < 7) //grey if sat. < 30%
		color = cGREY;
	else {	// Is a color
		if (H < 3)
			color = cRED;
		else if (H < 6)
			color = cORANGE;
		else if (H < 9)
			color = cYELLOW;
		else if (H < 15)
			color = cGREEN;
		else if (H < 20)
			color = cAQUA;
		else if (H < 27)
			color = cBLUE;
		else if (H < 30)
			color = cPURPLE;
		else if (H < 33)
			color = cPINK;
		else	// full circle
			color = cRED;	// back to Red
	}
	return color;
}
