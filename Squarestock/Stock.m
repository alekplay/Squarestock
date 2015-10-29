//
//  Stock.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "Stock.h"
#import "Company.h"
#import "Price.h"

@implementation Stock

#pragma mark INIT

// Designated initializer
- (instancetype)initWithCompany:(Company *)company currentPrice:(Price *)currentPrice andOpenPrice:(Price *)openPrice {
    if (self = [super init]) {
        _company = company;
        _currentPrice = currentPrice;
        _openPrice = openPrice;
        if (_currentPrice && _openPrice) {
            _historicalPrices = [self arrayWithHistoricalPrices];
        }
    }
    
    return self;
}

// Convenience initializer
- (instancetype)initWithCompany:(Company *)company currentPrice:(float)currentPriceValue atTime:(NSDate *)lastTradeTime andOpenPrice:(float)openPriceValue {
    Price *currentPrice = [[Price alloc] initWithValue:currentPriceValue andTradeTime:lastTradeTime];
    Price *openPrice = [[Price alloc] initWithValue:openPriceValue andTradeTime:nil];
    
    return [self initWithCompany:company currentPrice:currentPrice andOpenPrice:openPrice];
}

// Dummy data initializer
- (instancetype)init {
    return [self initWithCompany:[[Company alloc] init] currentPrice:[[Price alloc] init] andOpenPrice:[[Price alloc] init]];
}

#pragma mark Getters

- (float)dailyChange {
    return self.currentPrice.value - self.openPrice.value;
}

- (float)dailyChangePercent {
    return ((self.currentPrice.value == 0.0) ? 0.0 : (fabsf(self.dailyChange / self.currentPrice.value) * 100.0));
}

#pragma mark Helpers

// Generates array of 4 random prices and accurate end values (open-rand-rand-rand-rand-current)
- (NSArray *)arrayWithHistoricalPrices {
    
    // Get the lower and upper bound (20% of min/ max values)
    NSInteger minimumValue = MIN((NSInteger)roundf(self.currentPrice.value), (NSInteger)roundf(self.openPrice.value));
    NSInteger maximumValue = MAX((NSInteger)roundf(self.currentPrice.value), (NSInteger)roundf(self.openPrice.value));
    NSInteger lowerBound = minimumValue - (minimumValue * 0.2);
    NSInteger upperBound = maximumValue + (maximumValue * 0.2);
    
    // Add open price as first element in array
    NSMutableArray *mutableHistoricalPrices = [NSMutableArray arrayWithObject:self.openPrice];
    
    // Generate 4 random prices between the bounds (4 + 2 = 6 hours in a normal trading day)
    for (NSInteger i = 1; i < 6; i++) {
        NSInteger randomValue = lowerBound + arc4random_uniform((u_int32_t)upperBound - (u_int32_t)lowerBound);
        Price *price = [[Price alloc] initWithValue:randomValue andTradeTime:nil];
        [mutableHistoricalPrices addObject:price];
    }
    
    // Add current price as last element of array
    [mutableHistoricalPrices addObject:self.currentPrice];
    
    return [mutableHistoricalPrices copy];
}

@end