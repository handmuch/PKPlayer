//
//  PKRealTimeAnalyzer.m
//  PKPlayer
//
//  Created by 郭建华 on 2019/3/7.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import "PKRealTimeAnalyzer.h"

static int fftSize = 2048;  //数据维度

@interface PKRealTimeAnalyzer (){
    FFTSetup _fftSetup;
}

@property (nonatomic, strong) NSMutableArray <NSMutableArray<NSNumber *> *> *spectrumBuffer;
@property (nonatomic, strong) NSMutableArray <PKWaveBand *>*bands;

@end

@implementation PKRealTimeAnalyzer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fftSize = fftSize;
        _frequencyBands = 80;
        _startFrequency = 100;
        _endFrequency = 18000;
        _spectrumSmooth = 0.5;
        [self setup];
    }
    return self;
}

- (void)setup {
    //创建FFT转换器
    _fftSetup = vDSP_create_fftsetup((vDSP_Length)((int)(round(log2((double)fftSize)))), (FFTRadix)kFFTRadix2);
    
    self.spectrumBuffer = [NSMutableArray<NSMutableArray<NSNumber *> *> array];
    for (NSUInteger i = 0; i < 2; i++) {
        NSMutableArray<NSNumber *> *arr = [NSMutableArray<NSNumber *> array];
        for (int j = 0; j < self.frequencyBands; j++) {
            [arr addObject: [NSNumber numberWithFloat:0.0]];
        }
        [self.spectrumBuffer addObject:arr];
    }
}

- (void)dealloc {
    if (_fftSetup != NULL) {
        vDSP_destroy_fftsetup(_fftSetup);
        _fftSetup = NULL;
    }
}

#pragma mark - setter

- (void)setSpectrumSmooth:(CGFloat)spectrumSmooth {
    _spectrumSmooth = spectrumSmooth;
    _spectrumSmooth = MAX(0.0, _spectrumSmooth);
    _spectrumSmooth = MIN(1.0, _spectrumSmooth);
}

#pragma mark - public method

- (NSMutableArray <NSArray <NSNumber *>*>*)analyseWithBuffer:(AVAudioPCMBuffer *)buffer {
    NSMutableArray *channelsAmplitudes = [self fftBuffer:buffer];
    NSMutableArray *aWeights = [self creatFrequencyWeights];
    for (NSUInteger i = 0; i < channelsAmplitudes.count; i++) {
        @autoreleasepool {
            NSArray<NSNumber *> *amplitudes = channelsAmplitudes[i];
            NSMutableArray *weightedAmplitude = [NSMutableArray array];
            for (int i = 0; i < amplitudes.count; i++) {
                NSNumber *amplitude = [amplitudes objectAtIndex:i];
                NSNumber *aWeight = [aWeights objectAtIndex:i];
                float weighted = amplitude.floatValue * aWeight.floatValue;
                [weightedAmplitude addObject:[NSNumber numberWithFloat:weighted]];
            }
            
            NSMutableArray <NSNumber *>*spectrum = [NSMutableArray array];
            for (int t = 0; t < self.frequencyBands; t++) {
                CGFloat bandWidth = ((CGFloat)buffer.format.sampleRate / (CGFloat)self.fftSize);
                CGFloat sperturmCount = [self findMaxAmplitudeForBand:self.bands[t] inAmplitudes:amplitudes withBandWidth:bandWidth] * 5.0f;
                [spectrum addObject:[NSNumber numberWithFloat:sperturmCount]];
            }
            
            spectrum = [self highlightWaveformSpectrum:spectrum];
            for (int t = 0; t < self.frequencyBands; t++) {
                float oldVal = self.spectrumBuffer[i][t].floatValue;
                float newVal = spectrum[t].floatValue;
                float result = oldVal * self.spectrumSmooth + newVal * (1.0 - self.spectrumSmooth);
                self.spectrumBuffer[i][t] = [NSNumber numberWithFloat:(isnan(result) ?  0 : result)];
            }
        }
    }
    return self.spectrumBuffer.copy;
}

/**
 信号处理，返回

 @param buffer 信号数据
 @return 具体频率信号强度
 */
