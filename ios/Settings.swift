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


struct S<T: Codable> {
  static func set(_ object: T, _ key: String) {
    var data: Data!
    if #available(iOS 11.0, *) {
      data = try! NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
    } else {
      let _data = NSMutableData()
      let archiver = NSKeyedArchiver(forWritingWith: _data)
      archiver.requiresSecureCoding = true
      archiver.encode(object, forKey: key)
      data = _data as Data
    }
    UserDefaults.standard.set(data, forKey: key)
  }
  
  static func get(_ defaultValue: T, _ key: String) -> T {
    // Encode anything not encoded
    if let notEncodedObject = UserDefaults.standard.object(forKey: key) as? T {
      set(notEncodedObject, key: key)
    }
    // Decode value if obtainable and return it
    guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
      set(defaultValue, key: key)
      return defaultValue
    }
    if #available(iOS 9.0, *) {
      let t = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as Any?
      return (t as? T) ?? defaultValue
    } else {
      return (NSKeyedUnarchiver.unarchiveObject(with: data) as? T) ?? defaultValue
    }
  }
}

struct E<T: RawRepresentable> where T.RawValue: Codable {
	static func set(_ object: T, _ key: String) {
		S.set(object.rawValue, key: key)
	}
	static func get(_ defaultValue: T, _ key: String) -> T {
		return T(rawValue: S.get(defaultValue.rawValue, key: key))!
	}
}
struct A<C: Sequence, T: RawRepresentable> where A.Element == T, T.RawValue: Codable {
	private static func fromRawArray(_ values: [T.RawValue]) -> A {
		var ret = [T]()
    for value in values {
      ret.append(T(rawValue: value)!)
    }
    return ret as! A
	}
	private static func toRawArray(_ values: A) -> [T,RawValue] {
		var ret = [T.RawValue]()
    for value in values {
      ret.append(value.rawValue)
    }
    return ret
	}
	static func set(_ object: T, _key: String) {
		S.set(toRawArray(object), key: key)
	}
	static func get(_ defaultValue: T, _ key: String) -> T {
		return fromRawArray(S.get(defaultValue, key: key))
	}
}

