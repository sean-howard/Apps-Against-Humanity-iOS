//
//  CardManager.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "CardManager.h"
#import <Realm/Realm.h>
#import "Pack.h"
#import "WhiteCard.h"
#import "BlackCard.h"
#import "Hand.h"

@implementation CardManager

static CardManager *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

- (id)copy
{
    return [[CardManager alloc] init];
}

- (id)mutableCopy
{
    return [[CardManager alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}

#pragma mark - JSON to Realm if required
- (BOOL)packsAvailable
{
    RLMResults *packResults = [Pack allObjects];
    if ([packResults firstObject]) {
        self.packInPlay = (Pack *)[packResults firstObject];
        return YES;
    }
    return NO;
}

#pragma mark - Population and setup
- (void)populateDatabaseWithCards
{
    NSDictionary *cards = [self cardJson];
    
    NSString *packName = cards[@"pack"][@"name"];
    NSArray *whiteCards = cards[@"pack"][@"whiteCards"];
    NSArray *blackCards = cards[@"pack"][@"blackCards"];
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    
    Pack *pack = [Pack new];
    pack.packName = packName;
    
    for (NSDictionary *dict in whiteCards) {
        WhiteCard *whiteCard = [[WhiteCard alloc] initWithDictionary:dict];
        [WhiteCard createOrUpdateInDefaultRealmWithValue:whiteCard];
        [pack.whiteCards addObject:whiteCard];
    }
    
    for (NSDictionary *dict in blackCards) {
        BlackCard *blackCard = [[BlackCard alloc] initWithDictionary:dict];
        [BlackCard createOrUpdateInDefaultRealmWithValue:blackCard];
        [pack.blackCards addObject:blackCard];
    }
    
    [Pack createOrUpdateInDefaultRealmWithValue:pack];
    [[RLMRealm defaultRealm] commitWriteTransaction];
}

- (NSDictionary *)cardJson
{
    NSString *cardsPath = [[NSBundle mainBundle] pathForResource:@"cards" ofType:@"json"];
    
    NSData *cardData = [NSData dataWithContentsOfFile:cardsPath];
    
    NSError *error = nil;
    NSDictionary *cardsJson = [NSJSONSerialization JSONObjectWithData:cardData options:0 error:&error];
    if (error) {
        NSLog(@"%@ %@", error.localizedDescription, error.description);
        return nil;
    }
    
    return cardsJson;
}

#pragma mark - Single Card By cardId
- (WhiteCard *)whiteCardWithId:(NSInteger)cardId
{
    return [WhiteCard objectForPrimaryKey:@(cardId)];
}

- (BlackCard *)blackCardWithId:(NSInteger)cardId
{
    return [BlackCard objectForPrimaryKey:@(cardId)];
}

#pragma mark - Cards From Ids
- (NSArray *)getCardsFromIds:(NSArray *)cardIds
{
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (NSNumber *cardId in cardIds) {
        [tempArray addObject:[self whiteCardWithId:[cardId integerValue]]];
    }
    return tempArray;
}

#pragma mark - Random Cards
- (BlackCard *)randomBlackCardFromPack:(Pack *)pack
{
    if (!pack) {
        pack = self.packInPlay;
    }
    
    return pack.blackCards[arc4random() % [pack.blackCards count]];
}

- (WhiteCard *)randomWhiteCardFromPack:(Pack *)pack
{
    if (!pack) {
        pack = self.packInPlay;
    }
    
    return pack.whiteCards[arc4random() % [pack.whiteCards count]];
}

#pragma mark - Random Sets
- (NSArray *)getRandomSetOfWhiteCardsFromPack:(Pack *)pack limitedTo:(int)limit
{
    NSMutableArray *cards = [NSMutableArray new];
    WhiteCard *whiteCard;
    
    for (int i = 0; i < limit; i++) {
        do {
            whiteCard = [self randomWhiteCardFromPack:pack];
        } while ([cards containsObject:whiteCard]);
    
        [cards addObject:whiteCard];
    }
    return (NSArray *)cards;
}

@end
