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

class AttachmentsListView: UIView {

    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    @IBOutlet var contentView: UIView!

    var supportedTypes: [PickerType] = [.camera, .gallery, .file]
    var presentingViewController: UIViewController!
    var attachments = [Attachment]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setupView()
    }

    private func loadViewFromNib() {
        Bundle.main.loadNibNamed(AttachmentsListView.className(), owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

    private func setupView() {
        attachmentsCollectionView.registerCell(class: AddAttachmentCollectionViewCell.self)
        attachmentsCollectionView.registerCell(class: ThumbnailCollectionViewCell.self)
    }


    func initPopoverController<T: UIViewController>(presentationStyle: UIModalPresentationStyle = .formSheet, direction: UIPopoverArrowDirection = .up, backgroundColor: UIColor = .clear) -> T {
        let viewController = T(nibName: T.className(), bundle: nil)
        viewController.modalPresentationStyle = presentationStyle
        viewController.popoverPresentationController?.permittedArrowDirections = direction
        viewController.popoverPresentationController?.backgroundColor = backgroundColor
        return viewController
    }

    func didAddAttachment(attachment: Attachment) {
        attachments.append(attachment)
        attachmentsCollectionView.reloadData()
    }

    @objc func didTapDeleteImageButtonInCell(_ sender: UIButton) {
        attachments.remove(at: sender.tag)
        attachmentsCollectionView.reloadData()
    }

    @objc func didTapAddAttachmentsButtonInCell(_ sender: UIButton) {

        let pickerPopover: PickerViewController = initPopoverController(presentationStyle: .popover, direction: .left, backgroundColor: .darkGray)

        // allow all file types
        pickerPopover.documentTypes = ["public.content"]

        let imageHandler: PickerActionHandler = { (attachment, image) in
            self.didAddAttachment(attachment: attachment)
        }

        let fileHandler: PickerActionHandler = { (attachment, file) in
            self.didAddAttachment(attachment: attachment)
        }

        let cameraAction = PickerAction(title: Strings.AddAttachment.openCamera, pickerType: .camera, action: imageHandler)
        let galleryAction = PickerAction(title: Strings.AddAttachment.chooseFromGallery, pickerType: .gallery, action: imageHandler)
        let fileAction = PickerAction(title: Strings.AddAttachment.chooseFromFiles, pickerType: .file, action: fileHandler)

        if supportedTypes.contains(.camera) {
            pickerPopover.pickerActions.append(cameraAction)
        }
        if supportedTypes.contains(.gallery) {
            pickerPopover.pickerActions.append(galleryAction)
        }
        if supportedTypes.contains(.file) {
            pickerPopover.pickerActions.append(fileAction)
        }
        pickerPopover.popoverPresentationController?.sourceView = sender
        pickerPopover.preferredContentSize = CGSize(width: 205, height: 164)
        presentingViewController.present(pickerPopover, animated: true, completion: nil)
    }
}

extension AttachmentsListView: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : attachments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell: ThumbnailCollectionViewCell = collectionView.dequeReusableCell(forIndexPath: indexPath)
            cell.configureCellWithData(attachment: attachments[indexPath.row])
                cell.removeButton.tag = indexPath.row
                cell.removeButton.addTarget(self, action: #selector(self.didTapDeleteImageButtonInCell), for: .touchUpInside)

            return cell
        } else {
            let cell: AddAttachmentCollectionViewCell = collectionView.dequeReusableCell(forIndexPath: indexPath)
            cell.configureCell(multipleAttachementsType: true)
            cell.addImageButton.addTarget(self, action: #selector(didTapAddAttachmentsButtonInCell), for: .touchUpInside)
            return cell
        }
    }
}
