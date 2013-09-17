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
#import "ASQuery.h"

@class ASAPIClient;

/**
 * Contains all the functions related to one index
 * You can use APIClient.getIndex(indexName) to retrieve this object
 */
@interface ASRemoteIndex : NSObject

/**
 * Index initialization
 */
+(id) remoteIndexWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName;

/**
 * Index initialization
 */
-(id) initWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName;


/**
 * Add an object in this index
 *
 * @param content contains the object to add inside the index.
 *  The object is represented by an associative array
 */
-(void) addObject:(NSDictionary*)object
          success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result))success
          failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage))failure;

/**
 * Add an object in this index
 *
 * @param content contains the object to add inside the index.
 *  The object is represented by an associative array
 * @param objectID an objectID you want to attribute to this object
 * (if the attribute already exist the old object will be overwrite)
 */
-(void) addObject:(NSDictionary*)object withObjectID:(NSString*)objectID
           success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSString *errorMessage))failure;

/**
 * Add several objects
 *
 * @param objects contains an array of objects to add (NSArray of NSDictionary object).
 */
-(void) addObjects:(NSArray*)objects
           success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure;

/**
 * Get an object from this index
 *
 * @param objectID the unique identifier of the object to retrieve
 */
-(void) getObject:(NSString*)objectID
          success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSDictionary *result))success
          failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage))failure;

/**
 * Get an object from this index
 *
 * @param objectID the unique identifier of the object to retrieve
 * @param attributesToRetrieve, contains the list of attributes to retrieve as a string separated by ","
 */
-(void) getObject:(NSString*)objectID attributesToRetrieve:(NSArray*)attributes
          success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result))success
          failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSString *errorMessage))failure;

/**
 * Update partially an object (only update attributes passed in argument)
 *
 * @param partialObject contains the object attributes to override, the
 *  object must contains an objectID attribute
 */
-(void) partialUpdateObject:(NSDictionary*)partialObject objectID:(NSString*)objectID
                    success:(void(^)(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result))success
                    failure:(void(^)(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage))failure;

/**
 * Override the content of object
 *
 * @param object contains the object to save
 */
-(void) saveObject:(NSDictionary*)object objectID:(NSString*)objectID
           success:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSString *errorMessage))failure;

/**
 * Override the content of several objects
 *
 * @param objects contains an array of NSDictionary to update (each NSDictionary must contains an objectID attribute)
 */
-(void) saveObjects:(NSArray*)objects
            success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure;

/**
 * Delete an object from the index
 *
 * @param objectID the unique identifier of object to delete
 */
-(void) deleteObject:(NSString*)objectID
             success:(void(^)(ASRemoteIndex *index, NSString *objectID, NSDictionary *result))success
             failure:(void(^)(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage))failure;

/**
 * Search inside the index
 */
-(void) search:(ASQuery*)query
       success:(void(^)(ASRemoteIndex *index, ASQuery *query, NSDictionary *result))success
       failure:(void(^)(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage))failure;

/**
 * Wait the publication of a task on the server.
 * All server task are asynchronous and you can check with this method that the task is published.
 *
 * @param taskID the id of the task returned by server
 */
-(void) waitTask:(NSString*)taskID
         success:(void(^)(ASRemoteIndex *index, NSString *taskID, NSDictionary *result))success
         failure:(void(^)(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage))failure;


/**
 * Get settings of this index
 */
-(void) getSettings:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
                    failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure;

/**
 * Set settings for this index
 *
 * @param settigns the settings object that can contains :
 *  - minWordSizeForApprox1 (integer) the minimum number of characters to accept one typo (default = 3)
 *  - minWordSizeForApprox2: (integer) the minimum number of characters to accept two typos (default = 7)
 *  - hitsPerPage: (integer) the number of hits per page (default = 10)
 *  - attributesToRetrieve: (array of strings) default list of attributes to retrieve for objects
 *  - attributesToHighlight: (array of strings) default list of attributes to highlight
 *  - attributesToIndex: (array of strings) the list of fields you want to index.
 *    By default all textual and numerical attributes of your objects are indexed, but you should update it to get optimal
 *    results. This parameter has two important uses:
 *       - Limit the attributes to index.
 *         For example if you store a binary image in base64, you want to store it in the index but you
 *         don't want to use the base64 string for search.
 *       - Control part of the ranking (see the ranking parameter for full explanation).
 *         Matches in attributes at the beginning of the list will be considered more important than matches
 *         in attributes further down the list.
 *  - ranking: (array of strings) controls the way results are sorted.
 *     We have four available criteria:
 *       - typo (sort according to number of typos),
 *       - geo: (sort according to decreassing distance when performing a geo-location based search),
 *       - proximity: sort according to the proximity of query words in hits,
 *       - attribute: sort according to the order of attributes defined by **attributesToIndex**,
 *       - exact: sort according to the number of words that are matched identical to query word (and not as a prefix),
 *       - custom which is user defined
 *     (the standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"])
 *  - customRanking: (array of strings) lets you specify part of the ranking.
 *    The syntax of this condition is an array of strings containing attributes prefixed
 *    by asc (ascending order) or desc (descending order) operator.
 */
-(void) setSettings:(NSDictionary*)settings
            success:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage))failure;

/**
 * List all existing user keys associated to this index
 */
-(void) listUserKeys:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
             failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure;

/**
 * Get ACL of a user key associated to this index
 */
-(void) getUserKeyACL:(NSString*)key success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
              failure:(void(^)(ASRemoteIndex *index, NSString *key, NSString *errorMessage))failure;

/**
 * Delete an existing user key associated to this index
 */
-(void) deleteUserKey:(NSString*)key success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
              failure:(void(^)(ASRemoteIndex *index, NSString *key, NSString *errorMessage))failure;

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
 */
-(void) addUserKey:(NSArray*)acls
           success:(void(^)(ASRemoteIndex *index, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage))failure;

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
           success:(void(^)(ASRemoteIndex *index, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage))failure;

/**
 * Delete all previous search queries
 */
-(void) cancelPreviousSearches;

@property (strong, nonatomic) NSString     *indexName;
@property (strong, nonatomic) ASAPIClient  *apiClient;
@property (strong, nonatomic) NSString     *urlEncodedIndexName;

@end
