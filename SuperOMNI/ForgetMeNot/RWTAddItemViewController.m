//
//  RWTAddItemViewController.m
//  SuperOMNI
//
//  Created by Eric Tran on 7/2/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

#import "RWTAddItemViewController.h"
#import "RWTItem.h"


@interface RWTAddItemViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorIdTextField;

@property (strong, nonatomic) NSRegularExpression *uuidRegex;
@property (assign, nonatomic, getter = isNameFieldValid) BOOL nameFieldValid;
@property (assign, nonatomic, getter = isUUIDFieldValid) BOOL UUIDFieldValid;

@end

@implementation RWTAddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.saveBarButtonItem.enabled = NO;
    
    [self.nameTextField addTarget:self action:@selector(nameTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.uuidTextField addTarget:self action:@selector(uuidTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    NSString *uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
    self.uuidRegex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                               options:NSRegularExpressionCaseInsensitive
                                                                 error:nil];
}

- (void)nameTextFieldChanged:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.nameFieldValid = YES;
    } else {
        self.nameFieldValid = NO;
    }
    
    self.saveBarButtonItem.enabled = self.isNameFieldValid && self.isUUIDFieldValid;
}

- (void)uuidTextFieldChanged:(UITextField *)textField {
    NSInteger numberOfMatches = [self.uuidRegex numberOfMatchesInString:textField.text
                                                                options:kNilOptions
                                                                  range:NSMakeRange(0, textField.text.length)];
    if (numberOfMatches > 0) {
        self.UUIDFieldValid = YES;
    } else {
        self.UUIDFieldValid = NO;
    }
    
    self.saveBarButtonItem.enabled = self.isNameFieldValid && self.isUUIDFieldValid;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.itemAddedCompletion) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
        RWTItem *newItem = [[RWTItem alloc] initWithName:self.nameTextField.text
                                                    uuid:uuid
                                                   major:[self.majorIdTextField.text intValue]
                                                   minor:[self.minorIdTextField.text intValue]];
        self.itemAddedCompletion(newItem);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
