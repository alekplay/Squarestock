//
//  TickerManager.m
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import "TickerManager.h"

@interface TickerManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation TickerManager

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
    static TickerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)lookupTicker:(NSString *)tickerSymbol withCompletionHandler:(void (^)(NSArray *tickers, NSError *error))completionHandler {
    
    // Cancel all ongoing download tasks
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
    }];
    
    // Create the URL to be queried (Unofficial Yahoo Ticker Symbol Lookup API)
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://d.yimg.com/aq/autoc?query=%@&region=US&lang=en-US&callback=result", tickerSymbol]];
    
    // Set up and run the session (i.e. download the data)
    self.session = [NSURLSession sharedSession];
    [[self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Convert the resulting data into a string
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // Remove the callback (result(...)) part of the result
        NSRange begin = [dataString rangeOfString:@"(" options:NSLiteralSearch];
        NSRange end = [dataString rangeOfString:@")" options:NSBackwardsSearch|NSLiteralSearch];
        BOOL parseError = (begin.location == NSNotFound || end.location == NSNotFound ||end.location - begin.location < 2);
        if (!parseError) {
            NSString *jsonString = [dataString substringWithRange:NSMakeRange(begin.location + 1, (end.location - begin.location) - 1)];
            
            // Convert the resulting json into a dictionary
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            
            // Get the returned array of results
            NSArray *responseArray = json[@"ResultSet"][@"Result"];
            
            // Go through each ticker in the array and if it's an equity (stock) add it to the array
            NSMutableArray *tickersArray = [NSMutableArray array];
            for (NSDictionary *jsonTicker in responseArray) {
                if ([jsonTicker[@"typeDisp"] isEqualToString:@"Equity"]) {
                    
                    // Create ticker object
                    Ticker *ticker = [[Ticker alloc] init];
                    ticker.symbol = jsonTicker[@"symbol"];
                    ticker.name = jsonTicker[@"name"];
                    ticker.market = jsonTicker[@"exchDisp"];
                    
                    [tickersArray addObject:ticker];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Return the array of ticker objects back to the caller
                completionHandler(tickersArray, error);
            });
        }
    }] resume];
}

@end
