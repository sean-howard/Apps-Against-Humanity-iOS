//
//  NSString+_HTML_Markup.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 12/07/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import "NSString+_HTML_Markup.h"

@implementation NSString (_HTML_Markup)

- (NSString *)stringByConvertingBRsToNewLine
{
    return [self stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
}

@end
