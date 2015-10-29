//
//  StockManager.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stock, Company;

@interface StockManager : NSObject

+ (instancetype)sharedManager;

- (void)getCurrentDataForCompany:(Company *)company withCompletionHandler:(void (^)(Stock *stock, NSError *error))completionHandler;
- (void)lookupCompaniesForString:(NSString *)string withCompletionHandler:(void (^)(NSArray *companies, NSError *error))completionHandler;

@end