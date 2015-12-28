//
//  STFileReceiveModel.m
//  SpeedyTransfer
//
//  Created by zhuzhi on 15/12/27.
//  Copyright © 2015年 ZZ. All rights reserved.
//

#import "STFileReceiveModel.h"
#import "STContactInfo.h"
#import "HTSQLBuffer.h"
#import "HTFMDatabase.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@interface STFileReceiveModel ()
{
    HTFMDatabase *database;
}

@end

@implementation STFileReceiveModel

- (void)dealloc {
    [database close];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *defaultDbPath = [[ZZPath documentPath] stringByAppendingPathComponent:dbName];
        database = [[HTFMDatabase alloc] initWithPath:defaultDbPath];
        [database open];
        
        HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
        sql.SELECT(@"*").FROM(DBFileReceive._tableName).ORDERBY(DBFileReceive._id, @"DESC");
        FMResultSet *result = [database executeQuery:sql.sql];
        if (result) {
            NSMutableArray *tempArr = [NSMutableArray array];
            while ([result next]) {
                if (result.resultDictionary) {
                    [tempArr addObject:[[STFileReceiveInfo alloc] initWithDictionary:result.resultDictionary]];
                }
            }
            _receiveFiles = [NSArray arrayWithArray:tempArr];
        }
    }
    
    return self;
}

- (void)addTransferFile:(STFileReceiveInfo *)info {
    if (!info) {
        return;
    }
    
    if (!_receiveFiles) {
        _receiveFiles = [NSArray arrayWithObject:info];
    } else {
        @autoreleasepool {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:_receiveFiles];
            [arr insertObject:info atIndex:0];
            _receiveFiles = [NSArray arrayWithArray:arr];
        }
    }
}

- (NSString *)nameOfRecordRef:(NSData *)vcard {
    CFDataRef vCardData = CFDataCreate(NULL, [vcard bytes], [vcard length]);
    ABAddressBookRef book = ABAddressBookCreate();
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
    ABRecordRef recordRef;
    if (CFArrayGetCount(vCardPeople) > 0) {
        recordRef = CFArrayGetValueAtIndex(vCardPeople, 0);
    } else {
        return @"";
    }
    
    NSMutableString *name = [NSMutableString stringWithString:@""];
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    
    // Set Contact properties
    if (lastName.length > 0) {
        [name appendString:lastName];
    }
    
    if (firstName.length > 0) {
        [name appendString:firstName];
    }
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    NSString *phone = [STContactInfo getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    if (name.length <= 0 && phone.length > 0) {
        name = [NSMutableString stringWithString:phone];
    }
    
    return name;
}

- (STFileReceiveInfo *)saveContactInfo:(NSData *)vcardData {
    STFileReceiveInfo *entity = [[STFileReceiveInfo alloc] init];
    entity.identifier = [NSString uniqueID];
    entity.type = STFileTransferTypeContact;
    entity.status = STFileReceiveStatusReceived;
    entity.progress = 1.0f;
    entity.url = @"";
    entity.fileName = [self nameOfRecordRef:vcardData];
    entity.dateString = [[NSDate date] dateString];
    entity.fileSize = vcardData.length;
    entity.vcardString = [[NSString alloc] initWithData:vcardData encoding:NSUTF8StringEncoding];
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFileReceive._tableName)
    .SET(DBFileReceive._identifier, entity.identifier)
    .SET(DBFileReceive._type, @(entity.type))
    .SET(DBFileReceive._status , @(entity.status))
    .SET(DBFileReceive._fileName, entity.fileName)
    .SET(DBFileReceive._fileSize, @(entity.fileSize))
    .SET(DBFileReceive._date, entity.dateString)
    .SET(DBFileReceive._vcard, entity.vcardString);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    return entity;
}

- (STFileReceiveInfo *)savePicture:(NSString *)pictureName size:(double)size {
    STFileReceiveInfo *entity = [[STFileReceiveInfo alloc] init];
    entity.identifier = [NSString uniqueID];
    entity.type = STFileTransferTypePicture;
    entity.status = STFileReceiveStatusReceiving;
    entity.url = @"";
    entity.fileName = pictureName;
    entity.fileSize = size;
    entity.dateString = [[NSDate date] dateString];
    
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.INSERT(DBFileReceive._tableName)
    .SET(DBFileReceive._identifier, entity.identifier)
    .SET(DBFileReceive._type, @(entity.type))
    .SET(DBFileReceive._status , @(entity.status))
    .SET(DBFileReceive._fileName, entity.fileName)
    .SET(DBFileReceive._fileSize, @(entity.fileSize))
    .SET(DBFileReceive._date, entity.dateString);
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
    
    [self addTransferFile:entity];
    
    return entity;
}

- (void)updateStatus:(STFileReceiveStatus)status rate:(double)rate withIdentifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileReceive._tableName)
    .SET(DBFileReceive._status , @(status))
    .SET(DBFileReceive._sizePerSencond, @(rate))
    .WHERE(SQLStringEqual(DBFileReceive._identifier, identifier));
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

- (void)updateWithUrl:(NSString *)url identifier:(NSString *)identifier {
    HTSQLBuffer *sql = [[HTSQLBuffer alloc] init];
    sql.UPDATE(DBFileReceive._tableName)
    .SET(DBFileReceive._url, url)
    .WHERE(SQLStringEqual(DBFileReceive._identifier, identifier));
    
    if (![database executeUpdate:sql.sql]) {
        NSLog(@"%@", database.lastError);
    }
}

@end
