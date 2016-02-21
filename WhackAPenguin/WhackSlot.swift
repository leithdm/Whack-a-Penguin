//
//  WhackSlot.swift
//  WhackAPenguin
//
//  Created by DML_Admin on 04/11/2015.
//  Copyright © 2015 DML_Admin. All rights reserved.
//

import SpriteKit
import UIKit

//SKNode is the parent node for all children
class WhackSlot: SKNode {

  //to store the penguin picture node
  var charNode: SKSpriteNode!

  var visible = false
  var isHit = false

  //position of the whackHole
  func configurePosition(pos: CGPoint) {
    position = pos
    let sprite = SKSpriteNode(imageNamed: "whackHole")
    addChild(sprite) //add to the slot

    //a new cropnode, positioned slightly higher than the slot itself
    let cropNode = SKCropNode()
    cropNode.position = CGPoint(x: 0, y: 15)
    cropNode.zPosition = 1 //to the front of the other nodes
//    cropNode.maskNode = nil //useful for testing positions
    cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")

    //create character node
    charNode = SKSpriteNode(imageNamed: "penguinGood")
    charNode.position = CGPoint(x: 0, y: -90) //way below the hole i.e. penguin is hiding
    charNode.name = "character"
    cropNode.addChild(charNode) //character node added to the cropnode, and the cropnode to the slot

    addChild(cropNode)
  }

  func show(hideTime hideTime: Double) {
    if visible { return }

    charNode.xScale = 1
    charNode.yScale = 1
    charNode.runAction(SKAction.moveByX(0, y: 80, duration: 0.05))
    visible = true
    isHit = false

    if RandomInt(min: 0, max: 2) == 0 {
      charNode.texture = SKTexture(imageNamed: "penguinGood")
      charNode.name = "charFriend"
    } else {
      charNode.texture = SKTexture(imageNamed: "penguinEvil")
      charNode.name = "charEnemy"
    }

    RunAfterDelay(hideTime * 3.5) { [unowned self] in
      self.hide()
    }
  }

  func hide() {
    if !visible { return }
    charNode.runAction(SKAction.moveByX(0, y: -80, duration: 0.07))
    visible = false
  }

  func hit() {
    isHit = true

    //WAITFORDURATION() creates an action that waits for a period of time, measured in seconds
    let delay = SKAction.waitForDuration(0.25)

    let hide = SKAction.moveByX(0, y: -80, duration: 0.05)

    //RUNBLOCK() will run any code we want, provided as a closure. Better to hide the penguin as part of a sequence, rather than doing it directly.
    let notVisible = SKAction.runBlock { [unowned self] in self.visible = false }

    //SEQUENCE() takes an array of actions, and executes them in order.
    charNode.runAction(SKAction.sequence([delay, hide, notVisible]))

  }
}
