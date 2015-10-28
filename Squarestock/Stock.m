//
//  Stock.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "Stock.h"

@implementation Stock

// Designated initializer
- (instancetype)initWithTicker:(Ticker *)ticker currentPrice:(float)stockPrice time:(NSDate *)tradeTime andOpen:(float)openPrice {
    if ([super init]) {
        self.ticker = ticker;
        
        self.currentPrice = stockPrice;
        self.openPrice = openPrice;
        self.change = self.currentPrice - self.openPrice;
        self.pctChange = ((self.currentPrice == 0.0) ? 0.0 : (fabsf(self.change / self.currentPrice) * 100.0));
        
        self.tradeTime = tradeTime;
        
        self.historicalPrices = [self generateArrayWithRandomHistoricalPrices];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithTicker:[[Ticker alloc] init] currentPrice:0.0 time:[NSDate date] andOpen:0.0];
}

- (NSArray *)generateArrayWithRandomHistoricalPrices {
    // Get the min and max stock value
    int minimumValue = MIN((int)self.openPrice, (int)self.currentPrice);
    int maximumValue = MAX((int)self.openPrice, (int)self.currentPrice);
    
    // Create a lower bound 20% below  min, and upper bound 30% above max
    int lowerBound = minimumValue - (minimumValue * 0.2);
    int upperBound = maximumValue + (maximumValue * 0.3);
    
    // Generate a list of random historical prices, starting with the open and ending at the current price
    NSMutableArray *mutableHistoricalPrices = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:(int)self.openPrice]];
    for (int i = 1; i < 6; i++) {
        int randomValue = lowerBound + arc4random_uniform(upperBound - lowerBound);
        [mutableHistoricalPrices addObject:[NSNumber numberWithInt:randomValue]];
    }
    [mutableHistoricalPrices addObject:[NSNumber numberWithInt:(int)self.currentPrice]];
    
    // Return an immutable copy of this array
    return [mutableHistoricalPrices copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ trading at %f >", self.ticker.symbol, self.currentPrice];
}

@end