//
//  AKBallWithinTheBoxReverbTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AKFoundation.h"
#import "NSData+MD5.h"

#define testDuration 10.0

@interface TestBallWithinTheBoxReverbInstrument : AKInstrument
@end

@implementation TestBallWithinTheBoxReverbInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *xLocation = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                   secondPoint:akp(6)
                                         durationBetweenPoints:akp(testDuration)];
        
        AKLine *yLocation = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                   secondPoint:akp(4)
                                         durationBetweenPoints:akp(testDuration)];
        
        AKLine *zLocation = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                   secondPoint:akp(3)
                                         durationBetweenPoints:akp(testDuration)];
        
        AKBallWithinTheBoxReverb *ballWithinTheBoxReverb = [[AKBallWithinTheBoxReverb alloc] initWithInput:mono];
        ballWithinTheBoxReverb.xLocation = xLocation;
        ballWithinTheBoxReverb.yLocation = yLocation;
        ballWithinTheBoxReverb.zLocation = zLocation;
        ballWithinTheBoxReverb.diffusion =  akp(0);
        
        AKMix *mix = [[AKMix alloc] initWithInput1:mono
                                            input2:[[AKMix alloc] initMonoAudioFromStereoInput:ballWithinTheBoxReverb]
                                           balance:akp(0.1)];
        
        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKBallWithinTheBoxReverbTests : XCTestCase
@end

@implementation AKBallWithinTheBoxReverbTests

- (void)testBallWithinTheBoxReverb
{
    // Set up performance
    TestBallWithinTheBoxReverbInstrument *testInstrument = [[TestBallWithinTheBoxReverbInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-BallWithinTheBoxReverb.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"83b0eaeeccf43a86dc62b2fc7220fd5c");
}

@end