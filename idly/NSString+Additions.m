//
//  StringHelper.m
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//


#import "NSString+Additions.h"

@implementation NSString (helper)

- (NSString*) substringFrom: (NSInteger) a to: (NSInteger) b {
	NSRange r;
	r.location = a;
	r.length = b - a;
	return [self substringWithRange:r];
}

- (NSInteger) indexOf: (NSString*) substring from: (NSInteger) starts {
	NSRange r;
	r.location = starts;
	r.length = [self length] - r.location;
	
	NSRange index = [self rangeOfString:substring options:NSLiteralSearch range:r];
	if (index.location == NSNotFound) {
		return -1;
	}
	return index.location + index.length;
}

- (NSString*) trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) startsWith:(NSString*) s {
	if([self length] < [s length]) return NO;
	return [s isEqualToString:[self substringFrom:0 to:[s length]]];
}

- (BOOL)containsString:(NSString *)aString
{
	NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
	return range.location != NSNotFound;
}


- (NSString *)reformatTelephone
{
    /*
    if ([self containsString:@"-"]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([self containsString:@" "]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([self containsString:@"("]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([self containsString:@")"]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    return self;
     */
    // TODO: Replace everywhere this is called
    return @"IN STRING ADDITIONS FAILED";
}
-(NSString *)customFormat{
    /*
    NSArray *stringComponents = [NSArray arrayWithObjects:[self substringWithRange:NSMakeRange(0, 3)],
                                 [self substringWithRange:NSMakeRange(3, 3)],
                                 [self substringWithRange:NSMakeRange(6, [self length]-6)], nil];
    
    
   self= [NSString stringWithFormat:@"%@-%@-%@", [stringComponents objectAtIndex:0], [stringComponents objectAtIndex:1], [stringComponents objectAtIndex:2]];
    return self;*/
    // TODO: Replace everywhere this is called
    return @"IN STRING ADDITIONS FAILED";

}
- (BOOL)containsNullString
{
    return ([[self lowercaseString] containsString:@"null"]) ? YES : NO;
}

@end
