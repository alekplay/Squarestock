//
//  Ticker.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ticker : NSObject <NSCoding>

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *market;

/* TO BE IMPLEMENTED
@property (nonatomic)         BOOL     open;
@property (nonatomic)         BOOL     delayed;
*/

- (instancetype)initWithSymbol:(NSString *)symbol name:(NSString *)name andMarket:(NSString *)market;

@end
