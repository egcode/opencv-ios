//
//  ImageProcess.cpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/29/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#include "ImageProcess.hpp"

cv::Mat filterCanny(cv::Mat src) {
    cv::Mat dst;
    dst=src;
    cv::Canny(src, dst, 400, 1000, 5);
    return dst;
}

cv::Mat filterThreshold(cv::Mat src) {
    int threshold_value = 0;
    int const max_BINARY_value = 2147483647;
    cv::Mat dst;
    dst=src;
    cv::cvtColor(src, dst, cv::COLOR_RGB2GRAY);
    cv::threshold( dst, dst, threshold_value, max_BINARY_value,cv::THRESH_OTSU );
    return dst;
}
