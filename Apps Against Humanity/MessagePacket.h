//
//  MessagePacket.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagePacket : NSObject

extern NSString * const MessagePacketKeyData;
extern NSString * const MessagePacketKeyType;
extern NSString * const MessagePacketKeyAction;

typedef enum : NSInteger
{
    MessagePacketTypeUnknown = -1
} MessagePacketType;

typedef enum : NSInteger
{
    MessagePacketActionUnknown = -1,
    MessagePacketActionJoiningLobby = 0,
    MessagePacketActionStartGame
} MessagePacketAction;

@property (nonatomic, strong) id data;
@property (nonatomic, assign) MessagePacketType type;
@property (nonatomic, assign) MessagePacketAction action;

#pragma mark -
#pragma mark Initialization
- (instancetype)initWithData:(id)data type:(MessagePacketType)type action:(MessagePacketAction)action;

@end
