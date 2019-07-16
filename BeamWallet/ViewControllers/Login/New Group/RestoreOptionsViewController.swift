//
// RestoreOptionsViewController.swift
// BeamWallet
//
// Copyright 2018 Beam Development
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

class RestoreOptionsViewController: BaseTableViewController {

    private lazy var footerView: UIView = {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 150))
        view.backgroundColor = UIColor.clear
        var nextButton = BMButton.defaultButton(frame: CGRect(x: (UIScreen.main.bounds.size.width-253)/2, y: 100, width: 253, height: 44), color: UIColor.main.brightTeal)
        nextButton.setImage(IconNextBlue(), for: .normal)
        nextButton.setTitle(Localizable.shared.strings.next.lowercased(), for: .normal)
        nextButton.setTitleColor(UIColor.main.marineOriginal, for: .normal)
        nextButton.setTitleColor(UIColor.main.marineOriginal.withAlphaComponent(0.5), for: .highlighted)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        nextButton.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: nextButton.x),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -nextButton.x),
            nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -44),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.shared.strings.restore_wallet_title
        
        tableView.register([RestoreOptionCell.self])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = footerView
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
        
        AppModel.sharedManager().restoreType = BMRestoreType(BMRestoreAutomatic)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (Device.isXDevice || Device.isLarge) && !Device.isZoomed {
            guard let footerView = tableView.tableFooterView else
            {
                return
            }
            
            let cellsHeight:CGFloat = (tableView.tableHeaderView?.frame.height ?? 0) + tableView.rowHeight
            
            var frame = footerView.frame
            
            frame.size.height = tableView.contentSize.height - cellsHeight - 50;
            frame.origin.y = cellsHeight
            
            footerView.frame = frame
        }
    }
    
    @objc private func onNext() {
        Settings.sharedManager().resetWallet()
        AppModel.sharedManager().resetWallet(true)
        AppModel.sharedManager().isRestoreFlow = true
        
        self.pushViewController(vc: InputPhraseViewController())
    }
}

extension RestoreOptionsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1 ? 40 : 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        AppModel.sharedManager().restoreType = (indexPath.section == 0 ? BMRestoreType(BMRestoreAutomatic) : BMRestoreType(BMRestoreManual))
        
        tableView.reloadData()
    }
}

extension RestoreOptionsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let title = (indexPath.section == 0 ? Localizable.shared.strings.automatic_restore_title : Localizable.shared.strings.manual_restore_title)
        let text = (indexPath.section == 0 ? Localizable.shared.strings.automatic_restore_text : Localizable.shared.strings.manual_restore_text)
        let icon = (indexPath.section == 0 ? IconCloud() : IconManual())
        var selected = false
        
        if indexPath.section == 0 && AppModel.sharedManager().restoreType == BMRestoreAutomatic {
            selected = true
        }
        else if indexPath.section == 1 && AppModel.sharedManager().restoreType == BMRestoreManual {
            selected = true
        }
        
        let cell = tableView
            .dequeueReusableCell(withType: RestoreOptionCell.self, for: indexPath)
        cell.delegate = self
        cell.configure(with: (icon: icon, title: title, detail: text, selected: selected))

        return cell
    }
}

extension RestoreOptionsViewController : BMCellProtocol {
    func onRightButton(_ sender: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            AppModel.sharedManager().restoreType = (indexPath.section == 0 ? BMRestoreType(BMRestoreAutomatic) : BMRestoreType(BMRestoreManual))
            tableView.reloadData()
        }
    }
}