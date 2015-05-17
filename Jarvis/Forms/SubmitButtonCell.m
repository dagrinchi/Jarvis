//
//  SubmitButtonCell.m
//  Jarvis
//
//  Created by David Almeciga on 5/17/15.
//  Copyright (c) 2015 dagrinchi. All rights reserved.
//

#import "SubmitButtonCell.h"

@implementation SubmitButtonCell

- (void)update
{
    [self.cellButton setTitle:self.field.title forState:UIControlStateNormal];
}

- (IBAction)submitAction:(id)sender {
    if (self.field.action) self.field.action(self);
}

@end
