//
//  Hand.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "Hand.h"
#import "Pack.h"
#import "CardManager.h"
#import <NSMutableArray-Shuffle/NSMutableArray+Shuffle.h>

@implementation Hand

- (instancetype)initWithCount:(int)count
{
    return [self initWithCount:count fromPack:nil];
}

- (instancetype)initWithCount:(int)count fromPack:(Pack *)pack
{
    if (self = [super init]) {
        _whiteCards = [[[CardManager sharedManager] getRandomSetOfWhiteCardsFromPack:pack limitedTo:count] mutableCopy];
    }
    return self;
}

- (instancetype)initWithCardIds:(NSArray *)cardIds
{
    if (self = [super init]) {
        _whiteCards = [[[CardManager sharedManager] getCardsFromIds:cardIds] mutableCopy];
    }
    return self;
}

#pragma mark - Convenience Methods
- (NSArray *)asCardIds
{
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (WhiteCard *whiteCard in self.whiteCards) {
        [tempArray addObject:@(whiteCard.cardId)];
    }
    return (NSArray *)tempArray;
}

#pragma mark - Lazy Inits
- (NSMutableArray *)whiteCards
{
    if (!_whiteCards) {
        _whiteCards = [NSMutableArray new];
    }
    return _whiteCards;
}

- (void)shuffle
{
    [self.whiteCards shuffle];
}

@end
