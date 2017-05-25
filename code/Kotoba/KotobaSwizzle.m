//
//  KotobaSwizzle.m
//  Kotoba
//
//  Created by Daniel Jalkut on 5/25/17.
//  Copyright © 2017 Daniel Jalkut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

// From JRSWizzle
// https://github.com/rentzsch/jrswizzle

@implementation NSObject (KotobaSwizzle)

+ (IMP) kotoba_replaceMethod:(SEL)origSel_ withImplementation:(IMP)altImp_ error:(NSError**)outError
{
	Method targetMethod = class_getInstanceMethod(self, origSel_);
	if (!targetMethod) {
		NSString* errorDescription = [NSString stringWithFormat:@"alternate method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]];
		*outError = [NSError errorWithDomain:@"NSCocoaErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
		return nil;
	}
	
	// We want to return whatever the LOGICAL old implementation was, so that the client can e.g. call
	// through to it. class_replaceMethod only returns the old IMP if it was literally implemented at the scope 
	// of the class "self". So for instance if we're overriding a method only for self that is implemented only in a
	// superclass, then it would return NULL, when we want to return whatever the expected implementation is.
	IMP oldImplementation = method_getImplementation(targetMethod);
	(void) class_replaceMethod(self, origSel_, altImp_, method_getTypeEncoding(targetMethod));
	return oldImplementation;
}

@end
