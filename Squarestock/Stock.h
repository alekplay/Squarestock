//
//  Stock.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Company, Price;

@interface Stock : NSObject

@property (nonatomic, strong) Company *company;
@property (nonatomic, strong) Price *currentPrice;
@property (nonatomic, strong) Price *openPrice;
@property (nonatomic, strong) NSArray *historicalPrices;
@property (nonatomic, readonly) float dailyChange;
@property (nonatomic, readonly) float dailyChangePercent;

- (instancetype)initWithCompany:(Company *)company currentPrice:(Price *)currentPrice andOpenPrice:(Price *)openPrice;
- (instancetype)initWithCompany:(Company *)company currentPrice:(float)currentPriceValue atTime:(NSDate *)lastTradeTime andOpenPrice:(float)openPriceValue;

@end