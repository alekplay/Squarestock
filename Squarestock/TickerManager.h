//
//  TickerManager.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ticker.h"

@interface TickerManager : NSObject

+ (instancetype)sharedManager;
- (void)lookupTicker:(NSString *)tickerSymbol withCompletionHandler:(void (^)(NSArray *tickers, NSError *error))completionHandler;

@end
