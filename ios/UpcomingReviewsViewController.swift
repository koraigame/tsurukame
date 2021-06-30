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

private class UpcomingReviewsDateFormatter: UpcomingReviewsXAxisValueFormatter {
  override init(_ startTime: Date) {
    super.init(startTime)
    dateFormatter.setLocalizedDateFormatFromTemplate("d MMM: \(hourFormat)")
  }

  func string(hour: Int) -> String {
    let date = startTime.addingTimeInterval(TimeInterval(hour * 60 * 60))
    return dateFormatter.string(from: date)
  }
}

class UpcomingReviewsViewController: UITableViewController {
  private var services: TKMServices!
  private var date: UpcomingReviewsDateFormatter!
  private var model: TKMTableModel?

  func setup(services: TKMServices) {
    self.services = services
  }

  // MARK: - UIView

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    date = UpcomingReviewsDateFormatter(Date())
    rerender()
  }

  private typealias ReviewData = ReviewComposition

  private func combineData(_ a: ReviewData, _ b: ReviewData) -> ReviewData {
    return ReviewData(reviews: a.reviews + b.reviews,
                      radical: a.radical + b.radical,
                      kanji: a.kanji + b.kanji,
                      vocab: a.vocab + b.vocab,
                      apprentice: a.apprentice + b.apprentice,
                      guru: a.guru + b.guru,
                      master: a.master + b.master,
                      enlightened: a.enlightened + b.enlightened)
  }

  private func format(_ fullData: [ReviewData], _ hour: Int) -> String {
    let data = fullData[hour], difference = fullData[hour].reviews - fullData[hour - 1].reviews
    return "\(data.reviews) (+\(difference)): " +
      (Settings.upcomingTypeOverSRS ? "\(data.radical)/\(data.kanji)/\(data.vocab)" :
        "\(data.apprentice)/\(data.guru)/\(data.master)/\(data.enlightened)")
  }

  private func getReviewData() -> [ReviewData] {
    let subjects = services.localCachingClient.availableSubjects
    var cumulativeData: [ReviewData] = []
    for data in subjects.reviewComposition {
      cumulativeData.append(combineData(cumulativeData.last ?? ReviewData(), data))
    }
    return cumulativeData
  }

  private func rerender() {
    let model = TKMMutableTableModel(tableView: tableView),
        reviewData = getReviewData()

    func formatData(hour: Int) -> String {
      let data = reviewData[hour],
          difference = data.reviews - (hour > 0 ? reviewData[hour - 1].reviews : 0)
      return "\(data.reviews) (+\(difference)): " +
        (Settings.upcomingTypeOverSRS ? "\(data.radical)/\(data.kanji)/\(data.vocab)" :
          "\(data.apprentice)/\(data.guru)/\(data.master)/\(data.enlightened)")
    }

    for hour in 0 ..< reviewData.count {
      if hour > 0, reviewData[hour].reviews == reviewData[hour - 1].reviews { continue }
      model.add(TKMBasicModelItem(style: .value1,
                                  title: date.string(hour: hour),
                                  subtitle: formatData(hour: hour),
                                  accessoryType: .none))
    }

    self.model = model
    model.reloadTable()
  }
}
