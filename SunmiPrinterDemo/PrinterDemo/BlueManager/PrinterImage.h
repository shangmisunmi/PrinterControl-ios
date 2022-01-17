//
//  PrinterImage.h
//  PrinterDemo
//
//  Created by SM1441 on 2021/12/13.
//  Copyright © 2021 mark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PrinterImage : NSObject

/**
 *  Print image
 *  @param  maxWidth (384: for 58mm printer, 576: for 80mm printer)
 *
 */
- (NSData *)printWithImage:(UIImage *)image
                  maxWidth:(NSInteger)maxWidth;

@end

NS_ASSUME_NONNULL_END
