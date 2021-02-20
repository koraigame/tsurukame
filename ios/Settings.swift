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

import Foundation

@objc enum ReviewOrder: UInt, Codable {
  case random = 1
  case ascendingSRSStage = 2
  case currentLevelFirst = 3
  case lowestLevelFirst = 4
  case newestAvailableFirst = 5
  case oldestAvailableFirst = 6
  case descendingSRSStage = 7
}

@objc enum InterfaceStyle: UInt, Codable {
  case system = 1
  case light = 2
  case dark = 3
}

struct S<T: Codable> {
  static func archiveData(_ object: T, _ key: String) -> Data {
    if #available(iOS 11.0, *) {
      return try! NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
    } else {
      let data = NSMutableData()
      let archiver = NSKeyedArchiver(forWritingWith: data)
      archiver.requiresSecureCoding = true
      archiver.encode(object, forKey: key)
      return data as Data
    }
  }
  
  static func get(_ defaultValue: T, _ key: String) -> T {
    // Encode anything not encoded
    if let notEncodedObject = UserDefaults.standard.object(forKey: key) as? T {
      UserDefaults.standard.set(archiveData(notEncodedObject, key), forKey: key)
    }
    // Decode value if obtainable and return it
    guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
      UserDefaults.standard.set(archiveData(defaultValue, key), forKey: key)
      return defaultValue
    }
    if #available(iOS 9.0, *) {
      let t = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as Any?
      return (t as? T) ?? defaultValue
    } else {
      return (NSKeyedUnarchiver.unarchiveObject(with: data) as? T) ?? defaultValue
    }
  }
  
  static func set(_ key: String, _ newValue: T) {
    UserDefaults.standard.set(archiveData(newValue, key), forKey: key)
  }
}

