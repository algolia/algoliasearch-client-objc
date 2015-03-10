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

/**
 * Describes all parameters of search query.
 */
@interface ASQuery : NSObject

/**
 * Initialize query with a full text query string
 */
+(instancetype) queryWithFullTextQuery:(NSString*)fullTextQuery;

/**
 * Initialize an empty query
 */
-(instancetype) init;

/**
 * Initialize query with a full text query string
 */
-(instancetype) initWithFullTextQuery:(NSString*)fullTextQuery;

/**
 *  Search for entries around a given latitude/longitude.
 *
 *  @param maxDist set the maximum distance in meters.
 *  Note: at indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist;

/**
 *  Search for entries around a given latitude/longitude.
 *
 *  @param maxDist set the maximum distance in meters.
 *  @param precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
 *  Note: at indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist precision:(NSUInteger)precision;

/**
 *  Search for entries around a given latitude/longitude (using IP geolocation)
 *
 *  @param maxDist set the maximum distance in meters.
 *  Note: at indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchAroundLatitudeLongitudeViaIP:(NSUInteger)maxDist;

/**
 *  Search for entries around a given latitude/longitude (using IP geolocation)
 *
 *  @param maxDist set the maximum distance in meters.
 *  @param precision set the precision for ranking (for example if you set precision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
 *  Note: at indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchAroundLatitudeLongitudeViaIP:(NSUInteger)maxDist precision:(NSUInteger)precision;


/**
 *  Search for entries inside a given area defined by the two extreme points of a rectangle.
 *    At indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchInsideBoundingBoxWithLatitudeP1:(float)latitudeP1 longitudeP1:(float)longitudeP1 latitudeP2:(float)latitudeP2 longitudeP2:(float)longitudeP2;

/**
 * Return the final query string used in URL.
 */
-(NSString*) buildURL;

/**
 * Select how the query words are interpreted:
 * "prefixAll": all query words are interpreted as prefixes,
 * "prefixLast": only the last word is interpreted as a prefix (default behavior),
 * "prefixNone": no query word is interpreted as a prefix. This option is not recommended.
 */
@property (strong, nonatomic) NSString            *queryType;

/**
 * Select the strategy to avoid having an empty result page.
 * "None": No specific processing is done when a query does not return any result,
 * "LastWords": when a query does not return any result, the final word will be removed until there is results,
 * "FirstWords": when a query does not return any result, the first word will be removed until there is results.
 * "allOptional": When a query does not return any result, a second trial will be made with all words as optional (which is equivalent to transforming the AND operand between query terms in a OR operand)
 */
@property (strong, nonatomic) NSString              *removeWordsIfNoResult;

/**
 * Specify the list of attribute names to retrieve.
 * By default all attributes are retrieved.
 */
@property (strong, nonatomic) NSArray             *attributesToRetrieve;
/**
 * Specify the list of attribute names to highlight.
 * By default indexed attributes are highlighted.
 */
@property (strong, nonatomic) NSArray             *attributesToHighlight;
/**
 * Specify the list of attributes to snippet alongside the number of words to return 
 * (syntax is 'attributeName:nbWords'). 
 * Attributes are separated by a comma (Example: "attributesToSnippet=name:10,content:10").
 * By default no snippet is computed.
*/
@property (strong, nonatomic) NSArray             *attributesToSnippet;
/**
 * Filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example tag1,(tag2,tag3) means tag1 AND (tag2 OR tag3).
 * At indexing, tags should be added in the _tags attribute of objects (for example {"_tags":["tag1","tag2"]} )
 */
@property (strong, nonatomic) NSString            *tagFilters;

/**
 * Add a list of numeric filters separated by a comma.
 * The syntax of one filter is `attributeName` followed by `operand` followed by `value. Supported operands are `<`, `<=`, `=`, `>` and `>=`.
 * You can have multiple conditions on one attribute like for example `numerics=price>100,price<1000`.
 */
@property (strong, nonatomic) NSString            *numericFilters;
/**
 * Set the full text query.
 */
