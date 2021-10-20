//
//  ContentView.swift
//  ARAnchorPlayground
//
//  Created by Nien Lam on 10/13/21.
//

import SwiftUI
import ARKit
import RealityKit
import Combine


enum AppState {
    case menu
    case armode
}

enum GameMode {
    case dance1
    case dance2
}

enum DancePoses {
    case idle
    case houseDance
    case chickenDance
    case robotDance
    case sillyDance
}

// MARK: - View model for handling communication between the UI and ARView.
class ViewModel: ObservableObject {
    @Published var currAppState: AppState = AppState.armode
    @Published var currGameMode: GameMode = GameMode.dance1
    @Published var userName: String = ""
    @Published var userName2: String = ""
    @Published var selectedPose: DancePoses = DancePoses.idle
    @Published var canContinueToViewSelection = false


    let uiSignal = PassthroughSubject<UISignal, Never>()

    enum UISignal {
        case menuPress
        case pose1Press
        case pose2Press
        case pose3Press
        case pose4Press
        
    }
    
}



// MARK: - UI Layer.
struct ContentView : View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            
            if(viewModel.currAppState == AppState.armode){
                
                ARViewContainer(viewModel: viewModel)
                
                VStack(){
                                        
                    HStack(){
                        
                    
                        Image("celestial-dancer")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(Circle())
                        
                        Image("female-dancer")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(Circle())
                        
                        
                        Image("harlequina")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(Circle())
                        
                        Image("little-dancer")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(Circle())
                    
                    }.padding()
                    
                    Text("Strike a pose based off of your favorite dance - see other art for inspiration!")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                
                
                HStack(){
                    
                    VStack(){
                        // Pose 1 button.
                        Button {
                            viewModel.uiSignal.send(.pose1Press)
                        } label: {
                            Text("Pose 1")
                                .foregroundColor(.white)
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(lineWidth: 1.5)
                                        .fill(.red)
                                )
                        }
                        
                        // Pose 2 button.
                        Button {
                            viewModel.uiSignal.send(.pose2Press)
                        } label: {
                            Text("Pose 2")
                                .foregroundColor(.white)
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(lineWidth: 1.5)
                                        .fill(.red)
                                )
                        }
                        
                    }
                    
                    
                    
                    VStack(){
                        // Pose 3 button.
                        Button {
                            viewModel.uiSignal.send(.pose3Press)
                        } label: {
                            Text("Pose 3")
                                .foregroundColor(.white)
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(lineWidth: 1.5)
                                        .fill(.red)
                                )
                        }
                        
                        
                        // Pose 4 button.
                        Button {
                            viewModel.uiSignal.send(.pose4Press)
                        } label: {
                            Text("Pose 4")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(lineWidth: 1.5)
                                        .fill(.red)

                                )
                        }
                        
                    }
    
                    Spacer()
                    
                    if(viewModel.currGameMode == GameMode.dance1){
                        // Text field.
                        TextField("Enter Your First Name", text: $viewModel.userName)
                            .font(.system(size: 18))
                            .frame(width: 200)
                            .background(
                                Rectangle()
                                    .stroke(lineWidth: 1.5)
                                    .fill(.red)
                                    .background(Color.white)
                            )
                    }
                    else if(viewModel.currGameMode == GameMode.dance2){
                        // Text field.
                        TextField("Enter Your First Name", text: $viewModel.userName2)
                            .font(.system(size: 18))
                            .frame(width: 200)
                            .background(
                                Rectangle()
                                    .stroke(lineWidth: 1.5)
                                    .fill(.red)
                                    .background(Color.white)
                            )
                        
                    }
                    
                    

                    

                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                    .padding(.bottom, 20)
                
            }//end of AR mode
         
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
    
    
}


