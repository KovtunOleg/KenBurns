//
//  ImageTableViewController.m
//  KenBurns
//
//  Created by Oleg Kovtun on 12.03.13.
//  Copyright (c) 2013 Oleg Kovtun. All rights reserved.
//

#import "ImageTableViewController.h"
#import "ImageCell.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "VideoMap.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ImageTableViewController () <ELCImagePickerControllerDelegate>
@property (nonatomic,copy) VideoMap* tempVideoMap;
@end

@implementation ImageTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tempVideoMap = [VideoMap instance];
        [self setupNavigationButtons];
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.editing = YES;
    }
    return self;
}

#pragma mark - Actions

- (void) doneButtonAction {
    [VideoMap updateWithVideoMap:self.tempVideoMap];
    
    if ( self.onDoneBlock ) {
        self.onDoneBlock();
    }
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void) addButtonAction {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
	[self presentModalViewController:elcPicker animated:YES];
}

- (void) cancelButtonAction {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Setups

- (void) setupNavigationButtons {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction)];
    self.navigationItem.rightBarButtonItems = @[addButton,doneButton];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tempVideoMap images].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if ( imageCell == nil ) {
        imageCell = [ImageCell imageCell];
    }
    [imageCell setImageVideo:[self.tempVideoMap images][indexPath.row]];
    return imageCell;
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.tempVideoMap removeMapAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

// Override to support rearranging the table view.
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.tempVideoMap moveMapFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ImageCell height];
}

#pragma mark - ELCImagePickerControllerDelegate

- (void) elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infoArray {
    [self dismissModalViewControllerAnimated:YES];

    for (NSDictionary *info in infoArray) {
        
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        NSString *key = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
        
        if ([mediaType isEqualToString:ALAssetTypePhoto] && ![self.tempVideoMap containsInfo:key]) {
            UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self.tempVideoMap addMapWithImage:image info:key];
        }
    }
    [self.tableView reloadData];
}

- (void) elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end
