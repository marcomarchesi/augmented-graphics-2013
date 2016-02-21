//
//  VideoViewController.m
//  OpenCV Tutorial
//


#import "VideoViewController.h"
#import "UIImage2OpenCV.h"
#import "AGConstants.h"
#import "AGObjectDetect.h"
#import "AG_Quantize.h"



#define kTransitionDuration	0.75


@interface VideoViewController ()
{
    VideoSource * videoSource;
    cv::Mat outputFrame;
    objectDef newObject;
    
}

@end

@implementation VideoViewController
@synthesize matchLabel = _matchLabel;
@synthesize imageView;
@synthesize containerView;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mode = MODE_RGB;
    sliderValue = 1.5;
    matchCounter = 0;

    UIImage *sampleUIImage = [UIImage imageNamed:@"circle01.jpg"];
    sampleImage = [sampleUIImage toMat];
    
    contour_unique_load = AGObjectDetect::getSampleFromImage(sampleImage);
    contourImage = AGObjectDetect::matFromContours(contour_unique_load);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
       
    //add frame camera view
    self.imageView = [[GLESImageView alloc] initWithFrame:self.containerView.bounds];
    [self.imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.containerView addSubview:self.imageView];
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(750, 680, 201, 44)];
    logoView.image = [UIImage imageNamed:@"augmented-graphics_logo.jpg"];
    [self.containerView addSubview:logoView];
    
    sampleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 660, 128, 96)];
    sampleImageView.image = [UIImage imageWithMat:sampleImage andImageOrientation:UIImageOrientationUp];
    [self.containerView addSubview:sampleImageView];
    
    contourImageView = [[UIImageView alloc]initWithFrame:CGRectMake(180, 660, 128, 96)];
    contourImageView.image = [UIImage imageWithMat:contourImage andImageOrientation:UIImageOrientationUp];
    [self.containerView addSubview:contourImageView];
    
    matchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 160, 256, 192)];
    [self.containerView addSubview:matchImageView];
    //matchImageView.image = [UIImage imageDetectedFrom:sampleImage];
    
    
    // Init video source:
    videoSource = [[VideoSource alloc] init];
    videoSource.delegate = self;
    [videoSource startRunning];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [videoSource startRunning];
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [videoSource stopRunning];
    
}

- (IBAction) showSavedMediaBrowser:(id)sender {
    
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;

    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
    [popover presentPopoverFromRect:CGRectMake(10, 50, 300, 200) inView:self.containerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    popover.delegate = self;
    self.popOverController= popover;
    //[controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    switch (selectedSegment) {
        case 0:
            mode = MODE_RGB;
            break;
        case 1:
            mode = MODE_SHAPE;
            break;
        case 2:
            mode = MODE_OBJECT_DETECTION;
            break;
        case 3:
            mode = MODE_EM;
            break;
        default:
            break;
    }
  
}

#pragma mark - UIImagePickerDelegate

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            sampleImage = [editedImage toMat];
            if(mode==MODE_OBJECT_DETECTION){
                contour_unique_load = AGObjectDetect::getSampleFromImage(sampleImage);
                contourImage = AGObjectDetect::matFromContours(contour_unique_load);
            }
            contourImageView.image = [UIImage imageWithMat:contourImage andImageOrientation:UIImageOrientationUp];
            sampleImageView.image = [UIImage imageWithMat:sampleImage andImageOrientation:UIImageOrientationUp];
            //imageToUse = editedImage;
        } else {
            sampleImage = [originalImage toMat];
            if(mode==MODE_OBJECT_DETECTION){
                contour_unique_load = AGObjectDetect::getSampleFromImage(sampleImage);
                contourImage = AGObjectDetect::matFromContours(contour_unique_load);
            }
            contourImageView.image = [UIImage imageWithMat:contourImage andImageOrientation:UIImageOrientationUp];
            sampleImageView.image = [UIImage imageWithMat:sampleImage andImageOrientation:UIImageOrientationUp];
            //imageToUse = originalImage;
        }
        // Do something with imageToUse
    }
    
//    // Handle a movied picked from a photo album
//    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo) {
//        
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
//        
//        // Do something with the picked movie available at moviePath
//    }
    
  [picker dismissViewControllerAnimated:YES completion:nil];
    //[picker release];
}



#pragma mark - DetectionDelegate
-(void)detected{
    
    
    //[self performSegueWithIdentifier:@"ImageSegue" sender:Nil];
}

#pragma mark - VideoSourceDelegate

- (void) frameCaptured:(cv::Mat) frame
{

    AGObjectDetect::approxValue = sliderValue;
    
    
    bool isMainQueue = dispatch_get_main_queue(); //corrected
    

    if (isMainQueue)
    {
       
        if(mode == MODE_OBJECT_DETECTION)
            {
                
                std::vector<std::vector<cv::Point>> contourFrame;
                contourFrame = AGObjectDetect::getContoursFromImage(frame,cv::Point(320,240),75);
                result = AGObjectDetect::compare(contour_unique_load,contourFrame);
                newObject = AGObjectDetect::objectDetection(frame,contourFrame,result,AG_MATCH_THRESHOLD_DEFAULT);
                outputFrame = newObject.image;
                bitwise_xor(outputFrame, frame, outputFrame);

                //cvtColor(outputFrame, outputFrame, CV_RGB2BGRA);
            
            }else{
            AGObjectDetect::processFrame(frame, outputFrame,mode);
            }
        
        
        [self.imageView drawFrame:outputFrame];
        
        
    }
    else
    {
        dispatch_sync( dispatch_get_main_queue(),
                      ^{ if(mode == MODE_OBJECT_DETECTION)
        {
            std::vector<std::vector<cv::Point>> contourFrame;
            contourFrame = AGObjectDetect::getContoursFromImage(frame,cv::Point(320,240),75);
            result = AGObjectDetect::compare(contour_unique_load,contourFrame);
            newObject = AGObjectDetect::objectDetection(frame,contourFrame,result,AG_MATCH_THRESHOLD_DEFAULT);
            outputFrame = newObject.image;
            bitwise_xor(outputFrame, frame, outputFrame);

        } else{
            AGObjectDetect::processFrame(frame, outputFrame,mode);
        }

                          [self.imageView drawFrame:outputFrame];
                          
                      });
        
    }
    
    if(mode == MODE_OBJECT_DETECTION)
        [self performSelectorOnMainThread:@selector(updateMatchLabel) withObject:nil waitUntilDone:YES];
    

}

-(void)updateMatchLabel{

    
    
    self.matchLabel.textColor = [UIColor whiteColor];
    if(newObject.match == true){
        self.matchLabel.text = [NSString stringWithFormat:@"Object DETECTED with rate %f",result];
    }
    else
        self.matchLabel.text = [NSString stringWithFormat:@"Object not detected with rate %f",result];
}

@end