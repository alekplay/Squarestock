//
//  Company.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "Company.h"

@implementation Company

#pragma mark - Init

// Designated initializer
- (instancetype)initWithSymbol:(NSString *)symbol name:(NSString *)name andMarket:(NSString *)market {
    if (self = [super init]) {
        _symbol = symbol;
        _name = name;
        _market = market;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _symbol = [aDecoder decodeObjectForKey:@"CompanySymbol"];
        _name = [aDecoder decodeObjectForKey:@"CompanyName"];
        _market = [aDecoder decodeObjectForKey:@"CompanyMarket"];
    }
    
    return self;
}

// Dummy data initializer
- (instancetype)init {
    return [self initWithSymbol:@"SYMBOL" name:@"Name" andMarket:@"MARKET"];
}

#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.symbol forKey:@"CompanySymbol"];
    [aCoder encodeObject:self.name forKey:@"CompanyName"];
    [aCoder encodeObject:self.market forKey:@"CompanyMarket"];
}

#pragma mark Helpers

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ as %@ trading at %@>", self.name, self.symbol, self.market];
}

@end