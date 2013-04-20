//
//  TVHUICustomTabBar.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/23/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHUICustomTabBar.h"

@implementation TVHUICustomTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)customize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        /*UIImage *tabbarBg = [UIImage imageNamed:@"tabbar.png"];
        UIImage *tabBarSelected = [UIImage imageNamed:@"tabbar_selected.png"];
        [self setBackgroundImage:tabbarBg ]; 
        [self setSelectionIndicatorImage:tabBarSelected];*/
        
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar.png"]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"] ];
    }
    [self.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setTitle:NSLocalizedString([obj title], @"")];
    }];
}

@end
