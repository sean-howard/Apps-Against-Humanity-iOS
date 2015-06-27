//
//  SocketClient.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketClientDelegate <NSObject>
@optional

- (void)clientDidStartBrowsing;
- (void)clientDidFailToBroadcast;
- (void)clientDidUpdateServices:(NSArray *)services;
- (void)clientDidFinishFindingServices:(NSArray *)services;
- (void)clientDidConnectToServer;
- (void)clientDidDisconnectFromServer;

@end

@interface SocketClient : NSObject

- (void)startBrowsing;
- (void)stopBrowsing;
- (void)resolveService:(NSNetService *)service;

@property (nonatomic) id <SocketClientDelegate>delegate;

@end