@property (strong, nonatomic) NSString            *fullTextQuery;
/**
 * Specify the minimum number of characters in a query word to accept one typo in this word.
 * Defaults to 3.
 */
@property NSUInteger                              minWordSizeForApprox1;
/**
 * Specify the minimum number of characters in a query word to accept two typos in this word.
 * Defaults to 7.
 */
@property NSUInteger                               minWordSizeForApprox2;
/**
 * Set the page to retrieve (zero base). Defaults to 0.
 */
@property NSUInteger                               page;
/**
 *  Set the number of hits per page. Defaults to 10.
 */
@property NSUInteger                               hitsPerPage;
/**
 * if set, the result hits will contain ranking information in _rankingInfo attribute.
 */
@property BOOL                                     getRankingInfo;
/**
 * If set to YES, plural won't be considered as a typo (for example car/cars will be considered as equals). Default to NO.
 */
@property BOOL                                     ignorePlural;

/**
 * This option allow to control the number of typo in the results set.
 */
@property (strong, nonatomic) NSString             *typoTolerance;
/**
 *  If set to false, disable typo-tolerance on numeric tokens. Default to true.
 */
@property BOOL                                     typosOnNumericTokens;
/**
 * If set to false, disable this query won't appear in the analytics. Default to true.
 */
@property BOOL                                      analytics;
/**
 * If set to false, this query will not use synonyms defined in configuration. Default to true.
 */
@property BOOL                                      synonyms;
/**
 * If set to false, words matched via synonyms expansion will not be replaced by the matched synonym in highlight result. Default to true.
 */
@property BOOL                                      replaceSynonyms;

/**
 *
 * If set to YES, enable the distinct feature (disabled by default) if the attributeForDistinct index
 *   setting is set.
 *   This feature is similar to the SQL "distinct" keyword: when enabled in a query with the distinct=1 parameter,
 *   all hits containing a duplicate value for the attributeForDistinct attribute are removed from results.
 *   For example, if the chosen attribute is show_name and several hits have the same value for show_name, 
 *   then only the best one is kept and others are removed.
 */
@property BOOL                                     distinct;
/**
 * Contains insideBoundingBox query (you should use searchInsideBoundingBox selector to set it)
 */
@property (strong, nonatomic) NSString             *insideBoundingBox;
/**
 * Contains aroundLatLong query (you should use searchAroundLatitude:longitude:maxDist selector to set it)
 */
@property (strong, nonatomic) NSString             *aroundLatLong;
/**
 * If set to YES use geolocation via client IP instead of passing a latitude/longitude manually
 */
@property BOOL                                     aroundLatLongViaIP;
/**
  * Set the list of words that should be considered as optional when found in the query (array of NSString).
  */
@property (strong, nonatomic) NSArray              *optionalWords;
/**
 *  Set the minimum number of optional words that need to match
 */
@property NSUInteger                               optionalWordsMinimumMatched;

/**
 * Filter the query by a list of facets. Each facet is encoded as `attributeName:value`. For example: ["category:Book","author:John%20Doe"].
 */
@property (strong, nonatomic) NSArray              *facetFilters;

/**
 * Filter the query by a list of facets encoded as one string by example "(category:Book,author:John)"
 */
@property (strong, nonatomic) NSString             *facetFiltersRaw;

/**
 * List of object attributes that you want to use for faceting. <br/>
 * Only attributes that have been added in **attributesForFaceting** index setting can be used in this parameter. 
 * You can also use `*` to perform faceting on all attributes specified in **attributesForFaceting**.
 */
@property (strong, nonatomic) NSArray             *facets;

/**
 * List of object attributes you want to use for textual search (must be a subset of the attributesToIndex 
 * index setting). Attributes are separated with a comma (for example @"name,address").
 * You can also use a JSON string array encoding (for example encodeURIComponent("[\"name\",\"address\"]")).
 * By default, all attributes specified in attributesToIndex settings are used to search.
 */
@property (strong, nonatomic) NSString            *restrictSearchableAttributes;

@end
