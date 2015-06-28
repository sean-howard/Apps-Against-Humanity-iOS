//
//  Lobby.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lobby : NSObject
@property (nonatomic, strong) NSString *lobbyName;
@property (nonatomic, strong) NSNetService *service;
@end