@objcMembers class Settings: NSObject {
  static var userCookie: String {
    get {return S.get("", #keyPath(userCookie))}
    set(n) {S.set(n, #keyPath(userCookie))}
  }
  static var userEmailAddress: String {
    get {return S.get("", #keyPath(userEmailAddress))}
    set(n) {S.set(n, #keyPath(userEmailAddress))}
  }
  static var userApiToken: String {
    get {return S.get("", #keyPath(userApiToken))}
    set(n) {S.set(n, #keyPath(userApiToken))}
  }
  static var interfaceStyle: InterfaceStyle {
    get {return E.get(InterfaceStyle.system, #keyPath(interfaceStyle))}
    set(n) {E.set(n, #keyPath(interfaceStyle))}
  }
  static var notificationsAllReviews: Bool {
    get {return S.get(false, #keyPath(notificationsAllReviews))}
    set(n) {S.set(n, #keyPath(notificationsAllReviews))}
  }
  static var notificationsBadging: Bool {
    get {return S.get(false, #keyPath(notificationsAllReviews))}
    set(n) {S.set(n, #keyPath(notificationsBadging))}
  }
  static var prioritizeCurrentLevel: Bool {
    get {return S.get(false, #keyPath(prioritizeCurrentLevel))}
    set(n) {S.set(n, #keyPath(prioritizeCurrentLevel))}
  }
  static var lessonOrder: [TKMSubject.TypeEnum] {
    get {return A.get([.radical, .kanji, .vocabulary], #keyPath(lessonOrder))}
    set(n) {A.set(n, #keyPath(lessonOrder))}
  }
  static var lessonBatchSize: Int {
    get {return S.get(5, #keyPath(lessonBatchSize))}
    set(n) {S.set(n, #keyPath(lessonBatchSize))}
  }
  static var reviewOrder: ReviewOrder {
    get {return E.get(ReviewOrder.random, #keyPath(reviewOrder))}
    set(n) {E.set(n, #keyPath(reviewOrder))}
  }
  static var reviewBatchSize: Int {
    get {return S.get(5, #keyPath(reviewBatchSize))}
    set(n) {S.set(n, #keyPath(reviewBatchSize))}
  }
  static var groupMeaningReading: Bool {
    get {return S.get(false, #keyPath(groupMeaningReading))}
    set(n) {S.set(n, #keyPath(groupMeaningReading))}
  }
  static var meaningFirst: Bool {
    get {return S.get(true, #keyPath(meaningFirst))}
    set(n) {S.set(n, #keyPath(meaningFirst))}
  }
  static var showAnswerImmediately: Bool {
    get {return S.get(true, #keyPath(showAnswerImmediately))}
    set(n) {S.set(n, #keyPath(showAnswerImmediately))}
  }
  static var selectedFonts: Set<String> {
    get {return S.get([], #keyPath(selectedFonts))}
    set(n) {S.set(n, #keyPath(selectedFonts))}
  }
  static var fontSize: Float {
    get {return S.get(1.0, #keyPath(fontSize))}
    set(n) {S.set(n, #keyPath(fontSize))}
  }
  static var exactMatch: Bool {
    get {return S.get(false, #keyPath(exactMatch))}
    set(n) {S.set(n, #keyPath(exactMatch))}
  }
  static var enableCheats: Bool {
    get {return S.get(true, #keyPath(enableCheats))}
    set(n) {S.set(n, #keyPath(exactMatch))}
  }
  static var showOldMnemonic: Bool {
    get {return S.get(true, #keyPath(showOldMnemonic))}
    set(n) {S.set(n, #keyPath(showOldMnemonic))}
  }
  static var useKatakanaForOnyomi: Bool {
    get {return S.get(true, #keyPath(useKatakanaForOnyomi))}
    set(n) {S.set(n, #keyPath(useKatakanaForOnyomi))}
  }
  static var showSRSLevelIndicator: Bool {
    get {return S.get(false, #keyPath(showSRSLevelIndicator))}
    set(n) {S.set(n, #keyPath(showSRSLevelIndicator))}
  }
  static var showAllReadings: Bool {
    get {return S.get(false, #keyPath(showAllReadings))}
    set(n) {S.set(n, #keyPath(showAllReadings))}
  }
  static var autoSwitchKeyboard: Bool {
    get {return S.get(false, #keyPath(autoSwitchKeyboard))}
    set(n) {S.set(n, #keyPath(autoSwitchKeyboard))}
  }
  static var allowSkippingReviews: Bool {
    get {return S.get(false, #keyPath(allowSkippingReviews))}
    set(n) {S.set(n, #keyPath(allowSkippingReviews))}
  }
  static var minimizeReviewPenalty: Bool {
    get {return S.get(true, #keyPath(minimizeReviewPenalty))}
    set(n) {S.set(n, #keyPath(minimizeReviewPenalty))}
  }
  static var playAudioAutomatically: Bool {
    get {return S.get(false, #keyPath(playAudioAutomatically))}
    set(n) {S.set(n, #keyPath(playAudioAutomatically))}
  }
  static var installedAudioPackages: Set<String> {
    get {return S.get([], #keyPath(installedAudioPackages))}
    set(n) {S.set(n, #keyPath(installedAudioPackages))}
  }
  static var animateParticleExplosion: Bool {
    get {return S.get(true, #keyPath(animateParticleExplosion))}
    set(n) {S.set(n, #keyPath(animateParticleExplosion))}
  }
  static var animateLevelUpPopup: Bool {
    get {return S.get(true, #keyPath(animateLevelUpPopup))}
    set(n) {S.set(n, #keyPath(animateLevelUpPopup))}
  }
  static var animatePlusOne: Bool {
    get {return S.get(true, #keyPath(animatePlusOne))}
    set(n) {S.set(n, #keyPath(animatePlusOne))}
  }
  static var subjectCatalogueViewShowAnswers: Bool {
    get {return S.get(true, #keyPath(subjectCatalogueViewShowAnswers))}
    set(n) {S.set(n, #keyPath(subjectCatalogueViewShowAnswers))}
  }
}