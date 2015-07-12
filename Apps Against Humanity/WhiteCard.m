//
//  WhiteCard.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "WhiteCard.h"
#import <GTMNSStringHTMLAdditions/GTMNSString+HTML.h>

@implementation WhiteCard

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.text = [dict[@"text"] gtm_stringByUnescapingFromHTML];
        self.cardId = [dict[@"id"] integerValue];
    }
    return self;
}

- (Pack *)pack
{
    return (Pack *)[[self linkingObjectsOfClass:@"Pack" forProperty:@"whiteCards"] firstObject];
}

+ (NSString *)primaryKey {
    return @"cardId";
}

@end
