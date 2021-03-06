// NSArray+INExtensions.h
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


@interface NSArray (INExtensions)

#pragma mark - Initializing with Sets
/// @name Initializing with Sets

/**
 Creates an array initialized with all objects of the given set in undefined order.
 
 @param set The NSSet with objects to put into this new array.
 @return A new array with the set's objects.
 @see initWithSet:
 */
+ (id)arrayWithSet:(NSSet *)set;


/**
 Initializes an array with all objects of the given set in undefined order.
 
 @param set The NSSet with objects to put into this new array.
 @return A new array with the set's objects.
 */
- (instancetype)initWithSet:(NSSet *)set;


#pragma mark - Array tests
/// @name Array tests

/**
 Returns true if there are any elements in this array, otherwise false.
 
 This method can even be used when the array itself may be nil,
 because calling a method on nil will return NO and then the array has definetly no elements.
 
 @return True if the array is not nil and contains any elements.
 */
- (BOOL)hasElements;


/**
 Returns the first object which passes the given predicate test.
 
 Internally it uses [NSArray indexOfObjectPassingTest:] method.
 Use with something like
 
    MyClass *object = [array firstObjectPassingTest:^BOOL(MyClass obj) { return obj.testSucceeded; }];
 
 @param predicate The test which has to return YES for the element to find.
 @return The first object which passes the test or nil if none does.
 @see indexOfObjectPassingTest:
 */
- (id)firstObjectPassingTest:(BOOL (^)(id obj))predicate;


#pragma mark - Printing
/// @name Printing

/**
 Returns a string representing this array, but with an own format which can be specified.
 
 With this method it is possible to print an array in another way compared to the default description which may suit more the needs.
 
 @param start A leading string only printed once before all other, i.e. "(".
 @param elementFormatter A formatter string for printing each but the last element in the array, i.e. "%@,". The formatter string must have one "%@" symbol for printing the element.
 @param lastElementFormatter A formatter string for printing the last element in the array, i.e. "%@". The formatter string must have one "%@" symbol for printing the element.
 @param end A tailing string only printed once after all elements, i.e ")".
 @return A string representation.
 */
- (NSString *)descriptionWithStart:(NSString *)start elementFormatter:(NSString *)elementFormatter lastElementFormatter:(NSString *)lastElementFormatter end:(NSString *)end;


#pragma mark - Array order manipulation
/// @name Array order manipulation

/**
 Returns this array in reverse order with the same elements.
 
 @return A new reversed array.
 */
- (NSArray *)arrayReversed;


/**
 Sorts an array by a given property name.
 
 The Array has to contain objects which are Key-Value-Compliant for the given key.
 The objects will be sorted by the given key either in ascending or in descending order.
 The sort will be done by NSArray's sortedArrayUsingDescriptors with a NSSortDescriptor.
 
 @param key The property's name of the objects in the array for which to sort the array.
 @param ascending YES if the new array should be sorted ascending or NO if it should be sorted descending.
 @return A new sorted array with the same objects sorted by the key.
 */
- (NSArray *)arraySortedByKey:(NSString *)key ascending:(BOOL)ascending;


#pragma mark - Array randomizing
/// @name Array randomizing

/**
 Returns a new array with randomly chosen elements removed from this array. The order of the elements remains unchanged.
 
 Uses INRandom for generating random values.
 
 @param numberOfElements How many elements should be removed. If the number is equal or higher than the array has elements in it an empty array will be returned.
 @return A new array with a subset of this one.
 */
- (NSArray *)arrayWithRandomElementsRemoved:(NSUInteger)numberOfElements;


/**
 Returns a new array with randomly chosen elements added from this array. The order of the elements remains unchanged.
 
 Uses INRandom for generating random values.

 @param numberOfElements How many elements should be chosen. If the number is equal or higher than the array has elements in it a copy of the array will be returned.
 @return A new array with a subset of the given one.
 */
- (NSArray *)arrayWithRandomElementsChosen:(NSUInteger)numberOfElements;


/**
 Returns a new array with the elements in random order.
 
 Uses INRandom for generating random values.

 @return A new array with the same objects, but in random order.
 */
- (NSArray *)arrayWithRandomizedOrder;


/**
 Returns a random object from this array.
 
 Uses INRandom for generating the random index.
 
 @return An object from this array or nil if the array is empty.
 */
- (id)randomObject;


@end
