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
extern NSString * const MessagePacketKeyAction;

typedef enum : NSInteger
{
    MessagePacketActionUnknown = -1,
    MessagePacketActionJoiningLobby = 0,
    MessagePacketActionStartGameSession,
    MessagePacketActionStartGameMatch,
    MessagePacketActionSelectBlackCardPlayer,
    MessagePacketActionDistributeWhiteCards,
    MessagePacketActionDisplayBlackQuestionCard,
    MessagePacketActionSubmitWhiteCards,
    MessagePacketActionAllCardsSubmitted,
    MessagePacketActionChooseWinner
} MessagePacketAction;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) MessagePacketAction action;

#pragma mark -
#pragma mark Initialization
- (instancetype)initWithRawData:(id)message;
- (instancetype)initWithData:(NSDictionary *)data action:(MessagePacketAction)action;
- (NSString *)asString;
- (NSDictionary *)serialise;

@end
