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

#import <Parse/Parse.h>

@class PDDSlot, PDDRoom;

typedef enum {
    kPDDTalkSectionByTime = 0,
    kPDDTalkSectionByTrack = 1,
    kPDDTalkSectionByNone = 2
} PDDTalkSectionType;

@interface PDDTalk : PFObject<PFSubclassing>
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *abstract;
@property (nonatomic) BOOL alwaysFavorite;
@property (strong, nonatomic) NSArray *speakers;
@property (strong, nonatomic) PDDSlot *slot;
@property (strong, nonatomic) PDDRoom *room;
@property (strong, nonatomic) PFFile *icon;
@property (nonatomic) BOOL isBreak;
@property (nonatomic) BOOL allDay;
@property (strong, nonatomic) NSString *videoID;

+ (NSString *)stringTime:(NSDate *)startTime;
- (NSString *)talkTime;
- (void)toggleFavorite:(BOOL)isFavorite;
- (BOOL)isFavorite;
@end
