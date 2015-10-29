//
//  SearchViewController.h
//  Squarestock
//
//  Created by Aleksander Skjoelsvik on 10/27/15.
//  Copyright © 2015 Aleksander Skjoelsvik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Company, SearchViewController;

@protocol SearchViewControllerDelegate <NSObject>

- (void)searchViewController:(SearchViewController *)searchViewController didFinishSearchingForCompany:(Company *)company;
- (void)searchViewControllerDidCancel:(SearchViewController *)searchViewController;

@end

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SearchViewControllerDelegate> delegate;
@property (nonatomic, strong) Company *currentCompany;

@end
