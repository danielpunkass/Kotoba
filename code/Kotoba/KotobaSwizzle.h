//
//  KotobaSwizzle.h
//  Kotoba
//
//  Created by Daniel Jalkut on 5/25/17.
//  Copyright © 2017 Daniel Jalkut. All rights reserved.
//

@interface NSObject (KotobaSwizzle)

+ (IMP)kotoba_replaceMethod:(SEL)origSel_ withImplementation:(IMP)altImp_ error:(NSError**)error_;

@end
