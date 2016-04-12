//
//  MIPicker.m
//  GMPhotoPicker
//
//  Created by lihau on 5/2/16.
//  Copyright © 2016 Guillermo Muntaner Perelló. All rights reserved.
//

#import "MIPicker.h"
#import "GMImagePickerController.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPluginResult.h>

@interface MIPicker () <GMImagePickerControllerDelegate>
@end

@implementation MIPicker

@synthesize callbackId;

#pragma mark - GMImagePickerControllerDelegate

- (void) pick:(CDVInvokedUrlCommand *)command{
    self.callbackId = command.callbackId;
    
    BOOL showCamera = [[command.arguments objectAtIndex:0] boolValue];
    int selectLimit = [[command.arguments objectAtIndex:1] integerValue];
    BOOL selectMultiple = [[command.arguments objectAtIndex:2] boolValue];
    NSArray* selected = [command.arguments objectAtIndex:3];
    
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
//    picker.customNavigationBarPrompt = @"Take a new photo or select an existing one!";
    
    picker.colsInPortrait = 3;
    picker.colsInLandscape = 5;
    picker.minimumInteritemSpacing = 2.0;
    
    if (!selectMultiple) {
        picker.allowsMultipleSelection = NO;
    }
    //    picker.confirmSingleSelection = YES;
    //    picker.confirmSingleSelectionPrompt = @"Do you want to select the image you have chosen?";
    
    picker.showCameraButton = showCamera;
    picker.autoSelectCameraImages = YES;
    
    picker.modalPresentationStyle = UIModalPresentationPopover;
    
    //image only
    picker.mediaTypes = @[@(PHAssetMediaTypeImage)];
    
    UIColor *hobinutColor = [UIColor colorWithRed:0.70196078431373 green:0.48235294117647 blue:0.2 alpha:1];
//    picker.pickerBackgroundColor = hobinutColor;
//    picker.pickerTextColor = [UIColor whiteColor];
    picker.toolbarBarTintColor = hobinutColor;
    picker.toolbarTextColor = [UIColor whiteColor];
    picker.toolbarTintColor = [UIColor whiteColor];
    picker.navigationBarBackgroundColor = hobinutColor;
    picker.navigationBarTextColor = [UIColor whiteColor];
    picker.navigationBarTintColor = [UIColor whiteColor];
    //    picker.pickerFontName = @"Verdana";
    //    picker.pickerBoldFontName = @"Verdana-Bold";
    //    picker.pickerFontNormalSize = 14.f;
    //    picker.pickerFontHeaderSize = 17.0f;
    picker.pickerStatusBarStyle = UIStatusBarStyleLightContent;
//    picker.useCustomFontForNavigationBar = YES;
    
    [self.viewController showViewController:picker sender:nil];
}

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"GMImagePicker: User ended picking assets. Number of selected items is: %lu", (unsigned long)assetArray.count);
    
    int total = [assetArray count];
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
}

//Optional implementation:
-(void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker
{
    NSLog(@"GMImagePicker: User pressed cancel button");
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (BOOL)assetsPickerController:(GMImagePickerController *)picker shouldSelectAsset:(PHAsset *)asset{
    return picker.canSelectAsset;
}

@end
