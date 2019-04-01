//
//  NearbyUsersTable.swift
//  HCIProject
//
//  Created by AB Brooks on 11/12/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import UIKit

class NearbyUsersTable: UITableView, UITableViewDelegate, UITableViewDataSource {

    var userNames: [String] = ["Bill","Sue","Becky"]
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell{
            cell.userLabel?.text = userNames[indexPath.row]
            return cell
        }
        return UITableViewCell()
        
    }
   

}
