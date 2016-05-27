//
//  GameScene.m
//  Zombie
//
//  Created by Jose Carlos Noriega Defferrari on 4/21/16.
//  Copyright (c) 2016 Jose Carlos Noriega Defferrari. All rights reserved.
//

#import "GameScene.h"
#import "SimpleMonster.h"
#define kMinDistance    25
#define kMinDuration    0.1
#define kMinSpeed       100
#define kMaxSpeed       500

@interface GameScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) CGPoint faceDirection;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic, strong) NSMutableArray * monsters;
@end

static const uint32_t limitCategory = 0x1 << 0;
static const uint32_t playerCategory = 0x1 << 1;
static const uint32_t projectileCategory = 0x1 << 2;

@implementation GameScene
CGPoint start;
NSTimeInterval startTime;
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.monsters = [NSMutableArray array];
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.physicsWorld.gravity = CGVectorMake(0,0);
        
        self.faceDirection = CGPointMake(1,0);
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"Player2-1"];
        self.player.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.allowsRotation = NO;
        
        CGSize sceneSize = self.frame.size;
        CGFloat lowerXlimit = self.player.size.width/2;
        CGFloat lowerYlimit = self.player.size.height/2;
        CGFloat upperXlimit = sceneSize.width - self.player.size.width/2;
        CGFloat upperYlimit = sceneSize.height - self.player.size.height/2;
        SKConstraint *constraint = [SKConstraint
                                    positionX:[SKRange rangeWithLowerLimit:lowerXlimit upperLimit:upperXlimit]
                                    Y:[SKRange rangeWithLowerLimit:lowerYlimit upperLimit:upperYlimit]];
        self.player.constraints = @[constraint];
        NSLog(@"first time = %g",self.lastUpdateTimeInterval);
        [self addChild:self.player];
        
        [SimpleMonster initializeDirections];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
     SKNode* obj;
     
     if ([obj isKindOfClass:[GameScene class]]) {
     [((GameScene*)obj) ]
     }
     
     
     /* Avoid multi-touch gestures (optional) */
    if ([touches count] > 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Save start location and time
    start = location;
    startTime = touch.timestamp;
}

- (SimpleMonster * )addMonster: (NSTimeInterval)currentTime {
    
    // Create sprite
    SimpleMonster * monster = [SimpleMonster spriteNodeWithImageNamed:@"monster"];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size]; // 1
    monster.physicsBody.dynamic = YES; // 2
    //monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
    monster.userData = [[NSMutableDictionary alloc] initWithDictionary:@{@"Damage":@(25)}];
    
    [monster update: currentTime];
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    int minX = monster.size.width / 2;
    int maxX = self.frame.size.width - monster.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    
    monster.position = CGPointMake(actualX, actualY);
    monster.physicsBody.velocity=CGVectorMake(monster.direction.x*30, monster.direction.y*30);
    monster.physicsBody.linearDamping = 0; //You may want to remove the air-resistance external force.
    monster.physicsBody.affectedByGravity = false;
    
    CGSize sceneSize = self.frame.size;
    CGFloat lowerXlimit = monster.size.width/2;
    CGFloat lowerYlimit = monster.size.height/2;
    CGFloat upperXlimit = sceneSize.width - monster.size.width/2;
    CGFloat upperYlimit = sceneSize.height - monster.size.height/2;
    SKConstraint *constraint = [SKConstraint
                                positionX:[SKRange rangeWithLowerLimit:lowerXlimit upperLimit:upperXlimit]
                                Y:[SKRange rangeWithLowerLimit:lowerYlimit upperLimit:upperYlimit]];
    monster.constraints = @[constraint];
    
    [self addChild:monster];
    return monster;
    
    
    /* // Determine speed of the monster
     int minDuration = 2.0;
     int maxDuration = 4.0;
     int rangeDuration = maxDuration - minDuration;
     int actualDuration = (arc4random() % rangeDuration) + minDuration;
     
     // Create the actions
     SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
     SKAction * actionMoveDone = [SKAction removeFromParent];
     [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
     */
}

