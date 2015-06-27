//
//  SocketServer.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SocketServer;

@protocol SocketServerDelegate <NSObject>
@optional

- (void)serverDidStartBroadcasting;
- (void)serverDidFailToBroadcast;
- (void)serverDidAcceptNewConnections:(NSArray *)connections;
- (void)serverDidLoseConnections:(NSArray *)connections;
- (void)serverDidDisconnect;

@end

@interface SocketServer : NSObject
@property (nonatomic) id<SocketServerDelegate>delegate;
- (void)startBroadcast;

@end
