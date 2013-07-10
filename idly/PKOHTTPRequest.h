//
//  PKOHTTPRequest.h
//
//  Created by Brandon Eum on 2/21/13.
//

#import "ASIHTTPRequest.h"


@interface PKOHTTPRequest : ASIHTTPRequest
{
    int route;
}

@property (nonatomic) int route;


@end