// MARK: - AR View.
struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        SimpleARView(frame: .zero, viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class SimpleARView: ARView, ARSessionDelegate {
    var viewModel: ViewModel
    var arView: ARView { return self }
    var originAnchor: AnchorEntity!
    var pov: AnchorEntity!
    var subscriptions = Set<AnyCancellable>()
    var DancePlayer: DanceUser?
    var DancePlayer2: DanceUser?

    // Dictionary for tracking image anchors.
    var imageAnchorToEntity: [ARImageAnchor: AnchorEntity] = [:]


    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
        
        setupEntities()
    }
    

    func setupScene() {
        // Setup world tracking and image detection.
        let configuration = ARWorldTrackingConfiguration()
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]

        // Create set hold target image references.
        var set = Set<ARReferenceImage>()

        // Target Image - Dance
        // (97.8 x 43.8 x 36.5 cm)
        
        if let detectionImage = makeDetectionImage(named: "little-dancer.jpeg",
                                                   referenceName: "DANCE_TARGET",
                                                   physicalWidth: 0.238) {
            set.insert(detectionImage)
        }

        // Setup target image B.
        if let detectionImage = makeDetectionImage(named: "celestial-dancer.jpeg",
                                                   referenceName: "DANCE_TARGET_2",
                                                   physicalWidth: 0.238) {
            set.insert(detectionImage)
        }

        // Add target images to configuration.
        configuration.detectionImages = set
        configuration.maximumNumberOfTrackedImages = 2

        // Run configuration.
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // Called every frame.
//        scene.subscribe(to: SceneEvents.Update.self) { event in
//            self.renderLoop()
//        }.store(in: &subscriptions)
        
        // Process UI signals.
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }.store(in: &subscriptions)
        
        // Process text value.
            viewModel.$userName.sink { value in
            print("👇 Did change user name:", value)
                //self.viewModel.userName = value;
                self.DancePlayer?.drawName(text: value)
        }.store(in: &subscriptions)
        
        // Process text value.
            viewModel.$userName2.sink { value in
            print("👇 Did change user name2:", value)
                //self.viewModel.userName = value;
                self.DancePlayer2?.drawName(text: value)
        }.store(in: &subscriptions)
        
        // Respond to collision events.
        arView.scene.subscribe(to: CollisionEvents.Began.self) { event in

            print("💥 Collision with \(event.entityA.name) & \(event.entityB.name)")

        }.store(in: &subscriptions)
        
        // Show physics
        //arView.debugOptions = [.showPhysics]

        // Set session delegate.
        arView.session.delegate = self
    }


    // Helper method for creating a detection image.
    func makeDetectionImage(named: String, referenceName: String, physicalWidth: CGFloat) -> ARReferenceImage? {
        guard let targetImage = UIImage(named: named)?.cgImage else {
            print("❗️ Error loading target image:", named)
            return nil
        }

        let arReferenceImage  = ARReferenceImage(targetImage, orientation: .up, physicalWidth: physicalWidth)
        arReferenceImage.name = referenceName

        return arReferenceImage
    }
    
    // Process UI signals.
    func processUISignal(_ signal: ViewModel.UISignal) {
        switch signal {
            case .menuPress:
                print("👇 Did press reset button")
                // Reset scene and all anchors.
                arView.scene.anchors.removeAll()
                subscriptions.removeAll()
                
                setupScene()
                setupEntities()
                break;
            case .pose1Press:
                if(self.viewModel.currGameMode == GameMode.dance1){
                    print("👇 set house dance")
                    DancePlayer?.switchModel(poseType: DancePoses.houseDance)
                 }
                else{
                    DancePlayer2?.switchModel(poseType: DancePoses.houseDance)
                }
        
                break;
                
            case .pose2Press:
            print("👇 set chicken dance")
                 if(self.viewModel.currGameMode == GameMode.dance1){
                    DancePlayer?.switchModel(poseType: DancePoses.chickenDance)
                 }
                else{
                    DancePlayer2?.switchModel(poseType: DancePoses.chickenDance)
                }
                break;
                
            case .pose3Press:
            print("👇 set robot dance")

                if(self.viewModel.currGameMode == GameMode.dance1){
                    DancePlayer?.switchModel(poseType: DancePoses.robotDance)
                 }
                else{
                    DancePlayer2?.switchModel(poseType: DancePoses.robotDance)
                }
                break;
                
            case .pose4Press:
                if(self.viewModel.currGameMode == GameMode.dance1){
                    print("👇 set silly dance")
                    DancePlayer?.switchModel(poseType: DancePoses.sillyDance)
                 }
                else{
                    DancePlayer2?.switchModel(poseType: DancePoses.sillyDance)
                }
                break;
        }
    }

    // Called when an anchor is added to scene.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // Handle image anchors.
        anchors.compactMap { $0 as? ARImageAnchor }.forEach {
            // Grab reference image name.
            guard let referenceImageName = $0.referenceImage.name else { return }

            // Create anchor and place at image location.
            let anchorEntity = AnchorEntity(world: $0.transform)
            arView.scene.addAnchor(anchorEntity)
            
            // Setup logic based on reference image.
            
            if referenceImageName == "DANCE_TARGET" {
                print("calling session for The Little Fourteen-Year-Old Dancer");
                setupEntitiesForDanceImage1(anchorEntity: anchorEntity)
                
                
            } else if referenceImageName == "DANCE_TARGET_2" {
                setupEntitiesForDanceImage2(anchorEntity: anchorEntity)
            }
        }
    }


    // Setup method for non image anchor entities.
    func setupEntities() {
        
        // Create an anchor at scene origin.
        originAnchor = AnchorEntity(world: .zero)
        arView.scene.addAnchor(originAnchor)
        
        // Add pov entity that follows the camera.
        pov = AnchorEntity(.camera)
        arView.scene.addAnchor(pov)
    }

    // IMPORTANT: Attach to anchor entity. Called when image target is found.
    func setupEntitiesForDanceImage1(anchorEntity: AnchorEntity) {
        self.viewModel.currGameMode = GameMode.dance1;
                
        DancePlayer = DanceUser()
        DancePlayer?.position.z = 0.15
        anchorEntity.addChild(DancePlayer!)
        DancePlayer?.disableModels()
        DancePlayer?.standingModel.isEnabled = true;
        DancePlayer?.animateSelf(currModel: (DancePlayer?.standingModel)!)
        
        arView.installGestures([.translation], for: DancePlayer!)

    }

    func setupEntitiesForDanceImage2(anchorEntity: AnchorEntity) {
        self.viewModel.currGameMode = GameMode.dance2;
        
        DancePlayer?.collision = nil;
        DancePlayer?.position.x = DancePlayer?.prevX ?? 0;
        DancePlayer?.position.y = DancePlayer?.prevY ?? 0;
        DancePlayer?.position.z = DancePlayer?.prevZ ?? 0;
        
        anchorEntity.addChild(DancePlayer!)

        DancePlayer2 = DanceUser()
        DancePlayer2?.position.z = 0.15
        DancePlayer2?.disableModels()
        DancePlayer2?.standingModel.isEnabled = true;
        DancePlayer2?.animateSelf(currModel: (DancePlayer2?.standingModel) as! Entity)
        
        anchorEntity.addChild(DancePlayer2!)

        arView.installGestures([.translation], for: DancePlayer2!)
        
    }

}

