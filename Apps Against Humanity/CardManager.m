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
        return YES;
    }
    return NO;
}

- (void)populateDatabaseWithCards
{
    NSDictionary *cards = [self cardJson];
    
    NSString *packName = cards[@"pack"][@"name"];
    NSArray *whiteCards = cards[@"pack"][@"whiteCards"];
    NSArray *blackCards = cards[@"pack"][@"blackCards"];
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    
    Pack *pack = [Pack new];
    pack.packId = 1;
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

@end
