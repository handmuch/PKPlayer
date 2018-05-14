//
//  PKImageCoder.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/5/9.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 图片类型
 */
typedef NS_ENUM(NSInteger, PKLocalFileImageType) {
    PKLocalFileImageTypeUnknown = 0,
    PKLocalFileImageTypeJEPG,
    PKLocalFileImageTypeJEPG2000,
    PKLocalFileImageTypeTIFF,
    PKLocalFileImageTypeBMP,
    PKLocalFileImageTypeICO,
    PKLocalFileImageTypeICNS,
    PKLocalFileImageTypeGIF,
    PKLocalFileImageTypePNG,
    PKLocalFileImageTypeWebP,
    PKLocalFileImageTypeOther,
};

typedef NS_ENUM(NSUInteger, PKImageDisposeMethod) {
    PKImageDisposeMethodNone = 0,
    PKImageDisposeMethodBackground,
    PKImageDisposeMethodPervious,
};

typedef NS_ENUM(NSUInteger, PKImageBlendOperation) {
    PKImageBlendOperationNone = 0,
    PKImageBlendOperationOver,
};

@interface PKImageFrame : NSObject

@property (nonatomic, assign) NSUInteger index;          //frame index
@property (nonatomic, assign) NSUInteger width;          //frame width
@property (nonatomic, assign) NSUInteger height;         //frame heigh
@property (nonatomic, assign) NSUInteger offsetX;        //frame origin.x in canvas
@property (nonatomic, assign) NSUInteger offsetY;        //frame origin.y in canvas
@property (nonatomic, assign) NSTimeInterval duration;   //frame duration in seconds
@property (nonatomic, assign) PKImageDisposeMethod dispose;
@property (nonatomic, assign) PKImageBlendOperation blend; //the image
@property (nonatomic, strong) UIImage *image;

+ (instancetype)frameWithImage:(UIImage *)image;

@end

#pragma mark - Decoder

@interface PKImageDecoder : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, assign, readonly) PKLocalFileImageType imageType;
@property (nonatomic, assign, readonly) CGFloat scale;
@property (nonatomic, assign, readonly) NSUInteger frameCount;
@property (nonatomic, assign, readonly) NSUInteger loopCount;
@property (nonatomic, assign, readonly) NSUInteger width;
@property (nonatomic, assign, readonly) NSUInteger height;
@property (nonatomic, assign, readonly, getter=isFinalized) BOOL finalized;

- (instancetype)initWithScale:(CGFloat)scale NS_DESIGNATED_INITIALIZER;

- (BOOL)updateData:(nullable NSData *)data final:(BOOL)final;

- (nullable PKImageFrame *) frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;

- (NSTimeInterval)frameDurationAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)framePropertiesAtIndex:(NSUInteger)index;

- (nullable NSDictionary *)imageProperties;

@end

#pragma mark - Encoder

@interface PKImageEncoder : NSObject



@end


@interface PKImageCoder : NSObject


@end
