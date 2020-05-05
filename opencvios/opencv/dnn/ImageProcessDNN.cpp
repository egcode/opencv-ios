//
//  ImageProcessDNN.cpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#include "ImageProcessDNN.hpp"


const size_t inWidth = 300;
const size_t inHeight = 300;
const double inScaleFactor = 1.0;
const float confidenceThreshold = 0.7;
const cv::Scalar meanVal(104.0, 177.0, 123.0);

#define CAFFE

const std::string caffeConfigFile = "deploy.prototxt";
const std::string caffeWeightFile = "res10_300x300_ssd_iter_140000_fp16.caffemodel";

const std::string tensorflowConfigFile = "opencv_face_detector.pbtxt";
const std::string tensorflowWeightFile = "opencv_face_detector_uint8.pb";


ImageProcessDNN::ImageProcessDNN(std::string path)
{
    this->path = path;
    std::cout<<"printing path: "<<path<<std::endl;
    
#ifdef CAFFE
    this->net = cv::dnn::readNetFromCaffe(path + caffeConfigFile, path + caffeWeightFile);
#else
    this->net = cv::dnn::readNetFromTensorflow(path + tensorflowWeightFile, path + tensorflowConfigFile);
#endif

}


cv::Mat ImageProcessDNN::filterDNN(cv::Mat src) {
    
    if (this->path == "") {
        return src;
    }
    if(src.empty())
        return src;

    cv::Mat frameOpenCVDNN;
    //Convert to RGB
    cv::cvtColor(src, frameOpenCVDNN, cv::COLOR_BGR2RGB);

    int frameHeight = frameOpenCVDNN.rows;
    int frameWidth = frameOpenCVDNN.cols;
    
#ifdef CAFFE
    cv::Mat inputBlob = cv::dnn::blobFromImage(frameOpenCVDNN, inScaleFactor, cv::Size(inWidth, inHeight), meanVal, false, false);
#else
    cv::Mat inputBlob = cv::dnn::blobFromImage(frameOpenCVDNN, inScaleFactor, cv::Size(inWidth, inHeight), meanVal, true, false);
#endif
    
    this->net.setInput(inputBlob, "data");
    
    cv::Mat detection = this->net.forward("detection_out");
    
    cv::Mat detectionMat(detection.size[2], detection.size[3], CV_32F, detection.ptr<float>());
    
    for(int i = 0; i < detectionMat.rows; i++)
    {
        float confidence = detectionMat.at<float>(i, 2);
        
        if(confidence > confidenceThreshold)
        {
            int x1 = static_cast<int>(detectionMat.at<float>(i, 3) * frameWidth);
            int y1 = static_cast<int>(detectionMat.at<float>(i, 4) * frameHeight);
            int x2 = static_cast<int>(detectionMat.at<float>(i, 5) * frameWidth);
            int y2 = static_cast<int>(detectionMat.at<float>(i, 6) * frameHeight);
            
            cv::rectangle(frameOpenCVDNN, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(0, 255, 0),2, 4);
        }
    }

    //Convert Back to BGR
    cv::cvtColor(frameOpenCVDNN, frameOpenCVDNN, cv::COLOR_RGB2BGR);
    return frameOpenCVDNN;
}
