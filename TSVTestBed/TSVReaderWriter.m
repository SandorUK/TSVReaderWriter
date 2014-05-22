//
//  CSVReaderWriter.h
//  TSVTestBed
//
//  Created by Sandor Kolotenko on 2014.05.19..
//  Copyright (c) 2014 Sandor Kolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSVReaderWriter.h"
#define CSVFileDelimiter @"\t"
#define CSVFileNewLine "\n"
#define CSVFileReadBufferSize 1
#define CSVStringRead @"CSVStringRead"

// FIXED: Interface and enums should be placed in a separate header file.
@implementation TSVReaderWriter {
    NSStream* workStream;
}


// FIXED add new parameter to return an error
//  - (void)open:(NSString*)path mode:(FileMode)mode
- (void)open:(NSString*)path mode:(FileMode)mode __deprecated{
    // Supporting backward compatibility
    NSError *error = nil;
    [self open:path mode:mode andError:&error];
    
    if (error) {
        @throw error;
    }
}

- (void)open:(NSString*)path mode:(FileMode)mode andError:(NSError **)error{
    // FIXED: Check whether file exists at all
    // FIXED: Return NSError instead of NSException
    // FIXED: Important: You should reserve the use of exceptions for programming or unexpected runtime errors such as out-of-bounds collection access, attempts to mutate immutable objects, sending an invalid message, and losing the connection to the window server. You usually take care of these sorts of errors with exceptions when an application is being created rather than at runtime.
    *error = nil;
    
    _currentMode = mode;
    
    NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
    
    // Check for full path for reading file and for directory only for writing as new file
    // WARNING: Old file will be overwritten in this case
    
    NSString *pathToCheck = path;
    
    if (mode == FileModeWrite) {
        pathToCheck = [path stringByDeletingLastPathComponent];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCheck] ){
        
        [details setObject:NSLocalizedString(@"Path does not exist",
                                             @"Path does not exist")
                    forKey:NSLocalizedDescriptionKey];
        [details setValue:pathToCheck
                   forKey:NSFilePathErrorKey];
        *error = [NSError errorWithDomain:CSVReaderWriterErrorDomain
                                     code:FileDoesNotExist
                                 userInfo:details];
        return;
    }
    
    // Public interface defines FileMode as NS_OPTIONS which implies a bit mask usage
    // However here we have had logic which either open file for reading or writing,
    // opening file for reading and writing using the bitmaks (FileModeRead | FileModeWrite) was
    // not possible. Also append mode is set to NO for writing.
    // Because the task states that "it works and meets the needs of the application" about the code
    // I have decided to replace NS_OPTIONS with NS_ENUM to avoid errors with setting multiple flags.
    
    switch (mode) {
        case FileModeRead:
            workStream = [NSInputStream inputStreamWithFileAtPath:path];
            
            break;
        case FileModeWrite:
            workStream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:NO];
            break;
        default:
            break;
    }
    
    [workStream open];
}

- (NSString*)readLineWithError:(NSError**)error {
    uint8_t ch = 0;
    *error = nil;
    NSMutableString* str = [NSMutableString string];
    
    while ([(NSInputStream*)workStream hasBytesAvailable]) {
        long readCount = [(NSInputStream*)workStream read:&ch maxLength:1];
        if (readCount == 1)
        {
            if (ch == '\n')
                break;
            [str appendFormat:@"%c", ch];
        }
        else if(readCount < 0)
        {
            NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
            [details setObject:NSLocalizedString(@"Error reading from file",
                                                 @"Error reading from file")
                        forKey:NSLocalizedDescriptionKey];
            [details setObject:str forKey:CSVStringRead];
            *error = [NSError errorWithDomain:CSVReaderWriterErrorDomain
                                         code:FileReadError
                                     userInfo:details];

        }
    }
    return str;
}


- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 __deprecated{
    NSError *error;
    BOOL result = [self read:column1 column2:column2 andError:&error];
    
    if (error) {
        return NO;
    }
    
    return result;
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 andError:(NSError**)error{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    BOOL isRead = [self read:columns andError:error];
    
    if (*error) {
        return NO;
    }
    
    // Set only first 2 columns for output
    if (isRead && [columns count] >= 2) {
        *column1 = [columns objectAtIndex:0];
        *column2 = [columns objectAtIndex:1];
        
        return YES;
    }
    
    // Reset columns to nil
    *column1 = nil;
    *column2 = nil;
    
    return NO;
}

// Backward compatibility
- (BOOL)read:(NSMutableArray*)columns __deprecated{
    NSError *error;
    BOOL result = [self read:columns andError:&error];
    
    if (error) {
        return NO;
    }
    
    return result;
}

// FIXED: this method name implies all the columns should be returned not only
// first two of them. Also array should be dynamically generated.
- (BOOL)read:(NSMutableArray*)columns andError:(NSError **)error {
    
    *error = nil;
    NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
    
    if (_currentMode != FileModeRead){
        
        [details setObject:NSLocalizedString(@"Invalid stream mode",
                                             @"Invalid stream mode")
                    forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:CSVReaderWriterErrorDomain
                                     code:FileReadError
                                 userInfo:details];

        return NO;
    }
    else if(!columns){
        [details setObject:NSLocalizedString(@"columns is nil",
                                             @"columns is nil")
                    forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:CSVReaderWriterErrorDomain
                                     code:FileReadError
                                 userInfo:details];
        return NO;

    }

    NSString* line = [self readLineWithError:error];
    
    if (*error) {
        return NO;
    }
    
    if ([line length] > 0) {
        
        NSArray* splitLine = [line componentsSeparatedByString: CSVFileDelimiter];
        
        // FIXED componentsSeparatedByString always returns a value even if no
        // separator is present, thus [splitLine count] == 0 will never be TRUE
        // if [line length] is more than 0.
        
        [columns addObjectsFromArray:splitLine];
        
        return true;
    }
    return false;
}

- (void)writeLine:(NSString*)line {
    if (_currentMode != FileModeWrite) {
        return;
    }
    
    NSMutableData *data = [NSMutableData dataWithData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    
    const uint8_t *buffer = [data bytes];
    
    // Add LF to the end of line
    unsigned char* lf = (unsigned char*)CSVFileNewLine;
    [data appendBytes:lf length:1];
    
    [(NSOutputStream*)workStream write:buffer maxLength:[data length]];
}

- (void)write:(NSArray*)columns {
    if (_currentMode != FileModeWrite ||
        !columns) {
        return;
    }
    
    // FIXED method for string building already provided by SDK
    [self writeLine:[columns componentsJoinedByString:CSVFileDelimiter]];
}

- (void)close {
    if (workStream) {
        [workStream close];
    }
}

@end