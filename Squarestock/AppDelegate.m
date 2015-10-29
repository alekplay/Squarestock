//
//  AppDelegate.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "AppDelegate.h"
#import "Company.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerDefaults];
    
    return YES;
}

- (void)registerDefaults {
    // Set Apple to be the standard company when the user first runs the app
    Company *company = [[Company alloc] initWithSymbol:@"AAPL" name:@"Apple Inc." andMarket:@"NASDAQ"];
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:company];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kSQArchivedSelectedCompanyKey: archive}];
}

@end