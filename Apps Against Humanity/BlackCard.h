//
//  BlackCard.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Realm/Realm.h>

@class Pack;
@interface BlackCard : RLMObject

@property NSString *text;
@property NSInteger pick;
@property NSInteger cardId;
@property (readonly) Pack *pack;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<BlackCard>
RLM_ARRAY_TYPE(BlackCard)
