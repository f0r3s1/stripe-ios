//
//  STPEphemeralKeyManagerTest.m
//  Stripe
//
//  Created by Ben Guo on 5/9/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Stripe/Stripe.h>
#import "STPFixtures.h"

@interface STPEphemeralKeyManager (Testing)
@property (nonatomic) STPEphemeralKey *customerKey;
@property (nonatomic) NSDate *lastEagerKeyRefresh;
@end

@interface STPEphemeralKeyManagerTest : XCTestCase

@property (nonatomic) NSString *apiVersion;

@end

@implementation STPEphemeralKeyManagerTest

- (void)setUp {
    [super setUp];
    self.apiVersion = @"2015-03-03";
}

- (id)mockKeyProviderWithKey:(STPEphemeralKey *)key {
    XCTestExpectation *exp = [self expectationWithDescription:@"createCustomerKey"];
    id mockKeyProvider = OCMProtocolMock(@protocol(STPEphemeralKeyProvider));
    OCMStub([mockKeyProvider createCustomerKeyWithAPIVersion:[OCMArg isEqual:self.apiVersion]
                                                  completion:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        STPEphemeralKeyCompletionBlock completion;
        [invocation getArgument:&completion atIndex:3];
        completion(key, nil);
        [exp fulfill];
    });
    return mockKeyProvider;
}

- (void)testGetCustomerKeyCreatesNewKeyAfterInit {
    STPEphemeralKey *expectedKey = [STPFixtures ephemeralKey];
    id mockKeyProvider = [self mockKeyProviderWithKey:expectedKey];
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    XCTestExpectation *exp = [self expectationWithDescription:@"getCustomerKey"];
    [sut getCustomerKey:^(STPEphemeralKey *resourceKey, NSError *error) {
        XCTAssertEqualObjects(resourceKey, expectedKey);
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testGetCustomerKeyUsesStoredKeyIfNotExpiring {
    id mockKeyProvider = OCMProtocolMock(@protocol(STPEphemeralKeyProvider));
    OCMReject([mockKeyProvider createCustomerKeyWithAPIVersion:[OCMArg any] completion:[OCMArg any]]);
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    STPEphemeralKey *expectedKey = [STPFixtures ephemeralKey];
    sut.customerKey = expectedKey;
    XCTestExpectation *exp = [self expectationWithDescription:@"getCustomerKey"];
    [sut getCustomerKey:^(STPEphemeralKey *resourceKey, NSError *error) {
        XCTAssertEqualObjects(resourceKey, expectedKey);
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testGetCustomerKeyCreatesNewKeyIfExpiring {
    STPEphemeralKey *expectedKey = [STPFixtures ephemeralKey];
    id mockKeyProvider = [self mockKeyProviderWithKey:expectedKey];
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    sut.customerKey = [STPFixtures expiringEphemeralKey];
    XCTestExpectation *exp = [self expectationWithDescription:@"retrieve"];
    [sut getCustomerKey:^(STPEphemeralKey *resourceKey, NSError *error) {
        XCTAssertEqualObjects(resourceKey, expectedKey);
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testEnterForegroundRefreshesResourceKeyIfExpiring {
    id mockKeyProvider = [self mockKeyProviderWithKey:[STPFixtures expiringEphemeralKey]];
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    XCTAssertNotNil(sut);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testEnterForegroundDoesNotRefreshResourceKeyIfNotExpiring {
    id mockKeyProvider = OCMProtocolMock(@protocol(STPEphemeralKeyProvider));
    OCMReject([mockKeyProvider createCustomerKeyWithAPIVersion:[OCMArg any] completion:[OCMArg any]]);
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    sut.customerKey = [STPFixtures ephemeralKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)testThrottlingEnterForegroundRefreshes {
    id mockKeyProvider = OCMProtocolMock(@protocol(STPEphemeralKeyProvider));
    OCMReject([mockKeyProvider createCustomerKeyWithAPIVersion:[OCMArg any] completion:[OCMArg any]]);
    STPEphemeralKeyManager *sut = [[STPEphemeralKeyManager alloc] initWithKeyProvider:mockKeyProvider apiVersion:self.apiVersion];
    sut.customerKey = [STPFixtures expiringEphemeralKey];
    sut.lastEagerKeyRefresh = [NSDate dateWithTimeIntervalSinceNow:-60];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
