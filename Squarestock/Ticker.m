//
//  Ticker.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "Ticker.h"

@implementation Ticker

#pragma mark - Init

// Designated initializer
- (instancetype)initWithSymbol:(NSString *)symbol name:(NSString *)name andMarket:(NSString *)market {
    if (self = [super init]) {
        self.symbol = symbol;
        self.name = name;
        self.market = market;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.symbol = [aDecoder decodeObjectForKey:@"TickerSymbol"];
        self.name = [aDecoder decodeObjectForKey:@"TickerName"];
        self.market = [aDecoder decodeObjectForKey:@"TickerMarket"];
        //self.open = [aDecoder decodeBoolForKey:@"TickerOpen"];
        //self.delayed = [aDecoder decodeBoolForKey:@"TickerDelayed"];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithSymbol:@"SYMBOL" name:@"Name" andMarket:@"MARKET"];
}

#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.symbol forKey:@"TickerSymbol"];
    [aCoder encodeObject:self.name forKey:@"TickerName"];
    [aCoder encodeObject:self.market forKey:@"TickerMarket"];
    //[aCoder encodeBool:self.open forKey:@"TickerOpen"];
    //[aCoder encodeBool:self.delayed forKey:@"TickerDelayed"];
}

#pragma mark Helpers

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ as %@ trading at %@>", self.name, self.symbol, self.market];
}

@end