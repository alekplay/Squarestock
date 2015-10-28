//
//  StockManager.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "StockManager.h"

@interface StockManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation StockManager

/* TO DO:
 1. Handle Errors
 */

#pragma MARK: Initialization

- (instancetype)init {
    if (self = [super init]) {
        self.session = [NSURLSession sharedSession];
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

#pragma mark - 

- (void)getCurrentDataForTicker:(Ticker *)ticker withCompletionHandler:(void (^)(Stock *stock, NSError *error))completionHandler {
    
    // Using the (unofficial) Yahoo JSON API
    /*NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://finance.yahoo.com/webservice/v1/symbols/%@/quote?format=json", ticker.symbol]];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *dictionary = json[@"list"][@"resources"][0][@"resource"][@"fields"];
        Stock *stock = [[Stock alloc] initWithDictionary:dictionary andTicker:ticker];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(stock, nil);
        });
    }] resume];*/
    
    // Cancel all ongoing download tasks
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
    }];
    
    // Query the (unofficial) Yahoo Finance API for information regarding the currently selected ticker
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://finance.yahoo.com/d/quotes.csv?s=%@&f=ol1t1d1d2", ticker.symbol]];
    [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // The result is in CSV format, so convert it to string and separate it by ','
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *dataArray = [dataString componentsSeparatedByString:@","];
            
            // Get the stock prices and convert to float
            float openPrice = [dataArray[0] floatValue];
            float stockPrice = [dataArray[1] floatValue];
            // Get the trade time and date (which are strings), remove the extra quotes on each side, and concat
            NSString *tradeTime = [dataArray[2] substringWithRange:NSMakeRange(1, [dataArray[2] length] - 2)];
            NSString *tradeDate = [dataArray[3] substringWithRange:NSMakeRange(1, [dataArray[3] length] - 2)];
            NSString *dateString = [NSString stringWithFormat:@"%@ %@", tradeDate, tradeTime];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/dd/yyyy hh:mma";
            dateFormatter.timeZone = [NSTimeZone localTimeZone];
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            // Create a new stock object and return to the caller
            Stock *stock = [[Stock alloc] initWithTicker:ticker currentPrice:stockPrice time:date andOpen:openPrice];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(stock, nil);
            });
        } else {
            completionHandler(nil, error);
        }
    }] resume];
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
}

@end
