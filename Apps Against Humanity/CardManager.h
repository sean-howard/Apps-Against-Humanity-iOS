//
//  CardManager.h
//  Apps Against Humanity
//
//  Created by Sean Howard on 21/06/2015.
//  Copyright © 2015 Sean Howard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BlackCard;
@class WhiteCard;

@interface CardManager : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (CardManager*)sharedManager;
- (BOOL)packsAvailable;
- (void)populateDatabaseWithCards;
- (WhiteCard *)getWhiteCardById:(NSInteger)cardId;
- (BlackCard *)getBlackCardById:(NSInteger)cardId;
@end
