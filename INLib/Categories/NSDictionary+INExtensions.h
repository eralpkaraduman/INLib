// NSDictionary+INExtensions.h
//
// Copyright (c) 2014 Sven Korset
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


@interface NSDictionary (INExtensions)

/// Returns primitive values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The bool value for the key.
- (BOOL)boolForKey:(id)key;

/// Returns primitive values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The int value for the key.
- (int)intForKey:(id)key;

/// Returns primitive values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The float value for the key.
- (float)floatForKey:(id)key;

/// Returns primitive values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The double value for the key.
- (double)doubleForKey:(id)key;

/// Returns primitive values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The long value for the key.
- (long)longForKey:(id)key;

/// Returns a string values from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The string value for the key.
- (NSString *)stringForKey:(id)key;

/// Returns an array from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The array value for the key.
- (NSArray *)arrayForKey:(id)key;

/// Returns a dictionary from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The dictionary value for the key.
- (NSDictionary *)dictForKey:(id)key;

/// Returns a NSNumber from the dictionary.
/// @param key The dictionary's key to retrieve.
/// @return The number value for the key.
- (NSNumber *)numberForKey:(id)key;


@end
