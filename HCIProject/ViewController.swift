/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/
import Foundation
import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    
    @IBOutlet weak var sceneView: VirtualObjectARView!
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - UI Elements
    
    var focusSquare = FocusSquare()
    
    var savedPosition = SCNVector3()
    var time = "12pm"
    
    var timeIndication = UILabel()
    var first = true
    
    
    var counter = 0
    
    var lightMenuVisible = false
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// The view controller that displays the virtual object selection menu.
    var objectsViewController: VirtualObjectSelectionViewController?
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    
    var virtue = [VirtualObject]()
    var subNode = SCNNode()
    var loadedObjects = [VirtualObject]()
    
    var light = SCNNode()
    var theSun = SCNNode()
    var sunSlider = UISlider()
    var sunLight = SCNNode()
    var storedPosition = SCNVector3()
    
    var dayWheelImageView = UIImageView()
    // MARK: - View Controller Life Cycle
    
    
    var lightButton = UIButton()
    let sunColor = UIColor(red: 1, green: 214/255, blue: 26/255, alpha: 1)
    
    let sectionColor = UIColor(red: 0, green: 188/255, blue: 255/255, alpha: 1)
    
    var currentRotation = CGFloat.pi/1
    
    
    
    var sectionLeftSlider = UISlider()
    var sectionRightSlider = UISlider()
    var sectionBottomSlider = UISlider()
    
    var sectionLeft = SCNNode()
    var sectionRight = SCNNode()
    var sectionBottom = SCNNode()
    
    var generalSectionButton = UIButton()
    var garbageButton = UIButton()
    
    var sectionLeftButton = UIButton()
    
    var sectionRightButton = UIButton()
    
    var sectionBottomButton = UIButton()
    
    var sectionStatus = "none"
    var sectionActive = false
    
    var sectionLeftPosition = SCNVector3()
    var sectionRightPosition = SCNVector3()
    var sectionBottomPosition = SCNVector3()
    
    func insertSectionFunctionality(){
        generalSectionButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 80, y: 180, width: 40, height: 40))
        generalSectionButton.backgroundColor = UIColor.white
        generalSectionButton.addTarget(self, action: #selector(sectionActivated), for: .touchUpInside)
        generalSectionButton.layer.cornerRadius = 20
        generalSectionButton.isHidden = true
        generalSectionButton.setBackgroundImage(UIImage(imageLiteralResourceName: "generalSectioningIcon") , for: .normal)
        sceneView.addSubview(generalSectionButton)
        
        garbageButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 80, y: 240, width: 40, height: 40))
        garbageButton.backgroundColor = UIColor.white
        garbageButton.addTarget(self, action: #selector(garbageActivated), for: .touchUpInside)
        garbageButton.layer.cornerRadius = 20
        garbageButton.isHidden = true
        garbageButton.setBackgroundImage(UIImage(imageLiteralResourceName: "garbage") , for: .normal)
        sceneView.addSubview(garbageButton)
        
        sectionLeftButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 75, y: 320, width: 30, height: 30))
        sectionLeftButton.backgroundColor = UIColor.white
        sectionLeftButton.addTarget(self, action: #selector(leftSectionActivated), for: .touchUpInside)
        sectionLeftButton.layer.cornerRadius = 15
        sectionLeftButton.isHidden = true
        sectionLeftButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sL3") , for: .normal)
        sceneView.addSubview(sectionLeftButton)
        
        sectionRightButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 75, y: 380, width: 30, height: 30))
        sectionRightButton.backgroundColor = UIColor.white
        sectionRightButton.addTarget(self, action: #selector(rightSectionActivated), for: .touchUpInside)
        sectionRightButton.layer.cornerRadius = 15
        sectionRightButton.isHidden = true
        sectionRightButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sR3") , for: .normal)
        sceneView.addSubview(sectionRightButton)
        
        sectionBottomButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 75, y: 440, width: 30, height: 30))
        sectionBottomButton.backgroundColor = UIColor.white
        sectionBottomButton.addTarget(self, action: #selector(bottomSectionActivated), for: .touchUpInside)
        sectionBottomButton.layer.cornerRadius = 15
        sectionBottomButton.isHidden = true
        sectionBottomButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sB3") , for: .normal)
        sceneView.addSubview(sectionBottomButton)
        
        
        sectionLeftSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sectionLeftSlider.minimumValue = 0
        sectionLeftSlider.maximumValue = 100
        sectionLeftSlider.isContinuous = true
        sectionLeftSlider.tintColor = sectionColor
        sectionLeftSlider.addTarget(self, action: #selector(ViewController.sliderLeftSectionValueDidChange(_:)), for: .valueChanged)
        sectionLeftSlider.isHidden = true
        sectionLeftSlider.value = 50.0
        self.view.addSubview(sectionLeftSlider)
        
        sectionRightSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sectionRightSlider.minimumValue = 0
        sectionRightSlider.maximumValue = 100
        sectionRightSlider.isContinuous = true
        sectionRightSlider.tintColor = sectionColor
        sectionRightSlider.addTarget(self, action: #selector(ViewController.sliderRightSectionValueDidChange(_:)), for: .valueChanged)
        sectionRightSlider.value = 50.0
        sectionRightSlider.isHidden = true
        
        self.view.addSubview(sectionRightSlider)
        
        sectionBottomSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sectionBottomSlider.minimumValue = 0
        sectionBottomSlider.maximumValue = 100
        sectionBottomSlider.isContinuous = true
        sectionBottomSlider.tintColor = sectionColor
        sectionBottomSlider.addTarget(self, action: #selector(ViewController.sliderBottomSectionValueDidChange(_:)), for: .valueChanged)
        sectionBottomSlider.value = 50.0
        sectionBottomSlider.isHidden = true
        
        self.view.addSubview(sectionBottomSlider)
    }
    
    @objc func garbageActivated(){
        sectionBottomButton.isHidden = false
        sectionLeftButton.isHidden = false
        sectionRightButton.isHidden = false
        
        sectionLeft.isHidden = true
        sectionRight.isHidden = true
        sectionBottom.isHidden = true
        
        sectionBottomSlider.isHidden = true
        sectionRightSlider.isHidden = true
        sectionLeftSlider.isHidden = true
        
        sectionStatus = "none"
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        garbageButton.isHidden = true
        
        sectionLeftButton.isEnabled = true
        sectionRightButton.isEnabled = true
        sectionBottomButton.isEnabled = true
    }
    
    
    @objc func sectionActivated(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if sectionActive == false{
            
            generalSectionButton.setBackgroundImage(UIImage(imageLiteralResourceName: "xSlice") , for: .normal)
            
            lightButton.isHidden = true
            
            switch sectionStatus {
            case "none":
                sectionLeftButton.isHidden = false
                sectionRightButton.isHidden = false
                sectionBottomButton.isHidden = false
                break
            case "left":
                sectionLeftButton.isHidden = false
                sectionLeftSlider.isHidden = false
                
                garbageButton.isHidden = false
                break
            case "right":
                sectionRightButton.isHidden = false
                sectionRightSlider.isHidden = false
                
                garbageButton.isHidden = false
                break
            case "bottom":
                sectionBottomButton.isHidden = false
                sectionBottomSlider.isHidden = false
                garbageButton.isHidden = false
                break
            default:
                sectionLeftButton.isHidden = false
                sectionRightButton.isHidden = false
                sectionBottomButton.isHidden = false
                break
            }
            sectionActive = true
        }
        else{
            generalSectionButton.setBackgroundImage(UIImage(imageLiteralResourceName: "generalSectioningIcon") , for: .normal)
            
            sectionLeftButton.isHidden = true
            sectionRightButton.isHidden = true
            sectionBottomButton.isHidden = true
            
            sectionLeftSlider.isHidden = true
            sectionRightSlider.isHidden = true
            sectionBottomSlider.isHidden = true
            sectionRight.isHidden = true
            sectionLeft.isHidden = true
            sectionBottom.isHidden = true
            
            lightButton.isHidden = false
            sectionActive = false
            
            garbageButton.isHidden = true
        }
        
        
        
    }
    
    @objc func leftSectionActivated(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        sectionLeftButton.isEnabled = false
        sectionLeftSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sectionLeftSlider.minimumValue = 0
        sectionLeftSlider.maximumValue = 100
        sectionLeftSlider.isContinuous = true
        sectionLeftSlider.tintColor = sectionColor
        sectionLeftSlider.addTarget(self, action: #selector(ViewController.sliderLeftSectionValueDidChange(_:)), for: .valueChanged)
        sectionLeftSlider.value = 50.0
        self.view.addSubview(sectionLeftSlider)
        
        garbageButton.isHidden = false
        
        sectionRightButton.isHidden = true
        sectionBottomButton.isHidden = true
        
        sectionLeft = geometryNodeFromImage(named: "leftSection", width: 0.00, height: 0.40, length: 0.40)
        
        sectionLeftPosition = SCNVector3Make(savedPosition.x - 0.1, savedPosition.y + 0.1, savedPosition.z)
        sectionLeft.position = sectionLeftPosition
        
        sectionLeft.geometry?.firstMaterial?.diffuse.contents = sectionColor
        sectionLeft.filters = addBloom()
        sectionLeft.opacity = 0.5
        
        let subAdd = sceneView.scene.rootNode.childNode(withName: "sub", recursively: true)!
        subAdd.addChildNode(sectionLeft)
        sectionStatus = "left"
    }
    
    @objc func sliderLeftSectionValueDidChange(_ sender:UISlider!){
        
        
        let difference = 0.01 * (sender.value - 50.0)
        
        
//        print(sectionLeft.position.x + difference)
        
        
        
        let newPosition = SCNVector3Make(sectionLeftPosition.x + difference, sectionLeftPosition.y , sectionLeftPosition.z)
        
        sectionLeft.position = newPosition
    }
    
    @objc func rightSectionActivated(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        garbageButton.isHidden = false
        sectionRightButton.isEnabled = false
        sectionLeftButton.isHidden = true
        sectionBottomButton.isHidden = true
        sectionRightSlider.removeFromSuperview()
        sectionRightSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sectionRightSlider.minimumValue = 0
        sectionRightSlider.maximumValue = 100
        sectionRightSlider.isContinuous = true
        sectionRightSlider.tintColor = sectionColor
        sectionRightSlider.addTarget(self, action: #selector(ViewController.sliderRightSectionValueDidChange(_:)), for: .valueChanged)
        sectionRightSlider.value = 50.0
        
        self.view.addSubview(sectionRightSlider)
        
        sectionRight = geometryNodeFromImage(named: "rightSection", width: 0.40, height: 0.40, length: 0.00)
        
        sectionRightPosition = SCNVector3Make(savedPosition.x, savedPosition.y + 0.1, savedPosition.z + 0.5)
        sectionRight.position = sectionRightPosition
        
        sectionRight.opacity = 0.5
        
        sectionRight.geometry?.firstMaterial?.diffuse.contents = sectionColor
        sectionRight.filters = addBloom()
        
        let subAdd = sceneView.scene.rootNode.childNode(withName: "sub", recursively: true)!
        subAdd.addChildNode(sectionRight)
        
        sectionStatus = "right"
    }
    
    @objc func sliderRightSectionValueDidChange(_ sender:UISlider!){
        
        
        let difference = 0.01 * (sender.value - 50.0)
        
        if sender.value < 18.0{
            loadedObjects[1].isHidden = false
            loadedObjects[2].isHidden = true
        }
        else{
            loadedObjects[1].isHidden = true
            loadedObjects[2].isHidden = false
        }
        
        let newPosition = SCNVector3Make(sectionRightPosition.x, sectionRightPosition.y , sectionRightPosition.z + difference)
        
        sectionRight.position = newPosition
    }
    
    @objc func bottomSectionActivated(){
        
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            garbageButton.isHidden = false
            sectionBottomButton.isEnabled = false
//            sectionBottom.removeFromParentNode()
            sectionLeftButton.isHidden = true
            sectionRightButton.isHidden = true
            sectionBottomSlider.removeFromSuperview()
            
            sectionBottom = geometryNodeFromImage(named: "rightSection", width: 0.40, height: 0.00, length: 0.40)
            print("here1")
            
            sectionBottomPosition = SCNVector3Make(savedPosition.x, savedPosition.y - 0.1, savedPosition.z)
            sectionBottom.position = sectionBottomPosition
            sectionBottom.opacity = 0.5
            
            
            sectionBottom.geometry?.firstMaterial?.diffuse.contents = sectionColor
            sectionBottom.filters = addBloom()
            
            let subAdd = sceneView.scene.rootNode.childNode(withName: "sub", recursively: true)!
            subAdd.addChildNode(sectionBottom)
            
            print("here2")
            
            sectionBottomSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
            sectionBottomSlider.minimumValue = 0
            sectionBottomSlider.maximumValue = 100
            sectionBottomSlider.isContinuous = true
            sectionBottomSlider.tintColor = sectionColor
            sectionBottomSlider.addTarget(self, action: #selector(ViewController.sliderBottomSectionValueDidChange(_:)), for: .valueChanged)
            sectionBottomSlider.value = 50.0
            
            print("here3")
            
            self.view.addSubview(sectionBottomSlider)
            print("here4")
            sectionStatus = "bottom"
            
            print("here5")
        
    }
    
    @objc func sliderBottomSectionValueDidChange(_ sender:UISlider!){
        
        
        let difference = 0.01 * (sender.value - 50.0)
        
        
        let newPosition = SCNVector3Make(savedPosition.x, savedPosition.y + difference, savedPosition.z)
        
        sectionBottom.position = newPosition
    }
    
    func geometryNodeFromImage(named name: String, width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode {
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        
        let rectangleMaterial = SCNMaterial()
        rectangleMaterial.diffuse.contents = UIImage(named: name)
        box.materials = [rectangleMaterial]
        
        return SCNNode(geometry: box)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        subNode.name = "sub"
        sceneView.scene.rootNode.addChildNode(subNode)
        
        sceneView.setupDirectionalLighting(queue: updateQueue)

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        lightButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 80, y: 120, width: 40, height: 40))
        lightButton.backgroundColor = UIColor.white
        lightButton.addTarget(self, action: #selector(lightActivated), for: .touchUpInside)
        lightButton.layer.cornerRadius = 20
        lightButton.isHidden = true
        lightButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sunSlice") , for: .normal)
        sceneView.addSubview(lightButton)
        
        sunSlider = UISlider(frame:CGRect(x: 10, y: UIScreen.main.bounds.height - 220, width: UIScreen.main.bounds.width - 20, height: 20))
        sunSlider.minimumValue = 0
        sunSlider.maximumValue = 144
        sunSlider.value = 72
        sunSlider.isContinuous = true
        sunSlider.tintColor = sunColor
        sunSlider.addTarget(self, action: #selector(ViewController.sliderValueDidChange(_:)), for: .valueChanged)
        sunSlider.isHidden = true
        
        self.view.addSubview(sunSlider)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        let newGeneralPosition = SCNVector3Make(savedPosition.x, savedPosition.y + 1.0, savedPosition.z)
        
        light.removeFromParentNode()
        light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.omni
        light.scale = SCNVector3Make(1, 1, 1)
        light.position = newGeneralPosition
        light.light?.intensity = 100
        
        let subAdd = sceneView.scene.rootNode.childNode(withName: "sub", recursively: true)!
        subAdd.addChildNode(light)
        
        storedPosition = newGeneralPosition
        
        sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = SCNLight.LightType.ambient
        sunLight.scale = SCNVector3Make(1, 1, 1)
        sunLight.position = newGeneralPosition
//        sunLight.light?.intensity = 50
        sceneView.scene.rootNode.addChildNode(sunLight)
        
        timeIndication = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 40))
        timeIndication.center.x = sceneView.center.x
        timeIndication.font = UIFont(name: "Helvetica Neue", size: 32.0)
        timeIndication.textColor = UIColor.white
        timeIndication.text = "12:00pm"
        timeIndication.isHidden = true
        sceneView.addSubview(timeIndication)
        timeIndication.center.x = sceneView.center.x
        
        insertSectionFunctionality()
        
        let availableObjects: [VirtualObject] = {
            let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
            
            let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
            
            return fileEnumerator.compactMap { element in
                let url = element as! URL
                
                guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }
                
                return VirtualObject(url: url)
            }
        }()
        
        virtue = availableObjects
    }
    
    func convertSliderValToTime(input: Float) -> String{
        let totalMinutes = 5*input
        let beginningMinuteCount = Float(360)
        
        var amPM = "am"
        
        let newCount = Int(beginningMinuteCount + totalMinutes)
        
        var hourCount = Int(newCount/60)
        let minuteCount = Int(newCount) - (hourCount*60)
        
        switch hourCount {
        case 12:
            hourCount = 12
            amPM = "pm"
            break
        case 13:
            hourCount = 1
            amPM = "pm"
            break
        case 14:
            hourCount = 2
            amPM = "pm"
            break
        case 15:
            hourCount = 3
            amPM = "pm"
            break
        case 16:
            hourCount = 4
            amPM = "pm"
            break
        case 17:
            hourCount = 5
            amPM = "pm"
            break
        case 18:
            hourCount = 6
            amPM = "pm"
            break
        case 19:
            hourCount = 7
            amPM = "pm"
            break
        default:
            amPM = "am"
            break
        }
        
        if minuteCount < 10{
            let finalString = String(Int(hourCount)) + ":" + "0" + String(Int(minuteCount)) + amPM
            return finalString
        }
        else{
            let finalString = String(Int(hourCount)) + ":" + String(Int(minuteCount)) + amPM
            return finalString
        }
        
        
        
    }
    
    
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        let angle = CGFloat(sender.value * 1.25) * (CGFloat.pi/180)
        
        let radius = 1.00
        
        let xVal = CGFloat(radius) *  cos(angle) * (-1)
        let yVal = CGFloat(radius) *  sin(angle)
        
        let newPosition = SCNVector3Make(savedPosition.x + Float(xVal), savedPosition.y + Float(yVal), savedPosition.z)
        
        self.theSun.position = newPosition
        self.light.position = newPosition
        
        
        timeIndication.text = convertSliderValToTime(input: sender.value)
        
        sceneView.bringSubview(toFront: dayWheelImageView)
        
        sunLight.removeFromParentNode()
        sunLight = SCNNode()
        sunLight.light = SCNLight()
        sunLight.light?.type = SCNLight.LightType.ambient
        sunLight.scale = SCNVector3Make(1, 1, 1)
        sunLight.position = newPosition
        sceneView.scene.rootNode.addChildNode(sunLight)
        
        storedPosition = newPosition
        
    }
    
    @objc func swipeLeft(){
        
    }
    
    @objc func swipeRight(){
        
        
    }
    
    
    func addPaperPlane(x: Float = 0, y: Float = 0, z: Float = -0.5) {
        guard let paperPlaneScene = SCNScene(named: "candle.scn"), let paperPlaneNode = paperPlaneScene.rootNode.childNode(withName: "candle", recursively: true) else {
            print("noooo")
            return }
        paperPlaneNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(paperPlaneNode)
    }
    
    @objc func lightActivated(){
        
        generalSectionButton.isHidden = true
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if lightMenuVisible == false{
            lightMenuVisible = true
            sunSlider.isHidden = false
            lightButton.setBackgroundImage(UIImage(imageLiteralResourceName: "xSlice") , for: .normal)
            timeIndication.isHidden = false
        }
        else{
            theSun.removeFromParentNode()
            lightMenuVisible = false
            sunSlider.isHidden = true
            lightButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sunSlice") , for: .normal)
            timeIndication.isHidden = true
            generalSectionButton.isHidden = false
            return
        }
        
        if first == true{
            first = false
            let angle = 90 * (CGFloat.pi/180)
            
            let arearadius = 1.00
            
            let xVal = CGFloat(arearadius) *  cos(angle) * (-1)
            let yVal = CGFloat(arearadius) *  sin(angle)
            
            storedPosition = SCNVector3Make(savedPosition.x + Float(xVal), savedPosition.y + Float(yVal), savedPosition.z)
        }
        
        
        var newGeneralPosition = storedPosition
        
        sceneView.bringSubview(toFront: dayWheelImageView)
        theSun.removeFromParentNode()
        
        let radius = Float(0.03)
        
        let objectSph = SCNSphere(radius: CGFloat(radius))
        theSun = SCNNode(geometry: objectSph)
        
        
        
        
        
        newGeneralPosition = storedPosition
        
        
        
        
        
        theSun.name = "Sun"
        
        
        theSun.position = newGeneralPosition
        theSun.geometry?.firstMaterial?.diffuse.contents = sunColor
        sceneView.scene.rootNode.addChildNode(theSun)
        theSun.filters = addBloom()
        
        light.removeFromParentNode()
        light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.omni
        light.scale = SCNVector3Make(1, 1, 1)
        light.position = newGeneralPosition
        light.light?.intensity = 100
        
        
        let constraint2 = SCNLookAtConstraint(target: sceneView.scene.rootNode)
        constraint2.isGimbalLockEnabled = true
        light.constraints = [constraint2]
        
        let subAdd = sceneView.scene.rootNode.childNode(withName: "sub", recursively: true)!
        subAdd.addChildNode(light)
        
        sceneView.bringSubview(toFront: dayWheelImageView)
    }
    
//    func newFunc(){
//
//    }
    
    func addBloom() -> [CIFilter]? {
        let bloomFilter = CIFilter(name:"CIBloom")!
        bloomFilter.setValue(10.0, forKey: "inputIntensity")
        bloomFilter.setValue(30.0, forKey: "inputRadius")
        
        
        return [bloomFilter]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }

    // MARK: - Scene content setup

    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }

        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }

    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
        lightButton.isHidden = true
        self.generalSectionButton.isHidden = true
        
        sectionBottomButton.isHidden = true
        sectionLeftButton.isHidden = true
        sectionRightButton.isHidden = true
        
        sectionLeft.isHidden = true
        sectionRight.isHidden = true
        sectionBottom.isHidden = true
        
        sectionBottomSlider.isHidden = true
        sectionRightSlider.isHidden = true
        sectionLeftSlider.isHidden = true
        
        sectionStatus = "none"
        
        garbageButton.isHidden = true
        
        sectionLeftButton.isEnabled = true
        sectionRightButton.isEnabled = true
        sectionBottomButton.isEnabled = true
        
        sectionActive = false
    }

    // MARK: - Focus Square

    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
            addObjectButton.isHidden = false
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addObjectButton.isHidden = true
        }
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addSun(position: SCNVector3) {
        
        let sun = Sun()
        sun.position = position
        
        theSun = sun
        
        let prevScale = theSun.scale
//        theSun.scale = SCNVector3(1, 1, 1)
        let scaleAction = SCNAction.scale(to: CGFloat(prevScale.x), duration: 1.5)
        scaleAction.timingMode = .linear
        
        // Use a custom timing function
        //        scaleAction.timingFunction = { (p: Float) in
        //            return self.easeOutElastic(p)
        //        }
        
        sceneView.scene.rootNode.addChildNode(theSun)
    }

}

