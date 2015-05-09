//
//  MessagePacket.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "MessagePacket.h"

NSString * const MessagePacketKeyData = @"data";
NSString * const MessagePacketKeyType = @"type";
NSString * const MessagePacketKeyAction = @"action";

@implementation MessagePacket

- (instancetype)initWithData:(id)data type:(MessagePacketType)type action:(MessagePacketAction)action
{
    if (self = [super init]) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:MessagePacketKeyData];
    [coder encodeInteger:self.type forKey:MessagePacketKeyType];
    [coder encodeInteger:self.action forKey:MessagePacketKeyAction];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:MessagePacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:MessagePacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:MessagePacketKeyAction]];
    }
    
    return self;
}

@end
