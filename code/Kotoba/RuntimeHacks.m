//
//  RuntimeHacks.m
//  Kotoba
//
//  Created by Daniel Jalkut on 5/25/17.
//  Copyright © 2017 Daniel Jalkut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KotobaSwizzle.h"

@interface _UIDictionaryManager : NSObject

- (NSArray*) _currentlyAvailableDefinitionDictionaries;

@end

// Quiet warnings passing messages to UIDefinitionDictonary and ASAsset
@class UIDefinitionDictionary;
@interface NSObject (KotobaHacks)
- (BOOL) activated;
- (NSObject*) rawAsset;
- (NSDictionary*) attributes;
@end

// Override the internal -[_UIDictionaryManager _currentlyAvailableDefinitionDictionaries] method
// to omit and/or reorder definition dictionaries to the desired order.
typedef	NSArray* (*IMP_currentlyAvailableDefinitionDictionaries)(id self, SEL cmd);
static IMP_currentlyAvailableDefinitionDictionaries originalCurrentlyAvailableDefinitionDictionaries = NULL;

static NSArray* KotobaHackedCurrentlyAvailableDefinitionDictionaries(id self, SEL cmd)
{
	NSArray* originalArray = originalCurrentlyAvailableDefinitionDictionaries(self, cmd);
	NSMutableArray* amendedArray = [NSMutableArray arrayWithCapacity:[originalArray count]];

	// This is the opportunity to tweak the returned array however seen fit. Note that you
	// can also impact the priority of a dictionary by moving it to the front or end of
	// the array...
	for (NSObject* thisDictionary in originalArray) {
		if ([thisDictionary activated]) {
#if 1
			// Proof of concept: only allow bilingual dictionaries through ...
			if ([[[[thisDictionary rawAsset] attributes] objectForKey:@"DictionaryType"] isEqualToString:@"Bilingual"]) {
				[amendedArray addObject:thisDictionary];
			}
#else
			// Another proof of concept: allow any dictionary relating to a given language
			NSString* wantedLanguage = @"es";

			if ([[[[thisDictionary rawAsset] attributes] objectForKey:@"IndexLanguages"] containsObject:wantedLanguage]) {
				[amendedArray addObject:thisDictionary];
			}
#endif
		}

	}

	return amendedArray;
}

void ApplyRuntimeHacks(void) {
	Class class = NSClassFromString(@"_UIDictionaryManager");
	if (class == Nil) {
		NSLog(@"Couldn't get class for _UIDictionaryManager; patches not installed.");
		return;
	}

	SEL targetSelector = NSSelectorFromString(@"_currentlyAvailableDefinitionDictionaries");
	if ([class instancesRespondToSelector:targetSelector])
	{
		NSError* swizzleError = nil;

		originalCurrentlyAvailableDefinitionDictionaries = (IMP_currentlyAvailableDefinitionDictionaries)[class kotoba_replaceMethod:targetSelector withImplementation:(IMP)KotobaHackedCurrentlyAvailableDefinitionDictionaries error:&swizzleError];
		if (swizzleError != nil) {
			NSLog(@"Failed to patch _currentlyAvailableDefinitionDictionaries with error %@", swizzleError);
		}
	}
	else {
		NSLog(@"_UIDictionaryManager doesn't implemented expected _currentlyAvailableDefinitionDictionaries; patch not installed");
	}
}
