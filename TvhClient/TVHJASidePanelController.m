//
//  TVHJASidePanelController.m
//  TvhClient
//
//  Created by Luis Fernandes on 5/25/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHJASidePanelController.h"
#import "MGSplitViewController.h"

@implementation TVHJASidePanelController

- (void)_placeButtonForLeftPanel {
    if (self.leftPanel) {
        UIViewController *buttonController = self.centerPanel;
        if ([buttonController isKindOfClass:[UISplitViewController class]]) {
            UISplitViewController *nav = (UISplitViewController *)buttonController;
            if ([nav.viewControllers count] > 0) {
                buttonController = [nav.viewControllers objectAtIndex:0];
            }
        }
        if ([buttonController isKindOfClass:[MGSplitViewController class]]) {
            MGSplitViewController *nav = (MGSplitViewController *)buttonController;
            if ([nav.viewControllers count] > 0) {
                buttonController = nav.detailViewController;
            }
        }
        
        if ([buttonController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)buttonController;
            if ([nav.viewControllers count] > 0) {
                buttonController = [nav.viewControllers objectAtIndex:0];
            }
        }
        if ( buttonController.navigationItem ) {
            buttonController.navigationItem.leftBarButtonItem = [self leftButtonForCenterPanel];
        }
    }
}

@end
