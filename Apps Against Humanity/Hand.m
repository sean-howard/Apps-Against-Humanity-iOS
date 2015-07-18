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

@interface Hand ()
@property (nonatomic) int handSize;
@end

@implementation Hand

- (instancetype)initWithCount:(int)count
{
    return [self initWithCount:count fromPack:nil];
}

- (instancetype)initWithCount:(int)count fromPack:(Pack *)pack
{
    if (self = [super init]) {
        _whiteCards = [[[CardManager sharedManager] getRandomSetOfWhiteCardsFromPack:pack limitedTo:count] mutableCopy];
        _handSize = count;
    }
    return self;
}

- (instancetype)initWithCardIds:(NSArray *)cardIds
{
    if (self = [super init]) {
        _whiteCards = [[[CardManager sharedManager] getCardsFromIds:cardIds] mutableCopy];
        _handSize = (int)cardIds.count;
    }
    return self;
}

- (instancetype)initWithCards:(NSArray *)cards
{
    if (self = [super init]) {
        _whiteCards = [cards mutableCopy];
        _handSize = (int)cards.count;
    }
    return self;
}

- (void)topUpHand
{
    if ((int)self.whiteCards.count < self.handSize) {
        int cardsRequired = self.handSize - (int)self.whiteCards.count;
        
        NSMutableArray *topUpCards = [NSMutableArray new];
        
        for (int i = 0; i < cardsRequired; i++) {
            WhiteCard *whiteCard = [[CardManager sharedManager] randomWhiteCardFromLocalStore];
            [topUpCards addObject:whiteCard];
        }
        
        NSLog(@"topUpCards: %@", topUpCards);
        
        [[[CardManager sharedManager] localCardStore] removeObjectsInArray:topUpCards];
        [self.whiteCards addObjectsFromArray:topUpCards];
        
        NSLog(@"whiteCards: %@", self.whiteCards);
    }
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
