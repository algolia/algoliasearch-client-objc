/*
 * Copyright (c) 2013 Algolia
 * http://www.algolia.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ASAPIClient.h"
#import "ASAPIClient+Network.h"
#import "ASRemoteIndex.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

@implementation ASAPIClient

+(id) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames
{
    return [[ASAPIClient alloc] initWithApplicationID:applicationID apiKey:apiKey hostnames:hostnames];
}

+(id) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey
{
    return [[ASAPIClient alloc] initWithApplicationID:applicationID apiKey:apiKey];
}

-(id) initWithApplicationID:(NSString*)papplicationID apiKey:(NSString*)papiKey
{
    self = [super init];
    if (self) {
        self.applicationID = papplicationID;
        self.apiKey = papiKey;
        self.tagFilters = nil;
        self.userToken = nil;
        
        NSMutableArray *array = [NSMutableArray arrayWithObjects:
                                 [NSString stringWithFormat:@"%@-1.algolia.io", papplicationID],
                                 [NSString stringWithFormat:@"%@-2.algolia.io", papplicationID],
                                 [NSString stringWithFormat:@"%@-3.algolia.io", papplicationID],
                                 nil];
        srandom((unsigned int)time(NULL));
        NSUInteger count = [array count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (random() % nElements) + i;
            [array exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        self.hostnames = array;
        if (self.applicationID == nil || [self.applicationID length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"Application ID must be set" userInfo:nil];
        if (self.apiKey == nil || [self.apiKey length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"APIKey must be set" userInfo:nil];
        if ([self.hostnames count] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"List of hosts must be set" userInfo:nil];
        NSMutableArray *httpRequestOperationManagers = [[NSMutableArray alloc] init];
        //NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; TODO nil
        for (NSString *host in self.hostnames) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", host]];
            AFHTTPRequestOperationManager *httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
            httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [httpRequestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:@"X-Algolia-API-Key"];
            [httpRequestOperationManager.requestSerializer setValue:self.applicationID forHTTPHeaderField:@"X-Algolia-Application-Id"];
            [httpRequestOperationManager.requestSerializer setValue:[NSString stringWithFormat:@"Algolia for objc %@", @"3.1.19"] forHTTPHeaderField:@"User-Agent"];
            [httpRequestOperationManagers addObject:httpRequestOperationManager];
        }
        operationManagers = httpRequestOperationManagers;
    }
    return self;
}

-(id) initWithApplicationID:(NSString*)papplicationID apiKey:(NSString*)papiKey hostnames:(NSArray*)phostnames
{
    self = [super init];
    if (self) {
        self.applicationID = papplicationID;
        self.apiKey = papiKey;
        self.tagFilters = nil;
        self.userToken = nil;

        if (phostnames == nil)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"List of hosts must be set" userInfo:nil];
        NSMutableArray *array = [NSMutableArray arrayWithArray:phostnames];
        srandom((unsigned int)time(NULL));
        NSUInteger count = [array count];
        for (NSUInteger i = 0; i < count; ++i) {
            // Select a random element between i and end of array to swap with.
            NSUInteger nElements = count - i;
            NSUInteger n = (random() % nElements) + i;
            [array exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        self.hostnames = array;
        if (self.applicationID == nil || [self.applicationID length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"Application ID must be set" userInfo:nil];
        if (self.apiKey == nil || [self.apiKey length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"APIKey must be set" userInfo:nil];
        if ([self.hostnames count] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"List of hosts must be set" userInfo:nil];
        NSMutableArray *httpRequestOperationManagers = [[NSMutableArray alloc] init];
        for (NSString *host in self.hostnames) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", host]];
            AFHTTPRequestOperationManager *httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
            httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [httpRequestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:@"X-Algolia-API-Key"];
            [httpRequestOperationManager.requestSerializer setValue:self.applicationID forHTTPHeaderField:@"X-Algolia-Application-Id"];
            if (self.tagFilters != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.tagFilters forHTTPHeaderField:@"X-Algolia-TagFilters"];
            }
            if (self.userToken != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-Algolia-UserToken"];
            }
            [httpRequestOperationManagers addObject:httpRequestOperationManager];
        }
        operationManagers = httpRequestOperationManagers;
    }
    return self;
}

-(void) setExtraHeader:(NSString*)value forHeaderField:key
{
    for (AFHTTPRequestOperationManager *manager in operationManagers) {
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
}

-(void) multipleQueries:(NSArray*)queries
                success:(void(^)(ASAPIClient *client, NSArray *queries, NSDictionary *result))success
                failure: (void(^)(ASAPIClient *client, NSArray *queries, NSString *errorMessage))failure
{
    NSMutableArray *queriesTab =[[NSMutableArray alloc] initWithCapacity:[queries count]];
    int i = 0;
    for (NSDictionary *query in queries) {
        NSString *queryParams = [[query objectForKey:@"query"] buildURL];
        //NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:queryParams forKey:@"params"];
        queriesTab[i++] = @{@"params": queryParams, @"indexName": [query objectForKey:@"indexName"]};
    }
    NSString *path = [NSString stringWithFormat:@"/1/indexes/*/queries"];
    NSMutableDictionary *request = [NSMutableDictionary dictionaryWithObject:queriesTab forKey:@"requests"];
    [self performHTTPQuery:path method:@"POST" body:request index:0 success:^(id JSON) {
        if (success != nil)
            success(self, queries, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, queries, errorMessage);
    }];
}

