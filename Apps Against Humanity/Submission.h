//
//  Submission.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 10/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
@class WhiteCard;

@interface Submission : NSObject
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) NSArray *whiteCards;

- (NSDictionary *)serialise;

@end
