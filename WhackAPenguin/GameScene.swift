//
//  GameScene.swift
//  WhackAPenguin
//
//  Created by DML_Admin on 04/11/2015.
//  Copyright (c) 2015 DML_Admin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	//MARK: - properties
	
	var numRounds = 0
	var slots = [WhackSlot]()
	
	//speed at which character pops up out of hole
	var popupTime = 0.85
	
	var gameScore: SKLabelNode!
	var score: Int = 0 {
		
		didSet {
			gameScore.text = "Score: \(score)"
		}
	}
	
	//MARK: - lifecycle methods
	
	override func didMoveToView(view: SKView) {
		
		let background = SKSpriteNode(imageNamed: "whackBackground")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .Replace
		background.zPosition = -1
		addChild(background)
		
		gameScore = SKLabelNode(fontNamed: "Chalkduster")
		gameScore.text = "Score: 0"
		gameScore.position = CGPoint(x: 8, y: 8)
		gameScore.horizontalAlignmentMode = .Left
		gameScore.fontSize = 48
		addChild(gameScore)
		
		//position the slots
		for i in 0 ..< 5 { createSlotAt(CGPoint(x: 100 + (i * 170), y: 410))}
		for i in 0..<5 { createSlotAt(CGPoint(x: 180 + (i * 170), y: 320))}
		for i in 0..<5 { createSlotAt(CGPoint(x: 100 + (i * 170), y: 230))}
		for i in 0..<5 { createSlotAt(CGPoint(x: 180 + (i * 170), y: 140))}
		
		
		RunAfterDelay(2) { [unowned self] in
			self.createEnemy()
		}
		
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touch = touches.first {
			let location = touch.locationInNode(self)
			
			//figure out all the nodes that were tapped at this location
			let nodes = nodesAtPoint(location)
			//loop through all the nodes and figure out next course of action
			for node in nodes {
				
				if node.name == "charFriend" {
					//should not have whacked a friend
					let whackSlot = node.parent!.parent as! WhackSlot //parent of penguin which is cropnode, parent of cropnode which is whackslot
					//if ALREADY invisible or if ALREADY hit then continue onto next item in loop. Prevents the same penguin from being hit more than once.
					if !whackSlot.visible { continue }
					if whackSlot.isHit { continue }
					whackSlot.hit()
					score -= 5
					runAction(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
				}
				else if node.name == "charEnemy" {
					//should have whacked
					let whackSlot = node.parent!.parent as! WhackSlot
					
					if !whackSlot.visible { continue }
					if whackSlot.isHit { continue }
					
					whackSlot.charNode.xScale = 0.75
					whackSlot.charNode.yScale = 0.75
					whackSlot.hit()
					++score
					runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
					
					//        let delay = SKAction.waitForDuration(0.05)
					
					if let explosion = SKEmitterNode(fileNamed: "sliceHitEnemy") {
						explosion.position = whackSlot.position
						explosion.zPosition = 2
						let explosionAction = SKAction.runBlock { [unowned self] in self.addChild(explosion)}
						whackSlot.runAction(SKAction.sequence([explosionAction]))
					}
				}
			}
		}
	}
	
	
	//MARK: - scene setup
	
	//create slots
	func createSlotAt(pos: CGPoint) {
		let slot = WhackSlot()
		slot.configurePosition(pos)
		addChild(slot)
		slots.append(slot)
	}
	
	
	//create enemmies
	func createEnemy() {
		++numRounds
		
		if numRounds >= 30 {
			for slot in slots {
				slot.hide()
			}
			
			let gameOver = SKSpriteNode(imageNamed: "gameOver")
			gameOver.position = CGPoint(x: 512, y: 384)
			gameOver.zPosition = 1
			addChild(gameOver)
			return
		}
		
		popupTime *= 0.991
		slots = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(slots) as! [WhackSlot]
		
		//potentially up to 5 slots could be shown at any one time.
		slots[0].show(hideTime: popupTime)
		if RandomInt(min: 0, max: 12) > 4 { slots[1].show(hideTime: popupTime) }
		if RandomInt(min: 0, max: 12) > 8 { slots[2].show(hideTime: popupTime) }
		if RandomInt(min: 0, max: 12) > 10 { slots[3].show(hideTime: popupTime) }
		if RandomInt(min: 0, max: 12) > 11 { slots[4].show(hideTime: popupTime)    }
		
		let minDelay = popupTime / 2.0
		let maxDelay = popupTime * 2
		
		//randomize the speed at which a character is created. This is not to be confused with the popup time
		RunAfterDelay(RandomDouble(min: minDelay, max: maxDelay)) { [unowned self] in
			self.createEnemy()
		}
		
	}
}
