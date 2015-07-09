//
//  Player.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 27/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "Player.h"

@implementation Player
- (NSDictionary *)serialise
{
    return @{@"playerName":self.name,
             @"uniqueID":self.uuid};
}
@end
