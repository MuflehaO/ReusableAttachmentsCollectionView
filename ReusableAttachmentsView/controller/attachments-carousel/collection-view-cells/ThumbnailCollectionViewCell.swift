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


import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var filenameLabel: UILabel!

    func configureCellWithData(image: UIImage?) {
        if let tempImage = image {
            thumbnailImageView.image = tempImage
        }
    }

    func configureCellWithData(attachment: Attachment) {
        if attachment.isImage() {
            if let attachmentData = attachment.data {
                let attachmentImage = UIImage(data: attachmentData)
                thumbnailImageView.image = attachmentImage
                filenameLabel.isHidden = true
            }
        } else {
            filenameLabel.isHidden = false
            filenameLabel.text = attachment.fileName
            thumbnailImageView.image = UIImage(systemName: "doc.text.fill")
            return
        }
    }
}
