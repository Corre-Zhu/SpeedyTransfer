//
//  HTSQLBuffer.h
//  
//
//  Created by zz on 13-6-22.
//  Copyright (c) 2013年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HTSQLBuffer;

typedef HTSQLBuffer * (^HTSQLBufferBlockV)(void);
typedef HTSQLBuffer * (^HTSQLBufferBlockS)(NSString *string);
typedef HTSQLBuffer * (^HTSQLBufferBlockSS)(NSString *string1,NSString *stirng2);
typedef HTSQLBuffer * (^HTSQLBufferBlockU)(NSUInteger value);
typedef HTSQLBuffer * (^HTSQLBufferBlockKV)(NSString* key,id value);
typedef HTSQLBuffer * (^HTSQLBufferBlockD)(id params);

typedef HTSQLBuffer * (^HTSQLBufferBlockVaList)(id param,...);

#define HANDLESQL(sql) [HTSQLBuffer handleSpecialSQL:sql]

#define SQLTableField(tableName,field)         [NSString stringWithFormat:@"%@.%@",tableName,field]
#define SQLTableFieldEqual(tableName1,field1,tableName2,field2)         [NSString stringWithFormat:@"%@.%@=%@.%@",tableName1,field1,tableName2,field2]

#define SQLFieldEqual(field1,field2)           [NSString stringWithFormat:@"%@=%@",field1,field2]

#define SQLStringEqual(field,value)            [NSString stringWithFormat:@"%@='%@'",field,value]
#define SQLStringNotEqual(field,value)         [NSString stringWithFormat:@"%@!='%@'",field,value]
#define SQLStringIn(field,array)               [HTSQLBuffer SQLString:field inArray:array]

#define SQLNumberEqual(field,value)            [NSString stringWithFormat:@"%@=%d",field,value]
#define SQLNumberNotEqual(field,value)         [NSString stringWithFormat:@"%@!=%d",field,value]
#define SQLNumberGreater(field,value)          [NSString stringWithFormat:@"%@>%d",field,value]
#define SQLNumberLess(field,value)             [NSString stringWithFormat:@"%@<%d",field,value]
#define SQLNumberGreaterOrEqual(field,value)   [NSString stringWithFormat:@"%@>=%d",field,value]
#define SQLNumberLessOrEqual(field,value)      [NSString stringWithFormat:@"%@<=%d",field,value]
#define SQLNumberBetween(field,value1,value2)  [NSString stringWithFormat:@"(%@=>%d AND %@<=%d)",field,value1,field,value2]
#define SQLNumberIn(field,array)               [HTSQLBuffer SQLNumber:field inArray:array]


@interface HTSQLBuffer : NSObject

@property (nonatomic,readonly) HTSQLBufferBlockS INSERT;
@property (nonatomic,readonly) HTSQLBufferBlockS UPDATE;
@property (nonatomic,readonly) HTSQLBufferBlockS DELELTE;
@property (nonatomic,readonly) HTSQLBufferBlockS REPLACE;

@property (nonatomic,readonly) HTSQLBufferBlockS SELECT;
@property (nonatomic,readonly) HTSQLBufferBlockVaList SELECT_S;
@property (nonatomic,readonly) HTSQLBufferBlockS FROM;
@property (nonatomic,readonly) HTSQLBufferBlockVaList FROM_S;

@property (nonatomic,readonly) HTSQLBufferBlockS WHERE;
@property (nonatomic,readonly) HTSQLBufferBlockS AND;
@property (nonatomic,readonly) HTSQLBufferBlockS OR;
@property (nonatomic,readonly) HTSQLBufferBlockKV LIKE;
@property (nonatomic,readonly) HTSQLBufferBlockKV SET;
@property (nonatomic,readonly) HTSQLBufferBlockKV SET_A;

@property (nonatomic,readonly) HTSQLBufferBlockS GROUPBY;
@property (nonatomic,readonly) HTSQLBufferBlockSS ORDERBY;
@property (nonatomic,readonly) HTSQLBufferBlockU LIMIT;
@property (nonatomic,readonly) HTSQLBufferBlockU OFFSET;
@property (nonatomic) BOOL distinct;

@property (nonatomic) Class entity;
//@property (nonatomic,strong,readonly) NSArray *queryFields;

- (id)initWithSQL:(NSString *)sql;
- (NSString *)sql;

+ (NSString *)handleSpecialSQL:(NSString *)sql;
+ (NSString *)SQLString:(NSString *)field inArray:(NSArray *)array;
+ (NSString *)SQLNumber:(NSString *)field inArray:(NSArray *)array;

@end
