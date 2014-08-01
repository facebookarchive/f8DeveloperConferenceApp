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

#import "PDDTalk.h"
#import "PDDSlot.h"
#import "PDDRoom.h"
#import "PDDSpeaker.h"
#import "PDDConstants.h"

#import <Parse/PFObject+Subclass.h>

@implementation PDDTalk

@dynamic title;
@dynamic abstract;
@dynamic alwaysFavorite;
@dynamic speakers;
@dynamic slot;
@dynamic room;
@dynamic icon;
@dynamic isBreak;
@dynamic allDay;
@dynamic videoID;

+ (NSString *)parseClassName {
    return @"Talk";
}

+ (NSString *)stringTime:(NSDate *)startTime {
    return [[[self class] _dateFormatter] stringFromDate:startTime];
}

- (NSString *)talkTime {
    return [[self class] stringTime:self.slot.startTime];
}

- (void)toggleFavorite:(BOOL)isFavorite {
    if (![PFUser currentUser]) {
        return;
    }
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsFavoriteKey];
    BOOL contains = [self isFavorite];

    if (!(contains ^ isFavorite)) {
        return; // status quo is fine, the UI shouldn't have allowed this case in the first place
    }

    NSNotification *notification;
    if (isFavorite) {
        if (favorites == nil) {
            favorites = @[ self.objectId ];
        } else {
            favorites = [favorites arrayByAddingObject:self.objectId];
        }
        PFRelation *favoritesRelation = [[PFUser currentUser] relationForKey:@"favoriteTalks"];
        [favoritesRelation addObject:self];
        [[PFUser currentUser] saveEventually];
        notification = [NSNotification notificationWithName:PDDTalkFavoriteTalkAddedNotification object:self];
    } else {
        favorites = [favorites filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *objectId, NSDictionary *bindings) {
            return ![objectId isEqualToString:self.objectId];
        }]];
        PFRelation *favoritesRelation = [[PFUser currentUser] relationForKey:@"favoriteTalks"];
        [favoritesRelation removeObject:self];
        [[PFUser currentUser] saveEventually];
        notification = [NSNotification notificationWithName:PDDTalkFavoriteTalkRemovedNotification object:self];
    }
    [[NSUserDefaults standardUserDefaults] setObject:favorites forKey:kDefaultsFavoriteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (BOOL)isFavorite {
    NSSet *favorites = [NSSet setWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsFavoriteKey]];
    return [favorites containsObject:self.objectId];
}

- (NSString *)description {
    return self.title;
}

#pragma mark - Private methods
+ (NSDateFormatter *)_dateFormatter {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a"];
    }
    return formatter;
}

@end