- (NSMutableArray *)fftBuffer:(AVAudioPCMBuffer *)buffer {
    @autoreleasepool {
        NSMutableArray *amplitudes = [[NSMutableArray alloc]initWithCapacity:2];
        float *const *floatChannelData = buffer.floatChannelData;
        //抽取buffer中的样本数据
        int channelCount = (int)buffer.format.channelCount;
        BOOL isInterleaved = buffer.format.isInterleaved;
        NSMutableArray *channels = [NSMutableArray array];
        for (int i = 0; i < channelCount; i++) {
            for (AVAudioFrameCount i = 0; i < buffer.frameLength; i++) {
                [channels addObject:@(buffer.floatChannelData[0][i])];
            }
        }
        
        //1.判读是左右声道数据否交错，获取数据的方式不一样
        if (isInterleaved) {
            NSMutableArray *interleaveData = [NSMutableArray array];
            for (int i = 0; i < fftSize * channelCount; i++) {
                [interleaveData addObject:@(floatChannelData[0][i])];
            }
            NSMutableArray *channelsTemp = [NSMutableArray array];
            for (int i = 0; i < channelCount; i += channelCount) {
                for (int j = i; j < interleaveData.count; j += channelCount) {
                    NSNumber *channelData = interleaveData[j];
                    [channelsTemp addObject:channelData];
                }
            }
            channels = channelsTemp;
        }
        
        for (int i = 0; i < channelCount; i++) {
            //2: 加汉宁窗
            float *channelData = floatChannelData[i];
            //注意C语言的数组申请方法，直接用float[] = {0}也是可以，但感觉不够清晰
            float *window = (float *)calloc(fftSize, sizeof(float));
            int hann = (int)vDSP_HANN_NORM;
            vDSP_hann_window(window, (vDSP_Length)fftSize, hann);
            vDSP_vmul(channelData, 1, window, 1, channelData, 1, (vDSP_Length)fftSize);
            
            //3:将实数包装成
            float *realp = (float *)calloc((fftSize/2), sizeof(float));
            float *imagp = (float *)calloc((fftSize/2), sizeof(float));
            DSPSplitComplex *fftInout = new DSPSplitComplex;
            fftInout->realp = realp;
            fftInout->imagp = imagp;
            vDSP_ctoz((const DSPComplex *)channelData, 2, fftInout, 1, (vDSP_Length)fftSize/2);
            
            //4:执行FFT
            vDSP_fft_zrip(_fftSetup, fftInout, 1, (vDSP_Length)(round(log2((double)fftSize))), (FFTDirection)FFT_FORWARD);
            
            //5:调整结果
            fftInout->imagp[0] = 0;
            float fftNormFactor = 1.0/(float)fftSize;
            vDSP_vsmul(fftInout->realp, 1, &fftNormFactor, fftInout->realp, 1, (vDSP_Length)(fftSize/2));
            vDSP_vsmul(fftInout->imagp, 1, &fftNormFactor, fftInout->imagp, 1, (vDSP_Length)(fftSize/2));
            float channelAmplitudes[1024] = {0.0f};
            vDSP_zvabs(fftInout, 1, channelAmplitudes, 1, (vDSP_Length)(fftSize/2));
            channelAmplitudes[0] = channelAmplitudes[0]/2;
            NSMutableArray *channelAmplitudeArray = [[NSMutableArray alloc]init];
            for (int i = 0; i < 1024; i++) {
                @autoreleasepool {
                    [channelAmplitudeArray addObject:@(channelAmplitudes[i])];
                }
            }
            [amplitudes addObject:channelAmplitudeArray];
        }
        return amplitudes;
    }
}

- (CGFloat)findMaxAmplitudeForBand:(PKWaveBand *)band
                      inAmplitudes:(NSArray <NSNumber *>*)amplitudes
                     withBandWidth:(CGFloat)bandWidth {
//    NSLog(@"%@", amplitudes);
    int startIndex = int(round(band.lowerFrequency / bandWidth));
    int endIndex = int(MIN(int(round(band.upperFrequency / bandWidth)), amplitudes.count - 1));
    NSMutableArray *rangArray = [NSMutableArray arrayWithArray:[amplitudes subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)]];
    [rangArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    return [[rangArray firstObject] floatValue];
}

