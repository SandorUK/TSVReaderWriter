//
//  CSVReaderWriter.h
//  TSVTestBed
//
//  Created by Sandor Kolotenko on 2014.05.19..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CSVReaderWriterErrorDomain @"CSVReaderWriterError"
typedef NS_ENUM (NSInteger, CSVReaderWriterError){
    FileDoesNotExist,
    FileReadError,
    FileWriteError
};

// TODO: I would rather use NSFileHandle to impelemnt this class from scratch.

// FIXED: Because the task states that "it works and meets the needs of the application" about the code
// I have decided to replace NS_OPTIONS with NS_ENUM to avoid errors with setting multiple flags.
typedef NS_ENUM(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface TSVReaderWriter : NSObject{
    FileMode _currentMode;
}

- (void)open:(NSString*)path mode:(FileMode)mode __deprecated;
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 __deprecated;
- (BOOL)read:(NSMutableArray*)columns __deprecated;

- (void)open:(NSString*)path mode:(FileMode)mode andError:(NSError**)error;
- (BOOL)read:(NSMutableArray*)columns andError:(NSError**)error;
- (void)write:(NSArray*)columns;
- (void)close;

@end

