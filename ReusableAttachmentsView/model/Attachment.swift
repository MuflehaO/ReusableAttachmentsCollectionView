//
// Copyright (c) 2019, Xgrid Inc, http://xgrid.co
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

enum FileType: String {
    case jpg = ".jpg"
    case png = ".png"
    case pdf = ".pdf"
    case xlsx = ".xlsx"
    case xls = ".xls"
    case doc = ".doc"
    case docx = ".docx"
    case csv = ".csv"
}

class Attachment {

    var localUrl: URL? //path within the app
    var fileName: String?
    var data: Data? //bytes of the attachment
    var fileType: String? //eg. jpg, png, .pdf etc

    //to differentiate between images and other files
    func isImage() -> Bool {
        if let type = fileType {
            switch type {
            case FileType.pdf.rawValue,
                 FileType.xlsx.rawValue,
                 FileType.doc.rawValue,
                 FileType.docx.rawValue,
                 FileType.xls.rawValue,
                 FileType.csv.rawValue:
                return false
            default:
                return true
            }
        }
        return false
    }
}
