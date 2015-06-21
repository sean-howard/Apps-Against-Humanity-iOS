//
//  Pack.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Realm/Realm.h>
#import "WhiteCard.h"
#import "BlackCard.h"

@interface Pack : RLMObject
@property NSString *packName;
@property NSInteger packId;
@property RLMArray <WhiteCard> *whiteCards;
@property RLMArray <BlackCard> *blackCards;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Pack>
RLM_ARRAY_TYPE(Pack)
