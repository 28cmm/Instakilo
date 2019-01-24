//
//  Imagee.m
//  InstaKilo
//
//  Created by Yilei Huang on 2019-01-23.
//  Copyright © 2019 Joshua Fanng. All rights reserved.
//

#import "Imagee.h"

@implementation Imagee
- (instancetype)initWithImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
