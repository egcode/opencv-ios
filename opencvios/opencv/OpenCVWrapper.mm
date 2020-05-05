//
//  OpenCVWrapper.m
//  opencvios
//
//  Created by Eugene Golovanov on 4/27/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//
#import <opencv2/opencv.hpp>
#include "ImageProcess.hpp"
#include "ImageProcessMTCNN.hpp"
#include "ImageProcessHaar.hpp"
#include "ImageProcessDNN.hpp"
#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>

@implementation OpenCVWrapper {
    ImageProcessType type;
    ImageProcessMTCNN *impMTCNN;
    ImageProcessDNN *impDNN;
}
using namespace std;

- (instancetype)initWithType:(ImageProcessType)type
{
    self = [super init];
    if (self) {
        self->type = type;
        
        switch (self->type) {
            case ImageProcessTypeMTCNN:
                self->impMTCNN = new ImageProcessMTCNN([self getMTCNNPath]);
                break;
            case ImageProcessTypeDNN:
                self->impDNN = new ImageProcessDNN([self getDNNPath]);
                break;

            default:
                break;
        }

    }
    return self;
}

- (void)dealloc
{
    if (self->impMTCNN) {
        delete self->impMTCNN;
    }
    if (self->impDNN) {
        delete self->impDNN;
    }
}

- (UIImage *) processImageWithType:(UIImage *)image {
    
    cv::Mat src=[self cvMatFromUIImage:image];
    cv::Mat dst;
    
    std::string pathToModels;
    
    switch (self->type) {
        case ImageProcessTypeCanny:
            dst = filterCanny(src);
            break;
        case ImageProcessTypeThreshold:
            dst = filterThreshold(src);
            break;
        case ImageProcessTypeMTCNN:
            dst = self->impMTCNN->filterMTCNN(src);
            break;
        case ImageProcessTypeHaar:
            dst = filterHaar(src, [self getHaarPath]);
            break;
        case ImageProcessTypeDNN:
            dst = self->impDNN->filterDNN(src);
            break;
        default:
            dst = filterCanny(src);
            break;
    }
    return [self UIImageFromCVMat:dst];
}


# pragma mark - DNN
- (std::string)getDNNPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"deploy" ofType:@"prototxt"];
    
    if ([fileManager fileExistsAtPath:path]){
        cout<<"exist";
        NSString *mainPath = [path substringToIndex:[path length]-15];
        return [mainPath cStringUsingEncoding:NSUTF8StringEncoding];
    } else {
        cout<<"not exist";
    }
    
    return "";
}

# pragma mark - Haar

- (std::string)getHaarPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
    
    if ([fileManager fileExistsAtPath:path]){
        return [path cStringUsingEncoding:NSUTF8StringEncoding];
    } else {
        cout<<"not exist";
    }
    
    return "";
}

# pragma mark - MTCNN

- (std::string)getMTCNNPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"det1" ofType:@"prototxt"];
    
    if ([fileManager fileExistsAtPath:path]){
        cout<<"exist";
        NSString *mainPath = [path substringToIndex:[path length]-13];
        return [mainPath cStringUsingEncoding:NSUTF8StringEncoding];

    } else {
        cout<<"not exist";
    }
    
    return "";
}


# pragma mark - Global Stuff

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end

