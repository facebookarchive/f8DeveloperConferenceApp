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

#import "PDDAppDelegate.h"

#import "PDDTabBarController.h"
#import "PDDMyScheduleViewController.h"
#import "PDDScheduleViewController.h"
#import "PDDWelcomeViewController.h"
#import "PDDLoginViewController.h"
#import "PDDMapListViewController.h"
#import "PDDAlertsViewController.h"

#import "PDDTalk.h"
#import "PDDSpeaker.h"
#import "PDDRoom.h"
#import "PDDSlot.h"
#import "PDDMessage.h"
#import "PDDGeneralInfo.h"

#import "PDDConstants.h"

#import "UIColor+PDD.h"

#import <Parse/Parse.h>

@interface PDDAppDelegate () <PFLogInViewControllerDelegate, UITabBarControllerDelegate>
- (void)_customizeAppearance;
- (void)_scheduleLocalNotification:(NSNotification *)notification;
- (void)_unscheduleLocalNotification:(NSNotification *)notification;
- (UILocalNotification *)_localNotificationForTalk:(PDDTalk *)talk;
@property (strong, nonatomic) PDDLoginViewController *loginViewController;
@property (strong, nonatomic) PDDAlertsViewController *alertsViewController;
@property (strong, nonatomic) PDDScheduleViewController *scheduleViewController;
@property (strong, nonatomic) UIViewController *savedViewController;
@end

@implementation PDDAppDelegate

#pragma mark - UIApplicationDelegate methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PDDTalk registerSubclass];
    [PDDSpeaker registerSubclass];
    [PDDRoom registerSubclass];
    [PDDSlot registerSubclass];
    [PDDMessage registerSubclass];
    [PDDGeneralInfo registerSubclass];
    [Parse setApplicationId:@"YOUR_APP_ID"
                  clientKey:@"YOUR_CLIENT_KEY"];
    [PFFacebookUtils initializeFacebook];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    PDDScheduleViewController *scheduleViewController = [[PDDScheduleViewController alloc] init];
    self.scheduleViewController = scheduleViewController;
    self.savedViewController = scheduleViewController;
    
    UIViewController *myScheduleViewController = [[PDDMyScheduleViewController alloc] init];
    
    UIViewController *mapViewController = [[PDDMapListViewController alloc] init];
    
    PDDAlertsViewController *alertsViewController = [[PDDAlertsViewController alloc] init];
    self.alertsViewController = alertsViewController;
    [alertsViewController populateDataWithCompletionHandler:nil];
    
    UINavigationController *scheduleNavViewController = [[UINavigationController alloc] initWithRootViewController:scheduleViewController];
    [scheduleNavViewController.navigationBar setTranslucent:NO];
    
    UINavigationController *myScheduleNavViewController = [[UINavigationController alloc] initWithRootViewController:myScheduleViewController];
    [myScheduleNavViewController.navigationBar setTranslucent:NO];
    
    UINavigationController *mapNavViewController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    [mapNavViewController.navigationBar setTranslucent:NO];
    
    UINavigationController *alertsNavViewController = [[UINavigationController alloc] initWithRootViewController:alertsViewController];
    [alertsNavViewController.navigationBar setTranslucent:NO];

    self.tabBarController = [[PDDTabBarController alloc] init];
    self.tabBarController.viewControllers = @[ scheduleNavViewController,
                                               myScheduleNavViewController,
                                               alertsNavViewController,
                                               mapNavViewController ];
    self.tabBarController.delegate = self;
    [self.tabBarController.tabBar setTranslucent:NO];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_scheduleLocalNotification:)
                                                 name:PDDTalkFavoriteTalkAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_unscheduleLocalNotification:)
                                                 name:PDDTalkFavoriteTalkRemovedNotification
                                               object:nil];

    [self _customizeAppearance];
    
    if (![PFUser currentUser]) {
        [self _showLogin:NO];
    }

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Clears fired notifications from the Notification Center
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    // Facebook Login support
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    if (application.applicationState != UIApplicationStateActive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    // Go to the alerts view controller
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
}

// ****************************************************************************
// App switching methods to support Facebook Login
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // Fetch messages in the background
    [self.alertsViewController populateDataWithCompletionHandler:completionHandler];
}

#pragma mark - PFLoginViewDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // Register for remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    // Save profile information, if needed
    if ([user isNew]) {
        [self _saveFacebookProfile];
    } else {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITabBarControllerDelegate methods
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // Go to the welcome page if previously in the schedule track
    UINavigationController *navController = (UINavigationController *)viewController;
    UIViewController *visibleViewController = [navController visibleViewController];
    if ([visibleViewController isKindOfClass:[PDDScheduleViewController class]] &&
        [self.savedViewController isKindOfClass:[PDDScheduleViewController class]]) {
        [self.scheduleViewController goToTrack:0];
    }
    // Save currently visible view controller for follow-on checks
    self.savedViewController = visibleViewController;
}

#pragma mark - Public methods
- (void)logout {
    [PFUser logOut];
    [self _showLogin:YES];
    // Back to welcome
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

#pragma mark - Private methods
- (void)_showLogin:(BOOL)animated {
    if (nil == self.loginViewController) {
        PDDLoginViewController *loginViewController = [[PDDLoginViewController alloc] init];
        loginViewController.delegate = self;
        _loginViewController = loginViewController;
    }
    [self.tabBarController presentViewController:self.loginViewController animated:animated completion:nil];
}

- (void)_customizeAppearance {
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor pddTextColor]];
    [[UIPageControl appearance] setBackgroundColor:[UIColor clearColor]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor pddTextColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
}

- (void)_scheduleLocalNotification:(NSNotification *)notification {
    PDDTalk *talk = (PDDTalk *)notification.object;
    if ([self _localNotificationForTalk:talk]) {
        // We should never be double-scheduling local notifications, but just in
        // case one already exists for this talk,
        return;
    }

    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-7 * 60 * 60]; // PDT is GMT-700
    notif.alertAction = @"OK";
    notif.alertBody = [NSString stringWithFormat:@"%@ starting in 5 minutes in %@!", talk.title, talk.room.name];
    notif.userInfo = @{ PDDTalkObjectIdKey: talk.objectId };
    notif.fireDate = [talk.slot.startTime dateByAddingTimeInterval:-5 * 60];
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (void)_unscheduleLocalNotification:(NSNotification *)notification {
    PDDTalk *talk = (PDDTalk *)notification.object;
    UILocalNotification *notif = [self _localNotificationForTalk:talk];
    if (notif) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
}

- (UILocalNotification *)_localNotificationForTalk:(PDDTalk *)talk {
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSInteger idx = [notifs indexOfObjectPassingTest:^BOOL(NSNotification *not, NSUInteger idx, BOOL *stop) {
        return [[not.userInfo objectForKey:PDDTalkObjectIdKey] isEqualToString:talk.objectId];
    }];
    if (idx == NSNotFound) {
        return nil;
    }
    return [notifs objectAtIndex:idx];
}

- (void)_saveFacebookProfile {
    [FBRequestConnection startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             [PFUser currentUser][@"firstName"] = user.first_name;
             [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
             }];
         } else {
             [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
         }
    }];
}

@end
