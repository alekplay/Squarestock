//
//  Company.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject <NSCoding>

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *market;

- (instancetype)initWithSymbol:(NSString *)symbol name:(NSString *)name andMarket:(NSString *)market;

@end
