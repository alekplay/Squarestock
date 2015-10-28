//
//  StockManager.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stock.h"

@interface StockManager : NSObject

+ (instancetype)sharedManager;
- (void)getCurrentDataForTicker:(Ticker *)ticker withCompletionHandler:(void (^)(Stock *stock, NSError *error))completionHandler;

@end
