//
//  HTJSONAdapter.h
//
//  Created by Pat Ren on 12-1-11.
//

// JSON序列化和反序列化接口

#import <Foundation/Foundation.h>

@interface NSString (HTJSONAdapter)
- (id)jsonValue;
- (NSDictionary *)jsonDictionary;
@end

@interface NSData (HTJSONAdapter)
- (id)jsonValue;
@end

@interface NSDictionary (HTJSONAdapter)
- (NSString *)jsonString;
@end

@interface NSArray (HTJSONAdapter)
- (NSString *)jsonString;
@end
