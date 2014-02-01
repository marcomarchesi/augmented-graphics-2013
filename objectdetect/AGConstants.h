//
//  AGConstants.h
//  objectdetect
//
//  Created by Marco Marchesi on 9/5/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#ifndef objectdetect_Constants_h
#define objectdetect_Constants_h

// Define modes

#define MODE_RGB    0       // normal mode
#define MODE_SHAPE  1       // find contours
#define MODE_POSTER 2       // posterization with clustering
#define MODE_ROBUST_EDGE 3  // compare with past frames TODO
#define MODE_COLOR 4        // find dominant color
#define MODE_OBJECT_DETECTION 5 // image segmentation
#define MODE_COMPARE 6      // compare shapes
#define MODE_EM 7           // thesis algorithms
#define MODE_OBJECT 8       // get the object once detected

#define AG_MATCH_THRESHOLD_DEFAULT 0.3


// Define colors

#define cBLACK 0
#define cWHITE 1
#define cGREY  2
#define cRED    3
#define cORANGE 4
#define cYELLOW 5
#define cGREEN 6
#define cAQUA 7
#define cBLUE 8
#define cPINK 9
#define cPURPLE 10

#endif
