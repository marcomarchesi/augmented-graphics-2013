//
//  EmObjectDetect.cpp
//  objectdetect
//
//  Created by Marco Marchesi on 10/17/13.
//  Copyright (c) 2013 Marco Marchesi. All rights reserved.
//

#include "EmObjectDetect.h"
#include "UIImage2OpenCV.h"
#include "AGConstants.h"

EmObjectDetect::EmObjectDetect()
:rng(12345)
,ksize_width(10)
,ksize_height(10)
,max_ksize_width(50)
,max_ksize_height(50)
,threshold1(20)
,threshold2(30)
,max_threshold1(100)
,max_threshold2(100)
,epsilon_factor(2)
,max_epsilon_factor(100)
,dilation_size(1)
,max_dilation_size(20)
,erosion_size(0)
,max_erosion_size(20)
,center_dist(50)
,max_center_dist(250)
,maxNumberOfPoint(25)
,maxNumberOfPoint_limit(100)
{
    //focus window
	//rect = cv::Rect(160,120,320,240);
    rect = cv::Rect(0,0,640,480);
    x=10, max_x=160, y=10, max_y=120;
    // Inizializzazione buffer
	for(unsigned i=0;i<NumberOfFrames;i++)
		img[i] = Mat::zeros(rect.size(), CV_8UC3);
	img_idx=0;
    PixelDist=75, maxPixelDist=100;
	PointPercentage=10, maxPointPercentage=100;
	minimum_dist=75, max_minimum_dist=250;
	minimum_dist_bis=50, max_minimum_dist_bis=100;
}

vector<vector<cv::Point> > EmObjectDetect::image_load_elaboration(Mat sample)
{
    
	vector<vector<cv::Point> > largest_contour_load;
	Mat img;
    
    //
    
    // resize image
    double scaleFactor = sample.cols/640;
    resize(sample, sample, cv::Size(round(sample.cols/scaleFactor),round(sample.rows/scaleFactor)));
    sample = sample(Range(1,480), Range(1,640));
    sample.convertTo(img, CV_LOAD_IMAGE_GRAYSCALE);
    
	if( !img.empty() )
	{
		// Apply the erosion operation
		Mat erosion;
		Mat element = getStructuringElement( MORPH_ELLIPSE, cv::Size(erosion_size + 1, erosion_size + 1), cv::Point(erosion_size, erosion_size) );
		erode(img, erosion, element);
        
		// frame filtering
		GaussianBlur(erosion, img, cv::Size( (2*ksize_width)+1,(2*ksize_height)+1 ), 1.5, 1.5);
		Canny(img, img, threshold1, threshold2, 3, true);
        
		// Apply the dilation operation
		Mat dilation;
		element = getStructuringElement( MORPH_ELLIPSE , cv::Size(dilation_size + 1, dilation_size + 1), cv::Point(dilation_size, dilation_size) );
		dilate(img, dilation, element);
		erosion_size=2;  // erosion for "camera_acquisition_elaboration"
		dilation_size=2; // dilation for "camera_acquisition_elaboration"
        
		// create "Filtered" windows
		//window_output("Filtered load", img);
		//window_output("Dilation load", dilation);
        
		// find the contours
		findContours(dilation, contours_load, hierarchy_load, CV_RETR_TREE, CV_CHAIN_APPROX_NONE);
        
		// find the contour of the largest area
		double area_max=100;
		int area_max_idx=0;
		for(unsigned i=0; i<contours_load.size(); i++)
			if( contourArea(Mat(contours_load[i])) > area_max )
			{
				area_max=contourArea(Mat(contours_load[i]));
				area_max_idx=i;
			}
        
		// Create a mask for largest contour to mask out that region from image.
		Mat mask = Mat::zeros(img.size(), img.type());
		// Create a mask for details contour to mask out that region from image.
		Mat mask_1 = Mat::zeros(img.size(), img.type());
        
		// At this point, mask has value of 255 for pixels within the contour and value of 0 for those not in contour.
		//drawContours(mask, contours_load, area_max_idx, Scalar(255,255,255), 2, 8, hierarchy_load, 0);
        
		// Largest contour load copy
		largest_contour_load.push_back(contours_load[area_max_idx]);
        
		// Ogni contorno compare contemporaneamente a 2 livelli della gerarchia: la sua parte esterna risulta ad un livello gerarchico
		// pi˘ alto rispetto alla sua parte interna.
		for(unsigned i=0;i<contours_load.size();i++)
		{
			// Trovo la parte esterna, a livello gerarchico, del contorno pi˘ grande
			if(hierarchy_load[i][3]==area_max_idx)
			{
				for(unsigned j=0;j<contours_load.size();j++)
				{
					// Trovo la parte interna, a livello gerarchico, del contorno pi˘ grande  e da questa ne traccio i contorni innestati
					// Trovo solo i dettagli del contorno pi˘ grande (contorno grande escluso!)
					if(hierarchy_load[j][3]==i)
					{
						//color = Scalar(rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255));
						//drawContours(mask_1, contours_load, j, color, 2, 8, hierarchy_load, 0);
						// Copio i sottocontorni (dettagli) del contorno pi˘ grande
						largest_contour_load.push_back(contours_load[j]);
					}
				}
			}
		}
        
	}
	return largest_contour_load;
}

