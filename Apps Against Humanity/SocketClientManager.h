//
//  SocketClientManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketClientManagerDelegate <NSObject>
@optional

- (void)clientDidStartBrowsing;
- (void)clientDidFailToBroadcast;
- (void)clientDidUpdateServices:(NSArray *)services;
- (void)clientDidFinishFindingServices:(NSArray *)services;
- (void)clientDidConnectToServer;
- (void)clientDidDisconnectFromServer;

@end

@interface SocketClientManager : NSObject

- (void)startBrowsing;
- (void)stopBrowsing;
- (void)resolveService:(NSNetService *)service;

@property (nonatomic) id <SocketClientManagerDelegate>delegate;

@end
