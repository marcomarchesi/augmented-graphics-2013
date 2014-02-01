//
//  ImageDetect.cpp
//  objectdetect
//
//  Created by Marco Marchesi on 9/2/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "ImageDetect.h"


cv::Mat ImageDetect::compare(cv::Mat image1,cv::Mat image2){
    
    
    // SURF is the default feature detector and extractor
    detector= new cv::OrbFeatureDetector;
    extractor= new cv::OrbDescriptorExtractor;
    // BruteForce matcher is the default matcher
    matcher= new cv::BFMatcher(cv::NORM_L2, false);
    
    
    cv::Mat d1, d2;
    std::vector<cv::KeyPoint> k1,k2;
    std::vector<cv::Point2f> p1,p2;
    
    // vector of keypoints
    cv::vector<cv::KeyPoint> keypoints1, keypoints2;
    
    
    cv::cvtColor(image1, image1, CV_BGRA2GRAY);
    cv::cvtColor(image2, image2, CV_BGRA2GRAY);
    
    cv::vector<cv::DMatch> matches;
    //matcher->match(descriptors1,descriptors2, matches);
    
    match(image1, image2, k1,k2, d1,d2, matches, p1, p2);
    
    
    
    cv::Mat imageMatches;
    cv::drawMatches(image1, k1, image2, k2, matches, imageMatches, cv::Scalar::all(-1));
    NSLog(@"keypoints are %li",k1.size());
    
    //-- Localize the object
    std::vector<cv::Point2f> obj;
    std::vector<cv::Point2f> scene;
    
    for( int i = 0; i < matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( k1[ matches[i].queryIdx ].pt );
        scene.push_back( k1[ matches[i].trainIdx ].pt );
    }
    
    //    cv::Mat H = findHomography( obj, scene, CV_RANSAC );
    //
    //    if(!H.empty()){
    //    //-- Get the corners from the image_1 ( the object to be "detected" )
    //    std::vector<cv::Point2f> obj_corners(4);
    //    std::vector<cv::Point2f> scene_corners(4);
    //    obj_corners[0] = cvPoint(0,0);
    //    obj_corners[1] = cvPoint( image1.cols, 0 );
    //    obj_corners[2] = cvPoint( image1.cols, image1.rows );
    //    obj_corners[3] = cvPoint( 0, image1.rows );
    //
    //
    //    cv::perspectiveTransform(obj_corners, scene_corners, H);
    //
    //        cv::line( imageMatches, obj_corners[0], obj_corners[1], cv::Scalar(255, 0, 0), 4 );
    //        cv::line( imageMatches, obj_corners[1], obj_corners[2], cv::Scalar( 255, 0, 0), 4 );
    //        cv::line( imageMatches, obj_corners[2], obj_corners[3], cv::Scalar( 255, 0, 0), 4 );
    //        cv::line( imageMatches, obj_corners[3], obj_corners[0], cv::Scalar( 255, 0, 0), 4 );
    //
    //    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    //        cv::line( imageMatches, scene_corners[0]+ cv::Point2f( image1.cols, 0 ), scene_corners[1] + cv::Point2f( image1.cols, 0 ), cv::Scalar(0, 255, 0), 4 );
    //    cv::line( imageMatches, scene_corners[1] + cv::Point2f( image1.cols, 0 ), scene_corners[2] + cv::Point2f( image1.cols, 0 ), cv::Scalar( 0, 255, 0), 4 );
    //    cv::line( imageMatches, scene_corners[2] + cv::Point2f( image1.cols, 0 ), scene_corners[3] + cv::Point2f( image1.cols, 0 ), cv::Scalar( 0, 255, 0), 4 );
    //    cv::line( imageMatches, scene_corners[3] + cv::Point2f( image1.cols, 0 ), scene_corners[0] + cv::Point2f( image1.cols, 0 ), cv::Scalar( 0, 255, 0), 4 );
    //    }
    
    
    cv::Mat t;
    cv::cvtColor(imageMatches, t, CV_BGRA2BGR);
    cv::cvtColor(t, imageMatches, CV_BGR2BGRA);
    
    return imageMatches;
    
}


