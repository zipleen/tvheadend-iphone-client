//
//  TVHWebLogViewController.m
//  TvhClient
//
//  Created by zipleen on 27/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHWebLogViewController.h"
#import "TVHSettings.h"

@interface TVHWebLogViewController ()
@property (weak, nonatomic) TVHSettings *settings;
@end

@implementation TVHWebLogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settings = [TVHSettings sharedInstance];
    [self load];
}

- (void)load {
    NSURL *url = [NSURL URLWithString:[self.settings web1Url]];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:12];
    
    (void)[NSURLConnection connectionWithRequest:requestObj delegate:self];
    
    [self.webView setDelegate:self];
    [self.webView loadRequest:requestObj];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSURLCredential * cred = [NSURLCredential credentialWithUser:[self.settings web1User]
                                                        password:[self.settings web1Pass]
                                                     persistence:NSURLCredentialPersistenceForSession];
    [[NSURLCredentialStorage sharedCredentialStorage]setCredential:cred forProtectionSpace:[challenge protectionSpace]];
    
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection; {
    if ( [self.settings web1User] ) {
        if ( ! [[self.settings web1User] isEqualToString:@""] ) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)backButton:(id)sender {
    [self.webView goBack];
}

- (IBAction)reloadButton:(id)sender {
    [self load];
}

- (IBAction)resizeButton:(id)sender {
    if( self.splitViewController ) {
        MGSplitViewDividerStyle newStyle = ((self.splitViewController.dividerStyle == MGSplitViewDividerStyleThin) ? MGSplitViewDividerStylePaneSplitter : MGSplitViewDividerStyleThin);
        [self.splitViewController setDividerStyle:newStyle animated:YES];
    }
}
@end
