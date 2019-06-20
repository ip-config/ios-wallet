//
// ReceiveAddressViewModel.swift
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


class ReceiveAddressViewModel: NSObject {
    
    enum ReceiveAddressViewModelSaveState: Int {
        case none = 0
        case new = 1
        case edit = 2
    }
    
    public var onAddressCreated : ((Error?) -> Void)?
    public var onDataChanged : (() -> Void)?
    public var onShared : (() -> Void)?

    public var address:BMAddress!
    public var startedAddress:BMAddress!
    public var pickedAddress:BMAddress?
    
    public var isShared = false
    
    public var amount:String?

    override init() {
        super.init()
    }
    
    public func createAddress() {
        AppModel.sharedManager().generateNewWalletAddress { (address, error) in
            if let result = address {
                DispatchQueue.main.async {
                    self.address = result
                    self.startedAddress = BMAddress.fromAddress(result)
                    self.onAddressCreated?(error)
                }
            }
            else if (error) != nil {
                DispatchQueue.main.async {
                    self.onAddressCreated?(error)
                }
            }
        }
    }
    
    public func revertChanges() {
        if pickedAddress != nil {
            if !isShared {
                if pickedAddress?.walletId == startedAddress?.walletId {
                    AppModel.sharedManager().deleteAddress(startedAddress?.walletId)
                }
                else if pickedAddress?.label != address?.label || pickedAddress?.category != address?.category {
                    AppModel.sharedManager().edit(pickedAddress!)
                }
            }
            
            if pickedAddress?.walletId != startedAddress?.walletId {
                AppModel.sharedManager().deleteAddress(startedAddress?.walletId)
            }
        }
        else if !isShared
        {
            AppModel.sharedManager().deleteAddress(address?.walletId)
        }
    }
    
    public func isNeedAskToSave() -> ReceiveAddressViewModelSaveState {
        if pickedAddress != nil {
            if !isShared {
                if pickedAddress?.walletId == startedAddress?.walletId {
                    if !address.label.isEmpty || (!address.category.isEmpty && address.category != LocalizableStrings.zero) {
                        return .new
                    }
                }
                else if pickedAddress?.label != address?.label || pickedAddress?.category != address?.category {
                    return .edit
                }
            }
        }
        else if !isShared
        {
            if !address.label.isEmpty || (!address.category.isEmpty && address.category != LocalizableStrings.zero) {
                return .new
            }
        }
        
        return .none
    }
    
    public func onExpire() {
        if let top = UIApplication.getTopMostViewController() {
            let vc = AddressExpiresPickerViewController(duration: -1)
            vc.completion = { [weak self]
                obj in
                
                self?.address?.duration = obj == 24 ? 86400 : 0
                
                AppModel.sharedManager().setExpires(Int32(obj), toAddress: self?.address?.walletId ?? String.empty())
                
                self?.onDataChanged?()
            }
            vc.isGradient = true
            top.pushViewController(vc: vc)
        }
    }
    
    public func onCategory() {
        if let top = UIApplication.getTopMostViewController() {
            if AppModel.sharedManager().categories.count == 0 {
                top.alert(title: LocalizableStrings.categories_empty_title, message: LocalizableStrings.categories_empty_text, handler: nil)
            }
            else{
                let vc  = CategoryPickerViewController(category: AppModel.sharedManager().findCategory(byId: self.address!.category))
                vc.completion = { [weak self]
                    obj in
                    guard let strongSelf = self else { return }

                    if let category = obj {
                        strongSelf.address?.category = String(category.id)
                        
                        AppModel.sharedManager().setWalletCategory(strongSelf.address!.category, toAddress: strongSelf.address!.walletId)
                        
                        self?.onDataChanged?()
                    }
                }
                vc.isGradient = true
                top.pushViewController(vc: vc)
            }
        }
    }
    
    public func onChangeAddress() {
        if let top = UIApplication.getTopMostViewController() {
            let vc = ReceiveListViewController()
            vc.completion = {[weak self]
                obj in
                
                self?.isShared = false
                
                self?.pickedAddress = BMAddress()
                self?.pickedAddress?.label = obj.label
                self?.pickedAddress?.category = obj.category
                self?.pickedAddress?.walletId = obj.walletId
                
                self?.address = obj
                
                self?.onDataChanged?()
            }
            vc.excepted = self.startedAddress
            vc.currenltyPicked = self.address
            top.pushViewController(vc: vc)
        }
    }
    
    public func onQRCode() {
        if let top = UIApplication.getTopMostViewController() {
            isShared = true
            
            let modalViewController = QRViewController(address: address, amount: amount)
            modalViewController.onShared = { [weak self] in
                self?.onShared?()
            }
            modalViewController.modalPresentationStyle = .overFullScreen
            modalViewController.modalTransitionStyle = .crossDissolve
            top.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    public func onShare() {
        if let top = UIApplication.getTopMostViewController() {
            let vc = UIActivityViewController(activityItems: [address.walletId ?? String.empty()], applicationActivities: [])
            vc.completionWithItemsHandler = {[weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if completed {
                    self?.isShared = true
                    
                    if activityType == UIActivity.ActivityType.copyToPasteboard {
                        ShowCopied()
                    }
                    
                    self?.onShared?()
                }
            }
            vc.excludedActivityTypes = [UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.print,UIActivity.ActivityType.openInIBooks]
            top.present(vc, animated: true)
        }
    }
}