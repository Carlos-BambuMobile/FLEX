//
//  FLEXUtility.m
//  Flipboard
//
//  Created by Ryan Olson on 4/18/14.
//  Copyright (c) 2014 Flipboard. All rights reserved.
//

#import "FLEXUtility.h"
#import "FLEXResources.h"

@implementation FLEXUtility

+ (UIColor *)consistentRandomColorForObject:(id)object
{
    CGFloat hue = (((NSUInteger)object >> 4) % 256) / 255.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

+ (NSString *)descriptionForView:(UIView *)view includingFrame:(BOOL)includeFrame
{
    NSString *description = [[view class] description];
    
    NSString *viewControllerDescription = nil;
    SEL viewDelSel = NSSelectorFromString([NSString stringWithFormat:@"%@ewDelegate", @"_vi"]);
    if ([view respondsToSelector:viewDelSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id viewDel = [view performSelector:viewDelSel];
#pragma clang diagnostic pop
        if (viewDel) {
            viewControllerDescription = [[viewDel class] description];
        }
    }
    
    if ([viewControllerDescription length] > 0) {
        description = [description stringByAppendingFormat:@" (%@)", viewControllerDescription];
    }
    
    if (includeFrame) {
        description = [description stringByAppendingFormat:@" frame:%@", NSStringFromCGRect(view.frame)];
    }
    
    if ([view.accessibilityLabel length] > 0) {
        description = [description stringByAppendingFormat:@" · %@", view.accessibilityLabel];
    }
    
    return description;
}

+ (NSString *)detailDescriptionForView:(UIView *)view
{
    return [NSString stringWithFormat:@"frame = %@", NSStringFromCGRect(view.frame)];
}

+ (UIImage *)circularImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGFloat diameter = radius * 2.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), NO, 0.0);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(imageContext, [color CGColor]);
    CGContextFillEllipseInRect(imageContext, CGRectMake(0, 0, diameter, diameter));
    UIImage *circularImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circularImage;
}

+ (UIColor *)scrollViewGrayColor
{
    return [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
}

+ (UIColor *)hierarchyIndentPatternColor
{
    static UIColor *patternColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *indentationPatternImage = [FLEXResources hierarchyIndentPattern];
        patternColor = [UIColor colorWithPatternImage:indentationPatternImage];
    });
    return patternColor;
}

+ (NSString *)applicationImageName
{
    return [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
}

+ (NSString *)applicationName
{
    return [[[FLEXUtility applicationImageName] componentsSeparatedByString:@"/"] lastObject];
}

+ (NSString *)safeDescriptionForObject:(id)object
{
    // Don't assume that we have an NSObject subclass.
    // Check to make sure the object responds to the description methods.
    NSString *description = nil;
    if ([object respondsToSelector:@selector(debugDescription)]) {
        description = [object debugDescription];
    } else if ([object respondsToSelector:@selector(description)]) {
        description = [object description];
    }
    return description;
}

+ (UIFont *)defaultFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)defaultTableViewCellLabelFont
{
    return [self defaultFontOfSize:12.0];
}

+ (NSString *)stringByEscapingHTMLEntitiesInString:(NSString *)originalString
{
    static NSDictionary *escapingDictionary = nil;
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        escapingDictionary = @{ @" " : @"&nbsp;",
                                @">" : @"&gt;",
                                @"<" : @"&lt;",
                                @"&" : @"&amp;",
                                @"'" : @"&apos;",
                                @"\"" : @"&quot;",
                                @"«" : @"&laquo;",
                                @"»" : @"&raquo;"
                                };
        regex = [NSRegularExpression regularExpressionWithPattern:@"(&|>|<|'|\"|«|»)" options:0 error:nil];
    });
    
    NSMutableString *mutableString = [originalString mutableCopy];
    
    NSArray *matches = [regex matchesInString:mutableString options:0 range:NSMakeRange(0, [mutableString length])];
    for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSString *foundString = [mutableString substringWithRange:result.range];
        NSString *replacementString = escapingDictionary[foundString];
        if (replacementString) {
            [mutableString replaceCharactersInRange:result.range withString:replacementString];
        }
    }
    
    return [mutableString copy];
}

@end