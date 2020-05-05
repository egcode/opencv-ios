//
//  ImageProcessHaar.hpp
//  opencvios
//
//  Created by Eugene Golovanov on 4/30/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#ifndef ImageProcessHaar_hpp
#define ImageProcessHaar_hpp

#include <iostream>
#include <stdio.h>

#include "opencv2/objdetect.hpp"
#include "opencv2/videoio.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"

// Haar inferencing
cv::Mat filterHaar(cv::Mat src, std::string path);

#endif /* ImageProcessHaar_hpp */