extension SCNNode {
    
    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        
        do {
            guard let sceneURL = Bundle.main.url(forResource: file, withExtension: nil) else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            let objScene = try SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy:SCNSceneSource.AnimationImportPolicy.doNotPlay])
            
            for childNode in objScene.rootNode.childNodes {
                nodesInFile.append(childNode)
            }
        } catch {
            
        }
        
        return nodesInFile
    }
    
    func topmost(parent: SCNNode? = nil, until: SCNNode) -> SCNNode {
        if let pNode = self.parent {
            return pNode == until ? self : pNode.topmost(parent: pNode, until: until)
        } else {
            return self
        }
        
    }
    
}

class SceneObject: SCNNode {
    
    init(from file: String) {
        super.init()
        
        let nodesInFile = SCNNode.allNodes(from: file)
        nodesInFile.forEach { (node) in
            self.addChildNode(node)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Sun: SceneObject {
    
    var animating: Bool = false
    let patrolDistance: Float = 4.85
    
    init() {
        super.init(from: "Sun.scn")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func animate() {
//
//        if animating { return }
//        animating = true
//
//        let rotateOne = SCNAction.rotateBy(x: 0, y: CGFloat(Float.random(min: -Float.pi, max: Float.pi)), z: 0, duration: 5.0)
//
//        let backwards = rotateOne.reversed()
//        let rotateSequence = SCNAction.sequence([rotateOne, backwards])
//        let repeatForever = SCNAction.repeatForever(rotateSequence)
//
//        runAction(repeatForever)
//    }
//
//    func patrol(targetPos: SCNVector3) {
//        let distanceToTarget = targetPos.distance(receiver: self.position)
//
//        if distanceToTarget < patrolDistance {
//            removeAllActions()
//            animating = false
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.20
//            look(at: targetPos)
//            SCNTransaction.commit()
//        } else {
//            if !animating {
//                animate()
//            }
//        }
//    }
}
