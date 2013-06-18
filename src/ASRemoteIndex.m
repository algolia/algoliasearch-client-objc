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

#import "ASRemoteIndex.h"
#import "ASAPIClient+Network.h"

@implementation ASRemoteIndex

+(id) remoteIndexWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName
{
    return [[ASRemoteIndex alloc] initWithAPIClient:client indexName:indexName];
}

-(id) initWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName
{
    self = [super init];
    if (self) {
        self.apiClient = client;
        self.indexName = indexName;
        self.urlEncodedIndexName = [ASAPIClient urlEncode:indexName];
    }
    return self;
}

-(void) addObject:(NSDictionary*)object success:(void(^)(NSDictionary *object, NSDictionary *result))success
          failure:(void(^)(NSDictionary *object, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@", self.urlEncodedIndexName];
    [self.apiClient performHTTPQuery:path method:@"POST" body:object index:0 success:^(id JSON) {
        if (success != nil)
            success(object, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(object, errorMessage);
    }];
}

-(void) addObject:(NSDictionary*)object withObjectID:(NSString*)objectID
          success:(void(^)(NSDictionary *object, NSString *objectID, NSDictionary *result))success
          failure:(void(^)(NSDictionary *object, NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    [self.apiClient performHTTPQuery:path method:@"PUT" body:object index:0 success:^(id JSON) {
        if (success != nil)
            success(object, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(object, objectID, errorMessage);
    }];
}

-(void) addObjects:(NSArray*)objects success:(void(^)(NSArray *objects, NSDictionary *result))success
           failure:(void(^)(NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSDictionary *object in objects) {
        [requests addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"addObject", @"action",
                             object, @"body", nil]];
    }
    NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil];
    [self.apiClient performHTTPQuery:path method:@"POST" body:request index:0 success:^(id JSON) {
        if (success != nil)
            success(objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(objects, errorMessage);
    }];
}

-(void) getObject:(NSString*)objectID success:(void(^)(NSString *objectID, NSDictionary *result))success
          failure:(void(^)(NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(objectID, errorMessage);
    }];
}

-(void) getObject:(NSString*)objectID attributesToRetrieve:(NSArray*)attributes
          success:(void(^)(NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result))success
          failure:(void(^)(NSString *objectID, NSArray *attributesToRetrieve, NSString *errorMessage))failure
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"/1/indexes/%@/%@?attributes=", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    BOOL firstEntry = YES;
    for (NSString *attribute in attributes) {
        if (!firstEntry)
            [path appendString:@","];
        [path appendString:[ASAPIClient urlEncode:attribute]];
        firstEntry = NO;
    }
    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(objectID, attributes, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(objectID, attributes, errorMessage);
    }];
}

-(void) partialUpdateObject:(NSDictionary*)partialObject objectID:(NSString*)objectID
                    success:(void(^)(NSDictionary *partialObject, NSString *objectID, NSDictionary *result))success
                    failure:(void(^)(NSDictionary *partialObject, NSString *objectID, NSString *errorMessage))failure
{
    NSMutableString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@/partial", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    [self.apiClient performHTTPQuery:path method:@"POST" body:partialObject index:0 success:^(id JSON) {
        if (success != nil)
            success(partialObject, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(partialObject, objectID, errorMessage);
    }];
}

-(void) saveObject:(NSDictionary*)object objectID:(NSString*)objectID
           success:(void(^)(NSDictionary *object, NSString *objectID, NSDictionary *result))success
           failure:(void(^)(NSDictionary *object, NSString *objectID, NSString *errorMessage))failure
{
    NSMutableString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    [self.apiClient performHTTPQuery:path method:@"PUT" body:object index:0 success:^(id JSON) {
        if (success != nil)
            success(object, objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(object, objectID, errorMessage);
    }];
}

-(void) saveObjects:(NSArray*)objects
            success:(void(^)(NSArray *objects, NSDictionary *result))success
            failure:(void(^)(NSArray *objects, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/batch", self.urlEncodedIndexName];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    for (NSDictionary *object in objects) {
        [requests addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"updateObject", @"action",
                             [object valueForKey:@"objectID"], @"objectID",
                             object, @"body", nil]];
    }
    NSDictionary *request = [NSDictionary dictionaryWithObjectsAndKeys:requests, @"requests", nil];
    [self.apiClient performHTTPQuery:path method:@"POST" body:request index:0 success:^(id JSON) {
        if (success != nil)
            success(objects, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(objects, errorMessage);
    }];
}

-(void) deleteObject:(NSString*)objectID
             success:(void(^)(NSString *objectID, NSDictionary *result))success
             failure:(void(^)(NSString *objectID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/%@", self.urlEncodedIndexName, [ASAPIClient urlEncode:objectID]];
    [self.apiClient performHTTPQuery:path method:@"DELETE" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(objectID, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(objectID, errorMessage);
    }];
}

-(void) search:(ASQuery*)query
       success:(void(^)(ASQuery *query, NSDictionary *result))success
       failure:(void(^)(ASQuery *query, NSString *errorMessage))failure
{
    NSString *queryParams = [query buildURL];
    NSString *path = nil;
    
    if ([queryParams length] > 0) {
        path = [NSString stringWithFormat:@"/1/indexes/%@?%@", self.urlEncodedIndexName, queryParams];
    } else {
        path = [NSString stringWithFormat:@"/1/indexes/%@", self.urlEncodedIndexName];
    }
    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(query, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(query, errorMessage);
    }];
}

-(void) waitTask:(NSString*)taskID
success:(void(^)(NSString *taskID, NSDictionary *result))success
failure:(void(^)(NSString *taskID, NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/task/%@", self.urlEncodedIndexName, taskID];
    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        NSString *status = [JSON valueForKey:@"status"];
        if ([status compare:@"published"] == NSOrderedSame) {
            if (success != nil)
                success(taskID, JSON);
        } else {
            sleep(1);
            [self waitTask:taskID success:success failure:failure];
        }
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(taskID, errorMessage);
    }];
}

-(void) getSettings:(void(^)(NSDictionary *result))success
            failure:(void(^)(NSString *errorMessage))failure
{
    NSString *path = [NSString stringWithFormat:@"/1/indexes/%@/settings", self.urlEncodedIndexName];
    [self.apiClient performHTTPQuery:path method:@"GET" body:nil index:0 success:^(id JSON) {
        if (success != nil)
            success(JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(errorMessage);
    }];
}

-(void) setSettings:(NSDictionary*)settings
            success:(void(^)(NSDictionary *settings, NSDictionary *result))success
            failure:(void(^)(NSDictionary *settings, NSString *errorMessage))failure
{
    NSMutableString *path = [NSString stringWithFormat:@"/1/indexes/%@/settings", self.urlEncodedIndexName];
    [self.apiClient performHTTPQuery:path method:@"PUT" body:settings index:0 success:^(id JSON) {
        if (success != nil)
            success(settings, JSON);
    } failure:^(NSString *errorMessage) {
        if (failure != nil)
            failure(settings, errorMessage);
    }];
}
@end
