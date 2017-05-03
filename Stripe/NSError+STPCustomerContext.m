//
//  NSError+STPCustomerContext.m
//  Stripe
//
//  Created by Ben Guo on 5/18/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import "NSError+STPCustomerContext.h"
#import "StripeError.h"

@implementation NSError (STPCustomerContext)

+ (NSError *)stp_customerContextMissingKeyProviderError {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: [self stp_unexpectedErrorMessage],
                               STPErrorMessageKey: @"STPCustomerContext is missing a key provider. Did you forget to set the singleton instance's key provider?"
                               };
    return [[self alloc] initWithDomain:StripeDomain code:STPCustomerContextMissingKeyProviderError userInfo:userInfo];
}

@end
