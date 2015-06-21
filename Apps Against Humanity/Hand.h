//
//  Hand.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Pack;

@interface Hand : NSObject

@property (nonatomic, strong) NSMutableArray *whiteCards;
@property (nonatomic, strong, readonly, getter=asCardIds) NSArray *cardIds;

- (instancetype)initWithCount:(int)count;
- (instancetype)initWithCount:(int)count fromPack:(Pack *)pack;
- (instancetype)initWithCardIds:(NSArray *)cardIds;

@end
