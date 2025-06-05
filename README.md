# React Native Manual Push Integration for iOS (Objective-C)

1. Replace the contents of the `AppcuesPush.swift` file we created on the call:
    ```swift
    import Foundation
    import appcues_react_native

    @objc public class AppcuesPush: NSObject {
        @objc public static func setPushToken(_ deviceToken: Data?) {
            appcues_react_native.Implementation.setPushToken(deviceToken)
        }

        @objc public static func didReceiveNotification(
            response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) -> Bool {
            return appcues_react_native.Implementation.didReceiveNotification(response: response, completionHandler: completionHandler)
        }
    }
    ```

2. Update your `AppDelegate.mm` file. Make sure to remove any previous function calls to `AppcuesPush` that we may have tested on the call:
    1. Ensure the Swift interfaces are still being imported: `#import "SLL-Swift.h"`
    2. Update the implementation of `- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken`. Add the following line at the top of the function:
        ```objc
        [AppcuesPush setPushToken:deviceToken];
        ```
    3. Update the implementation of `- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler`. Add the following lines at the top of the function:
        ```objc
        if ([AppcuesPush didReceiveNotificationWithResponse:response withCompletionHandler:completionHandler]) {
            // If Appcues handles it, return early
            return;
        }
        ```
    4. Ensure `- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler` is configured to show notifications when the app is in the foreground:
        ```objc
        // Decide if and how the notification will be shown to the user
        if (@available(iOS 14.0, *)) {
            completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList);  // iOS 14+
        } else {
            completionHandler(UNNotificationPresentationOptionAlert);  // Older iOS versions
        }
        ```

## Full Sample Code

https://github.com/mmaatttt/rn-appcues-push-objc
Commit with the specific changes: https://github.com/mmaatttt/rn-appcues-push-objc/commit/b9f10c93338fe6affc59487492e37bca5ba045ab

`AppcuesPush.swift`
```swift
import Foundation
import appcues_react_native

@objc public class AppcuesPush: NSObject {
  @objc public static func setPushToken(_ deviceToken: Data?) {
    appcues_react_native.Implementation.setPushToken(deviceToken)
  }

  @objc public static func didReceiveNotification(
    response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) -> Bool {
    return appcues_react_native.Implementation.didReceiveNotification(response: response, completionHandler: completionHandler)
  }
}
```

`AppDelegate.mm`
```objc
#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <UserNotifications/UserNotifications.h>
// STEP 2.1
#import "SLL-Swift.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"SLL";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  [application registerForRemoteNotifications];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self bundleURL];
}

- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // STEP 2.2
    [AppcuesPush setPushToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"%@", error.description);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {

  // STEP 2.3
  if ([AppcuesPush didReceiveNotificationWithResponse:response withCompletionHandler:completionHandler]) {
    // If Appcues handles it, return early
    return;
  }

    completionHandler();  // If not handled by Appcues, complete the handler
}

// Called when a notification is delivered to a foreground app.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
  // STEP 2.4
  // Decide if and how the notification will be shown to the user
  if (@available(iOS 14.0, *)) {
      completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList);  // iOS 14+
  } else {
      completionHandler(UNNotificationPresentationOptionAlert);  // Older iOS versions
  }
}

@end

```