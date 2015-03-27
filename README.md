# Algolia Search API Client for iOS and OS X



[Algolia Search](http://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.

Our Objective-C client lets you easily use the [Algolia Search API](https://www.algolia.com/doc/rest_api) from your iOS & OS X applications. It wraps the [Algolia Search REST API](http://www.algolia.com/doc/rest_api).


[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-objc.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-objc)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/p/AlgoliaSearch-Client.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client.svg)]()




Table of Contents
=================
**Getting Started**

1. [Setup](#setup)
1. [Quick Start](#quick-start)
1. [Online documentation](#documentation)
1. [Tutorials](#tutorials)

**Commands Reference**

1. [Add a new object](#add-a-new-object-in-the-index)
1. [Update an object](#update-an-existing-object-in-the-index)
1. [Search](#search)
1. [Get an object](#get-an-object)
1. [Delete an object](#delete-an-object)
1. [Delete by query](#delete-by-query)
1. [Index settings](#index-settings)
1. [List indices](#list-indices)
1. [Delete an index](#delete-an-index)
1. [Clear an index](#clear-an-index)
1. [Wait indexing](#wait-indexing)
1. [Batch writes](#batch-writes)
1. [Security / User API Keys](#security--user-api-keys)
1. [Copy or rename an index](#copy-or-rename-an-index)
1. [Backup / Retrieve all index content](#backup--retrieve-all-index-content)
1. [Logs](#logs)





Setup
-------------
To setup your project, follow these steps:




 1. [Download and add sources](https://github.com/algolia/algoliasearch-client-objc/archive/master.zip) to your project or use cocoapods by adding `pod 'AlgoliaSearch-Client', '~> 3.1'` in your Podfile (or `pod 'AlgoliaSearch-Client', '~> 2.0'` if your are using AFNetworking 1.x in your project)  or drop the source folder on your project (If you are not using a Podfile, you will also need to add [AFNetworking library](https://github.com/AFNetworking/AFNetworking) in your project).
 2. Add the `#import "ASAPIClient.h"` call to your project
 3. Initialize the client with your ApplicationID and API-Key. You can find all of them on [your Algolia account](http://www.algolia.com/users/edit).

```objc
ASAPIClient *apiClient = 
    [ASAPIClient apiClientWithApplicationID:@"YourApplicationID" apiKey:@"YourAPIKey"];
```










Quick Start
-------------

In 30 seconds, this quick start tutorial will show you how to index and search objects.

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/algoliasearch-client-csharp/blob/master/contacts.json) in the ```contacts``` index using the following code:
```objc
// Load JSON file
NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"json"];
NSData* jsonData = [NSData dataWithContentsOfFile:jsonPath];
NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
// Load all objects of json file in an index named "contacts"
ASRemoteIndex *index = [apiClient getIndex:@"contacts"];
[index addObjects:dict[@"objects"] success:nil failure:nil];
```

You can now search for contacts using firstname, lastname, company, etc. (even with typos):
```objc
// search by firstname
[index search:[ASQuery queryWithFullTextQuery:@"jimmie"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
// search a firstname with typo
[index search:[ASQuery queryWithFullTextQuery:@"jimie"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
// search for a company
[index search:[ASQuery queryWithFullTextQuery:@"california paint"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
// search for a firstname & company
[index search:[ASQuery queryWithFullTextQuery:@"jimmie paint"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
```

Settings can be customized to tune the search behavior. For example, you can add a custom sort by number of followers to the already great built-in relevance:
```objc
NSArray *customRanking = @[@"desc(followers)"];
NSDictionary *settings = @{@"customRanking": customRanking};
[index setSettings:settings success:nil
  failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
    NSLog(@"Error when applying settings: %@", errorMessage);
}];
```

You can also configure the list of attributes you want to index by order of importance (first = most important):
```objc
NSArray *customRanking = @[@"lastname", @"firstname", @"company", @"email", @"city", @"address"];
NSDictionary *settings = @{@"attributesToIndex": customRanking};
[index setSettings:settings success:nil
  failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
    NSLog(@"Error when applying settings: %@", errorMessage);
}];
```

Since the engine is designed to suggest results as you type, you'll generally search by prefix. In this case the order of attributes is very important to decide which hit is the best:
```objc
[index search:[ASQuery queryWithFullTextQuery:@"or"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];

[index search:[ASQuery queryWithFullTextQuery:@"jim"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
```









Documentation
================

Check our [online documentation](http://www.algolia.com/doc/guides/objc):
 * [Initial Import](http://www.algolia.com/doc/guides/objc#InitialImport)
 * [Ranking &amp; Relevance](http://www.algolia.com/doc/guides/objc#RankingRelevance)
 * [Indexing](http://www.algolia.com/doc/guides/objc#Indexing)
 * [Search](http://www.algolia.com/doc/guides/objc#Search)
 * [Sorting](http://www.algolia.com/doc/guides/objc#Sorting)
 * [Filtering](http://www.algolia.com/doc/guides/objc#Filtering)
 * [Faceting](http://www.algolia.com/doc/guides/objc#Faceting)
 * [Geo-Search](http://www.algolia.com/doc/guides/objc#Geo-Search)
 * [Security](http://www.algolia.com/doc/guides/objc#Security)
 * [REST API](http://www.algolia.com/doc/rest)


Tutorials
================

Check out our [tutorials](http://www.algolia.com/doc/tutorials):
 * [Search bar with autocomplete menu](http://www.algolia.com/doc/tutorials/auto-complete)
 * [Search bar with multi category autocomplete menu](http://www.algolia.com/doc/tutorials/multi-auto-complete)
 * [Instant search result pages](http://www.algolia.com/doc/tutorials/instant-search)



Commands Reference
==================





Add a new object to the Index
-------------

Each entry in an index has a unique identifier called `objectID`. There are two ways to add en entry to the index:

 1. Using automatic `objectID` assignment. You will be able to access it in the answer.
 2. Supplying your own `objectID`.

You don't need to explicitly create an index, it will be automatically created the first time you add an object.
Objects are schema less so you don't need any configuration to start indexing. If you wish to configure things, the settings section provides details about advanced settings.

Example with automatic `objectID` assignment:

```objc
NSDictionary *newObject = @{@"firstname": @"Jimmie", @"lastname": @"Barninger"};
[index addObject:newObject 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
  	NSLog(@"Object ID: %@", result[@"objectID"]);
} failure:nil];
```

Example with manual `objectID` assignment:

```objc
NSDictionary *newObject = @{@"firstname": @"Jimmie", @"lastname": @"Barninger"};
[index addObject:newObject withObjectID:@"myID" 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result) {
    NSLog(@"Object ID: %@", result[@"objectID"]);
} failure:nil];
```

Update an existing object in the Index
-------------

You have three options when updating an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.
 3. Apply an operation to some attributes.

Example on how to replace all attributes of an existing object:

```objc
NSDictionary *newObject = @{
	@"firstname": @"Jimmie",
    @"lastname": @"Barninger",
	@"city": @"New York"
};
[index saveObject:newObject objectID:@"myID" success:nil failure:nil];
```

You have many ways to update an object's attributes:

 1. Set the attribute value
 2. Add an element to an array
 3. Remove an element from an array
 4. Add an element to an array if it doesn't exist
 5. Increment an attribute
 6. Decrement an attribute

Example to update only the city attribute of an existing object:

```objc
NSDictionary *partialObject = @{@"city": @"San Francisco"};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Example to add a tag:

```objc
NSDictionary *operation = @{
	@"value": @"MyTag",
	@"_operation": @"Add"
};
NSDictionary *partialObject = @{@"_tags": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Example to remove a tag:

```objc
NSDictionary *operation = @{
	@"value": @"MyTag",
	@"_operation": @"Remove"
};
NSDictionary *partialObject = @{@"_tags": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Example to add a tag if it doesn't exist:

```objc
NSDictionary *operation = @{
	@"value": @"MyTag",
	@"_operation": @"AddUnique"
};
NSDictionary *partialObject = @{@"_tags": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Example to increment a numeric value:

```objc
NSDictionary *operation = @{
	@"value": 42,
	@"_operation": @"Increment"
};
NSDictionary *partialObject = @{@"price": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Example to decrement a numeric value:

```objc
NSDictionary *operation = @{
	@"value": 42,
	@"_operation": @"Decrement"
};
NSDictionary *partialObject = @{@"price": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```



Search
-------------


To perform a search, you only need to initialize the index and perform a call to the search function.

You can use the following optional arguments on ASQuery class:

### Query Parameters

#### Full Text Search Parameters

 * **fullTextQuery**: (string) The instant search query string. All words of the query are interpreted as prefixes (for example "John Mc" will match "John Mccamey" and "Johnathan Mccamey"). If no query parameter is set all objects are retrieved.
 * **setQueryType**: Selects how the query words are interpreted. It can be one of the following values:
  * **prefixAll**: All query words are interpreted as prefixes.
  * **prefixLast**: Only the last word is interpreted as a prefix (default behavior).
  * **prefixNone**: No query word is interpreted as a prefix. This option is not recommended.
 * **setRemoveWordsIfNoResults**: This option is used to select a strategy in order to avoid having an empty result page. There are three different options:
  * **lastWords**: When a query does not return any results, the last word will be added as optional. The process is repeated with n-1 word, n-2 word, ... until there are results.
  * **firstWords**: When a query does not return any results, the first word will be added as optional. The process is repeated with second word, third word, ... until there are results.
  * **allOptional**: When a query does not return any results, a second trial will be made with all words as optional. This is equivalent to transforming the AND operand between query terms to an OR operand. 
  * **none**: No specific processing is done when a query does not return any results (default behavior).
 * **minWordSizeForApprox1**: The minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 4.
 * **minWordSizeForApprox2**: The minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 8.
 * **allowTyposOnNumericTokens**: If set to false, it disables typo tolerance on numeric tokens (numbers). Defaults to false.
 * **setTypoTolerance**: This option allows you to control the number of typos in the result set:
  * **true**: The typo tolerance is enabled and all matching hits are retrieved (default behavior).
  * **false**: The typo tolerance is disabled. For example, if one result matches without typos, then all results with typos will be hidden.
  * **min**: Only keep results with the minimum number of typos.
  * **strict**: Hits matching with 2 typos are not retrieved if there are some matching without typos. This option is useful if you want to avoid false positives as much as possible.
 * **allowTyposOnNumericTokens**: If set to false, disables typo tolerance on numeric tokens (numbers). Defaults to true.
 * **ignorePlural**: If set to true, plural won't be considered as a typo. For example, car and cars will be considered as equals. Defaults to false.
 * **restrictSearchableAttributes** List of attributes you want to use for textual search (must be a subset of the `attributesToIndex` index setting). Attributes are separated with a comma such as `"name,address"`. You can also use JSON string array encoding such as `encodeURIComponent("[\"name\",\"address\"]")`. By default, all attributes specified in `attributesToIndex` settings are used to search.
 * **advancedSyntax**: Enables the advanced query syntax. Defaults to 0 (false).
    * **Phrase query**: A phrase query defines a particular sequence of terms. A phrase query is built by Algolia's query parser for words surrounded by `"`. For example, `"search engine"` will retrieve records having `search` next to `engine` only. Typo tolerance is _disabled_ on phrase queries.
    * **Prohibit operator**: The prohibit operator excludes records that contain the term after the `-` symbol. For example, `search -engine` will retrieve records containing `search` but not `engine`.
 * **analytics**: If set to false, this query will not be taken into account in the analytics feature. Defaults to true.
 * **synonyms**: If set to false, this query will not use synonyms defined in the configuration. Defaults to true.
 * **replaceSynonymsInHighlight**: If set to false, words matched via synonym expansion will not be replaced by the matched synonym in the highlight results. Defaults to true.
 * **optionalWords**: An array of strings that contain the list of words that should be considered as optional when found in the query.

#### Pagination Parameters

 * **page**: (integer) Pagination parameter used to select the page to retrieve.<br/>Page is zero based and defaults to 0. Thus, to retrieve the 10th page you need to set `page=9`.
 * **hitsPerPage**: (integer) Pagination parameter used to select the number of hits per page. Defaults to 20.

#### Geo-search Parameters

 * **searchAroundLatitude:longitude:maxDist**: Search for entries around a given latitude/longitude.<br/>You specify the maximum distance in meters with the **maxDist** parameter.<br/>At indexing, you should specify the geo location of an object with the `_geoloc` attribute in the form ` {"_geoloc":{"lat":48.853409, "lng":2.348800}} `.
 * **searchAroundLatitude:longitude:maxDist:precision**: Search for entries around a given latitude/longitude with a given precision for ranking. For example, if you set precision=100, two objects that are a distance of less than 100 meters will be considered as identical for the "geo" ranking parameter.


 * **searchAroundLatitudeLongitudeViaIP:**: Search for entries around the latitude/longitude automatically computed from user IP address.<br/>You specify the maximum distance in meters with the **maxDist** parameter.<br/>At indexing, you should specify the geo location of an object with the `_geoloc` attribute in the form ` {"_geoloc":{"lat":48.853409, "lng":2.348800}} `.
 * **searchAroundLatitudeLlongitude:precision**: Search for entries around a latitude/longitude automatically computed from user IP address with a given precision for ranking. For example if you set precision=100, two objects that are a distance of less than 100 meters will be considered as identical for the "geo" ranking parameter.



 * **searchInsideBoundingBoxWithLatitudeP1:longitudeP1:latitudeP2:longitudeP2**: Search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).<br/>For example, `searchInsideBoundingBoxWithLatitudeP1(47.3165, 4.9665, 47.3424, 5.0201)`).<br/>At indexing, you should specify the geo location of an object with the _geoloc attribute in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`.

#### Parameters to Control Results Content

 * **attributesToRetrieve**: The list of object attributes you want to retrieve in order to minimize the answer size. By default, all attributes are retrieved. You can also use `*` to retrieve all values when an **attributesToRetrieve** setting is specified for your index.
 * **attributesToHighlight**: The list of attributes you want to highlight according to the query. If an attribute has no match for the query, the raw value is returned. By default, all indexed text attributes are highlighted. You can use `*` if you want to highlight all textual attributes. Numerical attributes are not highlighted. A matchLevel is returned for each highlighted attribute and can contain:
  * **full**: If all the query terms were found in the attribute.
  * **partial**: If only some of the query terms were found.
  * **none**: If none of the query terms were found.
 * **attributesToSnippet**: The list of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`). By default, no snippet is computed.
 * **getRankingInfo**: If set to YES, the result hits will contain ranking information in the **_rankingInfo** attribute.


#### Numeric Search Parameters
 * **numericFilters**: A string that contains the comma separated list of numeric filters you want to apply. The filter syntax is `attributeName` followed by `operand` followed by `value`. Supported operands are `<`, `<=`, `=`, `>` and `>=`.

You can easily perform range queries via the `:` operator. This is equivalent to combining a `>=` and `<=` operand. For example, `numericFilters=price:10 to 1000`.

You can also mix OR and AND operators. The OR operator is defined with a parenthesis syntax. For example, `(code=1 AND (price:[0-100] OR price:[1000-2000]))` translates to `encodeURIComponent("code=1,(price:0 to 10,price:1000 to 2000)")`.

You can also use a string array encoding (for example `numericFilters: ["price>100","price<1000"]`).

#### Category Search Parameters
 * **tagFilters**: Filter the query by a set of tags. You can AND tags by separating them with commas. To OR tags, you must add parentheses. For example, `tags=tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*. You can also use a string array encoding. For example, `tagFilters: ["tag1",["tag2","tag3"]]` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the **_tags** attribute of objects. For example `{"_tags":["tag1","tag2"]}`.

#### Faceting Parameters
 * **facetFilters**: Filter the query with a list of facets. Facets are separated by commas and is encoded as `attributeName:value`. To OR facets, you must add parentheses. For example: `facetFilters=(category:Book,category:Movie),author:John%20Doe`. You can also use a string array encoding. For example, `[["category:Book","category:Movie"],"author:John%20Doe"]`.
 * **facets**: List of object attributes that you want to use for faceting. <br/>Attributes are separated with a comma. For example, `"category,author"`. You can also use JSON string array encoding. For example, `["category","author"]`. Only the attributes that have been added in **attributesForFaceting** index setting can be used in this parameter. You can also use `*` to perform faceting on all attributes specified in **attributesForFaceting**.
 * **maxValuesPerFacet**: Limit the number of facet values returned for each facet. For example, `maxValuesPerFacet=10` will retrieve a maximum of 10 values per facet.

#### Distinct Parameter
 * **distinct**: If set to YES, enables the distinct feature, disabled by default, if the `attributeForDistinct` index setting is set. This feature is similar to the SQL "distinct" keyword. When enabled in a query with the `distinct=1` parameter, all hits containing a duplicate value for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`, then only the best one is kept and the others are removed.
**Note**: This feature is disabled if the query string is empty and there aren't any `tagFilters`, `facetFilters`, nor `numericFilters` parameters.

```objc
ASRemoteIndex *index = [apiClient getIndex:@"contacts"];
[index search:[ASQuery queryWithFullTextQuery:@"s"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];

ASQuery *query = [ASQuery queryWithFullTextQuery:@"s"];
query.attributesToRetrieve = @[@"firstname", @"lastname"];
query.hitsPerPage = 50;
[index search:query 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result: %@", result);
} failure:nil];
```

The server response will look like:

```json
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "objectID": "433",
      "_highlightResult": {
        "firstname": {
          "value": "<em>Jimmie</em>",
          "matchLevel": "partial"
        },
        "lastname": {
          "value": "Barninger",
          "matchLevel": "none"
        },
        "company": {
          "value": "California <em>Paint</em> & Wlpaper Str",
          "matchLevel": "partial"
        }
      }
    }
  ],
  "page": 0,
  "nbHits": 1,
  "nbPages": 1,
  "hitsPerPage": 20,
  "processingTimeMS": 1,
  "query": "jimmie paint",
  "params": "query=jimmie+paint&attributesToRetrieve=firstname,lastname&hitsPerPage=50"
}
```


Multiple queries
--------------

You can send multiple queries with a single API call using a batch of queries:

```objc
// perform 3 queries in a single API call:
//  - 1st query targets index `categories`
//  - 2nd and 3rd queries target index `products`
NSArray *queries = @[
	@{@"indexName": @"categories", @"query": anASQueryObject}, 
	@{@"indexName": @"products", @"query": anotherASQueryObject},
	@{@"indexName": @"products", @"query": anotherASQueryObject}
];
[client multipleQueries:queries
  success:^(ASAPIClient *client, NSArray *queries, NSDictionary *result) {
  	NSLog(@"Result: %@", result);
} failure:nil];
```



Get an object
-------------

You can easily retrieve an object using its `objectID` and optionally specify a comma separated list of attributes you want:

```objc
// Retrieves all attributes
[index getObject:@"myID" 
  success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
    NSLog(@"Object: %@", result);
} failure:nil];
// Retrieves only the firstname attribute
[index getObject:@"myID" attributesToRetrieve:@[@"firstname"] 
  success:^(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result) {
    NSLog(@"Object: %@", result);
} failure:nil];
```

You can also retrieve a set of objects:


```objc
[index getObjects:@[@"myID1", @"myID2"]
  success:^(ASRemoteIndex *index, NSArray *objectIDs, NSDictionary *result) {
	// do something
} failure:nil];
```






Delete an object
-------------

You can delete an object using its `objectID`:

```objc
[index deleteObject:@"myID" success:nil failure:nil];
```


Delete by query
-------------

You can delete all objects matching a single query with the following code. Internally, the API client performs the query, deletes all matching hits, and waits until the deletions have been applied.

```objc
ASQuery *query = /* [...] */;
[index deleteByQuery:query success:nil failure:nil];
```


Index Settings
-------------

You can retrieve all settings using the `getSettings` function. The result will contain the following attributes:


#### Indexing parameters
 * **attributesToIndex**: (array of strings) The list of fields you want to index.<br/>If set to null, all textual and numerical attributes of your objects are indexed. Be sure to update it to get optimal results.<br/>This parameter has two important uses:
  * *Limit the attributes to index*.<br/>For example, if you store a binary image in base64, you want to store it and be able to retrieve it, but you don't want to search in the base64 string.
  * *Control part of the ranking*.<br/>(see the ranking parameter for full explanation) Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after. You can disable this behavior if you add your attribute inside `unordered(AttributeName)`. For example, `attributesToIndex: ["title", "unordered(text)"]`.
**Notes**: All numerical attributes are automatically indexed as numerical filters. If you don't need filtering on some of your numerical attributes, please consider sending them as strings to speed up the indexing.<br/>
You can decide to have the same priority for two attributes by passing them in the same string using a comma as a separator. For example `title` and `alternative_title` have the same priority in this example, which is different than text priority: `attributesToIndex:["title,alternative_title", "text"]`.
 * **attributesForFaceting**: (array of strings) The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
 * **attributeForDistinct**: The attribute name used for the `Distinct` feature. This feature is similar to the SQL "distinct" keyword. When enabled in queries with the `distinct=1` parameter, all hits containing a duplicate value for this attribute are removed from results. For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`, then only the best one is kept and others are removed. **Note**: This feature is disabled if the query string is empty and there aren't any `tagFilters`, `facetFilters`, nor `numericFilters` parameters.
 * **ranking**: (array of strings) Controls the way results are sorted.<br/>We have nine available criteria:
  * **typo**: Sort according to number of typos.
  * **geo**: Sort according to decreasing distance when performing a geo location based search.
  * **words**: Sort according to the number of query words matched by decreasing order. This parameter is useful when you use the `optionalWords` query parameter to have results with the most matched words first.
  * **proximity**: Sort according to the proximity of the query words in hits.
  * **attribute**: Sort according to the order of attributes defined by attributesToIndex.
  * **exact**:
    * If the user query contains one word: sort objects having an attribute that is exactly the query word before others. For example, if you search for the TV show "V", you want to find it with the "V" query and avoid getting all popular TV shows starting by the letter V before it.
    * If the user query contains multiple words: sort according to the number of words that matched exactly (not as a prefix).
  * **custom**: Sort according to a user defined formula set in the **customRanking** attribute.
  * **asc(attributeName)**: Sort according to a numeric attribute using ascending order. **attributeName** can be the name of any numeric attribute in your records (integer, double or boolean).
  * **desc(attributeName)**: Sort according to a numeric attribute using descending order. **attributeName** can be the name of any numeric attribute in your records (integer, double or boolean). <br/>The standard order is ["typo", "geo", "words", "proximity", "attribute", "exact", "custom"].
 * **customRanking**: (array of strings) Lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by the asc (ascending order) or desc (descending order) operator. For example, `"customRanking" => ["desc(population)", "asc(name)"]`.
 * **queryType**: Select how the query words are interpreted. It can be one of the following values:
  * **prefixAll**: All query words are interpreted as prefixes.
  * **prefixLast**: Only the last word is interpreted as a prefix (default behavior).
  * **prefixNone**: No query word is interpreted as a prefix. This option is not recommended.
 * **separatorsToIndex**: Specify the separators (punctuation characters) to index. By default, separators are not indexed. Use `+#` to be able to search Google+ or C#.
 * **slaves**: The list of indices on which you want to replicate all write operations. In order to get response times in milliseconds, we pre-compute part of the ranking during indexing. If you want to use different ranking configurations depending of the use case, you need to create one index per ranking configuration. This option enables you to perform write operations only on this index and automatically update slave indices with the same operations.
 * **unretrievableAttributes**: The list of attributes that cannot be retrieved at query time. This feature allows you to have attributes that are used for indexing and/or ranking but cannot be retrieved. Defaults to null.
 * **allowCompressionOfIntegerArray**: Allows compression of big integer arrays. We recommended enabling this feature and then storing the list of user IDs or rights as an integer array. When enabled, the integer array is reordered to reach a better compression ratio. Defaults to false.

#### Query expansion
 * **synonyms**: (array of array of words considered as equals). For example, you may want to retrieve the **black ipad** record when your users are searching for **dark ipad**, even if the word **dark** is not part of the record. To do this, you need to configure **black** as a synonym of **dark**. For example, `"synomyms": [ [ "black", "dark" ], [ "small", "little", "mini" ], ... ]`.
 * **placeholders**: (hash of array of words). This is an advanced use case to define a token substitutable by a list of words without having the original token searchable. It is defined by a hash associating placeholders to lists of substitutable words. For example, `"placeholders": { "<streetnumber>": ["1", "2", "3", ..., "9999"]}` would allow it to be able to match all street numbers. We use the `< >` tag syntax to define placeholders in an attribute. For example:
  * Push a record with the placeholder: `{ "name" : "Apple Store", "address" : "&lt;streetnumber&gt; Opera street, Paris" }`.
  * Configure the placeholder in your index settings: `"placeholders": { "<streetnumber>" : ["1", "2", "3", "4", "5", ... ], ... }`.
 * **disableTypoToleranceOn**: (string array) Specify a list of words on which automatic typo tolerance will be disabled.
 * **altCorrections**: (object array) Specify alternative corrections that you want to consider. Each alternative correction is described by an object containing three attributes:
  * **word**: The word to correct.
  * **correction**: The corrected word.
  * **nbTypos** The number of typos (1 or 2) that will be considered for the ranking algorithm (1 typo is better than 2 typos).

  For example `"altCorrections": [ { "word" : "foot", "correction": "feet", "nbTypos": 1 }, { "word": "feet", "correction": "foot", "nbTypos": 1 } ]`.

#### Default query parameters (can be overwritten by queries)
 * **minWordSizefor1Typo**: (integer) The minimum number of characters needed to accept one typo (default = 4).
 * **minWordSizefor2Typos**: (integer) The minimum number of characters needed to accept two typos (default = 8).
 * **hitsPerPage**: (integer) The number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) Default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.
 * **attributesToHighlight**: (array of strings) Default list of attributes to highlight. If set to null, all indexed attributes are highlighted.
 * **attributesToSnippet**: (array of strings) Default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').<br/>By default, no snippet is computed. If set to null, no snippet is computed.
 * **highlightPreTag**: (string) Specify the string that is inserted before the highlighted parts in the query result (defaults to "&lt;em&gt;").
 * **highlightPostTag**: (string) Specify the string that is inserted after the highlighted parts in the query result (defaults to "&lt;/em&gt;").
 * **optionalWords**: (array of strings) Specify a list of words that should be considered optional when found in the query.

You can easily retrieve settings or update them:

```objc
[index getSettings:^(ASRemoteIndex *index, NSDictionary *result) {
    NSLog(@"Settings: %@", result);
} failure:nil];
```

```objc
NSArray *customRanking = @[@"desc(followers)", @"asc(name)"];
NSDictionary *settings = @{@"customRanking": customRanking};
[index setSettings:settings success:nil failure:nil];

```

List indices
-------------
You can list all your indices along with their associated information (number of entries, disk size, etc.) with the `listIndexes` method:

```objc
[client listIndexes:^(ASAPIClient *client, NSDictionary *result) {
    NSLog(@"Indexes: %@", result);
} failure:nil];
```

Delete an index
-------------
You can delete an index using its name:

```objc
[client deleteIndex:@"contacts" success:nil 
  failure:^(ASAPIClient *client, NSString *indexName, NSString *errorMessage) {
    NSLog(@"Could not delete: %@", errorMessage);
}];
```

Clear an index
-------------
You can delete the index contents without removing settings and index specific API keys by using the clearIndex command:

```objc
[index clearIndex:nil 
  failure:^(ASRemoteIndex *index, NSString *errorMessage) {
    NSLog(@"Could not clear index: %@", errorMessage);
}];
```

Wait indexing
-------------

All write operations return a `taskID` when the job is securely stored on our infrastructure but not when the job is published in your index. Even if it's extremely fast, you can easily ensure indexing is complete using the `waitTask` method on the `taskID` returned by a write operation.

For example, to wait for indexing of a new object:
```objc
[index addObject:newObject 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
    // Wait task
    [index waitTask:result[@"taskID"]
      success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
        NSLog(@"New object is indexed");
    } failure:nil];
} failure:nil];
```


If you want to ensure multiple objects have been indexed, you only need check the biggest taskID.

Batch writes
-------------

You may want to perform multiple operations with one API call to reduce latency.
We expose three methods to perform batch operations:
 * `addObjects`: Add an array of objects using automatic `objectID` assignment.
 * `saveObjects`: Add or update an array of objects that contains an `objectID` attribute.
 * `deleteObjects`: Delete an array of objectIDs.
 * `partialUpdateObjects`: Partially update an array of objects that contain an `objectID` attribute (only specified attributes will be updated).

Example using automatic `objectID` assignment:
```objc
NSDictionary *obj1 = @{@"firstname": @"Jimmie", @"lastname": @"Barninger"};
NSDictionary *obj2 = @{@"firstname": @"Warren", @"lastname": @"Speach"};
[index addObjects:@[obj1, obj2] 
  success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```

Example with user defined `objectID` (add or update):
```objc
NSDictionary *obj1 = @{@"firstname": @"Jimmie", @"lastname": @"Barninger", @"objectID": @"myID1"};
NSDictionary *obj2 = @{@"firstname": @"Warren", @"lastname": @"Speach", @"objectID": @"myID2"};
[index saveObjects:@[obj1, obj2] 
  success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```

Example that deletes a set of records:
```objc
[index deleteObjects:@[@"myID1", @"myID2"] success:nil failure:nil];
```

Example that updates only the `firstname` attribute:
```objc
NSDictionary *obj1 = @{@"firstname": @"Jimmie", @"objectID": @"myID1"};
NSDictionary *obj2 = @{@"firstname": @"Warren", @"objectID": @"myID2"};
[index partialUpdateObjects:@[obj1, obj2] 
  success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```



Security / User API Keys
-------------

The admin API key provides full control of all your indices.
You can also generate user API keys to control security.
These API keys can be restricted to a set of operations or/and restricted to a given index.

To list existing keys, you can use `listUserKeys` method:
```objc
// Lists global API Keys
[apiClient listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
    NSLog(@"User keys: %@", result);
} failure:nil];
// Lists API Keys that can access only to this index
[index listUserKeys:^(ASRemoteIndex *index, NSDictionary *result) {
    NSLog(@"User keys: %@", result);
} failure:nil];
```

Each key is defined by a set of permissions that specify the authorized actions. The different permissions are:
 * **search**: Allowed to search.
 * **browse**: Allowed to retrieve all index contents via the browse API.
 * **addObject**: Allowed to add/update an object in the index.
 * **deleteObject**: Allowed to delete an existing object.
 * **deleteIndex**: Allowed to delete index content.
 * **settings**: allows to get index settings.
 * **editSettings**: Allowed to change index settings.
 * **analytics**: Allowed to retrieve analytics through the analytics API.
 * **listIndexes**: Allowed to list all accessible indexes.

Example of API Key creation:
```objc
// Creates a new global API key that can only perform search actions
[apiClient addUserKey:@[@"search"] 
  success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
// Creates a new API key that can only perform search action on this index
[index addUserKey:@[@"search"] 
  success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
```

You can also create an API Key with advanced restrictions:

 * Add a validity period. The key will be valid for a specific period of time (in seconds).
 * Specify the maximum number of API calls allowed from an IP address per hour. Each time an API call is performed with this key, a check is performed. If the IP at the source of the call did more than this number of calls in the last hour, a 403 code is returned. Defaults to 0 (no rate limit). This parameter can be used to protect you from attempts at retrieving your entire index contents by massively querying the index.

 * Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited). This parameter can be used to protect you from attempts at retrieving your entire index contents by massively querying the index.
 * Specify the list of targeted indices. You can target all indices starting with a prefix or ending with a suffix using the '*' character. For example, "dev_*" matches all indices starting with "dev_" and "*_dev" matches all indices ending with "_dev". Defaults to all indices if empty or blank.

```objc
// Creates a new global API key that is valid for 300 seconds
[apiClient addUserKey:@[@"search"] withValidity:300 maxQueriesPerIPPerHour:0 maxHitsPerQuery:0
  success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
// Creates a new index specific API key valid for 300 seconds, with a rate limit of 100 calls per hour per IP and a maximum of 20 hits
[index addUserKey:[@"search"] withValidity:300 maxQueriesPerIPPerHour:100 maxHitsPerQuery:20
  success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
```

Update the permissions of an existing key:
```objc
// Update an existing global API key that is valid for 300 seconds
[apiClient updateUserKey:@"myAPIKey", withACL:@[@"search"] withValidity:300 maxQueriesPerIPPerHour:0 maxHitsPerQuery:0
  success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
// Update an existing index specific API key valid for 300 seconds, with a rate limit of 100 calls per hour per IP and a maximum of 20 hits
[index updateUserKey:@"myAPIKey" withACL:@[@"search"] withValidity:300 maxQueriesPerIPPerHour:100 maxHitsPerQuery:20
  success:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key: %@", result[@"key"]);
} failure:nil];
```
Get the permissions of a given key:
```objc
// Gets the rights of a global key
[apiClient getUserKeyACL:@"79710f2fbe18a06fdf12c17a16878654" 
  success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
    NSLog(@"Key details: %@", result);
} failure:nil];
// Gets the rights of an index specific key
[index getUserKeyACL:@"013464b04012cb73299395a635a2fc6c" 
  success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
    NSLog(@"Key details: %@", result);
} failure:nil];
```

Delete an existing key:
```objc
// Deletes a global key
[apiClient deleteUserKey:@"79710f2fbe18a06fdf12c17a16878654" success:nil 
  failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
    NSLog(@"Delete error: %@", errorMessage);
}];    
// Deletes an index specific key
[index deleteUserKey:@"013464b04012cb73299395a635a2fc6c" success:nil 
  failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
   NSLog(@"Delete error: %@", errorMessage);
}]; 
```



Copy or rename an index
-------------

You can easily copy or rename an existing index using the `copy` and `move` commands.
**Note**: Move and copy commands overwrite the destination index.

```objc
// Rename MyIndex in MyIndexNewName
[apiClient moveIndex:@"MyIndex" to:@"MyIndexNewName" 
  success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
    NSLog(@"Move Success: %@", result);
} failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
    NSLog(@"Move Failure: %@", errorMessage);
}];
// Copy MyIndex in MyIndexCopy
[apiClient copyIndex:@"MyIndex" to:@"MyIndexCopy" 
  success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
    NSLog(@"Copy Success: %@", result);
} failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
    NSLog(@"Copy Failure: %@", errorMessage);
}];
```

The move command is particularly useful if you want to update a big index atomically from one version to another. For example, if you recreate your index `MyIndex` each night from a database by batch, you only need to:
 1. Import your database into a new index using [batches](#batch-writes). Let's call this new index `MyNewIndex`.
 1. Rename `MyNewIndex` to `MyIndex` using the move command. This will automatically override the old index and new queries will be served on the new one.

```objc
// Rename MyNewIndex in MyIndex (and overwrite it)
[apiClient moveIndex:@"MyNewIndex" to:@"MyIndex" 
  success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
    NSLog(@"Move Success: %@", result);
} failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
    NSLog(@"Move Failure: %@", errorMessage);
}];
```

Backup / Retrieve of all index content
-------------

You can retrieve all index content for backup purposes or for SEO using the browse method.
This method retrieves 1,000 objects via an API call and supports pagination.

```objc
// Get first page
[index browse:0 success:^(ASRemoteIndex *index, NSUInteger page, NSDictionary *result) {
  NSLog(@"Index Content: %@", result);
} failure:^(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage) {
  NSLog(@"browse error: %@", errorMessage);
}];
// Get second page
[index browse:1 success:^(ASRemoteIndex *index, NSUInteger page, NSDictionary *result) {
  NSLog(@"Index Content: %@", result);
} failure:^(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage) {
  NSLog(@"browse error: %@", errorMessage);
}];
```

Logs
-------------

You can retrieve the latest logs via this API. Each log entry contains:
 * Timestamp in ISO-8601 format
 * Client IP
 * Request Headers (API Key is obfuscated)
 * Request URL
 * Request method
 * Request body
 * Answer HTTP code
 * Answer body
 * SHA1 ID of entry

You can retrieve the logs of your last 1,000 API calls and browse them using the offset/length parameters:
 * ***offset***: Specify the first entry to retrieve (0-based, 0 is the most recent log entry). Defaults to 0.
 * ***length***: Specify the maximum number of entries to retrieve starting at the offset. Defaults to 10. Maximum allowed value: 1,000.
 * ***onlyErrors***: Retrieve only logs with an HTTP code different than 200 or 201. (deprecated)
 * ***type***: Specify the type of logs to retrieve:
  * ***query***: Retrieve only the queries.
  * ***build***: Retrieve only the build operations.
  * ***error***: Retrieve only the errors (same as ***onlyErrors*** parameters).

```objc
// Get last 10 log entries
[apiClient getLogs:^(ASAPIClient *client, NSDictionary *result) {
    NSLog(@"GetLogs success: %@", result);
} failure:^(ASAPIClient *client, NSString *errorMessage) {
    NSLog(@"GetLogs failure: %@", errorMessage);
}];
// Get last 100 log entries
[apiClient getLogsWithOffset:0 length:100 
  success:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result) {
    NSLog(@"GetLog success: %@", result);
} failure:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage) {
    NSLog(@"GetLogs failure: %@", errorMessage);
}];
```