-(void) listIndexes:(void(^)(ASAPIClient *client, NSDictionary* result))success failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    [self performHTTPQuery:@"/1/indexes" method:@"GET" body:nil index:0 success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(void) moveIndex:(NSString*)srcIndexName to:(NSString*)dstIndexName
          success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
          failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/operation", [ASAPIClient urlEncode:srcIndexName]];
    NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:dstIndexName, @"destination", @"move", @"operation", nil];
    [self performHTTPQuery:path method:@"POST" body:request index:0 success:^(id JSON) {
        if (success != nil)
            success(self, srcIndexName, dstIndexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, srcIndexName, dstIndexName,errorMessage);
    }];
}

-(void) copyIndex:(NSString*)srcIndexName to:(NSString*)dstIndexName
          success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
          failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/operation", [ASAPIClient urlEncode:srcIndexName]];
    NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:dstIndexName, @"destination", @"copy", @"operation", nil];
    [self performHTTPQuery:path method:@"POST" body:request index:0 success:^(id JSON) {
        if (success != nil)
            success(self, srcIndexName, dstIndexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, srcIndexName, dstIndexName,errorMessage);
    }];
}

-(void) getLogs:(void(^)(ASAPIClient *client, NSDictionary *result))success
        failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    [self performHTTPQuery:@"/1/logs" method:@"GET" body:nil index:0 success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(void) getLogsWithOffset:(NSUInteger)offset length:(NSUInteger)length
                  success:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result))success
                  failure:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage))failure
{
    NSString *url = [NSString stringWithFormat:@"/1/logs?offset=%zd&length=%zd", offset, length];
    [self performHTTPQuery:url method:@"GET" body:nil index:0 success:^(id JSON) {
        success(self, offset, length, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, offset, length, errorMessage);
    }];
}

-(void) deleteIndex:(NSString*)indexName success:(void(^)(ASAPIClient *client, NSString *indexName, NSDictionary *result))success
            failure:(void(^)(ASAPIClient *client, NSString *indexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@", [ASAPIClient urlEncode:indexName]];
    
    [self performHTTPQuery:path method:@"DELETE" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(self, indexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, indexName, errorMessage);
    }];
}

-(void) listUserKeys:(void(^)(ASAPIClient *client, NSDictionary* result))success
                     failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    [self performHTTPQuery:@"/1/keys" method:@"GET" body:nil index:0 success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(void) getUserKeyACL:(NSString*)key success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                      failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    [self performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(void) deleteUserKey:(NSString*)key success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                       failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    [self performHTTPQuery:path method:@"DELETE" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(void) addUserKey:(NSArray*)acls success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];
    [self performHTTPQuery:@"/1/keys" method:@"POST" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, acls, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, acls, errorMessage);
    }];
}

-(void) addUserKey:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl", 
                                [NSNumber numberWithUnsignedInteger:validity], @"validity", 
                                [NSNumber numberWithUnsignedInteger:maxQueriesPerIPPerHour], @"maxQueriesPerIPPerHour", 
                                [NSNumber numberWithUnsignedInteger:maxHitsPerQuery], @"maxHitsPerQuery", 
                                nil];
    [self performHTTPQuery:@"/1/keys" method:@"POST" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, acls, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, acls, errorMessage);
    }];
}

-(void) addUserKey:(NSArray*)acls withIndexes:(NSArray*)indexes withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl", indexes, @"indexes",
                                 [NSNumber numberWithUnsignedInteger:validity], @"validity",
                                 [NSNumber numberWithUnsignedInteger:maxQueriesPerIPPerHour], @"maxQueriesPerIPPerHour",
                                 [NSNumber numberWithUnsignedInteger:maxHitsPerQuery], @"maxHitsPerQuery",
                                 nil];
    [self performHTTPQuery:@"/1/keys" method:@"POST" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, acls, indexes, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, acls, indexes, errorMessage);
    }];
}

-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];
    [self performHTTPQuery:path method:@"PUT" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, key, acls, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, acls, errorMessage);
    }];
}

-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl",
                                 [NSNumber numberWithUnsignedInteger:validity], @"validity",
                                 [NSNumber numberWithUnsignedInteger:maxQueriesPerIPPerHour], @"maxQueriesPerIPPerHour",
                                 [NSNumber numberWithUnsignedInteger:maxHitsPerQuery], @"maxHitsPerQuery",
                                 nil];
    [self performHTTPQuery:path method:@"PUT" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, key, acls, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, acls, errorMessage);
    }];
}

-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls withIndexes:(NSArray*)indexes withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl", indexes, @"indexes",
                                 [NSNumber numberWithUnsignedInteger:validity], @"validity",
                                 [NSNumber numberWithUnsignedInteger:maxQueriesPerIPPerHour], @"maxQueriesPerIPPerHour",
                                 [NSNumber numberWithUnsignedInteger:maxHitsPerQuery], @"maxHitsPerQuery",
                                 nil];
    [self performHTTPQuery:path method:@"PUT" body:dict index:0 success:^(id JSON) {
        if (success != nil)
            success(self, key, acls, indexes, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, acls, indexes, errorMessage);
    }];
}


-(ASRemoteIndex*) getIndex:(NSString*)indexName
{
    return [ASRemoteIndex remoteIndexWithAPIClient:self indexName:indexName];
}

@synthesize applicationID;
@synthesize apiKey;
@synthesize hostnames;
@synthesize operationManagers;
@synthesize tagFilters;
@synthesize userToken;
@end
