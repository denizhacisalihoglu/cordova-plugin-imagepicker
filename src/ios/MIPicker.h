//
//  MIPicker.h
//  GMPhotoPicker
//
//  Created by lihau on 5/2/16.
//  Copyright © 2016 Guillermo Muntaner Perelló. All rights reserved.
//
#import <Cordova/CDVPlugin.h>

@interface MIPicker : CDVPlugin

@property (copy) NSString* callbackId;

- (void) pick:(CDVInvokedUrlCommand *)command;

@end
