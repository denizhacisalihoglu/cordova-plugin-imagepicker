//
//  GMImagePickerController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
@import Photos;

@interface GMImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@end

@implementation GMImagePickerController

- (id)init{
    return [self initWithSelection:@[] withLimit: 1];
}

- (id) initWithSelection:(NSArray *)selection withLimit:(int)limit
{
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        for (PHAsset* asset in selection) {
            [_selectedAssets addObject:asset];
        }

        _maxLimit = limit;

        // Default values:
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        _autoDisableDoneButton = YES;
        _allowsMultipleSelection = YES;
        _confirmSingleSelection = NO;
        _showCameraButton = NO;

        // Grid configuration:
        _colsInPortrait = 3;
        _colsInLandscape = 5;
        _minimumInteritemSpacing = 2.0;

        // Sample of how to select the collections you want to display:
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        // If you don't want to show smart collections, just put _customSmartCollections to nil;
        //_customSmartCollections=nil;

        //image only
        _mediaTypes = @[@(PHAssetMediaTypeImage)];
//                        @[@(PHAssetMediaTypeAudio),
//                        @(PHAssetMediaTypeVideo),
//                        @(PHAssetMediaTypeImage)];

        self.preferredContentSize = kPopoverContentSize;

        // UI Customisation
        _pickerBackgroundColor = [UIColor whiteColor];
        _pickerTextColor = [UIColor darkTextColor];
        _pickerFontName = @"HelveticaNeue";
        _pickerBoldFontName = @"HelveticaNeue-Bold";
        _pickerFontNormalSize = 14.0f;
        _pickerFontHeaderSize = 17.0f;

        _navigationBarBackgroundColor = [UIColor whiteColor];
        _navigationBarTextColor = [UIColor darkTextColor];
        _navigationBarTintColor = [UIColor darkTextColor];

        _toolbarBarTintColor = [UIColor whiteColor];
        _toolbarTextColor = [UIColor darkTextColor];
        _toolbarTintColor = [UIColor darkTextColor];

        _pickerStatusBarStyle = UIStatusBarStyleDefault;

        [self setupNavigationController];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Ensure nav and toolbar customisations are set. Defaults are in place, but the user may have changed them
    self.view.backgroundColor = _pickerBackgroundColor;

    _navigationController.toolbar.translucent = YES;
    _navigationController.toolbar.barTintColor = _toolbarBarTintColor;
    _navigationController.toolbar.tintColor = _toolbarTintColor;
    [(UIView*)[_navigationController.toolbar.subviews objectAtIndex:0] setAlpha:0.75f];  // URGH - I know!

    _navigationController.navigationBar.backgroundColor = _navigationBarBackgroundColor;
    _navigationController.navigationBar.tintColor = _navigationBarTintColor;
    //status bar color follow navigation bar
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIApplication sharedApplication].statusBarFrame.size.width, 22)];
    statusBarView.backgroundColor = _navigationBarBackgroundColor;
    [_navigationController.navigationBar addSubview: statusBarView];

    NSDictionary *attributes;
    if (_useCustomFontForNavigationBar) {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor,
                       NSFontAttributeName : [UIFont fontWithName:_pickerBoldFontName size:_pickerFontHeaderSize]};
    } else {
        attributes = @{NSForegroundColorAttributeName : _navigationBarTextColor};
    }
    _navigationController.navigationBar.titleTextAttributes = attributes;

    [self updateToolbar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _pickerStatusBarStyle;
}


#pragma mark - Setup Navigation Controller

