//
//  HTFMDatabase.m
//  
//
//  Created by zhuzhi on 13-6-20.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import "HTFMDatabase.h"

@implementation HTFMDatabase

- (instancetype)initWithPath:(NSString *)inPath {
	self = [super initWithPath:inPath];
	
	if (self) {
		if ([self open]) {
			[self configureDatabase];
			[self close];
		}
	}
	
	return self;
}

- (BOOL)configureDatabase {
	[self setMaxBusyRetryTimeInterval:2.0f];
	self.logsErrors = YES;
	
	int status;
	
	status = sqlite3_exec(_db, "PRAGMA journal_mode = WAL;", NULL, NULL, NULL);
	if (status != SQLITE_OK)
	{
		NSLog(@"Error setting PRAGMA journal_mode: %d %s", status, sqlite3_errmsg(_db));
		return NO;
	}
	
	sqlite3_wal_autocheckpoint(_db, 300);
	
	return YES;
}

@end
