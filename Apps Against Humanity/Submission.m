//
//  Submission.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 10/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "Submission.h"
#import "Player.h"
#import "WhiteCard.h"

@implementation Submission
- (NSDictionary *)serialise
{
    return @{@"uniqueID":self.player.uuid,
             @"whiteCardIDs":[self whiteCardIDs]};
}

- (NSArray *)whiteCardIDs
{
    NSMutableArray *tempArray = [NSMutableArray new];
    for (WhiteCard *whiteCard in self.whiteCards) {
        [tempArray addObject:@(whiteCard.cardId)];
    }
    return tempArray;
}

@end
