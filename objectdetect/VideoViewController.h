//
//  VideoViewController.h
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "GLESImageView.h"
#import "VideoSource.h"



@interface VideoViewController : UIViewController<VideoSourceDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>{
    
    int mode;
    float sliderValue;
    double result;
    
    int matchCounter;
    
    std::vector<std::vector<cv::Point>> contour_unique_load;
    cv::Mat sampleImage;
    cv::Mat contourImage;
    cv::Mat matchedImage;
    UIImageView *sampleImageView;
    UIImageView *contourImageView;
    UIImageView *matchImageView;
     
}
@property (nonatomic,strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic,strong) IBOutlet UILabel *matchLabel;
@property (nonatomic, strong) GLESImageView *imageView;

-(IBAction)showSavedMediaBrowser:(id)sender;
- (IBAction)segmentSwitch:(id)sender;
@end







