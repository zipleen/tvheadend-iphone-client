//
//  TVHJASidePanelController.m
//  TvhClient
//
//  Created by zipleen on 5/25/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
