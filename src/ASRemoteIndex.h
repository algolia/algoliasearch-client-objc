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
+(instancetype) remoteIndexWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName;

/**
 * Index initialization
 */
-(instancetype) initWithAPIClient:(ASAPIClient*)client indexName:(NSString*)indexName;


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
 * Delete several objects
 *
 * @param objects contains an array of objectID to delete (NSArray of NSString object).
 */
-(void) deleteObjects:(NSArray*)objects
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
 * Get several objects from this index
 *
 * @param objectIDs the array of unique identifier of objects to retrieve
 */
-(void) getObjects:(NSArray*)objectIDs
           success:(void(^)(ASRemoteIndex *index, NSArray *objectIDs, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSArray *objectIDs, NSString *errorMessage))failure;

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
 * Partially override the content of several objects
 *
 * @param objects contains an array of NSDictionary to update (each NSDictionary must contains an objectID attribute)
 */
-(void) partialUpdateObjects:(NSArray*)objects
            success:(void(^)(ASRemoteIndex *index, NSArray *objects, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage))failure;


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
 * - minWordSizefor1Typo: (integer) the minimum number of characters to accept one typo (default = 3).
 * - minWordSizefor2Typos: (integer) the minimum number of characters to accept two typos (default = 7).
 * - hitsPerPage: (integer) the number of hits per page (default = 10).
 * - attributesToRetrieve: (array of strings) default list of attributes to retrieve in objects. 
 *   If set to null, all attributes are retrieved.
 * - attributesToHighlight: (array of strings) default list of attributes to highlight. 
 *   If set to null, all indexed attributes are highlighted.
 * - attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is attributeName:nbWords).
 *   By default no snippet is computed. If set to null, no snippet is computed.
 * - attributesToIndex: (array of strings) the list of fields you want to index.
 *   If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results.
 *   This parameter has two important uses:
 *     - Limit the attributes to index: For example if you store a binary image in base64, you want to store it and be able to 
 *       retrieve it but you don't want to search in the base64 string.
 *     - Control part of the ranking*: (see the ranking parameter for full explanation) Matches in attributes at the beginning of 
 *       the list will be considered more important than matches in attributes further down the list. 
 *       In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable 
 *       this behavior if you add your attribute inside `unordered(AttributeName)`, for example attributesToIndex: ["title", "unordered(text)"].
 * - attributesForFaceting: (array of strings) The list of fields you want to use for faceting. 
 *   All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
 * - ranking: (array of strings) controls the way results are sorted.
 *   We have six available criteria: 
 *    - typo: sort according to number of typos,
 *    - geo: sort according to decreassing distance when performing a geo-location based search,
 *    - proximity: sort according to the proximity of query words in hits,
 *    - attribute: sort according to the order of attributes defined by attributesToIndex,
 *    - exact: sort according to the number of words that are matched identical to query word (and not as a prefix),
 *    - custom: sort according to a user defined formula set in **customRanking** attribute.
 *   The standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"]
 * - customRanking: (array of strings) lets you specify part of the ranking.
 *   The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
 *   For example `"customRanking" => ["desc(population)", "asc(name)"]`  
 * - queryType: Select how the query words are interpreted, it can be one of the following value:
 *   - prefixAll: all query words are interpreted as prefixes,
 *   - prefixLast: only the last word is interpreted as a prefix (default behavior),
 *   - prefixNone: no query word is interpreted as a prefix. This option is not recommended.
 * - highlightPreTag: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
 * - highlightPostTag: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
 * - optionalWords: (array of strings) Specify a list of words that should be considered as optional when found in the query.
 */
-(void) setSettings:(NSDictionary*)settings
            success:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage))failure;

/**
 * Delete the index content without removing settings and index specific API keys.
 */
-(void) clearIndex:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure;

/**
 * List all existing user keys associated to this index
 */
-(void) listUserKeys:(void(^)(ASRemoteIndex *index, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSString *errorMessage))failure;

/**
 * Get ACL of a user key associated to this index
 */
-(void) getUserKeyACL:(NSString*)key
            success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
            failure:(void(^)(ASRemoteIndex *index, NSString *key, NSString *errorMessage))failure;

/**
 * Delete an existing user key associated to this index
 */
-(void) deleteUserKey:(NSString*)key
              success:(void(^)(ASRemoteIndex *index, NSString *key, NSDictionary *result))success
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
 * @param maxQueriesPerIPPerHour Specify the maximum number of API calls allowed from an IP address per hour.  Defaults to 0 (no rate limit).
 * @param maxHitsPerQuery Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited) 
 */
-(void) addUserKey:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
           success:(void(^)(ASRemoteIndex *index, NSArray *acls, NSDictionary *result))success
           failure:(void(^)(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage))failure;

/**
 * Update a user key associated to this index
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
-(void) updateUserKey:(NSString*) key withACL:(NSArray*)acls
              success:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result))success
              failure:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage))failure;

/**
 * Update a new user key associated to this index
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
-(void) updateUserKey:(NSString*) key withACL:(NSArray*)acls withValidity:(NSUInteger)validity maxQueriesPerIPPerHour:(NSUInteger)maxQueriesPerIPPerHour maxHitsPerQuery:(NSUInteger)maxHitsPerQuery
              success:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result))success
              failure:(void(^)(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage))failure;

/**
 * Browse all index content
 *
 * @param page Pagination parameter used to select the page to retrieve.
 *             Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
 * @param hitsPerPage: Pagination parameter used to select the number of hits per page. Defaults to 1000.
 */
-(void) browse:(NSUInteger)page hitsPerPage:(NSUInteger)hitsPerPage
       success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSDictionary *result))success
       failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSString *errorMessage))failure;

/**
 * Browse all index content
 *
 * @param page Pagination parameter used to select the page to retrieve.
 *             Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
 */
-(void) browse:(NSUInteger)page
       success:(void(^)(ASRemoteIndex *index, NSUInteger page, NSDictionary *result))success
       failure:(void(^)(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage))failure;

/**
 * Delete all previous search queries
 */
-(void) cancelPreviousSearches;

@property (nonatomic)           NSString     *indexName;
@property (readonly, nonatomic) ASAPIClient  *apiClient;
@property (nonatomic)           NSString     *urlEncodedIndexName;

@end
