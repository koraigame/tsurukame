// Copyright 2021 David Sansome
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreSpotlight
import Foundation
#if canImport(Intents)
import Intents
#endif
import MobileCoreServices

class SiriShortcutHelper: NSObject {
  enum ShortcutType: String {
    case reviews = "com.tsurukame.reviews"
    case lessons = "com.tsurukame.lessons"
  }

  public static let shared = SiriShortcutHelper()

  func attachShortcutActivity(_ vc: UIViewController, type: ShortcutType) {
    if #available(iOS 12.0, *) {
      vc.userActivity = newShortcutActivity(type: type)
      vc.userActivity?.becomeCurrent()
    }
  }

  @available(iOS 12.0, *)
<<<<<<< Updated upstream
  func newShortcutActivity(type: ShortcutType) -> NSUserActivity {
    let activity = NSUserActivity(activityType: type.rawValue)
    activity.persistentIdentifier = NSUserActivityPersistentIdentifier(type.rawValue)
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true

=======
  func newShortcutActivity(type: String) -> NSUserActivity {
    let activity = NSUserActivity(activityType: type)
    #if swift(>=5)
      activity.persistentIdentifier = NSUserActivityPersistentIdentifier(type)
      activity.isEligibleForSearch = true
      activity.isEligibleForPrediction = true
    #endif
>>>>>>> Stashed changes
    configureType(type, activity: activity)

    return activity
  }

<<<<<<< Updated upstream
  private func configureType(_ type: ShortcutType, activity: NSUserActivity) {
=======
  @available(iOS 9.0, *)
  func configureType(_ type: String, activity: NSUserActivity) {
>>>>>>> Stashed changes
    let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
    switch type {
    case .reviews:
      activity.title = "Start Wanikani Reviews"
      if #available(iOS 12.0, *) {
        #if swift(>=5)
          activity.suggestedInvocationPhrase = "Start Wanikani Reviews"
        #endif
      }
      attributes.contentDescription = "Keep it up and burn every one"
    case .lessons:
      activity.title = "Start Wanikani Lessons"
      if #available(iOS 12.0, *) {
        #if swift(>=5)
          activity.suggestedInvocationPhrase = "Start Wanikani Lessons"
        #endif
      }
      attributes.contentDescription = "Learn something new"
    }
    activity.contentAttributeSet = attributes
  }
}
