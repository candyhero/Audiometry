//
//  GameScene.swift
//  AudiometryProto
//
//  Created by Xavier Chan on 7/26/17.
//  Copyright © 2017 Xavier Chan. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioKit

var pbLeft : SKSpriteNode!
var pbRight : SKSpriteNode!

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        // Setup scene
        let tempTexture = SKTexture(imageNamed: "Button0_01")
        pbLeft = SKSpriteNode(texture: tempTexture)
        
        pbLeft.position = CGPoint(x: 0, y: 0)
        self.addChild(pbLeft)
        
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
