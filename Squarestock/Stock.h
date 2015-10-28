//
//  Stock.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ticker.h"

@interface Stock : NSObject

@property (nonatomic, strong) Ticker *ticker;
@property (nonatomic)         float currentPrice;
@property (nonatomic, strong) NSDate *tradeTime;
@property (nonatomic)         float openPrice;
@property (nonatomic)         float change;
@property (nonatomic)         float pctChange;
@property (nonatomic, strong) NSArray *historicalPrices;

- (instancetype)initWithTicker:(Ticker *)ticker currentPrice:(float)stockPrice time:(NSDate *)tradeTime andOpen:(float)openPrice;

@end