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

/**
 Representation of Regular Expression error.
 */
public struct RexyError: Error, CustomStringConvertible {
  /// Error description.
  public let description: String

  /**
   Creates a new regex error.

   - Parameter result: Compiled result.
   - Parameter compiledPattern: Compiled regex pattern.
   */
  public init(result: Int32, compiledPattern: regex_t) {
    var compiled = compiledPattern
    var buffer = [Int8](repeating: 0, count: 1024)

    regerror(result, &compiled, &buffer, buffer.count)
    description = String(cString: buffer)
  }
}
