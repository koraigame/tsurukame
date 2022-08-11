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

extension String: RegexConvertible {
  public var regex: Regex? {
    try? Regex(self)
  }
}

// MARK: - Operators

infix operator =~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence

public func =~ (source: String, pattern: RegexConvertible?) -> Bool {
  guard let matches = pattern?.regex?.isMatch(source) else {
    return false
  }

  return matches
}

public func !~ (source: String, pattern: RegexConvertible?) -> Bool {
  !(source =~ pattern)
}
