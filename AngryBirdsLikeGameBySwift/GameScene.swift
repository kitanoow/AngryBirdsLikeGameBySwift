//
//  GameScene.swift
//  AngryBirdsLikeGameBySwift
//
//  Created by kitano on 2014/08/31.
//  Copyright (c) 2014年 OneWorld Inc. All rights reserved.
//

import SpriteKit

enum GameStatus:Int{
    case kDragNone=0,  //初期値
    kDragStart, //Drag開始
    kDragEnd   //Drag終了
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    var ball:SKSpriteNode!;
    var target:SKSpriteNode!;
    var gameStatus:Int = 0;
    var startPos:CGPoint!;
    var sprtical_flg:Bool = false;
    var myWorld:SKNode = SKNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        var size:CGSize = view.frame.size
        
        self.backgroundColor = UIColor(red:0.15,green:0.15,blue:0.3,alpha:1.0)
        self.anchorPoint = CGPointMake(0.5, 0.5)
        myWorld.name = "world"
        self.addChild(myWorld)
        
        var camera:SKNode = SKNode()
        camera.name = "camera";
        myWorld.addChild(camera)
        
        
        //地面
        var ground:SKSpriteNode = SKSpriteNode(color: SKColor.brownColor(),
            size:CGSizeMake(size.width*10,size.height))
        ground.position = CGPointMake(0, -ground.size.height + 30);
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody!.dynamic = false;
        myWorld.addChild(ground)
        
        //ボール
        ball = SKSpriteNode(imageNamed:"ball.png")
        ball.position = CGPointMake(0, -20);
        ball.name = "ball";
        ball.physicsBody = SKPhysicsBody(circleOfRadius:ball.size.width/2)
        ball.physicsBody!.dynamic = false;
        myWorld.addChild(ball)
        
        
        //障害物
        var start_x:Int = 500;
        var sprite:SKSpriteNode = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(15,80))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody!.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(CGFloat(start_x + 100),-90);
        myWorld.addChild(sprite)
        
        sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(15,80))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody!.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(CGFloat(start_x + 200),-90);
        myWorld.addChild(sprite)
        
        sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(150,15))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody!.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(CGFloat(start_x + 150),-50);
        myWorld.addChild(sprite)
        
        sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(15,50))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody!.categoryBitMask = 0x1 << 0;
        sprite.position = CGPointMake(CGFloat(start_x + 120),-20);
        myWorld.addChild(sprite)
        
        sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(15,50))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody!.categoryBitMask = 0x1 << 0;
        sprite.position = CGPointMake(CGFloat(start_x + 180),-20);
        myWorld.addChild(sprite)
        
        sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(100,15))
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.position = CGPointMake(CGFloat(start_x + 150),0);
        sprite.physicsBody!.categoryBitMask = 0x1 << 0;
        myWorld.addChild(sprite)
        
        target = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(15,15))
        target.physicsBody = SKPhysicsBody(rectangleOfSize: target.size)
        target.physicsBody!.contactTestBitMask = 0x1 << 0;
        target.position = CGPointMake(CGFloat(start_x + 150),-35);
        myWorld.addChild(target)
        
        self.physicsWorld.contactDelegate = self;

        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            
            let location = touch.locationInNode(self)
            
            var node:SKNode! = self.nodeAtPoint(location);
            if(node != nil){
                if(node.name=="ball"){
                    gameStatus = GameStatus.kDragStart.rawValue;
                    startPos = location;
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if(gameStatus == GameStatus.kDragStart.rawValue ){
            var touch:UITouch = touches.anyObject() as UITouch;
            var touchPos:CGPoint = touch.locationInNode(self) ;
            ball.position = touchPos;
        }
        
        
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(gameStatus == GameStatus.kDragStart.rawValue  ){
            gameStatus = GameStatus.kDragEnd.rawValue ;
            
            var touch:UITouch = touches.anyObject() as UITouch;
            var endPos:CGPoint = touch.locationInNode(self) ;
            //x,yの移動距離を算出
            var diff:CGPoint = CGPointMake(startPos.x - endPos.x, startPos.y - endPos.y);
            ball.physicsBody!.dynamic = true;
            //yを少し大きく
            ball.physicsBody!.applyForce(CGVectorMake(diff.x * 20 , diff.y * 50))
            
            var scaleOut:SKAction = SKAction.scaleTo(0.5,duration:0.2);
            var moveUp:SKAction   = SKAction.moveByX(0,y:-100,duration:0.2);
            var scale1:SKAction   = SKAction.group([scaleOut,moveUp]);
            var delay:SKAction    = SKAction.waitForDuration(1.0);
            var scaleIn:SKAction  = SKAction.scaleTo(1,duration:1.0);
            var moveDown:SKAction = SKAction.moveByX(0,y:100,duration:1.0);
            var scale2:SKAction   = SKAction.group([scaleIn,moveDown])
            var moveSequence:SKAction = SKAction.sequence([scale1, delay,scale2]);
            myWorld.runAction(moveSequence)
            
        }
    }
    
    override func didSimulatePhysics(){
        var camera:SKNode = self.childNodeWithName("//camera")!
        if gameStatus == GameStatus.kDragEnd.rawValue && ball.position.x > 0 {
            camera.position = CGPointMake(ball.position.x, camera.position.y);
        }
        self.centerOnNode(camera)
    }
    func centerOnNode(node:SKNode) {
        if let scene:SKScene = node.scene
        {
            var cameraPositionInScene:CGPoint = scene.convertPoint(node.position, fromNode: node.parent!)
            node.parent!.position = CGPointMake(node.parent!.position.x - cameraPositionInScene.x,                                       node.parent!.position.y - cameraPositionInScene.y);
        }
    }
    
    func didBeginContact(contact:SKPhysicsContact){
        
        if !sprtical_flg {
            sprtical_flg = true;
            var path:String = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")!
            var spark:SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as SKEmitterNode!
            println(contact.contactPoint)
            spark.numParticlesToEmit = 50;
            spark.particlePosition = target.position;
            myWorld.addChild(spark)
            ball.removeFromParent();
            target.removeFromParent();
        }
        
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
