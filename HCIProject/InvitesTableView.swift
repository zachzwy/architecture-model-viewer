//
//  InvitesTableView.swift
//  HCIProject
//
//  Created by AB Brooks on 11/12/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import UIKit

class InvitesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    weak var mainDelegate: ARModeVCProtocol?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell") as? InviteCell{
            cell.subjectLabel?.text = "View my session"
            cell.fromLabel?.text = "From: Becky Jensen"
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainDelegate?.invitePressed()
    }

}
