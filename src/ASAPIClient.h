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
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 */
+(id) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey;

/**
 * Algolia Search initialization
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 * @param hostnames the list of hosts that you have received for the service
 */
+(id) apiClientWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames;

/**
 * Algolia Search initialization
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 */
-(id) initWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey;

/**
 * Algolia Search initialization
 * @param applicationID the application ID you have in your admin interface
 * @param apiKey a valid API key for the service
 * @param hostnames the list of hosts that you have received for the service
 */
-(id) initWithApplicationID:(NSString*)applicationID apiKey:(NSString*)apiKey hostnames:(NSArray*)hostnames;

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
 * Get the index object initialized (no server call needed for initialization)
 *
 * @param indexName the name of index
 */
-(ASRemoteIndex*) getIndex:(NSString*)indexName;

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
 * Create a new user key associated to this index
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
 */
-(void) addUserKey:(NSArray*)acls withValidity:(NSUInteger)validity
           success:(void(^)(ASAPIClient *client, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASAPIClient *client, NSArray *acls, NSString *errorMessage))failure;

@property (strong, nonatomic) NSString *applicationID;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSArray  *hostnames;
@property (strong, nonatomic) NSArray  *clients;
@end
