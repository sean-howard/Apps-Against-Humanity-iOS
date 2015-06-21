//
//  CardManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BlackCard;
@class WhiteCard;
@class Pack;
@class Hand;

@interface CardManager : NSObject

@property (nonatomic, strong) Pack *packInPlay;

/**
 * gets singleton object.
 * @return singleton
 */
+ (CardManager*)sharedManager;
- (BOOL)packsAvailable;
- (void)populateDatabaseWithCards;

- (WhiteCard *)whiteCardWithId:(NSInteger)cardId;
- (BlackCard *)blackCardWithId:(NSInteger)cardId;

- (WhiteCard *)randomWhiteCardFromPack:(Pack *)pack;
- (BlackCard *)randomBlackCardFromPack:(Pack *)pack;

- (NSArray *)getRandomSetOfWhiteCardsFromPack:(Pack *)pack limitedTo:(int)limit;
- (NSArray *)getCardsFromIds:(NSArray *)cardIds;

@end
