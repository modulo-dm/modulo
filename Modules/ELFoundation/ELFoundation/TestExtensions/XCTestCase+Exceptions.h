/**
 
 These files are not to be included in any targets except test case targets.
 Simply drag them to your project and make sure only the Tests target is checked.
 You'll be prompted to create an objc-bridging header.  Say yes, then add
 this to the newly created header:
 
 #import "XCTestCase+Exceptions.h"
 
 These methods should now be accessible from within Swift without doing 
 anything additional.
 
 */

@import Foundation;
@import XCTest;

@interface XCTestCase (Exceptions)

/**
 Replacement for the stock objc XCTAssertThrows, which is unavailable in Swift.
 
 :param: block The block to execute.
 :param: message The message to be displayed on failure to throw an exception.
 
 Example (Swift): XCTAssertThrows({ testThrow() }, "This method should've thrown an exception!")
 */
- (void)XCTAssertThrows:(void (^)(void))block :(NSString *)message;

/**
 Replacement for the stock objc XCTAssertThrowsSpecific, which is unavailable in Swift.
 
 :param: block The block to execute.
 :param: name The name of the assertion to look for.
 :param: message The message to be displayed on failure to throw an exception.
 
 Example (Swift): XCTAssertThrowsSpecific({ testThrow() }, "THG", "This method should've thrown a THG exception!")
 */
- (void)XCTAssertThrowsSpecific:(void (^)(void))block :(NSString *)name :(NSString *)message;

@end
