//
//  ImageProcess.hpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/29/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#ifndef ImageProcess_hpp
#define ImageProcess_hpp

#include <stdio.h>
#import <opencv2/opencv.hpp>

// Filter image with Canny filter
cv::Mat filterCanny(cv::Mat src);

// Filter image with simple Threshold
cv::Mat filterThreshold(cv::Mat src);

#endif /* ImageProcess_hpp */
