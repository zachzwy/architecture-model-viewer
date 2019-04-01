//
//  ARModeVC.swift
//  HCIProject
//
//  Created by AB Brooks on 11/3/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit

protocol ARModeVCProtocol : class
{
    func invitePressed()
}

class ARModeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var arContainerView: UIView!
    @IBOutlet weak var mainView: UIView!
//    @IBOutlet weak var sceneView: ARSKView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var hamburgerButton: UIButton!
    @IBOutlet var exitTutorialButton: UIButton!
    @IBOutlet var tutorialContainerView: UIView!
    
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var sideViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuTable: UITableView!
    
    @IBOutlet weak var modelsView: UIView!
    @IBOutlet weak var modelViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var modelsCollectionView: UICollectionView!
    @IBOutlet var editModeButton: UIButton!
    @IBOutlet var cancelEditModeButton: UIButton!
    @IBOutlet var importButton: UIButton!
    @IBOutlet var trashButton: UIButton!
    
    @IBOutlet var sideMenu: UIView!
    @IBOutlet var shareMenu: UIView!
    @IBOutlet var usersNearbyTable: NearbyUsersTable!
    @IBOutlet var editPermButton: UIButton!
    @IBOutlet var eyePermButton: UIButton!
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var invitesView: UIView!
    @IBOutlet var invitesTable: InvitesTableView!
    @IBOutlet weak var notification: UIView!
    
    var subViewController = ViewController()

    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0
    
    var isEditMode = false
    
    var isFirst = true
    var firstModel = true
    
    var notificationText2 = UILabel()

    @IBOutlet var notificationText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
