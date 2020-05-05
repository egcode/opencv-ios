//
//  ImageProcessDNN.hpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//


/*
 description here
 https://www.learnopencv.com/face-detection-opencv-dlib-and-deep-learning-c-python/
 
 DNN Face Detector in OpenCV
 This model was included in OpenCV from version 3.3. It is based on
 Single-Shot-Multibox detector (https://arxiv.org/abs/1512.02325)
 and uses ResNet-10 Architecture as backbone.
 The model was trained using images available from the web,
 but the source is not disclosed. OpenCV provides 2 models for this face detector.
 
 - Floating point 16 version of the original caffe implementation ( 5.4 MB )
 - 8 bit quantized version using Tensorflow ( 2.7 MB )
 
 Both models included in the code
 
 */


#ifndef ImageProcessDNN_hpp
#define ImageProcessDNN_hpp

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/dnn.hpp>
#include <iostream>
#include <string>
#include <vector>
#include <stdlib.h>

class ImageProcessDNN {
    private:
        cv::dnn::Net net;
        std::string path;
    public:
        ImageProcessDNN(std::string path);
    
        // DNN inferencing
        cv::Mat filterDNN(cv::Mat src);
};

#endif /* ImageProcessDNN_hpp */
