//
//  BlackCard.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "BlackCard.h"

@implementation BlackCard

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.text = dict[@"text"];
        self.cardId = [dict[@"id"] integerValue];
        self.pick = [dict[@"pick"] integerValue];
    }
    return self;
}

- (Pack *)pack
{
    return (Pack *)[[self linkingObjectsOfClass:@"Pack" forProperty:@"blackCards"] firstObject];
}

+ (NSString *)primaryKey {
    return @"cardId";
}

@end
