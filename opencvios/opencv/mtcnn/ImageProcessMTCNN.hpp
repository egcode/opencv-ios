//
//  ImageProcessMTCNN.hpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#ifndef ImageProcessMTCNN_hpp
#define ImageProcessMTCNN_hpp

#include <stdio.h>
#include <string>
#include <opencv2/dnn.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#import "detector.h"

class ImageProcessMTCNN {
    private:
        MTCNNDetector detector;
        std::string path;
    public:
        ImageProcessMTCNN(std::string path);
    
        // MTCNN inferencing
        cv::Mat filterMTCNN(cv::Mat src);
};

#endif /* ImageProcessMTCNN_hpp */
