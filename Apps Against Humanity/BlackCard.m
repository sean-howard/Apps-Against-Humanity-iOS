//
//  BlackCard.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "BlackCard.h"
#import <GTMNSStringHTMLAdditions/GTMNSString+HTML.h>
#import "NSString+_HTML_Markup.h"

@implementation BlackCard

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.text = [[dict[@"text"] stringByConvertingBRsToNewLine] gtm_stringByUnescapingFromHTML];
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
