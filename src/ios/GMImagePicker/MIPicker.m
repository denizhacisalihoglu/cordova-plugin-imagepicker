//
//  MIPicker.m
//  GMPhotoPicker
//
//  Created by lihau on 5/2/16.
//  Copyright © 2016 Tan Li Hau. All rights reserved.
//

#import "MIPicker.h"
#import "GMImagePickerController.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>

@interface MIPicker () <GMImagePickerControllerDelegate>
-(UIColor *)colorFromHexString:(NSString *)hexString;
@end

@implementation MIPicker

@synthesize callbackId;

#pragma mark - GMImagePickerControllerDelegate
- (void) pick:(CDVInvokedUrlCommand *)command{
    self.callbackId = command.callbackId;

    BOOL showCamera = [[command.arguments objectAtIndex:0] boolValue];
    int selectLimit = [[command.arguments objectAtIndex:1] intValue];
    BOOL selectMultiple = [[command.arguments objectAtIndex:2] boolValue];
    NSArray* selected = [command.arguments objectAtIndex:3];
    NSDictionary* options = [command.arguments objectAtIndex:4] ?: [NSDictionary dictionary];
    UIColor* themeColor = [self colorFromHexString:(options[@"themeColor"] ?: @"#000000")];
    UIColor* textColor = [self colorFromHexString:(options[@"textColor"] ?: @"#000000")];

    [self.commandDelegate runInBackground:^{
        NSMutableArray *ids = [NSMutableArray array];
        for (NSDictionary *obj in selected) {
            [ids addObject:[obj objectForKey:@"id"]];
        }

        //based on id get PHAsset
        PHFetchResult* results = [PHAsset fetchAssetsWithLocalIdentifiers:ids options:nil];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[results count]];
        for (PHAsset *result in results) {
            [array addObject:result];
        }

        // set up picker
        GMImagePickerController *picker = [[GMImagePickerController alloc] initWithSelection:array withLimit:selectLimit];
        picker.delegate = self;
        picker.title = @"Post";

        picker.customDoneButtonTitle = @"Done";
        picker.customCancelButtonTitle = @"Cancel";

        picker.colsInPortrait = 3;
        picker.colsInLandscape = 5;
        picker.minimumInteritemSpacing = 2.0;

        if (!selectMultiple) {
            picker.allowsMultipleSelection = NO;
        }

        picker.showCameraButton = showCamera;
        picker.autoSelectCameraImages = YES;

        picker.modalPresentationStyle = UIModalPresentationPopover;

        //image only
        picker.mediaTypes = @[@(PHAssetMediaTypeImage)];

        //styles
        picker.toolbarBarTintColor = themeColor;
        picker.toolbarTextColor = textColor;
        picker.toolbarTintColor = textColor;
        picker.navigationBarBackgroundColor = themeColor;
        picker.navigationBarTextColor = textColor;
        picker.navigationBarTintColor = textColor;
        picker.pickerStatusBarStyle = UIStatusBarStyleLightContent;

        [self.viewController showViewController:picker sender:nil];
    }];
}

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);

        int total = (int)[assetArray count];
        __block int count = 0;
        NSMutableArray* result = [NSMutableArray array];

        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        for (PHAsset* asset in assetArray) {
            [asset requestContentEditingInputWithOptions: options completionHandler: ^(PHContentEditingInput *contentEditingInput, NSDictionary* info){
                [result addObject:@{ @"image": [contentEditingInput.fullSizeImageURL absoluteString], @"id": [asset localIdentifier]}];
                if(++count == total){
                    //do something
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
                }
            }];
        }
    }];
}

//Optional implementation:
-(void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker {
    NSLog(@"GMImagePicker: User pressed cancel button");
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldSelectAsset:(PHAsset *)asset{
    return picker.canSelectAsset;
}


// Util
// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