- (void)setupNavigationController
{
    GMAlbumsViewController *albumsViewController = [[GMAlbumsViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
    _navigationController.delegate = self;

    _navigationController.navigationBar.translucent = YES;
    [_navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _navigationController.navigationBar.shadowImage = [UIImage new];

    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Only if OK was pressed do we want to completge the selection
        [self finishPickingAssets:self];
    }
}


#pragma mark - Select / Deselect Asset

- (void)selectAsset:(PHAsset *)asset
{
    if (self.selectedAssets.count < _maxLimit) {
        [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
        [self updateDoneButton];
    }

    if (!self.allowsMultipleSelection) {
        if (self.confirmSingleSelection) {
            NSString *message = self.confirmSingleSelectionPrompt ? self.confirmSingleSelectionPrompt : [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.message",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Do you want to select the image you tapped on?")];

            [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.confirm.title",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Are You Sure?")]
                                        message:message
                                       delegate:self
                              cancelButtonTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.no",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"No")]
                              otherButtonTitles:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"picker.action.yes",  @"GMImagePicker", [NSBundle bundleForClass:GMImagePickerController.class],  @"Yes")], nil] show];
        } else {
            [self finishPickingAssets:self];
        }
    } else if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    if (self.selectedAssets.count == 0) {
        [self updateDoneButton];
    }

    if (self.displaySelectionInfoToolbar || self.showCameraButton) {
        [self updateToolbar];
    }
}

- (BOOL)canSelectAsset{
    return self.selectedAssets.count < _maxLimit;
}



- (void)updateDoneButton
{
    if (!self.allowsMultipleSelection) {
        return;
    }

    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = (self.autoDisableDoneButton ? self.selectedAssets.count > 0 : TRUE);
    }
}

- (void)updateToolbar
{
    if (!self.allowsMultipleSelection && !self.showCameraButton) {
        return;
    }

    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        NSUInteger index = 1;
        if (_showCameraButton) {
            index++;
        }
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateNormal];
        [[viewController.toolbarItems objectAtIndex:index] setTitleTextAttributes:[self toolbarTitleTextAttributes] forState:UIControlStateDisabled];
        [[viewController.toolbarItems objectAtIndex:index] setTitle:[self toolbarTitle]];
        [viewController.navigationController setToolbarHidden:(self.selectedAssets.count == 0 && !self.showCameraButton) animated:YES];
    }
}


#pragma mark - User finish Actions

- (void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType == type);
    }];
}

- (NSString *)toolbarTitle
{
    if (self.allowsMultipleSelection) {
        return [NSString stringWithFormat:@"%lu of %lu Selected", (unsigned long)self.selectedAssets.count, (unsigned long)_maxLimit];
    }else{
        return nil;
    }
}

#pragma mark - Toolbar Items

- (void)cameraButtonPressed:(UIBarButtonItem *)button
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera!"
                                                        message:@"Sorry, this device does not have a camera."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        return;
    }

    // This allows the selection of the image taken to be better seen if the user is not already in that VC
    if (self.autoSelectCameraImages && [self.navigationController.topViewController isKindOfClass:[GMAlbumsViewController class]]) {
        [((GMAlbumsViewController *)self.navigationController.topViewController) selectAllAlbumsCell];
    }

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationPopover;

    UIPopoverPresentationController *popPC = picker.popoverPresentationController;
    popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPC.barButtonItem = button;

    [self showViewController:picker sender:button];
}

- (NSDictionary *)toolbarTitleTextAttributes {
    return @{NSForegroundColorAttributeName : _toolbarTextColor,
             NSFontAttributeName : [UIFont fontWithName:_pickerFontName size:_pickerFontHeaderSize]};
}

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:nil];

    NSDictionary *attributes = [self toolbarTitleTextAttributes];
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];

    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (UIBarButtonItem *)cameraButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed:)];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *camera = [self cameraButtonItem];
    UIBarButtonItem *title  = [self titleButtonItem];
    UIBarButtonItem *space  = [self spaceButtonItem];

    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_showCameraButton) {
        [items addObject:camera];
    }
    [items addObject:space];
    [items addObject:title];
    [items addObject:space];

    return [NSArray arrayWithArray:items];
}


#pragma mark - Camera Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Not Saved"
                                                        message:@"Sorry, unable to save the new image!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    // Note: The image view will auto refresh as the photo's are being observed in the other VCs
}

@end
