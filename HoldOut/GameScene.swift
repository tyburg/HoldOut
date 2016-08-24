//
//  GameScene.swift
//  HoldOut
//
//  Created by Tyler Burgett on 8/23/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

import SpriteKit
import Foundation

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Slash     : UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "cloud")
    let background = SKSpriteNode(imageNamed: "stormwind")
    var currentSlash:SKSpriteNode?
    var currentSecondAction:SKAction?
    
    var spawnTime = 2.0
    
    override func didMoveToView(view: SKView) {
        
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.position = CGPoint(x: size.width * 0.15, y: size.height * 0.3)
        player.zPosition = 500
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        startLevel(1)
    }
    
    
    func startLevel(level:Int) {
        switch level {
        case 1:
            // small monsters
            print("adding small monster")
            let gameSecond = SKAction.sequence([
                SKAction.runBlock(printer),
                SKAction.waitForDuration(1),
                SKAction.runBlock(stopInvation)
            ])
            
            runAction(SKAction.repeatAction(gameSecond, count: 30))
            break
        default:
            break
        }
    }
    
    
    func printer() {
        print("lol \(spawnTime)")
        decrement()
        
        let monsterSpawn = SKAction.sequence([
            SKAction.runBlock(addMonster),
            SKAction.waitForDuration(spawnTime)
        ])
        
        
        self.currentSecondAction = SKAction.repeatActionForever(monsterSpawn)
        self.runAction(currentSecondAction!, withKey: "currentSecondAction")
    }
    
   
    func stopInvation() {
        self.removeActionForKey("currentSecondAction")
        
        if (spawnTime < 0.3) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    
    func decrement() {
        if (spawnTime > 0.2) {
            spawnTime -= 0.06
        }
    }
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    func random(min min:CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "bigTrogdor")
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Slash
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        addChild(monster)
        let actualDuration = random (min: CGFloat(2.5), max: CGFloat(4.0))
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        //monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    
    func addMinion() {
        
    }
    
    
    func addBoss() {
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("screen touched")
        
        let slash:SKSpriteNode
        
        if (touches.count > 1) {
            slash = SKSpriteNode(imageNamed: "kame")
        } else {
            slash = SKSpriteNode(imageNamed: "slash")
        }
        
        slash.position = CGPoint(x: size.width * 0.23, y: size.height * 0.5)
        
        slash.physicsBody = SKPhysicsBody(rectangleOfSize: slash.size)
        slash.physicsBody?.dynamic = true
        slash.physicsBody?.categoryBitMask = PhysicsCategory.Slash
        slash.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        slash.physicsBody?.collisionBitMask = PhysicsCategory.None
        slash.physicsBody?.usesPreciseCollisionDetection = true
        
        let forceOfFury = SKAction.moveToX(slash.position.x + 1000.0, duration: 2.0)
        slash.zPosition = 500
        addChild(slash)
        slash.runAction(forceOfFury)
        self.currentSlash = slash
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.currentSlash?.removeAllActions()
        self.currentSlash?.removeFromParent()
    }
    
    
    func slashDidCollideWithMonster(slash:SKSpriteNode, monster:SKSpriteNode) {
        print ("WASTED")
        slash.removeFromParent()
        monster.removeFromParent()
        runAction(SKAction.playSoundFileNamed("swordsound.mp3", waitForCompletion: false))
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Slash != 0) {
            if let b1Node = firstBody.node, let b2Node = secondBody.node {
                slashDidCollideWithMonster(b1Node as! SKSpriteNode, monster: b2Node as! SKSpriteNode)
            }
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