Mat EmObjectDetect::matFromContours(vector<vector<cv::Point> > contours){
    
    Mat image = Mat::zeros(480,640,CV_8UC3);
    
    for(unsigned i=0; i<contours.size(); i++)
        drawContours(image, contours, i, Scalar(0,255,255), 1, 8);
    
    cv::cvtColor(image, image, CV_BGR2BGRA);
    return image;
    
}

Mat EmObjectDetect::camera_acquisition_elaboration(Mat inputFrame, vector<vector<cv::Point> > contour_unique_load,int mode)
{
    
	Mat src, temp;
    Mat average = Mat::zeros(rect.size(), CV_8UC3);
    vector<vector<cv::Point> > largest_contour(1);
    
	// get a new frame from camera
    src = inputFrame;
    
	//cap >> src;
    
    if ( !src.empty() )
	{
		// create "Source" window
        //		window_output("Source", src);
        
		// create "Focus Source" window
		Mat roiImg;
		roiImg = src(rect);
		//window_output("Focus Source", roiImg);
		
		// frame filtering
		cvtColor(roiImg, temp, CV_RGB2GRAY);
		GaussianBlur(temp, temp, cv::Size( (2*ksize_width)+1,(2*ksize_height)+1 ), 1.5, 1.5);
		Canny(temp, temp, threshold1, threshold2, 3, true);
        
		// create "Filtered" window
		//window_output("Filtered", temp);
        
		
		
		// find the contours
		findContours(temp, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE);
		
//		// Contours Matrices Initialization
//		Mat drawing = Mat::zeros(temp.size(), CV_8UC3);
//		
//		for(unsigned i=0; i<(contours.size()); i++)
//		{
//			// Define random color
//			color = Scalar(rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255));
//            
//			// Draw ALL contours
//			drawContours(drawing, contours, i, color, 1, 8, hierarchy);
//		}
        
		// create "Contours" windows
		//window_output("Contours", drawing);
        
        // -------------------------------------------------------------------------------------------------
        // INIZIALIZZAZIONE MASCHERE
        
		// Create new masks
		Mat mask_1 = Mat::zeros(roiImg.size(), roiImg.type());
		Mat mask_2 = Mat::zeros(temp.size(), CV_8UC3);
		Mat mask_3 = Mat::zeros(temp.size(), CV_8UC3);
        
        // -------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------
        // IDENTIFICAZIONE OGGETTO SCONOSCIUTO: SELEZIONE CONTORNI TRAMITE CENTRI DI MASSA
        
		if(contours.size() > 0)
		{
			// Vettore contenente gli indici dei contorni selezionati
			vector<int> idx_selected;
            
			// Centro del frame
			Point2f mass_center_ref(temp.cols/2, temp.rows/2);
            
			// Vettore dei momenti
			vector<Moments> mu(contours.size());
            
			// Vettore dei centri di massa
			vector<Point2f> mc(contours.size());
            
			// Calcolo i centri di massa di tutti i contorni
			for(unsigned w=0; w<(contours.size()); w++)
			{
				// Calcolo i momenti
				mu[w] = moments(contours[w], false);
                
				// Calcolo i centri di massa
				mc[w] = Point2f(mu[w].m10/mu[w].m00, mu[w].m01/mu[w].m00);
                
				// Seleziono i contorni i cui centri di massa distano meno di "minimum_dist" dal centro del frame
				if(euclideanDist(mc[w], mass_center_ref) < minimum_dist)
					idx_selected.push_back(w);
			}
            
			// Vettore degli indici dei contorni da escludere nei successivi confronti
			vector<int> no_contours;
			int flag, flag_bis;
            
			// Analizzo i contorni a 2 a 2
			for(unsigned i=0; i<idx_selected.size(); i++)
			{
				flag=1;
                
				for(unsigned j=0; j<idx_selected.size(); j++)
					if(i!=j)
					{
						flag_bis=1;
                        
						for(unsigned l=0; l<no_contours.size(); l++)
						{
							if(i==no_contours[l])
							{
								flag=0; // salta il confronto attuale e passa al prossimo i
								break;
							}
							
							if(j==no_contours[l])
							{
								flag_bis=0; // salta il confronto attuale e passa al prossimo j
								break;
							}
						}
                        
						if(flag==0)
							break; // passo al contorno i+1
                        
						if(flag_bis==1)
						{
							Point2f mc_medium( (mc[idx_selected[i]].x+mc[idx_selected[j]].x)/2, (mc[idx_selected[i]].y+mc[idx_selected[j]].y)/2 );
                            
							if(euclideanDist(mc_medium, mass_center_ref) < minimum_dist_bis)
							{
								color = Scalar(rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255));
								drawContours(mask_1, contours, idx_selected[i], color, 1, 8, hierarchy, 0);
								drawContours(mask_1, contours, idx_selected[j], color, 1, 8, hierarchy, 0);
                                
								// Copio i contorni appena tracciati
								for(unsigned k=0;k<contours[idx_selected[i]].size();k++)
									largest_contour[0].push_back(contours[idx_selected[i]][k]);
								for(unsigned k=0;k<contours[idx_selected[j]].size();k++)
									largest_contour[0].push_back(contours[idx_selected[j]][k]);
                                
								// escludo i contorni appena tracciati dai prossimi confronti
								no_contours.push_back(i);
								no_contours.push_back(j);
                                
								break; // passo al contorno i+1
							}
						}
                        
						if(j==(idx_selected.size()-1))
							no_contours.push_back(i); // il contorno i-esimo Ë stato confrontato con tutti gli altri senza esito positivo!
					}
			}
		}
        
        // -------------------------------------------------------------------------------------------------
        // RIEMPIMENTO REGIONE INDIVIDUATA DAI CONTORNI SELEZIONATI
        
		if(largest_contour[0].size() > 0)
		{
			// Trovo la figura convessa minima che racchiude i punti di tutti i contorni selezionati
			vector<vector<cv::Point>> hull(1);
			convexHull(largest_contour[0], hull[0], false);
            
			// Traccio la figura convessa minima
			drawContours(mask_1, hull, 0, Scalar(0,255,0), 1, 8);
			
			// Riempio la regione convessa e la salvo per la media successiva
			img[img_idx] = Mat::zeros(temp.size(), CV_8UC3);
			fillPoly(img[img_idx], hull, Scalar(255,255,255));
		}
		
		else
			img[img_idx] = Mat::zeros(temp.size(), CV_8UC3);
		
		// Finestra di output
		//window_output("Contorni Selezionati", mask_1);
        
        // -------------------------------------------------------------------------------------------------
        // RIEMPIMENTO BUFFER + MEDIA ULTIMI FRAME
        
		// Aggiorno l'indice del buffer
		if( img_idx==(NumberOfFrames-1) )
			img_idx=0;
		else
			img_idx++;
		
		// Media
		Mat average = Mat(temp.size(), CV_8UC3, Scalar(0,0,255));
		for(unsigned i=0;i<NumberOfFrames;i++)
			bitwise_and(average, img[i], average);
		
		// Finestra di output
		//window_output("Average Hull Filled", average);
        
        
        //average &= src;
    circle(average, cv::Point(average.cols/2, average.rows/2), 3, Scalar(0,255,0), -1, 8, 0);
    cvtColor(average,average, CV_RGB2RGBA);
    
    
        bitwise_xor(average, src, average);
        //bitaverage |= src;
    return average;
}
    return src;
}

