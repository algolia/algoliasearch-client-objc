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

#import "ASAPIClient.h"
#import "ASAPIClient+Network.h"
#import "ASRemoteIndex.h"


NSString *const Version = @"3.5.2";

@implementation ASAPIClient

+(instancetype) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames
{
    return [[self.class alloc] initWithApplicationID:applicationID apiKey:apiKey hostnames:hostnames tagFilters:nil userToken:nil];
}

+(instancetype) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey
{
    return [[self.class alloc] initWithApplicationID:applicationID apiKey:apiKey hostnames:nil tagFilters:nil userToken:nil];
}

-(instancetype) initWithApplicationID:(NSString*)papplicationID apiKey:(NSString*)papiKey hostnames:(NSArray*)phostnames tagFilters:(NSString*)tagFiltersHeader userToken:(NSString*)userTokenHeader
{
    self = [super init];
    if (self) {
        _applicationID = papplicationID;
        _apiKey = papiKey;
        _tagFilters = tagFiltersHeader;
        _userToken = userTokenHeader;
        _timeout = 30;
        _searchTimeout = 10;

        NSMutableArray *searchArray = nil;
        NSMutableArray *writeArray = nil;
        if (phostnames == nil) {
            searchArray = [NSMutableArray arrayWithObjects:
                           [NSString stringWithFormat:@"%@-dsn.algolia.net", papplicationID],
                           [NSString stringWithFormat:@"%@-1.algolianet.com", papplicationID],
                           [NSString stringWithFormat:@"%@-2.algolianet.com", papplicationID],
                           [NSString stringWithFormat:@"%@-3.algolianet.com", papplicationID],
                           nil];
            writeArray = [NSMutableArray arrayWithObjects:
                          [NSString stringWithFormat:@"%@.algolia.net", papplicationID],
                          [NSString stringWithFormat:@"%@-1.algolianet.com", papplicationID],
                          [NSString stringWithFormat:@"%@-2.algolianet.com", papplicationID],
                          [NSString stringWithFormat:@"%@-3.algolianet.com", papplicationID],
                          nil];
        } else {
            searchArray = writeArray = [NSMutableArray arrayWithArray:phostnames];
        }

        _writeHostnames = writeArray;
        _searchHostnames = searchArray;

        if (self.applicationID == nil || [self.applicationID length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"Application ID must be set" userInfo:nil];
        if (self.apiKey == nil || [self.apiKey length] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"APIKey must be set" userInfo:nil];
        if ([self.searchHostnames count] == 0)
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"List of hosts must be set" userInfo:nil];
        NSMutableArray *httpRequestOperationManagers = [[NSMutableArray alloc] init];
        //NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; TODO nil
        for (NSString *host in self.searchHostnames) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", host]];
            AFHTTPRequestOperationManager *httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
            httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [httpRequestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:@"X-Algolia-API-Key"];
            [httpRequestOperationManager.requestSerializer setValue:self.applicationID forHTTPHeaderField:@"X-Algolia-Application-Id"];
            [httpRequestOperationManager.requestSerializer setValue:[NSString stringWithFormat:@"Algolia for Objective-C %@", Version] forHTTPHeaderField:@"User-Agent"];
            if (self.tagFilters != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.tagFilters forHTTPHeaderField:@"X-Algolia-TagFilters"];
            }
            if (self.userToken != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-Algolia-UserToken"];
            }
            [httpRequestOperationManagers addObject:httpRequestOperationManager];
        }
        _writeOperationManagers = httpRequestOperationManagers;

        httpRequestOperationManagers = [[NSMutableArray alloc] init];
        for (NSString *host in self.searchHostnames) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", host]];
            AFHTTPRequestOperationManager *httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
            httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
            httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
            [httpRequestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:@"X-Algolia-API-Key"];
            [httpRequestOperationManager.requestSerializer setValue:self.applicationID forHTTPHeaderField:@"X-Algolia-Application-Id"];
            [httpRequestOperationManager.requestSerializer setValue:[NSString stringWithFormat:@"Algolia for Objective-C %@", Version] forHTTPHeaderField:@"User-Agent"];
            if (self.tagFilters != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.tagFilters forHTTPHeaderField:@"X-Algolia-TagFilters"];
            }
            if (self.userToken != nil) {
                [httpRequestOperationManager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-Algolia-UserToken"];
            }
            [httpRequestOperationManagers addObject:httpRequestOperationManager];
        }
        _searchOperationManagers = httpRequestOperationManagers;
    }
    return self;
}

