//
//  SimpleMonster.h
//  Zombie
//
//  Created by Jose Carlos Noriega Defferrari on 5/12/16.
//  Copyright © 2016 Jose Carlos Noriega Defferrari. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SimpleMonster : SKSpriteNode

@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) CGPoint direction;
@property (nonatomic, assign) NSTimeInterval lastUpdateTimeInterval;
@property NSMutableArray *walkFrames;
@property (nonatomic) int frameheight;
@property (nonatomic) int framewidth;


-(void) update: (NSTimeInterval)currentTime;
+(void) initializeDirections;
+ (id) spriteNodeWithImageNamed : (NSString *) name;
- (NSMutableArray *) getWalkingFrames: (int) index;
-(int) getDirection;
-(void) frameWallAvoidance;

@end