- (NSMutableArray <NSNumber *>*)creatFrequencyWeights {
    int Δf = 44100.0 / CGFloat(fftSize);
    int bins = fftSize / 2;
    NSMutableArray *binsArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 0; i < bins; i++) {
        CGFloat newBin = CGFloat(i) * Δf;
        [binsArray addObject:[NSNumber numberWithFloat:(newBin * newBin)]];
    }
    
    CGFloat c1 = powf(12194.217, 2.0);
    CGFloat c2 = powf(20.598997, 2.0);
    CGFloat c3 = powf(107.65265, 2.0);
    CGFloat c4 = powf(737.86223, 2.0);
    
    NSMutableArray *weights = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 0; i < binsArray.count; i++) {
        CGFloat result = [[binsArray objectAtIndex:i] floatValue];
        CGFloat num  = CGFloat(c1 * result * result);
        CGFloat den =  CGFloat((result + c2) * sqrtf((result + c3) * (result + c4) * (result + c1)));
        CGFloat weight = 1.2589 * num / den;
        [weights addObject:[NSNumber numberWithFloat:weight]];
    }
    return weights;
}

- (NSMutableArray <NSNumber *>*)highlightWaveformSpectrum:(NSMutableArray <NSNumber *>*)spectrum {
    //1: 定义权重数组，数组中间的5表示自己的权重
    //   可以随意修改，个数需要奇数
    NSArray *weigths = @[@(1), @(2), @(3), @(5), @(3), @(2), @(1)];
    int totalWeigths = 0;
    for (NSNumber *weigth in weigths) {
        totalWeigths += [weigth integerValue];
    }
    NSInteger startIndex = weigths.count / 2;
    //2: 开头几个不参与计算
    NSMutableArray *averagedSpectrum = [NSMutableArray arrayWithArray:[spectrum subarrayWithRange:NSMakeRange(0, startIndex)]];
    for (int i = (int)startIndex; i < (spectrum.count - startIndex); i++) {
        //3: zip作用: zip([a,b,c], [x,y,z]) -> [(a,x), (b,y), (c,z)]
        long count = MIN(((i + startIndex) - (i - startIndex) + 1), 7);
        long zipOneIdx = (i - startIndex);
        float total = 0;
        for (int j = 0; j < count; j++) {
            NSNumber *weigth = [weigths objectAtIndex:j];
            total += spectrum[zipOneIdx].floatValue * weigth.floatValue;
            zipOneIdx++;
        }
        float averaged = total / totalWeigths;
        [averagedSpectrum addObject:[NSNumber numberWithFloat:averaged]];
    }
    //4：末尾几个不参与计算
    NSUInteger idx = (spectrum.count - startIndex);
    for (NSUInteger i = idx; i < spectrum.count; i++) {
        [averagedSpectrum addObject:spectrum[i]];
    }
    return averagedSpectrum.copy;
}

#pragma mark - lazyInit

- (NSMutableArray <PKWaveBand *>*)bands {
    if (!_bands) {
        _bands = [[NSMutableArray alloc]initWithCapacity:2];
        float n = log2f(self.endFrequency/self.startFrequency) / float(self.frequencyBands);
        CGFloat startFrequency = self.startFrequency;
        for (int i = 1; i <= self.frequencyBands; i++) {
            //2：频带的上频点是下频点的2^n倍
            PKWaveBand *nextBand = [[PKWaveBand alloc]initWithlowerFrequency:startFrequency upperFrequency:0.0];
            float highFrequency = nextBand.lowerFrequency * powf(2, n);
            nextBand.upperFrequency = (i == self.frequencyBands ? self.endFrequency : highFrequency);
            [_bands addObject:nextBand];
            startFrequency = highFrequency;
        }
    }
    return _bands;
}

@end


@implementation PKWaveBand

- (instancetype)initWithlowerFrequency:(CGFloat)lowerFrequency
                        upperFrequency:(CGFloat)upperFrequency {
    self = [super init];
    if (self) {
        self.lowerFrequency = lowerFrequency;
        self.upperFrequency = upperFrequency;
    }
    return self;
}

@end
