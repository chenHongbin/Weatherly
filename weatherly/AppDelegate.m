//
//  AppDelegate.m
//  weatherly
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

#import "AppDelegate.h"
#import "WeatherViewController.h"
#import "WeatherManager.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    
    [[WeatherManager sharedWeatherManager] startUpdatingLocation];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    WeatherViewController *viewController = [[WeatherViewController alloc] init];
    [WeatherManager sharedWeatherManager].delegate = viewController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     [[WeatherManager sharedWeatherManager] startUpdatingLocation];
}


@end
