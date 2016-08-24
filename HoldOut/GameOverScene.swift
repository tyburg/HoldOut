import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.whiteColor()
        
        // 2
        let message = won ? "We are saved!" : "The city was overrun!"
        //let victoryMusic = SKAudioNode(fileNamed: "victory.mp3")
        
        // 3
        let label = SKLabelNode(fontNamed: "Futura")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        /*if (won) {
            victoryMusic.autoplayLooped = true
            addChild(victoryMusic)
        }*/
        
        // 4
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
                //victoryMusic.removeFromParent()
            }
            ]))
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}