//
//  ImageProcessMTCNN.cpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#include "ImageProcessMTCNN.hpp"

ImageProcessMTCNN::ImageProcessMTCNN(std::string path)
{
    this->path = path;
    std::cout<<"printing path: "<<path<<std::endl;
    
    ProposalNetwork::Config pConfig;
    pConfig.caffeModel = path + "det1.caffemodel";
    pConfig.protoText = path + "det1.prototxt";
    pConfig.threshold = 0.6f;
    
    RefineNetwork::Config rConfig;
    rConfig.caffeModel = path + "det2.caffemodel";
    rConfig.protoText = path + "det2.prototxt";
    rConfig.threshold = 0.7f;
    
    OutputNetwork::Config oConfig;
    oConfig.caffeModel = path + "det3.caffemodel";
    oConfig.protoText = path + "det3.prototxt";
    oConfig.threshold = 0.7f;
    
    this->detector = MTCNNDetector(pConfig, rConfig, oConfig);
}


using rectPoints = std::pair<cv::Rect, std::vector<cv::Point>>;
static cv::Mat drawRectsAndPoints(const cv::Mat &img,
                                  const std::vector<rectPoints> data)
{
    cv::Mat outImg;
    img.convertTo(outImg, CV_8UC3);
    
    for (auto &d : data) {
        cv::rectangle(outImg, d.first, cv::Scalar(0, 255, 255), 2);
        auto pts = d.second;
        for (size_t i = 0; i < pts.size(); ++i) {
            cv::circle(outImg, pts[i], 3, cv::Scalar(0, 255, 255), 1);
        }
    }
    return outImg;
}


cv::Mat ImageProcessMTCNN::filterMTCNN(cv::Mat src)
{
    if (this->path == "") {
        return src;
    }
    
    std::vector<Face> faces;
    
    {
        faces = this->detector.detect(src, 20.f, 0.709f);
    }
    
    std::cout << "Number of faces found in the supplied image - " << faces.size()
    << std::endl;
    
    std::vector<rectPoints> data;
    
    // show the image with faces in it
    for (size_t i = 0; i < faces.size(); ++i) {
        std::vector<cv::Point> pts;
        for (int p = 0; p < NUM_PTS; ++p) {
            pts.push_back(
                          cv::Point(faces[i].ptsCoords[2 * p], faces[i].ptsCoords[2 * p + 1]));
        }
        
        auto rect = faces[i].bbox.getRect();
        auto d = std::make_pair(rect, pts);
        data.push_back(d);
    }
    
    auto resultImg = drawRectsAndPoints(src, data);
    
    return resultImg;
}
