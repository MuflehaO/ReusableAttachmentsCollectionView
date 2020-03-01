//
// Copyright (c) 2020, Xgrid Inc, http://xgrid.co
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
import Photos
import UIKit
import MobileCoreServices

typealias PickerActionHandler = (Attachment, AnyObject) -> Void

enum PickerType {
    case camera
    case gallery
    case file
}

struct PickerAction {
    var title: String?
    var pickerType: PickerType?
    var action: PickerActionHandler?
}

class PickerViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var pickerActionsTableView: UITableView!

    var pickerActions = [PickerAction]()
    //default selected file type is PDF. It can be set to multiple file Types
    var documentTypes = [String(kUTTypePDF)]

    // MARK: - Lifecycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomPropertiesOnView()
    }

    // MARK: - Actions

    // MARK: - private methods
    private func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }

    private func accessPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                self.openPhotoLibrary()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self.openPhotoLibrary()
                        } else {
                            //show error alert
                        }
                    }
                }
            default:
                //show error alert
                print("error")
            }
        }
    }

    private func accessFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    private func openPhotoLibrary() {
        DispatchQueue.main.async {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }

    private func setupCustomPropertiesOnView() {
        pickerActionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
}

// MARK: - delegates
extension PickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let imageData = editedImage.jpegData(compressionQuality: 0.9) else {
            return
        }

        let phAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
        var fileName = phAsset?.value(forKey: "filename") as? String
        if let filename = fileName, filename.isEmpty {
            fileName = ProcessInfo.processInfo.globallyUniqueString
        }

        let cameraAction = self.pickerActions.filter({$0.pickerType! == .camera}).first
        let attachment = Attachment()
        attachment.fileName = fileName ?? ""
        attachment.data = imageData
        attachment.localUrl = editedImage.imageUrl()
        attachment.fileType = FileType.jpg.rawValue

        DispatchQueue.main.async {
            self.presentingViewController!.dismiss(animated: false) {

                if let action = cameraAction?.action {
                    action(attachment, editedImage)
                }
            }
        }
    }
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerActions.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .black
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 17.0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))
        cell?.textLabel?.text = pickerActions[indexPath.row].title
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pickerAction = pickerActions[indexPath.row]
        switch pickerAction.pickerType {
        case .camera:
            self.accessCamera()
        case .gallery:
            self.accessPhotoLibrary()
        case .file:
            self.accessFiles()
        default:
            break
        }
    }
}

extension PickerViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            DispatchQueue.main.async {
                self.presentingViewController?.dismiss(animated: false) {
                    let fileAction = self.pickerActions.filter({$0.pickerType! == .file}).first
                    let attachment = Attachment()
                    attachment.fileName = url.lastPathComponent
                    attachment.localUrl = url.absoluteURL
                    attachment.fileType = url.pathExtension

                    if let fileType = attachment.fileType {
                        attachment.fileType?.insert(".", at: fileType.startIndex)
                    }

                    do {
                        attachment.data = try Data(contentsOf: url, options: [.alwaysMapped, .uncached])
                    } catch {
                        print(error)
                    }

                    if let action = fileAction?.action {
                        action(attachment, " " as AnyObject)
                    }
                }
            }
        }
    }
}
