//
//  TVHPlayStream.m
//  TvhClient
//
//  Created by Luis Fernandes on 26/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHPlayStream.h"
#import "TVHServer.h"
#import "TVHSingletonServer.h"
#import "TVHPlayXbmc.h"

#define TVH_PROGRAMS @{@"VLC":@"vlc", @"Oplayer":@"oplayer", @"Buzz Player":@"buzzplayer", @"GoodPlayer":@"goodplayer", @"Ace Player":@"aceplayer" }
#define TVHS_TVHEADEND_STREAM_URL_INTERNAL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS&mux=mpegts"
#define TVHS_TVHEADEND_STREAM_URL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS"

@interface TVHPlayStream()
@property (nonatomic, weak) TVHServer *tvhServer;
@end

@implementation TVHPlayStream

- (id)init
{
    [NSException raise:@"Invalid Init" format:@"TVHPlayStream needs TVHServer to work"];
    return nil;
}

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    NSParameterAssert(tvhServer);
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    
    return self;
}

#pragma MARK get programs

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
    NSString *customPrefix = [self.tvhServer.settings customPrefix];
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
    return [self.tvhServer isTranscodingCapable];
}

#pragma mark play stream

- (BOOL)playStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    
    if ( [self playInternalStreamIn:program forObject:streamObject withTranscoding:transcoding] ) {
        return true;
    }
    
    return [self playToXbmc:program forObject:streamObject withTranscoding:transcoding];
}

- (BOOL)playInternalStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    NSString *streamUrl = [streamObject streamUrlWithTranscoding:transcoding withInternal:NO];
    NSURL *myURL = [self URLforProgramWithName:program forURL:streamUrl];
    if ( myURL ) {
        [self.tvhServer.analytics sendEventWithCategory:@"playTo"
                                             withAction:@"Internal"
                                              withLabel:program
                                              withValue:[NSNumber numberWithInt:1]];
        [[UIApplication sharedApplication] openURL:myURL];
        return true;
    }
    return false;
}

- (BOOL)playToXbmc:(NSString*)xbmcName forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding {
    TVHPlayXbmc *playXbmcService = [TVHPlayXbmc sharedInstance];
    NSDictionary *foundServices = [playXbmcService foundServices];
    
    NSString *xbmcServerAddress = [foundServices objectForKey:xbmcName];
    NSString *url = [playXbmcService validUrlForObject:streamObject withTranscoding:transcoding];
    if ( xbmcServerAddress && url ) {
        NSURL *playXbmcUrl = [NSURL URLWithString:xbmcServerAddress];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:playXbmcUrl];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        NSDictionary *httpParams = @{@"jsonrpc": @"2.0",
                                     @"method": @"player.open",
                                     @"params":
                                         @{@"item" :
                                               @{@"file": url}
                                           }
                                     };
        [httpClient postPath:@"/jsonrpc" parameters:httpParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Did something with %@ and %@ : %@", serverUrl, url, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [self.tvhServer.analytics sendEventWithCategory:@"playTo"
                                                 withAction:@"Xbmc"
                                                  withLabel:@"Success"
                                                  withValue:[NSNumber numberWithInt:1]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Failed to do something with %@ and %@", serverUrl, url);
            [self.tvhServer.analytics sendEventWithCategory:@"playTo"
                                                 withAction:@"Xbmc"
                                                  withLabel:@"Fail"
                                                  withValue:[NSNumber numberWithInt:1]];
        }];
        return true;
    }
    return false;
}

- (NSString*)streamUrlForObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding withInternal:(BOOL)internal
{
    NSString *streamUrl;
    if ( internal ) {
        streamUrl = streamObject.playlistStreamURL;
    } else {
        streamUrl = streamObject.streamURL;
    }
    
    if ( transcoding ) {
        if ( internal ) {
            return [self stringTranscodeUrlInternalFormat:streamUrl];
        } else {
            return [self stringTranscodeUrl:streamUrl];
        }
    } else {
        return streamUrl;
    }
}


- (NSString*)stringTranscodeUrl:(NSString*)url {
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL, self.tvhServer.settings.transcodeResolution];
}

- (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url {
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL_INTERNAL, self.tvhServer.settings.transcodeResolution];
}

- (NSURL*)URLforProgramWithName:(NSString*)title forURL:(NSString*)streamUrl {
    NSString *prefix = [TVH_PROGRAMS objectForKey:title];
    if ( prefix ) {
        NSURL *myURL = [self urlForSchema:prefix withURL:streamUrl];
        return myURL;
    }
    
    if ( [title isEqualToString:NSLocalizedString(@"Custom Player", nil)] ) {
        NSString *customPrefix = [self.tvhServer.settings customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, streamUrl ];
        NSURL *myURL = [NSURL URLWithString:url];
        return myURL;
    }
    
    return nil;
}

- (NSURL*)urlForSchema:(NSString*)schema withURL:(NSString*)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", schema, url]];
}

@end