// Clear matches for which NN ratio is > than threshold
// return the number of removed points
// (corresponding entries being cleared,
// i.e. size will be 0)
int ImageDetect::ratioTest(std::vector<std::vector<cv::DMatch> >
                         &matches) {
    int removed=0;
    // for all matches
    for (std::vector<std::vector<cv::DMatch> >::iterator
         matchIterator= matches.begin();
         matchIterator!= matches.end(); ++matchIterator) {
        // if 2 NN has been identified
        if (matchIterator->size() > 1) {
            // check distance ratio
            if ((*matchIterator)[0].distance/
                (*matchIterator)[1].distance > ratio) {
                matchIterator->clear(); // remove match
                removed++;
            }
        } else { // does not have 2 neighbours
            matchIterator->clear(); // remove match
            removed++;
        }
    }
    return removed;
}

// Insert symmetrical matches in symMatches vector
void ImageDetect::symmetryTest(const std::vector<std::vector<cv::DMatch> >& matches1,
                             const std::vector<std::vector<cv::DMatch> >& matches2,
                             std::vector<cv::DMatch>& symMatches) {
    // for all matches image 1 -> image 2
    for (std::vector<std::vector<cv::DMatch> >::
         const_iterator matchIterator1= matches1.begin();
         matchIterator1!= matches1.end(); ++matchIterator1) {
        // ignore deleted matches
        if (matchIterator1->size() < 2)
            continue;
        // for all matches image 2 -> image 1
        for (std::vector<std::vector<cv::DMatch> >::
             const_iterator matchIterator2= matches2.begin();
             matchIterator2!= matches2.end();
             ++matchIterator2) {
            // ignore deleted matches
            if (matchIterator2->size() < 2)
                continue;
            // Match symmetry test
            if ((*matchIterator1)[0].queryIdx ==
                (*matchIterator2)[0].trainIdx &&
                (*matchIterator2)[0].queryIdx ==
                (*matchIterator1)[0].trainIdx) {
                // add symmetrical match
                symMatches.push_back(cv::DMatch((*matchIterator1)[0].queryIdx,
                                                (*matchIterator1)[0].trainIdx,
                                                (*matchIterator1)[0].distance));
                break; // next match in image 1 -> image 2
            }
        }
    }
}

// Identify good matches using RANSAC
// Return fundamental matrix
cv::Mat ImageDetect::ransacTest(const std::vector<cv::DMatch>& matches,
                              const std::vector<cv::KeyPoint>& keypoints1,
                              const std::vector<cv::KeyPoint>& keypoints2,
                              std::vector<cv::DMatch>& outMatches,
                              std::vector<cv::Point2f>& points1,
                              std::vector<cv::Point2f>& points2) {
    // Convert keypoints into Point2f
    //std::vector<cv::Point2f> points1, points2;
    cv::Mat fundamental;
    for (std::vector<cv::DMatch>::
         const_iterator it= matches.begin();
         it!= matches.end(); ++it) {
        // Get the position of left keypoints
        float x= keypoints1[it->queryIdx].pt.x;
        float y= keypoints1[it->queryIdx].pt.y;
        points1.push_back(cv::Point2f(x,y));
        // Get the position of right keypoints
        x= keypoints2[it->trainIdx].pt.x;
        y= keypoints2[it->trainIdx].pt.y;
        points2.push_back(cv::Point2f(x,y));
    }
    // Compute F matrix using RANSAC
    std::vector<uchar> inliers(points1.size(),0);
    if (points1.size()>0&&points2.size()>0){
        cv::Mat fundamental= cv::findFundamentalMat(cv::Mat(points1),cv::Mat(points2), // matching points
                                                    inliers,       // match status (inlier or outlier)
                                                    CV_FM_RANSAC, // RANSAC method
                                                    distance,      // distance to epipolar line
                                                    confidence); // confidence probability
        // extract the surviving (inliers) matches
        std::vector<uchar>::const_iterator
        itIn= inliers.begin();
        std::vector<cv::DMatch>::const_iterator
        itM= matches.begin();
        // for all matches
        for ( ;itIn!= inliers.end(); ++itIn, ++itM) {
            if (*itIn) { // it is a valid match
                outMatches.push_back(*itM);
            }
        }
        if (refineF) {
            // The F matrix will be recomputed with
            // all accepted matches
            // Convert keypoints into Point2f
            // for final F computation
            points1.clear();
            points2.clear();
            for (std::vector<cv::DMatch>::
                 const_iterator it= outMatches.begin();
                 it!= outMatches.end(); ++it) {
                // Get the position of left keypoints
                float x= keypoints1[it->queryIdx].pt.x;
                float y= keypoints1[it->queryIdx].pt.y;
                points1.push_back(cv::Point2f(x,y));
                // Get the position of right keypoints
                x= keypoints2[it->trainIdx].pt.x;
                y= keypoints2[it->trainIdx].pt.y;
                points2.push_back(cv::Point2f(x,y));
            }
            // Compute 8-point F from all accepted matches
            if (points1.size()>0&&points2.size()>0){
                fundamental= cv::findFundamentalMat(cv::Mat(points1),cv::Mat(points2), // matches
                                                    CV_FM_8POINT); // 8-point method
            }
        }
    }
    return fundamental;
}

