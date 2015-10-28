//
//  AppDelegate.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "AppDelegate.h"
#import "Ticker.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerDefaults];
    
    return YES;
}

- (void)registerDefaults {
    // Set Apple to be the standard ticker when the user first runs the app
    Ticker *ticker = [[Ticker alloc] initWithSymbol:@"AAPL" name:@"Apple Inc." andMarket:@"NASDAQ"];
    NSData *archivedTicker = [NSKeyedArchiver archivedDataWithRootObject:ticker];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"ArchivedSelectedTicker":archivedTicker}];
}

@end