- (void)update:(NSTimeInterval)currentTime {
    NSTimeInterval interval = currentTime - self.lastUpdateTimeInterval;
    if (interval >= 5) {
        self.lastUpdateTimeInterval = currentTime;
        [self.monsters addObject: [self addMonster: currentTime]];
    }
    
    for (SimpleMonster * monster in self.monsters)
    {
        [monster update:currentTime];
    }
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    /*
     CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
     self.lastUpdateTimeInterval = currentTime;
     if (timeSinceLast > 1) { // more than a second since last update
     timeSinceLast = 1.0 / 60.0;
     self.lastUpdateTimeInterval = currentTime;
     }
     
     [self updateWithTimeSinceLastUpdate:timeSinceLast]; */
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Determine distance from the starting point
    CGFloat dx = location.x - start.x;
    CGFloat dy = location.y - start.y;
    CGFloat magnitude = sqrt(dx*dx+dy*dy);
    if (magnitude >= kMinDistance) {
        // Determine time difference from start of the gesture
        CGFloat dt = touch.timestamp - startTime;
        if (dt > kMinDuration) {
            // Determine gesture speed in points/sec
            CGFloat speed = magnitude / dt;
            if (speed >= kMinSpeed && speed <= kMaxSpeed) {
                // Calculate normalized direction of the swipe
                dx = dx / magnitude;
                dy = dy / magnitude;
                NSLog(@"Swipe detected with speed = %g and direction (%g, %g)",speed, dx, dy);
                CGFloat absY = fabs(dy);
                CGFloat absX = fabs(dx);
                CGFloat playerX = self.player.position.x;
                CGFloat playerY = self.player.position.y;
                CGPoint direction;
                NSMutableArray *walkingFrames = [NSMutableArray array];
                SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"Player"];
                int index = 0;
                int j;
                if (absY > absX) {
                    if (dy < 0) {
                        direction = CGPointMake(playerX, playerY - 1000);
                        self.faceDirection = CGPointMake(0, -1);
                        index = 2;
                    } else {
                        direction = CGPointMake(playerX, playerY + 1000);
                        self.faceDirection = CGPointMake(0, 1);
                        index = 0;
                    }
                } else {
                    if (dx < 0) {
                        direction = CGPointMake(playerX - 1000, playerY);
                        self.faceDirection = CGPointMake(-1, 0);
                        index = 3;
                    } else {
                        direction = CGPointMake(playerX + 1000, playerY);
                        self.faceDirection = CGPointMake(1, 0);
                        index = 1;
                    }
                }
                for (j=0; j<=3; j++) {
                    NSString * textureName = [NSString stringWithFormat:@"Player%d-%d", index, j];
                    SKTexture * texture = [playerAnimatedAtlas textureNamed:textureName];
                    [walkingFrames addObject:texture];
                }
                [self removeActionForKey:@"walkingHero"];
                SKAction * animation = [SKAction repeatActionForever:
                                        [SKAction animateWithTextures: walkingFrames
                                                         timePerFrame:0.125f
                                                               resize:NO
                                                              restore:YES]];
                SKAction * move = [SKAction moveTo:direction duration:15];
                SKAction * group = [SKAction group:@[animation, move]];

                [self.player runAction: group];
            }
        }
    } else {
        // 2 - Set up initial location of projectile
        [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
        SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
        projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
        projectile.physicsBody.dynamic = YES;
        projectile.physicsBody.categoryBitMask = projectileCategory;
        projectile.physicsBody.collisionBitMask = 0;
        projectile.physicsBody.usesPreciseCollisionDetection = YES;
        CGFloat projectilePositionX;
        CGFloat projectilePositionY;
        if (self.faceDirection.x != 0) {
            //looking horizontally
            projectilePositionX = self.player.position.x +
            self.faceDirection.x *(self.player.size.width/2 + projectile.size.width/2);
            projectilePositionY = self.player.position.y;
        } else {
            //looking vertically
            projectilePositionX = self.player.position.x;
            projectilePositionY = self.player.position.y +
            self.faceDirection.y *(self.player.size.height/2 + projectile.size.width/2);
        }
        projectile.position = CGPointMake(projectilePositionX, projectilePositionY);
        [self addChild:projectile];
        CGPoint projectileDestination = CGPointMake(self.player.position.x + self.faceDirection.x*1000,
                                                    self.player.position.y + self.faceDirection.y*1000);
        SKAction * actionMove = [SKAction moveTo:projectileDestination duration:5];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    }
}


@end

