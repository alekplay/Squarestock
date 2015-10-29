//
//  StockManager.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "StockManager.h"
#import "Stock.h"
#import "Company.h"



@interface StockManager ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionDataTask *lookUpDataTask;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation StockManager

#pragma mark Init

- (instancetype)init {
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    }
    
    return self;
}

+ (instancetype)sharedManager {
    static StockManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}


#pragma mark API Calls

- (void)getCurrentDataForCompany:(Company *)company withCompletionHandler:(void (^)(Stock *stock, NSError *error))completionHandler {
    /*  Yahoo! Finance API (unofficial) parameters explained here: jarloo.com/yahoo_finance/  */
    
    // Set up the API URL to be queried
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://finance.yahoo.com/d/quotes.csv?s=%@&f=ol1t1d1", company.symbol]];
    
    [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            
            // Convert response to http response so we can see the status codes
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                
                // Parse CSV response
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSArray *dataArray = [dataString componentsSeparatedByString:@","];
                
                // Get the open and current price as floats
                float openPrice = [dataArray[0] floatValue];
                float currentPrice = [dataArray[1] floatValue];
                
                // Get the date of the last trade as NSDate object
                NSString *lastTradeTime = [dataArray[2] substringWithRange:NSMakeRange(1, [dataArray[2] length] - 2)];
                NSString *lastTradeDay = [dataArray[3] substringWithRange:NSMakeRange(1, [dataArray[3] length] - 3)];
                NSDate *lastTradeDate = [self dateForTime:lastTradeTime andDay:lastTradeDay];
                
                // Create Stock object from data returned from API Call
                Stock *stock = [[Stock alloc] initWithCompany:company currentPrice:currentPrice atTime:lastTradeDate andOpenPrice:openPrice];
                
                // Run block on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(stock, nil);
                });
            } else {
                NSLog(@"Yahoo Stock Api - Bad HTTP Request: %ld", (long)httpResponse.statusCode);
                
                NSError *customError = [self errorWithDescription:@"Bad HTTP Request"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, customError);
                });
            }
        } else {
            NSLog(@"Yahoo Stock Api - Error: %@", error.localizedDescription);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
        }
    }] resume];
}

- (void)lookupCompaniesForString:(NSString *)string withCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler {
    
    // Cancel the previous request if it is still running
    if (self.lookUpDataTask != nil && self.lookUpDataTask.state == NSURLSessionTaskStateRunning) {
        [self.lookUpDataTask cancel];
    }
    
    // The API Url to be queried
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://d.yimg.com/aq/autoc?query=%@&region=US&lang=en-US&callback=result", string]];
    
    // Assign the data task to the property
    self.lookUpDataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            
            // Convert response to http response so we can see http status code
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                
                // Convert data to string
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                // Remove callback part of string (result(...))
                NSRange begin = [dataString rangeOfString:@"(" options:NSLiteralSearch];
                NSRange end = [dataString rangeOfString:@")" options:NSBackwardsSearch|NSLiteralSearch];
                BOOL parseError = (begin.location == NSNotFound || end.location == NSNotFound || end.location - begin.location < 2);
                if (!parseError) {
                    NSString *jsonString = [dataString substringWithRange:NSMakeRange(begin.location + 1, (end.location - begin.location) - 1)];
                    
                    // Parse the json string
                    NSError *jsonError;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
                    if (!jsonError) {
                        
                        // Get the array of results
                        NSArray *resultArray = json[@"ResultSet"][@"Result"];
                        
                        // Create an array to hold all valid companies
                        NSMutableArray *companiesArray = [NSMutableArray array];
                        
                        // Go through each of the results
                        for (NSDictionary *companyDict in resultArray) {
                            
                            // Only add to array if it's an equity stock
                            if ([companyDict[@"typeDisp"] isEqualToString:@"Equity"]) {
                                Company *company = [[Company alloc] initWithSymbol:companyDict[@"symbol"] name:companyDict[@"name"] andMarket:companyDict[@"exchDisp"]];
                                [companiesArray addObject:company];
                            }
                        }
                        
                        if (companiesArray.count > 0) {
                            
                            // Execute block on main thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionHandler(companiesArray, nil);
                            });
                        } else {
                            
                            // Handle no results error
                            NSLog(@"Yahoo Lookup Api - No Results for query: %@", string);
                        }
                    } else {
                        
                        // Handle JSON conversion error
                        NSLog(@"Yahoo Lookup Api - Json Conversion Error: %@", jsonError.localizedDescription);
                    }
                } else {
                    
                    // Handle parse error
                    NSLog(@"Yahoo Lookup Api - Parse Error");
                }
            } else {
                
                // Handle HTTP bad request
                NSLog(@"Yahoo Lookup Api - Bad HTTP Request: %ld", (long)httpResponse.statusCode);
            }
        } else {
            
            // Handle Error
            NSLog(@"Yahoo Lookup Api - Error: %@", error.localizedDescription);
        }
    }];
    
    [self.lookUpDataTask resume];
}

#pragma mark Errors

- (NSError *)errorWithDescription:(NSString *)description {
    return [[NSError alloc] initWithDomain:@"me.aleksanders.Squarestock.YahooAPI.ErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
}

#pragma mark Other

// Convenience method for translating a given time and date string to NSDate object
- (NSDate *)dateForTime:(NSString *)time andDay:(NSString *)day {
    
    // Set up the NSDateFormatter if it doesn't already exist
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"MM/dd/yyyy hh:mma";
        self.dateFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    
    // Convert to date
    NSString *dateString = [NSString stringWithFormat:@"%@ %@", day, time];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
}

@end
