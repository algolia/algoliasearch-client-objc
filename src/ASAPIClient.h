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

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ASRemoteIndex.h"

/**
 * Entry point in the Objective-C API.
 * You should instantiate a Client object with your ApplicationID, ApiKey and Hosts
 * to start using Algolia Search API
 */
@interface ASAPIClient : NSObject

/**
 * Algolia Search initialization
 *
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 */
+(instancetype) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey;

/**
 * Algolia Search initialization
 *
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 * @param hostnames the list of hosts that you have received for the service
 */
+(instancetype) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames;

/**
 * Algolia Search initialization
 *
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 */
+(instancetype) apiClientWithDSN:(NSString*)applicationID apiKey:(NSString*)apiKey;

/**
 * Algolia Search initialization
 *
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 * @param hotsnames the list of hosts that you have received for the service
 * @param dsnHost override the automatic computation of dsn hostname
 */
+(instancetype) apiClientWithDSN:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames dsnHost:(NSString*)dsnHost;

/**
 * Algolia Search initialization
 *
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 * @param hostnames the list of hosts that you have received for the service
 * @param dsn set to true if your account has the Distributed Search Option
 * @param dsnHost override the automatic computation of dsn hostname
 * @param tagFilters value of the header X-Algolia-TagFilters
 * @param userToken value of the header X-Algolia-UserToken
 */
-(instancetype) initWithApplicationID:(NSString*)papplicationID apiKey:(NSString*)papiKey hostnames:(NSArray*)phostnames dsn:(Boolean)dsn dsnHost:(NSString*)dsnHost tagFilters:(NSString*)tagFiltersHeader userToken:(NSString*)userTokenHeader;

/**
 * List all existing indexes
 * return an JSON Object in the success block in the form:
 * { "items": [ {"name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"},
 *              {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
 */
-(void) listIndexes:(void(^)(ASAPIClient *client, NSDictionary *result))success
                    failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure;

/**
 * Delete an index
 *
 * @param indexName the name of index to delete
 * return an object containing a "deletedAt" attribute in the success block
 */
-(void) deleteIndex:(NSString*)indexName
            success:(void(^)(ASAPIClient *client, NSString *indexName, NSDictionary *result))success
            failure:(void(^)(ASAPIClient *client, NSString *indexName, NSString *errorMessage))failure;

/**
 * Move an existing index.
 *
 * @param srcIndexName the name of index to copy.
 * @param dstIndexName the new index name that will contains srcIndexName (destination will be overriten if it already exist).
 */
-(void) moveIndex:(NSString*)srcIndexName to:(NSString*)dstIndexName
            success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
            failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure;
/**
 * Copy an existing index.
 *
 * @param srcIndexName the name of index to copy.
 * @param dstIndexName the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
 */
-(void) copyIndex:(NSString*)srcIndexName to:(NSString*)dstIndexName
          success:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result))success
          failure:(void(^)(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage))failure;

/**
 * Return 10 last log entries.
 */
-(void) getLogs:(void(^)(ASAPIClient *client, NSDictionary *result))success
          failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure;

/**
 * Return last logs entries.
 *
 * @param offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
 * @param length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
 */
-(void) getLogsWithOffset:(NSUInteger)offset length:(NSUInteger)length
        success:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result))success
        failure:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage))failure;

/**
 * Return last logs entries.
 *
 * @param offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
 * @param length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
 */
-(void) getLogsWithType:(NSUInteger)offset length:(NSUInteger)length type:(NSString*)type
                  success:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSDictionary *result))success
                  failure:(void(^)(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSString *errorMessage))failure;

/**
 * Get the index object initialized (no server call needed for initialization)
 *
 * @param indexName the name of index
 */
-(ASRemoteIndex*) getIndex:(NSString*)indexName;

/**
 * Allow to set custom extra header
 *
 * @param value of the header
 * @param key of the header
 */
-(void) setExtraHeader:(NSString*)value forHeaderField:key;

/**
 * Query multiple indexes with one API call
 *
 * @param query contains an array of queries with the associated index (NSArray of NSDictionary object @{"indexName":@"targettedIndex", @"query": theASQueryObject }).
 */
-(void) multipleQueries:(NSArray*)query
                        success:(void(^)(ASAPIClient *client, NSArray *queries, NSDictionary *result))success
                        failure: (void(^)(ASAPIClient *client, NSArray *queries, NSString *errorMessage))failure;

/**
 * List all existing user keys with their associated ACLs
 */
-(void) listUserKeys:(void(^)(ASAPIClient *client, NSDictionary *result))success
                     failure:(void(^)(ASAPIClient *client, NSString *errorMessage))failure;

/**
 * Get ACL of a user key
 */
-(void) getUserKeyACL:(NSString*)key success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                                     failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure;

/**
 * Delete an existing user key
 */
-(void) deleteUserKey:(NSString*)key success:(void(^)(ASAPIClient *client, NSString *key, NSDictionary *result))success
                                     failure:(void(^)(ASAPIClient *client, NSString *key, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 */
-(void) addUserKey:(NSArray*)acls
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 * @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
 * @param maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (no rate limit).
 * @param maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited) 
 */
-(void) addUserKey:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 * @param indexes restrict this new API key to specific index names
 * @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
 * @param maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (no rate limit).
 * @param maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
 */
-(void) addUserKey:(NSArray*)acls withIndexes:(NSArray*)indexes withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 */
-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
              failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 * @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
 * @param maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (no rate limit).
 * @param maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
 */
-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
              success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result))success
              failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSString *errorMessage))failure;

/**
 * Create a new user key
 *
 * @param acls the list of ACL for this key. Defined by an array of NSString that
 * can contains the following values:
 *   - search: allow to search (https and http)
 *   - addObject: allows to add/update an object in the index (https only)
 *   - deleteObject : allows to delete an existing object (https only)
 *   - deleteIndex : allows to delete index content (https only)
 *   - settings : allows to get index settings (https only)
 *   - editSettings : allows to change index settings (https only)
 * @param indexes restrict this new API key to specific index names
 * @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
 * @param maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (no rate limit).
 * @param maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited)
 */
-(void) updateUserKey:(NSString*)key withACL:(NSArray*)acls withIndexes:(NSArray*)indexes withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
              success:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSDictionary *result))success
              failure:(void(^)(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSString *errorMessage))failure;

@property (readonly, nonatomic) NSString *applicationID;
@property (readonly, nonatomic) NSString *apiKey;
@property (readonly, nonatomic) NSArray *writeHostnames;
@property (readonly, nonatomic) NSArray *searchHostnames;
@property (readonly, nonatomic) NSArray *searchOperationManagers;
@property (readonly, nonatomic) NSArray *writeOperationManagers;
@property NSTimeInterval timeout;
@property NSTimeInterval searchTimeout;

/**
 * Add security tag header (see http://www.algolia.com/doc/guides/objc#SecurityUser for more details)
 */
@property (nonatomic) NSString *tagFilters;

/**
 * Add user-token header (see http://www.algolia.com/doc/guides/objc#SecurityUser for more details)
 */
@property (nonatomic) NSString *userToken;

@end
