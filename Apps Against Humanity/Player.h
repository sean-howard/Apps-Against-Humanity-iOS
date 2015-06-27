//
//  Player.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 27/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@interface Player : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) SRWebSocket *socket;

- (NSDictionary *)serialise;

@end