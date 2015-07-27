//
//  Copyright (c) 2013 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ASExpiringCache.h"
#import "ASExpiringCacheItem.h"

@implementation ASExpiringCache {
    NSCache *cache;
    NSTimeInterval expiringTimeInterval;
    
    NSMutableArray *cacheKeys;
    NSTimer *timer;
}

- (instancetype)initWithExpiringTimeInterval:(NSTimeInterval)eti {
    self = [super init];
    if (self) {
        expiringTimeInterval = eti;
        cache = [[NSCache alloc] init];
        cacheKeys = [NSMutableArray array];
        
        // Garbage collector like, for the expired cache
        timer = [NSTimer timerWithTimeInterval:(2 * eti) target:self selector:@selector(clearExpiredCache) userInfo:nil repeats:YES];
        timer.tolerance = eti * 0.5;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc {
    [timer invalidate];
}

- (NSDictionary*)objectForKey:(NSString*)key {
    ASExpiringCacheItem *object = [cache objectForKey:key];
    if (object != nil) {
        if ([object hasExpired:expiringTimeInterval]) {
            [cache removeObjectForKey:key];
        } else {
            return object.content;
        }
    }
    
    return nil;
}

- (void)setObject:(NSDictionary*)obj forKey:(NSString*)key {
    [cache setObject:[ASExpiringCacheItem newItem:obj] forKey:key];
    [cacheKeys addObject:key];
}

- (void)clearCache {
    [cache removeAllObjects];
    [cacheKeys removeAllObjects];
}

- (void)clearExpiredCache {
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (int i = 0; i < [cacheKeys count]; ++i) {
        ASExpiringCacheItem *object = [cache objectForKey:cacheKeys[i]];
        if (object != nil) {
            if ([object hasExpired:expiringTimeInterval]) {
                [cache removeObjectForKey:cacheKeys[i]];
            } else {
                [tmp addObject:cacheKeys[i]];
            }
        }
    }
    
    cacheKeys = tmp;
}

@end
