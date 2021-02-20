//
//  mp3_encoder.cpp
//  PKPlayer
//
//  Created by 郭建华 on 2018/4/30.
//  Copyright © 2018年 PeterKwok. All rights reserved.
//

#include "mp3_encoder.h"

Mp3Encoder::Mp3Encoder() {
    
}

Mp3Encoder::~Mp3Encoder() {
    
}


/**
 初始化mp3编码器

 @param pcmFilePath pcm文件读取地址
 @param mp3FilePath mp3文件输出地址
 @param sampleRate 抽样率
 @param channels 声道
 @param bitRate 码率
 @return 0成功 -1失败
 */
int Mp3Encoder::Init(const char *pcmFilePath, const char *mp3FilePath, int sampleRate, int channels, int bitRate) {
    int ret = -1;
    pcmFile = fopen(pcmFilePath, "rb");
    if (pcmFile) {
        mp3File = fopen(mp3FilePath, "wb");
        if(mp3File) {
            lameClient = lame_init();
            lame_set_in_samplerate(lameClient, sampleRate);
            lame_set_out_samplerate(lameClient, sampleRate);
            lame_set_num_channels(lameClient, channels);
            lame_set_brate(lameClient, bitRate);
            lame_init_params(lameClient);
            ret = 0;
        }
    }
    return ret;
}


/**
 编码
 */
void Mp3Encoder::Encode() {
    int bufferSize = 1024 * 256;
    short *buffer = new short[bufferSize / 2];
    short *lefeBuffer = new short[bufferSize / 4];
    short *rightBuffer = new short[bufferSize / 4];
    unsigned char *mp3_buffer = new unsigned char[bufferSize];
    size_t readBufferSize = 0;
    while ((readBufferSize = fread(buffer, 2, bufferSize/2, pcmFile)) > 0) {
        for (int i = 0; i < readBufferSize; i++) {
            if (i % 2 == 0) {
                lefeBuffer[i/2] = buffer[i];
            }else {
                rightBuffer[i/2] = buffer[i];
            }
        }
        size_t worteSize = lame_encode_buffer(lameClient, (short int *)lefeBuffer, (short int *)rightBuffer, (int)(readBufferSize/2), mp3_buffer, bufferSize);
        fwrite(mp3_buffer, 1, worteSize, mp3File);
    }
    
    delete [] buffer;
    delete [] lefeBuffer;
    delete [] rightBuffer;
    delete [] mp3_buffer;
}


/**
 销毁
 */
void Mp3Encoder::Destory() {
    if(pcmFile) {
        fclose(pcmFile);
    }
    
    if (mp3File) {
        fclose(mp3File);
        lame_close(lameClient);
    }
}