// Match feature points using symmetry test and RANSAC
// returns fundamental matrix
cv::Mat ImageDetect::match(cv::Mat& image1,cv::Mat& image2, // input scene image
                         std::vector<cv::KeyPoint>& keypoints1, // input computed object keypoints
                         std::vector<cv::KeyPoint>& keypoints2,
                         cv::Mat& descriptors1, // input computed object descriptors
                         cv::Mat& descriptors2,
                         std::vector<cv::DMatch>& matches, // output matches
                         std::vector<cv::Point2f>& points1, // output object keypoints (Point2f)
                         std::vector<cv::Point2f>& points2) // output scene keypoints (Point2f)
{
    
    // 1a. Detection of the features
    detector->detect(image1,keypoints1);
    NSLog(@"detecting...keypoints 1 %li",keypoints1.size());
    // 1b. Extraction of the descriptors
    extractor->compute(image1,keypoints1,descriptors1);
    NSLog(@"detecting...descriptors 1 %i",descriptors1.rows);
    float percentage1 = descriptors1.rows/float(keypoints1.size())*100;
    NSLog(@"percentage 1 %.2f%%",percentage1);
    
    // 1a. Detection of the features
    detector->detect(image2,keypoints2);
    NSLog(@"detecting...keypoints 2 %li",keypoints2.size());
    // 1b. Extraction of the descriptors
    extractor->compute(image2,keypoints2,descriptors2);
    float percentage2 = descriptors2.rows/keypoints2.size()*100;
    NSLog(@"percentage 2 %.2f%%",percentage2);
    // 2. Match the two image descriptors
    // from object image to scene image
    // based on k nearest neighbours (with k=2)
    std::vector<std::vector<cv::DMatch> > matches1;
    matcher->knnMatch(descriptors1,
                      descriptors2,
                      matches1, // vector of matches (up to 2 per entry)
                      2);        // return 2 nearest neighbours
    // from scene image to object image
    // based on k nearest neighbours (with k=2)
    std::vector<std::vector<cv::DMatch> > matches2;
    matcher->knnMatch(descriptors2,
                      descriptors1,
                      matches2, // vector of matches (up to 2 per entry)
                      2);        // return 2 nearest neighbours
    // 3. Remove matches for which NN ratio is
    // > than threshold
    // clean object image -> scene image matches
    int removed= ratioTest(matches1);
    // clean scene image -> object image matches
    removed= ratioTest(matches2);
    // 4. Remove non-symmetrical matches
    std::vector<cv::DMatch> symMatches;
    symmetryTest(matches1,matches2,symMatches);
    // 5. Validate matches using RANSAC
    cv::Mat fundamental= ransacTest(symMatches,
                                    keypoints1,
                                    keypoints2,
                                    matches,
                                    points1,
                                    points2);
    // return the found fundamental matrix
    return fundamental;
}