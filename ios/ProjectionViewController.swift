// Copyright 2022 David Sansome
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
import UIKit

class ProjectionViewController: UITableViewController {
  private var services: TKMServices!
  private var model: TableModel?
  private var user: TKMUser!
  private var progressions: [TKMLevel]!
  private var subjects: [TKMSubject]!
  private var now: Date!
  private var stats: [[TimeInterval]]!

  private func time(_ item: TKMSubject, _ burn: Bool) -> TimeInterval {
    let assignment = services.localCachingClient.getAssignment(subjectId: item.id)
    if !((burn ? assignment?.hasBurnedAt : assignment?.hasPassedAt) ?? false) {
      var interval = assignment?.hasAvailableAt ?? false ? max(0,
                                                               assignment!.availableAtDate
                                                                 .timeIntervalSince(now)) : 0
      let target = burn ? SRSStage.burned : SRSStage.guru1
      for stage in (assignment?.srsStage ?? SRSStage.unlocking).advanced(by: 1) ..< target {
        interval += stage.duration(item)
      }
      return interval
    }
    return (burn ? assignment!.burnedAtDate : assignment!.passedAtDate).timeIntervalSince(now)
  }

  private func countComponent(_ componentLevel: Int32, _ itemLevel: Int32) -> Bool {
    // For items in future levels, don't count passing time for components on preceding levels
    return !(itemLevel > progressions[progressions.count - 1].level && componentLevel < itemLevel)
  }

  private func unlock(_ item: TKMSubject, _ itemLevel: Int32, _ burn: Bool) -> TimeInterval {
    return countComponent(item.level, itemLevel) ?
      (item.hasRadical ? 0 : item.componentSubjectIds.map {
        max(0, unlock(services.localCachingClient.getSubject(id: $0)!, item.level, false))
      }.reduce(0) { max($0, $1) }) + time(item, burn) : 0
  }

  func setup(services: TKMServices) {
    self.services = services
    user = services.localCachingClient.getUserInfo()
    progressions = services.localCachingClient.getAllLevelProgressions()
    subjects = services.localCachingClient.getAllSubjects()
    now = Date()
    stats = Array(repeating: [], count: Int(user.maxLevelGrantedBySubscription) + 1)
    subjects.filter { $0.hasKanji }
      .forEach { stats[Int($0.level)].append(unlock($0, $0.level, false)) }
    stats.append([subjects.map { unlock($0, $0.level, true) }.sorted(by: { $0 < $1 }).last!])
  }

  // MARK: - UIView

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    rerender()
  }

  private func rerender() {
    let model = MutableTableModel(tableView: tableView)

    let current = progressions[progressions.count - 1]
    var levels = progressions
    for level in current.level + 1 ... user.maxLevelGrantedBySubscription + 2 {
      var lvl = TKMLevel()
      lvl.level = Int32(level)
      levels!.append(lvl)
    }
    let sorted = progressions[0 ..< progressions.count - 1].map {
      return ($0.hasPassedAt ? $0.passedAtDate : $0.abandonedAtDate)
        .timeIntervalSince($0.unlockedAtDate)
    }.sorted(by: { $0 < $1 })
    let median = Double(sorted[sorted.count / 2] + sorted.reversed()[sorted.count / 2]) / 2.0
    let time = stats.map {
      $0.count == 0 ? 0 : $0.sorted(by: { $0 < $1 })[Int(ceil(CGFloat($0.count) * 0.9)) - 1]
    }

    var unlocked = now, fastest: Date?, real: Date?, format = DateFormatter()
    format.dateStyle = .short
    format.timeStyle = .short
    var levelOut: [(Int32, String)] = []
    for level in levels! {
      if level.hasUnlockedAt {
        unlocked = level.unlockedAtDate
        levelOut.append((level.level, format.string(from: unlocked!)))
      } else if level.level <= user.maxLevelGrantedBySubscription {
        fastest = (fastest ?? now) + time[Int(level.level) - 1]
        real = ((real ?? unlocked)!) + median
        real = fastest! > real! ? fastest : real
        levelOut
          .append((level.level, format.string(from: real!) + " | " + format.string(from: fastest!)))
      } else {
        let _fastest = (fastest ?? now) + time[Int(level.level) - 1]
        var _real = ((real ?? unlocked)!) +
          (level.level == user
            .maxLevelGrantedBySubscription + 2 ? time[Int(level.level) - 1] : median)
        _real = _fastest > _real ? _fastest : _real
        levelOut
          .append((level.level, format.string(from: _real) + " | " + format.string(from: _fastest)))
      }
    }

    for level in levelOut {
      model
        .add(BasicModelItem(style: .value1,
                            title: level.0 == user
                              .maxLevelGrantedBySubscription + 2 ? "全火" : String(level.0),
                            subtitle: level.1, accessoryType: .none, target: nil, action: nil))
    }

    self.model = model
    model.reloadTable()
  }
}