/*** Helper FUNCTION to find a cosine of angle between vectors from pt0->pt1 and pt0->pt2 ***/

//double EmObjectDetect::angle(cv::Point pt1, cv::Point pt2, cv::Point pt0)
//{
//    double dx1 = pt1.x - pt0.x;
//    double dy1 = pt1.y - pt0.y;
//    double dx2 = pt2.x - pt0.x;
//    double dy2 = pt2.y - pt0.y;
//    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
//}

/*** FUNCTION -> distance (Euclidean) between these two points ***/
    
    /*** FUNCTION -> distance (Euclidean) between these two points ***/
    
    double EmObjectDetect::euclideanDist(cv::Point p, cv::Point q)
    {
        cv::Point diff = p - q;
        
        if(p.x >= q.x)
            diff.x = p.x - q.x;
        else
            diff.x = q.x - p.x;
        
        if(p.y >= q.y)
            diff.y = p.y - q.y;
        else
            diff.y = q.y - p.y;
        
        return sqrt(diff.x*diff.x + diff.y*diff.y);
    }

double EmObjectDetect::euclideanDistInt(int p, int q)
{
	int diff = 0;
    
    if(p > q)
		diff = p - q;
    
	else
		diff = q - p;
    
	return diff;
}
    
    /*** FUNCTION -> distance (Euclidean) between these two pixels ***/
    
    double EmObjectDetect::euclideanDistPixel(Vec3b p, Vec3b q)
    {
        Vec3b diff = p - q;
        
        for(unsigned i=0; i<3; i++)
        {
            if(p[i] >= q[i])
                diff[i] = p[i] - q[i];
            else
                diff[i] = q[i] - p[i];
        }
        
        return sqrt( diff[0]*diff[0] + diff[1]*diff[1] + diff[2]*diff[2] );
    }

double EmObjectDetect::euclideanDistance(cv::Point p, cv::Point q)
{
    cv::Point diff = p - q;
    return sqrt(diff.x*diff.x + diff.y*diff.y);
}