class DanceUser: Entity, HasModel, HasCollision {
    var houseDance: Entity!
    var chickenDance: Entity!
    var sillyDance: Entity!
    var robotDance: Entity!
    var standingModel: Entity!
    var userNameText: Entity!
    
    let restX: Float = 0.03 ;
    
    var prevX : Float = 0.0;
    var prevY: Float = 0;
    var prevZ: Float = 0;

    
    required init(){
         super.init()

        houseDance = try! Entity.load(named: "house-dance")
        houseDance.scale = [0.001,0.001,0.001]
        houseDance.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        self.addChild(houseDance)

        chickenDance = try! Entity.load(named: "chicken-dance")
        chickenDance.scale = [0.001,0.001,0.001]
        chickenDance.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        self.addChild(chickenDance)

        sillyDance = try! Entity.load(named: "silly-dancing")
        sillyDance.scale = [0.001,0.001,0.001]
        sillyDance.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        self.addChild(sillyDance)
        
        robotDance = try! Entity.load(named: "robot-hip-hop")
        robotDance.scale = [0.001,0.001,0.001]
        robotDance.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        self.addChild(robotDance)

        standingModel = try! Entity.load(named: "standing-idle")
        standingModel.scale = [0.001,0.001,0.001]
        standingModel.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        self.addChild(standingModel)
        
        let collX: Float = (50 * 0.001)
        let collY: Float = (50 * 0.001)
        let collZ: Float = (200 * 0.001)
        
        let box: ShapeResource = .generateBox(size: [collX,collY,collZ]).offsetBy(translation: [0,0,-0.07])
        self.collision = CollisionComponent(shapes: [box])
        
        drawName(text: "", firstTime: true)

    }
    
    func disableModels(){
        houseDance.isEnabled = false;
        chickenDance.isEnabled = false
        sillyDance.isEnabled = false;
        robotDance.isEnabled = false;
        standingModel.isEnabled = false
    }
    
    func animateSelf(currModel: Entity){
         for animation in currModel.availableAnimations {
            currModel.playAnimation(animation.repeat())
        }
    }
    
    func drawName(text: String, firstTime: Bool = false){
        if(firstTime == false){
            self.removeChild(userNameText)
        }
 
        //Player text:
        let meshFont = MeshResource.Font(name: "Roboto Thin", size: 0.025)!

        let textMesh = MeshResource.generateText(text,
                                                  extrusionDepth: 0.025,
                                                 font: meshFont)

        let textMaterial  = SimpleMaterial(color: .blue, isMetallic: false)
        userNameText = ModelEntity(mesh: textMesh, materials: [textMaterial])
        userNameText.orientation *= simd_quatf(angle: -.pi / 2, axis: [1,0,0])
        userNameText.position.z = -0.185
        userNameText.position.x -= Float(Float(text.count) * 0.005)
            
        self.addChild(userNameText)
        
        //Save previous data:
        self.prevX = self.position.x
        self.prevY = self.position.y
        self.prevZ = self.position.z
        
        
    }
    
    
    func switchModel(poseType: DancePoses){
        switch(poseType){
        case DancePoses.idle:
            self.disableModels();
            standingModel.isEnabled = true;
            self.animateSelf(currModel: standingModel);
            break;
        case .houseDance:
            print("switch to house dance")
            self.disableModels();
            houseDance.isEnabled = true;
            self.animateSelf(currModel: houseDance);
            break;
        case .chickenDance:
            print("switch to chicken dance")
            self.disableModels();
            chickenDance.isEnabled = true;
            self.animateSelf(currModel: chickenDance);
            break;
        case .robotDance:
            print("switch to robot dance")
            self.disableModels();
            robotDance.isEnabled = true;
            self.animateSelf(currModel: robotDance);
            break;
        case .sillyDance:
            print("switch to silly dance")
            self.disableModels();
            sillyDance.isEnabled = true;
            self.animateSelf(currModel: sillyDance);
            break;
        }
    }
    
  
    
}
