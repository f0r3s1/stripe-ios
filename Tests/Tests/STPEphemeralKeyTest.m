//
//  STPEphemeralKeyTest.m
//  Stripe
//
//  Created by Ben Guo on 5/17/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STPEphemeralKey.h"
#import "STPTestUtils.h"

@interface STPEphemeralKeyTest : XCTestCase

@end

@implementation STPEphemeralKeyTest

- (void)testDecoding {
    NSDictionary *json = [STPTestUtils jsonNamed:@"EphemeralKey"];
    STPEphemeralKey *key = [STPEphemeralKey decodedObjectFromAPIResponse:json];
    XCTAssertNotNil(key);
}

@end
