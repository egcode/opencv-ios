//
//  ImageProcessHaar.cpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#include "ImageProcessHaar.hpp"

/** Global variables */
cv::String faceCascadePath;
cv::CascadeClassifier faceCascade;

void detectFaceOpenCVHaar(cv::CascadeClassifier faceCascade, cv::Mat &frameOpenCVHaar, int inHeight=300, int inWidth=0)
{
    int frameHeight = frameOpenCVHaar.rows;
    int frameWidth = frameOpenCVHaar.cols;
    if (!inWidth)
        inWidth = (int)((frameWidth / (float)frameHeight) * inHeight);
    
    float scaleHeight = frameHeight / (float)inHeight;
    float scaleWidth = frameWidth / (float)inWidth;
    
    cv::Mat frameOpenCVHaarSmall, frameGray;
    cv::resize(frameOpenCVHaar, frameOpenCVHaarSmall, cv::Size(inWidth, inHeight));
    cv::cvtColor(frameOpenCVHaarSmall, frameGray, cv::COLOR_BGR2GRAY);
    
    std::vector<cv::Rect> faces;
    faceCascade.detectMultiScale(frameGray, faces);
    
    for ( size_t i = 0; i < faces.size(); i++ )
    {
        int x1 = (int)(faces[i].x * scaleWidth);
        int y1 = (int)(faces[i].y * scaleHeight);
        int x2 = (int)((faces[i].x + faces[i].width) * scaleWidth);
        int y2 = (int)((faces[i].y + faces[i].height) * scaleHeight);
        cv::rectangle(frameOpenCVHaar, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(0,255,0), (int)(frameHeight/150.0), 2);
    }
}



cv::Mat filterHaar(cv::Mat src, std::string path) {
    
    if (path == "") {
        return src;
    }
    faceCascadePath = path;

    if( !faceCascade.load( faceCascadePath ) ){ printf("--(!)Error loading face cascade\n"); return src; };

    cv::Mat frame;

    if(src.empty())
        return src;
    detectFaceOpenCVHaar ( faceCascade, src );
    
    return src;
}
