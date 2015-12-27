//
//  HTSingleton.h
//  helloTalk
//
//  Created by 任健生 on 13-3-1.
//

#define HT_AS_SINGLETON( __class , __method) \
+ (__class *)__method;


#define HT_DEF_SINGLETON( __class , __method ) \
+ (__class *)__method {\
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}
