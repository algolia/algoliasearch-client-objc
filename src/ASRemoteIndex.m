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

#import "ASRemoteIndex.h"
#import "ASAPIClient+Network.h"

@implementation ASRemoteIndex

+(instancetype) remoteIndexWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName
{
    return [[ASRemoteIndex alloc] initWithAPIClient:client indexName:indexName];
}

-(instancetype) initWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName
{
    self = [super init];
    if (self) {
        _apiClient = client;
        _indexName = indexName;
        _urlEncodedIndexName = [ASAPIClient urlEncode:indexName];
    }
    return self;
}

-(AFHTTPRequestOperation *) addObject:(NSDictionary*)object
                              success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result))success
                              failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"POST" body:object managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, object, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, object, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addObject:(NSDictionary*)object
                         withObjectID:(NSString*)objectID
                              success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result))success
                              failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    return [self.apiClient performHTTPQuery:path method:@"PUT" body:object managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, object, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, object, objectID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addObjects:(NSArray*)objects
                               success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSDictionary *object in objects) {
        [requests addObject:@{@"action": @"addObject",
                              @"body": object}];
    }
    NSDictionary *request = @{@"requests": requests};
    return [self.apiClient performHTTPQuery:path method:@"POST" body:request managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objects, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) deleteObjects:(NSArray*)objects
                                  success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSString *object in objects) {
        [requests addObject:@{@"action": @"deleteObject",
                              @"objectID": object}];
    }
    NSDictionary *request = @{@"requests": requests};
    return [self.apiClient performHTTPQuery:path method:@"POST" body:request managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objects, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getObject:(NSString*)objectID
                              success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSDictionary *result))success
                              failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objectID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getObject:(NSString*)objectID
                 attributesToRetrieve:(NSArray*)attributes
                              success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result))success
                              failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSString *errorMessage))failure
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"/1/indexes/%@/%@?attributes=", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    BOOL firstEntry = YES;
    for (NSString *attribute in attributes) {
        if (!firstEntry)
            [path appendString:@","];
        [path appendString:[ASAPIClient urlEncode:attribute]];
        firstEntry = NO;
    }
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objectID, attributes, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objectID, attributes, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getObjects:(NSArray*)objectIDs
                               success:(void(^)(ASRemoteIndex *index, NSArray *objectIDs, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSArray *objectIDs, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/*/objects"];
    
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objectIDs count]];
    for (NSString *id in objectIDs) {
        [requests addObject:@{@"indexName": self.indexName, @"objectID": id}];
    }
    
    
    return [self.apiClient performHTTPQuery:path method:@"POST" body:@{@"requests": requests} managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objectIDs, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objectIDs, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) partialUpdateObject:(NSDictionary*)partialObject
                                       objectID:(NSString*)objectID
                                        success:(void(^)(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result))success
                                        failure:(void(^)(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@/partial", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    return [self.apiClient performHTTPQuery:path method:@"POST" body:partialObject managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, partialObject, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, partialObject, objectID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) partialUpdateObjects:(NSArray*)objects
                                         success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
                                         failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSDictionary *object in objects) {
        [requests addObject:@{@"action": @"partialUpdateObject",
                              @"objectID": [object valueForKey:@"objectID"],
                              @"body": object}];
    }
    NSDictionary *request = @{@"requests": requests};
    return [self.apiClient performHTTPQuery:path method:@"POST" body:request managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objects, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) saveObject:(NSDictionary*)object
                              objectID:(NSString*)objectID
                               success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    return [self.apiClient performHTTPQuery:path method:@"PUT" body:object managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, object, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, object, objectID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) saveObjects:(NSArray*)objects
                                success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
                                failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSDictionary *object in objects) {
        [requests addObject:@{@"action": @"updateObject",
                              @"objectID": [object valueForKey:@"objectID"],
                              @"body": object}];
    }
    NSDictionary *request = @{@"requests": requests};
    return [self.apiClient performHTTPQuery:path method:@"POST" body:request managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objects, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) deleteObject:(NSString*)objectID
                                 success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSDictionary *result))success
                                 failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage))failure
{
    NSAssert(objectID == nil || [objectID length] == 0, @"empty objectID is not allowed");
    
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    return [self.apiClient performHTTPQuery:path method:@"DELETE" body:nil managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, objectID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) search:(ASQuery*)query
                           success:(void(^)(ASRemoteIndex *index, ASQuery *query, NSDictionary *result))success
                           failure:(void(^)(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage))failure
{
    NSString *queryParams = [query buildURL];
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/query", self.urlEncodedIndexName];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:queryParams forKey:@"params"];
    return [self.apiClient performHTTPQuery:path method:@"POST" body:dict managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.searchTimeout success:^(id JSON) {
        if (success != nil)
            success(self, query, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, query, errorMessage);
    }];
}

-(void) cancelPreviousSearches
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/query", self.urlEncodedIndexName];
    [self.apiClient cancelQueries:@"POST" path:path];
}

-(AFHTTPRequestOperation *) waitTask:(NSString*)taskID
                             success:(void(^)(ASRemoteIndex *index, NSString *taskID, NSDictionary *result))success
                             failure:(void(^)(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/task/%@", self.urlEncodedIndexName, taskID];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        NSString *status = [JSON valueForKey:@"status"];
        if ([status compare:@"published"] == NSOrderedSame) {
            if (success != nil)
                success(self, taskID, JSON);
        } else {
            [NSThread sleepForTimeInterval:0.1f];
            [self waitTask:taskID success:success failure:failure];
        }
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, taskID, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getSettings:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
                                failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/settings", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) setSettings:(NSDictionary*)settings
                                success:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSDictionary *result))success
                                failure:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/settings", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"PUT" body:settings managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, settings, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, settings, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) clearIndex:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure
{
    NSDictionary *obj = [[NSDictionary alloc] init];
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/clear", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"POST" body:obj managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) listUserKeys:(void(^)(ASRemoteIndex *index, NSDictionary* result))success
                                 failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/keys", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        success(self, JSON);
    } failure:^(NSString *errorMessage) {
        failure(self, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) getUserKeyACL:(NSString*)key
                                  success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/keys/%@", self.urlEncodedIndexName, key];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) browse:(NSUInteger)page
                       hitsPerPage:(NSUInteger)hitsPerPage
                           success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSDictionary *result))success
                           failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/browse?page=%lu&hitsPerPage=%lu", self.urlEncodedIndexName, (unsigned long)page, (unsigned long)hitsPerPage];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, page, hitsPerPage, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, page, hitsPerPage, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) browse:(NSUInteger)page
                           success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSDictionary *result))success
                           failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/browse?page=%lu", self.urlEncodedIndexName, (unsigned long)page];
    return [self.apiClient performHTTPQuery:path method:@"GET" body:nil managers:self.apiClient.searchOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, page, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, page, errorMessage);
    }];
}


-(AFHTTPRequestOperation *) deleteUserKey:(NSString*)key
                                  success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSString *key, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/keys/%@", self.urlEncodedIndexName, key];
    return [self.apiClient performHTTPQuery:path method:@"DELETE" body:nil managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                               success:(void(^)(ASRemoteIndex *index, NSArray *acls, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage))failure
{
    NSDictionary *params = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];
    return [self addUserKey:acls withParams:params success:^(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(index, acls, result);
    } failure:^(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSString *errorMessage) {
        if (failure)
            failure(index, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) addUserKey:(NSArray*)acls
                            withParams:(NSDictionary*)params
                               success:(void(^)(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSString *errorMessage))failure
{
    [params setValue:acls forKey:@"acl"];
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/keys", self.urlEncodedIndexName];
    return [self.apiClient performHTTPQuery:path method:@"POST" body:params managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
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
                               success:(void(^)(ASRemoteIndex *index, NSArray *acls, NSDictionary *result))success
                               failure:(void(^)(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage))failure;
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self addUserKey:acls withParams:dict success:^(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(index, acls, result);
    } failure:^(ASRemoteIndex *index, NSArray* acls, NSDictionary *params, NSString *errorMessage) {
        if (failure)
            failure(index, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                               withParams:(NSDictionary*)params
                                  success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/keys/%@", self.urlEncodedIndexName, key];
    return [self.apiClient performHTTPQuery:path method:@"PUT" body:params managers:self.apiClient.writeOperationManagers index:0 timeout:self.apiClient.timeout success:^(id JSON) {
        if (success != nil)
            success(self, key, params, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(self, key, params, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                                  withACL:(NSArray*)acls
                                  success:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:acls forKey:@"acl"];
    return [self updateUserKey:key withParams:dict success:^(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(index, key, acls, result);
    } failure:^(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSString *errorMessage) {
        if (failure != nil)
            failure(index, key, acls, errorMessage);
    }];
}

-(AFHTTPRequestOperation *) updateUserKey:(NSString*)key
                                  withACL:(NSArray*)acls
                             withValidity:(NSUInteger)validity
                   maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour
                          maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
                                  success:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result))success
                                  failure:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage))failure;
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:acls, @"acl",
                                 @(validity), @"validity",
                                 @(maxQueriesPerIPPerHour), @"maxQueriesPerIPPerHour",
                                 @(maxHitsPerQuery), @"maxHitsPerQuery",
                                 nil];
    return [self updateUserKey:key withParams:dict success:^(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSDictionary *result) {
        if (success != nil)
            success(index, key, acls, result);
    } failure:^(ASRemoteIndex *index, NSString *key, NSDictionary *params, NSString *errorMessage) {
        if (failure != nil)
            failure(index, key, acls, errorMessage);
    }];
}

@end
