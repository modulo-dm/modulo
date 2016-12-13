//
//  System.m
//  modulo
//
//  Created by Sneed, Brandon on 12/13/16.
//  Copyright © 2016 TheHolyGrail. All rights reserved.
//

#import "System.h"

NSInteger modulo_system(NSString *command) {
    return system(command.UTF8String);
}