-(void) setExtraHeader:(NSString*)value forHeaderField:key
{
    for (AFHTTPRequestOperationManager *manager in self.writeOperationManagers) {
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    for (AFHTTPRequestOperationManager *manager in self.searchOperationManagers) {
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
}

-(AFHTTPRequestOperation *) multipleQueries:(NSArray*)queries
                                    success:(void(^)(ASAPIClient *client, NSArray *queries, NSDictionary *result))success
                                    failure:(void(^)(ASAPIClient *client, NSArray *queries, NSString *errorMessage))failure
{
    return [self multipleQueries:queries withStrategy:@"none" success:^(ASAPIClient *client, NSArray *queries, NSString *strategy, NSDictionary *result) {
        if (success != nil)
            success(client, queries, result);
    } failure:^(ASAPIClient *client, NSArray *queries, NSString *strategy, NSString *errorMessage) {
        if (failure != nil)
            failure(client, queries, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) multipleQueries:(NSArray*)queries withStrategy:(NSString*)strategy
                                    success:(void(^)(ASAPIClient *client, NSArray *queries, NSString* strategy, NSDictionary *result))success
                                    failure: (void(^)(ASAPIClient *client, NSArray *queries, NSString* strategy, NSString *errorMessage))failure
{
    NSMutableArray *queriesTab =[[NSMutableArray alloc] initWithCapacity:[queries count]];
    int i = 0;
    for (NSDictionary *query in queries) {
        NSString *queryParams = [query[@"query"] buildURL];
        queriesTab[i++] = @{@"params": queryParams, @"indexName": query[@"indexName"]};
    }
    NSString *path = [NSString stringWithFormat:@"/1/indexes/*/queries?strategy=%@", strategy];
    NSMutableDictionary *request = [NSMutableDictionary dictionaryWithObject:queriesTab forKey:@"requests"];
    return [self performHTTPQuery:path method:@"POST" body:request managers:self.searchOperationManagers index:0 timeout:self.searchTimeout success:^(id JSON) {
        if (success != nil)
            success(self, queries, strategy, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, queries, strategy, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) listIndexes:(void(^)(ASAPIClient *client, NSDictionary* result))success
                                failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    return [self performHTTPQuery:@"/1/indexes" method:@"GET" body:nil managers:self.searchOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) moveIndex:(NSString*)srcIndexName
                                   to:(NSString*)dstIndexName
                              success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
                              failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/operation", [ASAPIClient urlEncode:srcIndexName]];
    NSDictionary *request = @{@"destination": dstIndexName, @"operation": @"move"};
    return [self performHTTPQuery:path method:@"POST" body:request managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, srcIndexName, dstIndexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, srcIndexName, dstIndexName,errorMessage);
    }];
}

-(AFHTTPRequestOperation *) copyIndex:(NSString*)srcIndexName
                                   to:(NSString*)dstIndexName
                              success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
                              failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/operation", [ASAPIClient urlEncode:srcIndexName]];
    NSDictionary *request = @{@"destination": dstIndexName, @"operation": @"copy"};
    return [self performHTTPQuery:path method:@"POST" body:request managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, srcIndexName, dstIndexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, srcIndexName, dstIndexName,errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getLogs:(void(^)(ASAPIClient *client, NSDictionary *result))success
                            failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    return [self performHTTPQuery:@"/1/logs" method:@"GET" body:nil managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getLogsWithOffset:(NSUInteger)offset
                                       length:(NSUInteger)length
                                      success:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result))success
                                      failure:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage))failure
{
    NSString *url = [NSString stringWithFormat:@"/1/logs?offset=%zd&length=%zd", offset, length];
    return [self performHTTPQuery:url method:@"GET" body:nil managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        success(self, offset, length, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, offset, length, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getLogsWithType:(NSUInteger)offset
                                     length:(NSUInteger)length
                                       type:(NSString*)type
                                    success:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSDictionary *result))success
                                    failure:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSString *errorMessage))failure
{
    NSString *url = [NSString stringWithFormat:@"/1/logs?offset=%zd&length=%zd&type=%@", offset, length, type];
    return [self performHTTPQuery:url method:@"GET" body:nil managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        success(self, offset, length, type, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, offset, length, type, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) deleteIndex:(NSString*)indexName
                                success:(void(^)(ASAPIClient *client, NSString *indexName, NSDictionary *result))success
                                failure:(void(^)(ASAPIClient *client, NSString *indexName, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@", [ASAPIClient urlEncode:indexName]];

    return [self performHTTPQuery:path method:@"DELETE" body:nil managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, indexName, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, indexName, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) listUserKeys:(void(^)(ASAPIClient *client, NSDictionary* result))success
                                 failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure
{
    return [self performHTTPQuery:@"/1/keys" method:@"GET" body:nil managers:self.searchOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getUserKeyACL:(NSString*)key
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    return [self performHTTPQuery:path method:@"GET" body:nil managers:self.searchOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) deleteUserKey:(NSString*)key
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    return [self performHTTPQuery:path method:@"DELETE" body:nil managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                               success:(void(^)(ASAPIClient *client, NSArray* acls, NSDictionary *result))success
                               failure:(void(^)(ASAPIClient *client, NSArray* acls, NSString *errorMessage))failure
{
    NSDictionary *params = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];

    return [self addUserKey:acls withParams:params success:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSDictionary *result) {
        if (success != nil)
            success(client, acls, result);
    } failure:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                            withParams:(NSDictionary*)params
                               success:(void(^)(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSDictionary *result))success
                               failure:(void(^)(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSString *errorMessage))failure
{
    [params setValue:acls forKey:@"acl"];
    return [self performHTTPQuery:@"/1/keys" method:@"POST" body:params managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, acls, params, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, acls, params, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                          withValidity:(NSUInteger)validity
                maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour
                       maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
                               success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
                               failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self addUserKey:acls withParams:dict success:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSDictionary *result) {
        if (success != nil)
            success(client, acls, result);
    } failure:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                           withIndexes:(NSArray*)indexes
                          withValidity:(NSUInteger)validity
                maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour
                       maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
                               success:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSDictionary *result))success
                               failure:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl", indexes, @"indexes",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self addUserKey:acls withParams:dict success:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSDictionary *result) {
        if (success != nil)
            success(client, acls, indexes, result);
    } failure:^(ASAPIClient *client, NSArray* acls, NSDictionary* params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, acls, indexes, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                               withParams:(NSDictionary*)params
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *params, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *params, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/keys/%@", key];
    return [self performHTTPQuery:path method:@"PUT" body:params managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, params, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, params, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                                  withACL:(NSArray*)acls
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];
    return [self updateUserKey:key withParams:dict success:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(client, key, acls, result);
    } failure:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, key, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                                  withACL:(NSArray*)acls
                             withValidity:(NSUInteger)validity
                   maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour
                          maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self updateUserKey:key withParams:dict success:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(client, key, acls, result);
    } failure:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, key, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                                  withACL:(NSArray*)acls
                              withIndexes:(NSArray*)indexes
                             withValidity:(NSUInteger)validity
                   maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour
                          maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
                                  success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSDictionary *result))success
                                  failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl", indexes, @"indexes",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self updateUserKey:key withParams:dict success:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(client, key, acls, indexes, result);
    } failure:^(ASAPIClient *client, NSString *key, NSDictionary *params, NSString *errorMessage) {
        if (failure != nil)
            failure(client, key, acls, indexes, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) batch:(NSDictionary*)requests
                          success:(void(^)(ASAPIClient *client, NSDictionary *requests, NSDictionary *result))success
                          failure:(void(^)(ASAPIClient *client, NSDictionary *requests, NSString *errorMessage))failure
{
    NSDictionary *request = @{@"requests": requests};
    return [self performHTTPQuery:@"/1/indexes/*/batch" method:@"POST" body:request managers:self.writeOperationManagers index:0 timeout:self.timeout success:^(id JSON) {
        if (success != nil)
            success(self, requests, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, requests, errorMessage);
    }];
}


-(ASRemoteIndex*) getIndex:(NSString*)indexName
{
    return [ASRemoteIndex remoteIndexWithAPIClient:self indexName:indexName];
}

-(void) setTagFilters:(NSString *)tagFiltersHeader
{
    _tagFilters = tagFiltersHeader;

    for (AFHTTPRequestOperationManager* manager in self.writeOperationManagers) {
        [manager.requestSerializer setValue:self.tagFilters forHTTPHeaderField:@"X-Algolia-TagFilters"];
    }
    for (AFHTTPRequestOperationManager* manager in self.searchOperationManagers) {
        [manager.requestSerializer setValue:self.tagFilters forHTTPHeaderField:@"X-Algolia-TagFilters"];
    }
}

-(void) setUserToken:(NSString *)userTokenHeader
{
    _userToken = userTokenHeader;

    for (AFHTTPRequestOperationManager* manager in self.writeOperationManagers) {
        [manager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-Algolia-UserToken"];
    }
    for (AFHTTPRequestOperationManager* manager in self.searchOperationManagers) {
        [manager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-Algolia-UserToken"];
    }
}

@end
