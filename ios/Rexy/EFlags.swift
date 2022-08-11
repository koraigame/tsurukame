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

#if os(Linux)
  import Glibc
#else
  import Darwin.C
#endif

public extension Regex {
  /**
   POSIX regex matching flags (eflag).
   */
  struct EFlags: OptionSet {
    /// Raw value.
    public let rawValue: Int32

    /**
     Creates a new eflag.

     - Parameter rawValue: The value
     */
    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }

    /// First character not at beginning of line.
    public static let notBeginningOfLine = EFlags(rawValue: 1)

    /// Last character not at end of line.
    public static let notEndOfLine = EFlags(rawValue: 2)

    /// String start/end in pmatch[0].
    public static let startEnd = EFlags(rawValue: 4)
  }
}
