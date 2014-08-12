/**
 * Copyright 2014 Facebook, Inc.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to
 * use, copy, modify, and distribute this software in source code or binary
 * form for use in connection with the web services and APIs provided by
 * Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use
 * of this software is subject to the Facebook Developer Principles and
 * Policies [http://developers.facebook.com/policy/]. This copyright notice
 * shall be included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

#import "PDDUtils.h"

#import "PDDTalk.h"
#import "PDDSlot.h"
#import "PDDRoom.h"
#import "PDDGeneralInfo.h"
#import "PDDConstants.h"

@implementation PDDUtils

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)findAllTalksInBackgroundWithBlock:(PFArrayResultBlock)resultBlock {
    PFQuery *query = [PDDTalk query];
    [query includeKey:@"room"];
    [query includeKey:@"slot"];
    [query includeKey:@"speakers"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *talks, NSError *error) {
        resultBlock([[self class] sortedTalkArray:talks], error);
    }];
}

- (void) findFavoriteTalksInBackgroundWithBlock:(PFArrayResultBlock)resultBlock {
    if (![PFUser currentUser]) {
        resultBlock(@[], nil);
        return;
    }
    
    __block NSMutableArray *alwaysFavoriteTalks = [@[] mutableCopy];
    __block NSMutableArray *userFavoriteTalks = [@[] mutableCopy];
    
    PFQuery *queryAlwaysFavorite = [PDDTalk query];
    [queryAlwaysFavorite whereKey:@"alwaysFavorite" equalTo:@(YES)];
    [queryAlwaysFavorite includeKey:@"room"];
    [queryAlwaysFavorite includeKey:@"slot"];
    [queryAlwaysFavorite includeKey:@"speakers"];
    [queryAlwaysFavorite setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryAlwaysFavorite findObjectsInBackgroundWithBlock:^(NSArray *talks, NSError *error) {
        if (!error) {
            if (talks != nil && [talks count] > 0) {
                alwaysFavoriteTalks = [NSMutableArray arrayWithArray:talks];
            }
            PFQuery *query = [[[PFUser currentUser] relationForKey:@"favoriteTalks"] query];
            [query includeKey:@"room"];
            [query includeKey:@"slot"];
            [query includeKey:@"speakers"];
            [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
            [query findObjectsInBackgroundWithBlock:^(NSArray *talks, NSError *error) {
                if (!error) {
                    if (talks != nil && [talks count] > 0) {
                        userFavoriteTalks = [NSMutableArray arrayWithArray:talks];
                        NSMutableArray *talkIds = [@[] mutableCopy];
                        for (PFObject *talk in userFavoriteTalks) {
                            [talkIds addObject:talk.objectId];
                        }
                        // Update local storage of user favorites
                        [[NSUserDefaults standardUserDefaults] setObject:talkIds forKey:kDefaultsFavoriteKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                NSArray *favoriteTalks = [alwaysFavoriteTalks arrayByAddingObjectsFromArray:userFavoriteTalks];
                resultBlock([[self class] sortedTalkArray:favoriteTalks], error);
            }];
        } else {
            resultBlock(@[], error);
        }
    }];
}

+ (NSArray *)sortedTalkArray:(NSArray *)talks {
    return [talks sortedArrayUsingComparator:[[self class] _orderByTimeThenRoomComparator]];
}

+ (NSComparator)_orderByTimeThenRoomComparator {
    return ^NSComparisonResult(PDDTalk *talk1, PDDTalk *talk2) {
        NSComparisonResult timeResult = [talk1.slot.startTime compare:talk2.slot.startTime];
        if (timeResult != NSOrderedSame) {
            return timeResult;
        }
        return [talk1.room.order compare:talk2.room.order];
    };
}

- (void) findAlertsInBackgroundWithBlock:(PFArrayResultBlock)resultBlock {
    if (![PFUser currentUser]) {
        resultBlock(@[], nil);
        return;
    }
    
    __block NSMutableArray *userAlerts = [@[] mutableCopy];
    PFQuery *query = [[[PFUser currentUser] relationForKey:@"messages"] query];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *alerts, NSError *error) {
        if (!error) {
            if (alerts != nil && [alerts count] > 0) {
                userAlerts = [NSMutableArray arrayWithArray:alerts];
            }
        }
        resultBlock(userAlerts, error);
    }];
}

- (void) findInfoInBackgroundWithBlock:(PFObjectResultBlock)resultBlock {
    __block PDDGeneralInfo *info = nil;
    PFQuery *query = [PDDGeneralInfo query];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            info = (PDDGeneralInfo *) object;
        }
        resultBlock(info, error);
    }];
}


@end
