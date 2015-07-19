//
//  SubmittedWhiteCardsTableViewController.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 10/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BlackCard;

@interface SubmittedWhiteCardsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *submissions;
@property (nonatomic, strong) BlackCard *blackCardInPlay;
@end