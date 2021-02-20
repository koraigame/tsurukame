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

extension String {
  public func MD5() -> String {
    let str: Data = data(using: .utf8)!
    var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))

    _ = digest.withUnsafeMutableBytes { digestBytes in
      str.withUnsafeBytes { messageBytes in
        CC_MD5(messageBytes, CC_LONG(str.count), digestBytes)
      }
    }

    return digest.map { String(format: "%02hhx", $0) }.joined()
  }
}
