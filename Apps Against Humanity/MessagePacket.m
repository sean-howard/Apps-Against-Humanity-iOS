//
//  MessagePacket.m
//  Apps Against Humanity
//
//  Created by Sean Howard on 09/05/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import "MessagePacket.h"

NSString * const MessagePacketKeyData = @"data";
NSString * const MessagePacketKeyAction = @"action";


@implementation MessagePacket

- (instancetype)initWithData:(id)data action:(MessagePacketAction)action
{
    if (self = [super init]) {
        self.data = data;
        self.action = action;
    }
    return self;
}

- (instancetype)initWithRawData:(id)message
{
    if (self = [super init]) {
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
        self.action = [json[MessagePacketKeyAction] integerValue];
        self.data = json[MessagePacketKeyData];
    }
    return self;
}

- (NSString *)asString
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self serialise] options:0 error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)serialise
{
  return @{MessagePacketKeyAction:@(self.action),
           MessagePacketKeyData:self.data};
}

@end
