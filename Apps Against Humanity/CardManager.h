//
//  CardManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (CardManager*)sharedManager;
- (BOOL)packsAvailable;
- (void)populateDatabaseWithCards;

@end
