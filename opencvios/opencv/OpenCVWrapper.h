//
//  OpenCVWrapper.h
//  opencvios
//
//  Created by Eugene Golovanov on 4/27/19.
//  Copyright © 2019 Eugene Golovanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ImageProcessType) {
    ImageProcessTypeCanny,
    ImageProcessTypeThreshold,
    ImageProcessTypeMTCNN,
    ImageProcessTypeHaar,
    ImageProcessTypeDNN,
    ImageProcessTypeYolo3
};

@interface OpenCVWrapper : NSObject

- (instancetype)initWithType:(ImageProcessType)type;

- (UIImage *) processImageWithType:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
