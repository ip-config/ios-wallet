//
// BMSearchView.swift
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

import Foundation


class BMSearchView: UIView {
    
    private let searchField = UITextField()
    
    public var onSearchTextChanged : ((String) -> Void)?
    public var onCancelSearch : (() -> Void)?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 154))
        
        backgroundColor = UIColor.main.marine
        alpha = 0
        
        let y:CGFloat = Device.isXDevice ? 60 : 35

        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 15, y: y, width: 40, height: 40)
        backButton.contentHorizontalAlignment = .left
        backButton.tintColor = UIColor.white
        backButton.setImage(IconBack(), for: .normal)
        backButton.tag = 20192
        backButton.addTarget(self, action: #selector(stopSearch), for: .touchUpInside)
        addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 40, y: y, width: (UIScreen.main.bounds.size.width-80), height: 40)
        titleLabel.font = SemiboldFont(size: 17)
        titleLabel.numberOfLines = 1
        titleLabel.text = LocalizableStrings.transaction_search
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        let iconView = UIImageView(frame: CGRect(x: 10, y: 11, width: 14, height: 14))
        iconView.contentMode = .scaleAspectFit
        iconView.image = IconSearchSmall()?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = UIColor.main.steel
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 36))
        leftView.addSubview(iconView)
        
        searchField.frame = CGRect(x: 15, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, width:  (UIScreen.main.bounds.size.width-30), height: 36)
        searchField.leftView = leftView
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.layer.cornerRadius = 10
        searchField.font = RegularFont(size: 16)
        searchField.backgroundColor = UIColor.main.marineTwo.withAlphaComponent(0.8)
        searchField.placeholder = LocalizableStrings.search
        searchField.placeHolderColor = UIColor.main.steel
        searchField.tintColor = UIColor.white
        searchField.textColor = UIColor.white
        searchField.autocorrectionType = .no
        searchField.spellCheckingType = .no
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField.clearButtonTintColor = UIColor.main.steel
        
        addSubview(searchField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(LocalizableStrings.fatalInitCoderError)
    }
    
    public func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        }) { (_ ) in
            self.searchField.becomeFirstResponder()
        }
    }
    
    public func hide(){
        searchField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func stopSearch() {
        searchField.text = String.empty()
        onCancelSearch?()
    }
    
    @objc private func textFieldDidChange(_ textField: BMField) {
        let text = textField.text ?? String.empty()
        onSearchTextChanged?(text)
    }
}

extension BMSearchView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}