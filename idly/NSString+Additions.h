//
//  StringHelper.h
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//

#import <Foundation/Foundation.h>

@interface NSString (helper)

- (NSString*) substringFrom: (NSInteger) a to: (NSInteger) b;

- (NSInteger) indexOf: (NSString*) substring from: (NSInteger) starts;

- (NSString*) trim;

- (BOOL) startsWith:(NSString*) s;

- (BOOL) containsString:(NSString*) aString;

-(NSString *)customFormat;

- (NSString *)reformatTelephone;

- (BOOL)containsNullString;

@end
