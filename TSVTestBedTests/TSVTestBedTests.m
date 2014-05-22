//
//  TSVTestBedTests.m
//  TSVTestBedTests
//
//  Created by Sandor Kolotenko on 2014.05.19..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSVReaderWriter.h"
#define kTestExtension @"tsv"
@interface TSVTestBedTests : XCTestCase{
    NSString *_testFileTVSOK;
    NSString *_testFileTVSERR;
    NSString *_testWriteFile;
    NSArray *_testArray;
    TSVReaderWriter *_csvParser;
}
@end


@implementation TSVTestBedTests

- (void)setUp
{
    [super setUp];
    _testFileTVSOK = @"postboxes";
    _testFileTVSERR = @"nonexists";
    _testArray = [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _testWriteFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"newfile.%@", kTestExtension]];
    
    [self removeCreatedFiles];
    _csvParser = [[TSVReaderWriter alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_csvParser close];
    [self removeCreatedFiles];
}

- (void)removeCreatedFiles{
    // Delete pre-exisitng test files
    NSError *error;
    NSString *path = _testWriteFile;
    
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}

- (void)testReadFromGoodPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:_testFileTVSOK ofType:kTestExtension];;
    
    NSError *error;
    [_csvParser open:path mode:FileModeRead andError:&error];
    
    XCTAssertNil(error, @"Error was thrown for a good path");
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    BOOL isRead = [_csvParser read:output andError:&error];
    XCTAssertNil(error, @"Error was thrown for a good path");
    
    XCTAssertNotNil(output, @"Output array was set to NIL");
    XCTAssertTrue(isRead, @"Couldn't read from file.");
    XCTAssertTrue([output count] == 3, @"Test file contains 3 columns.");
    
    [_csvParser close];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)testReadTwoColumns{
    NSString *path = [[NSBundle mainBundle] pathForResource:_testFileTVSOK ofType:kTestExtension];;
    
    NSError *error;
    [_csvParser open:path mode:FileModeRead andError:&error];
    
    XCTAssertNil(error, @"Error was thrown for a good path");
    
    NSString *column1;
    NSString *column2;
    BOOL isRead = [_csvParser read:&column1
                          column2:&column2];
    
    XCTAssertNotNil(column1, @"Output column1 was set to NIL");
    XCTAssertNotNil(column2, @"Output column2 was set to NIL");
    XCTAssertTrue(isRead, @"Couldn't read from file.");
    
    [_csvParser close];
}
#pragma GCC diagnostic pop

- (void)testReadFromWrongPath
{
    NSString *path = _testFileTVSOK;
    
    NSError *error;
    [_csvParser open:path mode:FileModeRead andError:&error];
    
    XCTAssertNotNil(error, @"Error was not thrown for a wrong path");
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    BOOL isRead = [_csvParser read:output andError:&error];
    XCTAssertNil(error, @"Error was thrown for a good path");
    
    XCTAssertFalse(isRead, @"Could read from file.");
    XCTAssertNotNil(output, @"Output array was set to NIL");
    
    [_csvParser close];
}

- (void)testWriteToPath{

    NSError *error;
    [_csvParser open:_testWriteFile mode:FileModeWrite andError:&error];
    
    XCTAssertNil(error, @"Error was thrown for writing to a good path");
    
    [_csvParser write:_testArray];
    
    // Check if file exists
    BOOL fileExists = [[NSFileManager defaultManager] isDeletableFileAtPath:_testWriteFile];
    XCTAssertTrue(fileExists, @"File does not exists or marked as not deletable");
    
    [_csvParser close];
    
    // Check content
    [_csvParser open:_testWriteFile mode:FileModeRead andError:&error];
    
    XCTAssertNil(error, @"Error was thrown for a file written by test");
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    BOOL isRead = [_csvParser read:output andError:&error];
    XCTAssertNil(error, @"Error was thrown for a file written by test");
    
    XCTAssertNotNil(output, @"Output array was set to NIL");
    XCTAssertTrue(isRead, @"Couldn't read from file.");
    XCTAssertTrue([output count] == 4, @"Test file contains 4 columns.");

    BOOL isEqualToTestArray = [output isEqualToArray:_testArray];
    
    XCTAssertTrue(isEqualToTestArray, @"Written array is not equal to test one");
    
    [_csvParser close];
}

@end
