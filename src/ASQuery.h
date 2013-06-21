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

/**
 * Describes all parameters of search query.
 */
@interface ASQuery : NSObject

/**
 * Initialize query with a full text query string
 */
+(id) queryWithFullTextQuery:(NSString*)fullTextQuery;

/**
 * Initialize an empty query
 */
-(id) init;

/**
 * Initialize query with a full text query string
 */
-(id) initWithFullTextQuery:(NSString*)fullTextQuery;

/**
 *  Search for entries around a given latitude/longitude.
 *  @param maxDist set the maximum distance in meters.
 *  Note: at indexing, geoloc of an object should be set with _geoloc attribute containing lat and lng attributes (for example {"_geoloc":{"lat":48.853409, "lng":2.348800}})
 */
-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist;

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
 * "prefixAll": all query words are interpreted as prefixes (default behavior).
 * "prefixLast": only the last word is interpreted as a prefix. This option is recommended if you have a lot of content to speedup the processing.
 * "prefixNone": no query word is interpreted as a prefix. This option is not recommended.
 */
@property (strong, nonatomic) NSString            *queryType;

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
@property (strong, nonatomic) NSString            *tags;
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
 * Contains insideBoundingBox query (you should use searchInsideBoundingBox selector to set it)
 */
@property (strong, nonatomic) NSString             *insideBoundingBox;
/**
 * Contains aroundLatLong query (you should use searchAroundLatitude:longitude:maxDist selector to set it)
 */
@property (strong, nonatomic) NSString             *aroundLatLong;
@end
