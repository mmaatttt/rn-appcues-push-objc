//
//  AppcuesPush.swift
//  AwesomeProject
//
//  Created by Matt on 2025-06-05.
//

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
