//
//  STPCard+Private.h
//  Stripe
//
//  Created by Ben Guo on 1/4/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import "STPCard.h"
#import "STPInternalAPIResponseDecodable.h"

@interface STPCard (Private) <STPInternalAPIResponseDecodable>
- (nullable STPAddress *)address;
@end
