//
//  Price.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/28/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "Price.h"

@implementation Price

// Designated initializer
- (instancetype)initWithValue:(float)value andTradeTime:(NSDate *)tradeTime {
    if (self = [super init]) {
        _value = value;
        _tradeTime = tradeTime;
    }
    
    return self;
}

// Dummy data initializer
- (instancetype)init {
    return [self initWithValue:0.0 andTradeTime:[NSDate date]];
}

@end