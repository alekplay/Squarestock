//
//  Price.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/28/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Price : NSObject

@property (nonatomic, readonly) float value;
@property (nonatomic, strong, readonly) NSDate *tradeTime;

- (instancetype)initWithValue:(float)value andTradeTime:(NSDate  *)tradeTime;

@end