//        if let scene = SKScene(fileNamed: "Scene") {
//            sceneView.presentScene(scene)
//        }
        
        let screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        sideMenuTable.delegate = self
        sideMenuTable.dataSource = self
        
        modelsCollectionView.delegate = self
        modelsCollectionView.dataSource = self
        
        fadeView.isUserInteractionEnabled = false
        mainView.isUserInteractionEnabled = true
        
        usersNearbyTable.delegate = usersNearbyTable
        usersNearbyTable.dataSource = usersNearbyTable
        
        invitesTable.delegate = invitesTable
        invitesTable.dataSource = invitesTable
        invitesTable.mainDelegate = self
        notificationText.text = ""
        sendButton.addTarget(self, action: #selector(inviteSent), for: .touchUpInside)
        
        notificationText2 = UILabel(frame: CGRect(x: 0, y: 50, width: self.view.bounds.width, height: 40))
        notificationText2.textColor = UIColor.white
        notificationText2.font = UIFont(name: "Avenir", size: 20.0)
        notificationText2.textAlignment = .center
        self.view.addSubview(notificationText2)
//        addChildViewController(subViewController)
//        self.view.addSubview(subViewController.view)
//        subViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
//        self.view.sendSubview(toBack: subViewController.view)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        sceneView.session.pause()
    }
    
    @objc func inviteSent(){
        self.view.bringSubview(toFront: notificationText)
        notificationText2.text = "Invitation Sent"
        hideSideView(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.notificationText2.text = ""
        })
    }
    
    @IBOutlet weak var addModelButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
    
    
    @IBAction func showModelsView(_ sender: Any) {
        
        if isFirst == true{
            embeddedViewController?.selectObject()
            embeddedViewController?.selectObject()
            embeddedViewController?.selectObject()
            embeddedViewController?.selectObject()
            isFirst = false
        }
        
        
        modelViewConstraint.constant = -(screenHeight)+33
        mainView.isUserInteractionEnabled = false
        modelsView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, animations:{
            self.fadeView.alpha = 1.0
            self.hamburgerButton.alpha = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func hideModelsView(_ sender: Any) {
        modelViewConstraint.constant = 33
        mainView.isUserInteractionEnabled = true
        modelsView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations:{
            self.fadeView.alpha = 0.0
            self.hamburgerButton.alpha = 1.0
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func showSideView(_ sender: Any) {
        sideViewConstraint.constant = -(screenWidth)
        sideView.isUserInteractionEnabled = true
        mainView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations:{
            self.fadeView.alpha = 1.0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func hideSideView(_ sender: Any) {
        sideViewConstraint.constant = 0
        sideView.isUserInteractionEnabled = false
        mainView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, animations:{
            self.fadeView.alpha = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.lightGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.clear
        })
        
        if indexPath.row == 0{
            hideSideView(self)
            tutorialContainerView.isUserInteractionEnabled = true
            exitTutorialButton.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.3, animations:{
                self.exitTutorialButton.alpha = 1.0
                self.tutorialContainerView.alpha = 1.0
                self.hamburgerButton.alpha = 0.0
                self.addModelButton.alpha = 0.0
            })
        }
        if indexPath.row == 1{
            sideMenu.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3, animations:{
                self.sideMenu.alpha = 0.0
                self.shareMenu.alpha = 1.0
            })
            shareMenu.isUserInteractionEnabled = true
        }
        if indexPath.row == 2{
            sideMenu.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3, animations:{
                self.sideMenu.alpha = 0.0
                self.invitesView.alpha = 1.0
            })
            invitesView.isUserInteractionEnabled = true
        }
        if indexPath.row == 4{
            hideSideView(self)
            self.performSegue(withIdentifier: "goLoginVC", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 3){
            return 415
        }else{
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.row){
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell0",
                                                     for: indexPath) as! UITableViewCell
            return cell
            break;
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1",
                                                     for: indexPath) as! UITableViewCell
            return cell
            break;
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2",
                                                     for: indexPath) as! UITableViewCell
            return cell
            break;
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3",
                                                     for: indexPath) as! UITableViewCell
            return cell
            break;
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4",
                                                     for: indexPath) as! UITableViewCell
            return cell
            break;
        default:
            break;
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModelCell
        if(indexPath.row == 0){
            cell.modelTitle?.text = "Family House"

            cell.modelImageView?.image = UIImage(named: "smallHouse1")
        }else{
            cell.modelTitle?.text = "Solar House"

            cell.modelImageView?.image = UIImage(named: "smallHouse2")
        }
        
        if(!isEditMode){
            cell.editting = false
        }else{
            cell.editting = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModelCell
        print("selected!")
        if(!isEditMode){
            
            if firstModel == true{
                embeddedViewController?.loadedObjects[2].isHidden = false
                firstModel = false
                
            }
            else{
                embeddedViewController?.loadedObjects[0].isHidden = false
            }
            
            hideModelsView(self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModelCell
     }
    
    
    
    @IBAction func enterEditMode(_ sender: Any) {
        isEditMode = true
        modelsCollectionView.allowsMultipleSelection = true
        modelsCollectionView.reloadData()
        editModeButton.isUserInteractionEnabled = false
        editModeButton.alpha = 0.0
        cancelEditModeButton.isUserInteractionEnabled = true
        cancelEditModeButton.alpha = 1.0
        
        importButton.isUserInteractionEnabled = false
        importButton.alpha = 0.0
        
        trashButton.isUserInteractionEnabled = true
        trashButton.alpha = 1.0
        
    }
    
    @IBAction func cancelEditMode(_ sender: Any) {
        isEditMode = false
        modelsCollectionView.allowsMultipleSelection = false
        modelsCollectionView.reloadData()

        editModeButton.isUserInteractionEnabled = true
        editModeButton.alpha = 1.0
        cancelEditModeButton.isUserInteractionEnabled = false
        cancelEditModeButton.alpha = 0.0
        
        importButton.isUserInteractionEnabled = true
        importButton.alpha = 1.0
        
        trashButton.isUserInteractionEnabled = false
        trashButton.alpha = 0.0
        
        
        
    }
    
    @IBAction func importModels(_ sender: Any) {
        
    }
    
    @IBAction func deleteModels(_ sender: Any) {
    }
    
    @IBAction func exitTutorial(_ sender: Any) {
        
        exitTutorialButton.isUserInteractionEnabled = false
        tutorialContainerView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations:{
            self.exitTutorialButton.alpha = 0.0
            self.tutorialContainerView.alpha = 0.0
            self.hamburgerButton.alpha = 1.0
            self.addModelButton.alpha = 1.0
        })
    }
    
    @IBAction func exitShareMenu(_ sender: Any) {
        shareMenu.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations:{
            self.sideMenu.alpha = 1.0
            self.shareMenu.alpha = 0.0
        })
        sideMenu.isUserInteractionEnabled = true
    }
    
    @IBAction func eyeClicked(_ sender: Any) {
        eyePermButton.isUserInteractionEnabled = false
        editPermButton.isUserInteractionEnabled = true
        eyePermButton.alpha = 0.0
        editPermButton.alpha = 1.0
    }
    
    @IBAction func editClicked(_ sender: Any) {
        eyePermButton.isUserInteractionEnabled = true
        editPermButton.isUserInteractionEnabled = false
        eyePermButton.alpha = 1.0
        editPermButton.alpha = 0.0
    }
    
    @IBAction func exitInvitesMenu(_ sender: Any) {
        invitesView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations:{
            self.invitesView.alpha = 0.0
            self.sideMenu.alpha = 1.0
        })
        sideMenu.isUserInteractionEnabled = true
    }
    
    var embeddedViewController: ViewController? = nil
    
    // this method is a point in which you can hook onto segues
    // coming from this viewController and do anything you want to
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if it's a segue going to TableViewController and it has
        // the identifier we set in the storyboard, then this is the
        // tableViewController we want to get
        if segue.identifier == "embedSegue",
            let vc = segue.destination as? ViewController {
            self.embeddedViewController = vc
        }
    }
    
    
    
    

}

extension ARModeVC : ARModeVCProtocol {
    func invitePressed() {
        self.view.bringSubview(toFront: notificationText)
        notificationText2.text = "Viewing Becky's Session"
        hideSideView(self)
        for view in (embeddedViewController?.loadedObjects)!{
            view.isHidden = true
        }
        embeddedViewController?.loadedObjects[3].isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.notificationText2.text = ""
        })
    }
}

extension ARModeVC : ARSKViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
