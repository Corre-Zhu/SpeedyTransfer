//
//  HTJSONAdapter.m
//
//  Created by Pat Ren on 12-1-11.
//

#import "HTJSONAdapter.h"

@implementation NSString (HTJSONAdapter)
- (id)jsonValue {
    
    if (self.length <= 0) {
        return nil;
    }
    
    NSError *error = nil;
    id jsonValue = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
    
    if (error) {
        NSLog(@"json 解析异常,%@",self);
        NSLog(@"%@", [error description]);
        return nil;
    }
    return jsonValue;
    
}

- (NSDictionary *)jsonDictionary {
	id jsonValue = [self jsonValue];
	if ([jsonValue isKindOfClass:[NSDictionary class]]) {
		return (NSDictionary *)jsonValue;
	}
	
	return nil;
}

- (NSArray *)jsonArray {
    id jsonValue = [self jsonValue];
    if ([jsonValue isKindOfClass:[NSArray class]]) {
        return (NSArray *)jsonValue;
    }
    
    return nil;
}

@end

@implementation NSData (HTJSONAdapter)
- (id)jsonValue {
    
    if (self.length <= 0) {
        return nil;
    }

    NSError *error = nil;
    id jsonValue = [NSJSONSerialization JSONObjectWithData:self
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error];
    
    if (error) {
        NSLog(@"json 解析异常,%@",self);
        NSLog(@"%@", [error localizedFailureReason]);
        return nil;
    }
    return jsonValue;

}
@end

@implementation NSDictionary (HTJSONAdapter)

- (NSString *)jsonString {
    
    if (self.allKeys.count <= 0) {
        return nil;
    }
    
    NSError* error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:kNilOptions
                                                         error:&error];
    if (error) {
        NSLog(@"json 解析异常,%@",self);
        NSLog(@"%@", [error localizedFailureReason]);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
    
}

@end

@implementation NSArray (HTJSONAdapter)

- (NSString *)jsonString {
    
    if (self.count <= 0) {
        return nil;
    }
    
    NSError* error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:kNilOptions
                                                         error:&error];
    if (error) {
        NSLog(@"json 解析异常,%@",self);
        NSLog(@"%@", [error localizedFailureReason]);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
    
}

@end
