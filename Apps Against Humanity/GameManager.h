//
//  GameManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 28/06/2015.
//  Copyright (c) 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (GameManager*)sharedManager;

@end