@objcMembers class Settings: NSObject {
  static var userCookie: String {
    get {return S.get("", #keyPath(userCookie))}
    set(n) {S.set(#keyPath(userCookie), n)}
  }
  static var userEmailAddress: String {
    get {return S.get("", #keyPath(userEmailAddress))}
    set(n) {S.set(#keyPath(userEmailAddress), n)}
  }
  static var userApiToken: String {
    get {return S.get("", #keyPath(userApiToken))}
    set(n) {S.set(#keyPath(userApiToken), n)}
  }
  static var interfaceStyle: UInt {
    get {return S.get(InterfaceStyle.system.rawValue, #keyPath(interfaceStyle))}
    set(n) {S.set(#keyPath(interfaceStyle), n)}
  }
  static var notificationsAllReviews: Bool {
    get {return S.get(false, #keyPath(notificationsAllReviews))}
    set(n) {S.set(#keyPath(notificationsAllReviews), n)}
  }
  static var notificationsBadging: Bool {
    get {return S.get(false, #keyPath(notificationsAllReviews))}
    set(n) {S.set(#keyPath(notificationsBadging), n)}
  }
  static var prioritizeCurrentLevel: Bool {
    get {return S.get(false, #keyPath(prioritizeCurrentLevel))}
    set(n) {S.set(#keyPath(prioritizeCurrentLevel), n)}
  }
  static var lessonOrder: [Int32] {
    get {return S.get([
      TKMSubject_Type.radical.rawValue,
      TKMSubject_Type.kanji.rawValue,
      TKMSubject_Type.vocabulary.rawValue,
    ], #keyPath(lessonOrder))}
    set(n) {S.set(#keyPath(lessonOrder), n)}
  }
  static var lessonBatchSize: Int {
    get {return S.get(5, #keyPath(lessonBatchSize))}
    set(n) {S.set(#keyPath(lessonBatchSize), n)}
  }
  static var reviewOrder: UInt {
    get {return S.get(ReviewOrder.random.rawValue, #keyPath(reviewOrder))}
    set(n) {S.set(#keyPath(reviewOrder), n)}
  }
  static var reviewBatchSize: Int {
    get {return S.get(5, #keyPath(reviewBatchSize))}
    set(n) {S.set(#keyPath(reviewBatchSize), n)}
  }
  static var groupMeaningReading: Bool {
    get {return S.get(false, #keyPath(groupMeaningReading))}
    set(n) {S.set(#keyPath(groupMeaningReading), n)}
  }
  static var meaningFirst: Bool {
    get {return S.get(true, #keyPath(meaningFirst))}
    set(n) {S.set(#keyPath(meaningFirst), n)}
  }
  static var showAnswerImmediately: Bool {
    get {return S.get(true, #keyPath(showAnswerImmediately))}
    set(n) {S.set(#keyPath(showAnswerImmediately), n)}
  }
  static var selectedFonts: Set<String> {
    get {return S.get([], #keyPath(selectedFonts))}
    set(n) {S.set(#keyPath(selectedFonts), n)}
  }
  static var fontSize: Float {
    get {return S.get(1.0, #keyPath(fontSize))}
    set(n) {S.set(#keyPath(fontSize), n)}
  }
  static var exactMatch: Bool {
    get {return S.get(false, #keyPath(exactMatch))}
    set(n) {S.set(#keyPath(exactMatch), n)}
  }
  static var enableCheats: Bool {
    get {return S.get(true, #keyPath(enableCheats))}
    set(n) {S.set(#keyPath(exactMatch), n)}
  }
  static var showOldMnemonic: Bool {
    get {return S.get(true, #keyPath(showOldMnemonic))}
    set(n) {S.set(#keyPath(showOldMnemonic), n)}
  }
  static var useKatakanaForOnyomi: Bool {
    get {return S.get(true, #keyPath(useKatakanaForOnyomi))}
    set(n) {S.set(#keyPath(useKatakanaForOnyomi), n)}
  }
  static var showSRSLevelIndicator: Bool {
    get {return S.get(false, #keyPath(showSRSLevelIndicator))}
    set(n) {S.set(#keyPath(showSRSLevelIndicator), n)}
  }
  static var showAllReadings: Bool {
    get {return S.get(false, #keyPath(showAllReadings))}
    set(n) {S.set(#keyPath(showAllReadings), n)}
  }
  static var autoSwitchKeyboard: Bool {
    get {return S.get(false, #keyPath(autoSwitchKeyboard))}
    set(n) {S.set(#keyPath(autoSwitchKeyboard), n)}
  }
  static var allowSkippingReviews: Bool {
    get {return S.get(false, #keyPath(allowSkippingReviews))}
    set(n) {S.set(#keyPath(allowSkippingReviews), n)}
  }
  static var minimizeReviewPenalty: Bool {
    get {return S.get(true, #keyPath(minimizeReviewPenalty))}
    set(n) {S.set(#keyPath(minimizeReviewPenalty), n)}
  }
  static var playAudioAutomatically: Bool {
    get {return S.get(false, #keyPath(playAudioAutomatically))}
    set(n) {S.set(#keyPath(playAudioAutomatically), n)}
  }
  static var installedAudioPackages: Set<String> {
    get {return S.get([], #keyPath(installedAudioPackages))}
    set(n) {S.set(#keyPath(installedAudioPackages), n)}
  }
  static var animateParticleExplosion: Bool {
    get {return S.get(true, #keyPath(animateParticleExplosion))}
    set(n) {S.set(#keyPath(animateParticleExplosion), n)}
  }
  static var animateLevelUpPopup: Bool {
    get {return S.get(true, #keyPath(animateLevelUpPopup))}
    set(n) {S.set(#keyPath(animateLevelUpPopup), n)}
  }
  static var animatePlusOne: Bool {
    get {return S.get(true, #keyPath(animatePlusOne))}
    set(n) {S.set(#keyPath(animatePlusOne), n)}
  }
  static var subjectCatalogueViewShowAnswers: Bool {
    get {return S.get(true, #keyPath(subjectCatalogueViewShowAnswers))}
    set(n) {S.set(#keyPath(subjectCatalogueViewShowAnswers), n)}
  }
}
