//
//  TVHPlayStream.m
//  TvhClient
//
//  Created by zipleen on 26/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHPlayStream.h"
#import "TVHSettings.h"
#import "TVHServer.h"
#import "TVHSingletonServer.h"
#import "TVHPlayXbmc.h"

#define TVH_PROGRAMS @{@"VLC":@"vlc", @"Oplayer":@"oplayer", @"Buzz Player":@"buzzplayer", @"GoodPlayer":@"goodplayer", @"Ace Player":@"aceplayer" }
#define TVHS_TVHEADEND_STREAM_URL_INTERNAL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS&mux=mpegts"
#define TVHS_TVHEADEND_STREAM_URL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS"

@implementation TVHPlayStream

+ (id)sharedInstance {
    static TVHPlayStream *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHPlayStream alloc] init];
    });
    
    return __sharedInstance;
}

- (NSURL*)urlForSchema:(NSString*)schema withURL:(NSString*)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", schema, url]];
}

- (NSArray*)arrayOfAvailablePrograms {
    NSMutableArray *available = [[NSMutableArray alloc] init];
    for (NSString* key in TVH_PROGRAMS) {
        NSString *urlTarget = [TVH_PROGRAMS objectForKey:key];
        NSURL *url = [self urlForSchema:urlTarget withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:key];
        }
    }
    
    // custom
    NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
    if( [customPrefix length] > 0 ) {
        NSURL *url = [self urlForSchema:customPrefix withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:NSLocalizedString(@"Custom Player", nil)];
        }
    }
    
    // xbmc
    [available addObjectsFromArray:[[TVHPlayXbmc sharedInstance] availableXbmcServers]];
    
    return [available copy];
}

- (BOOL)isTranscodingCapable {
    TVHServer *tvhServer = [TVHSingletonServer sharedServerInstance];
    return [tvhServer isTranscodingCapable];
}

- (NSString*)stringTranscodeUrl:(NSString*)url {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL, [settings transcodeResolution]];
}

- (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL_INTERNAL, [settings transcodeResolution]];
}

- (NSURL*)URLforProgramWithName:(NSString*)title forURL:(NSString*)streamUrl {
    NSString *prefix = [TVH_PROGRAMS objectForKey:title];
    if ( prefix ) {
        NSURL *myURL = [self urlForSchema:prefix withURL:streamUrl];
        return myURL;
    }
    
    if ( [title isEqualToString:NSLocalizedString(@"Custom Player", nil)] ) {
        NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, streamUrl ];
        NSURL *myURL = [NSURL URLWithString:url];
        return myURL;
    }
    
    return nil;
}

- (BOOL)playProgramWithName:(NSString*)title forURL:(NSString*)streamUrl {
    
    if ( [self playInternalProgramWithName:title forURL:streamUrl] ) {
        return true;
    }
    
    return [[TVHPlayXbmc sharedInstance] playToXbmc:title withURL:streamUrl];
}

- (BOOL)playInternalProgramWithName:(NSString *)title forURL:(NSString *)streamUrl {
    NSURL *myURL = [self URLforProgramWithName:title forURL:streamUrl];
    if ( myURL ) {
        [TVHAnalytics sendEventWithCategory:@"playTo"
                                 withAction:@"Internal"
                                  withLabel:title
                                  withValue:[NSNumber numberWithInt:1]];
        [[UIApplication sharedApplication] openURL:myURL];
        return true;
    }
    return false;
}

@end
