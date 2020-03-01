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

class ModalViewController: UIViewController {

    @IBOutlet weak var attachmentsListView: AttachmentsListView!

    override func viewDidLoad() {
        super.viewDidLoad()
        attachmentsListView.presentingViewController = self
    }

    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: UIBarButtonItem) {
    }

}