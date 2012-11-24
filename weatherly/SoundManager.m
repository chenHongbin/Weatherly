//
//  SoundManager.m
//  Weatherli
//
//  Created by Ahmed Eid on 5/14/12.
//  Copyright (c) 2012 Ahmed Eid. All rights reserved.
//This file is part of Weatherli.
//
//Weatherli is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//Foobar is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with Weatherli.  If not, see <http://www.gnu.org/licenses/>.
//

#import "SoundManager.h"

SoundManager *sharedSoundManager = nil;

@implementation SoundManager
@synthesize player = _player;

+(SoundManager *)sharedSoundManager
{
    if (sharedSoundManager ==nil)
    {
        sharedSoundManager = [[super allocWithZone:NULL] init];
    }
    return sharedSoundManager;
}


#pragma mark - Singleton Stuff

- (id)init
{
    self = [super init];
    
    if (self) {
    }
    return self;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedSoundManager];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(void)playClankSound
{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/clank.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:
              [NSURL fileURLWithPath:resourcePath] error:&err];
    
    if( err ){
        NSLog(@"Failed loading sound: %@", [err localizedDescription]);
    }
    else{
        //set our delegate and begin playback
        self.player.delegate = self;
        [self.player play];
    }
}

-(void)playSwooshSound
{
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/swoosh.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                   [NSURL fileURLWithPath:resourcePath] error:&err];
    
    if( err ){
        NSLog(@"Failed loading sound: %@", [err localizedDescription]);
    }
    else{
        //set our delegate and begin playback
        self.player.delegate = self;
        [self.player play];
    }

}


@end
