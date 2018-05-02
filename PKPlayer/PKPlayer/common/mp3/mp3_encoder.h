//
//  mp3_encoder.h
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#ifndef PHUKET_TOUR_MP3_ENCODER
#define PHUKET_TOUR_MP3_ENCODER

#include "lame.h"

/**
 音频编码
 **/

class Mp3Encoder {
private:
    FILE *pcmFile;
    FILE *mp3File;
    lame_t lameClient;
    
public:
    Mp3Encoder();
    ~Mp3Encoder();
    int Init(const char *pcmFilePath, const char *mp3FilePath, int sampleRate, int channels, int bitRate);
    void Encode();
    void Destory();
    
};

#endif /* mp3_encoder_h */
