Algolia Search API Client for iOS and OS X
==================

This Objective-C client let you easily use the Algolia Search API from your application.
The service is currently in Beta, you can request an invite on our [website](http://www.algolia.com/pricing/).

Setup
-------------
To setup your project, follow these steps:

 1. Use cocoapods or Add source to your project by adding `pod 'AlgoliaSearch-Client', '~> 1.0'`in your Podfile or drop the source folder on your project (If you are not using a Podfile, you will also need to add [AFNetworking library](https://github.com/AFNetworking/AFNetworking) in your project).
 2. Add the `#import "ASAPIClient.h"` call to your project
 3. Initialize the client with your ApplicationID, API-Key and list of hostnames (you can find all of them on your Algolia account)

```objc
  ASAPIClient *apiClient = 
    [ASAPIClient apiClientWithApplicationID:@"YourApplicationID" apiKey:@"YourAPIKey" 
                hostnames:[NSArray arrayWithObjects:@"YourHostname-1.algolia.io", 
                                                    @"YourHostname-2.algolia.io", 
                                                    @"YourHostname-3.algolia.io", nil]];
```


Quick Start
-------------
This quick start is a 30 seconds tutorial where you can discover how to index and search objects.

Without any prior-configuration, you can index the 1000 world's biggest cities in the ```cities``` index with the following code:
```objc
// Load JSON file
NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"1000-cities" ofType:@"json"];
NSData* jsonData = [NSData dataWithContentsOfFile:jsonPath];
NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
// Load all objects of json file in an index named "cities"
ASRemoteIndex *index = [apiClient getIndex:@"cities"];
[apiClient listIndexes:^(id JSON) {
  NSLog(@"Indexes: %@", JSON);
} failure:nil];
```
The [1000-cities.json](https://github.com/algolia/algoliasearch-client-objc/blob/master/1000-cities.json) file contains city names extracted from [Geonames](http://www.geonames.org) and formated in our [batch format](http://docs.algoliav1.apiary.io/#post-%2F1%2Findexes%2F%7BindexName%7D%2Fbatch). The ```body```attribute contains the user-object that can be any valid JSON.

You can then start to search for a city name (even with typos):
```objc
[index search:[ASQuery queryWithFullTextQuery:@"san fran"] success:^(ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
[index search:[ASQuery queryWithFullTextQuery:@"loz anqel"] success:^(ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

Settings can be customized to tune the index behavior. For example you can add a custom sort by population to the already good out-of-the-box relevance to raise bigger cities above smaller ones. To update the settings, use the following code:
```objc
NSArray *customRanking = [NSArray arrayWithObjects:@"desc(population)", @"asc(name)", nil];
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:customRanking, @"customRanking", nil];
[index setSettings:settings success:nil failure:nil];
```

And then search for all cities that start with an "s":
```objc
[index search:[ASQuery queryWithFullTextQuery:@"s"] success:^(ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

Search 
-------------
To perform a search, you just need to initialize the index and perform a call to the search function.<br/>
You can use the following optional arguments on ASQuery class:

 * **fullTextQuery**: the full text query.
 * **attributesToRetrieve**: specify the list of attribute names to retrieve.<br/>By default all attributes are retrieved.
 * **attributesToHighlight**: specify the list of attribute names to highlight.<br/>By default indexed attributes are highlighted.
 * **attributesToSnippet**: specify the list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').<br/>By default no snippet is computed.
 * **minWordSizeForApprox1**: the minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 3.
 * **minWordSizeForApprox2**: the minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 7.
 * **getRankingInfo**: if set to YES, the result hits will contain ranking information in _rankingInfo attribute.
 * **page**: *(pagination parameter)* page to retrieve (zero base).<br/>Defaults to 0.
 * **hitsPerPage**: *(pagination parameter)* number of hits per page.<br/>Defaults to 10.
 * **searchAroundLatitude:longitude:maxDist**: ssearch for entries around a given latitude/longitude.<br/>You specify the maximum distance in meters with the **radius** parameter (in meters).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **searchInsideBoundingBoxWithLatitudeP1:longitudeP1:latitudeP2:longitudeP2:**: search entries inside a given area defined by the two extreme points of a rectangle.<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes (default behavior).
  * **prefixLast**: only the last word is interpreted as a prefix. This option is recommended if you have a lot of content to speedup the processing.
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **tags**: filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example, `tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the _tags attribute of objects (for example `{"_tags":["tag1","tag2"]}` )

```objc
ASRemoteIndex *index = [apiClient getIndex:@"MyIndexName"];
[index search:[ASQuery queryWithFullTextQuery:@"s"] success:^(ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];

ASQuery *query = [ASQuery queryWithFullTextQuery:@"s"];
query.attributesToRetrieve = [NSArray arrayWithObjects:@"population", @"name", nil];
query.hitsPerPage = 50;
[index search:query success:^(ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

The server response will look like:

```javascript
{
    "hits":[
            { "name": "Betty Jane Mccamey",
              "company": "Vita Foods Inc.",
              "email": "betty@mccamey.com",
              "objectID": "6891Y2usk0",
              "_highlightResult": {"name": {"value": "Betty <em>Jan</em>e Mccamey", "matchLevel": "full"}, 
                                   "company": {"value": "Vita Foods Inc.", "matchLevel": "none"},
                                   "email": {"value": "betty@mccamey.com", "matchLevel": "none"} }
            },
            { "name": "Gayla Geimer Dan", 
              "company": "Ortman Mccain Co", 
              "email": "gayla@geimer.com", 
              "objectID": "ap78784310" 
              "_highlightResult": {"name": {"value": "Gayla Geimer <em>Dan</em>", "matchLevel": "full" },
                                   "company": {"value": "Ortman Mccain Co", "matchLevel": "none" },
                                   "email": {"highlighted": "gayla@geimer.com", "matchLevel": "none" } }
            }],
    "page":0,
    "nbHits":2,
    "nbPages":1,
    "hitsPerPage:":20,
    "processingTimeMS":1,
    "query":"jan"
}
```

Add a new object in the Index
-------------

Each entry in an index has a unique identifier called `objectID`. You have two ways to add en entry in the index:

 1. Using automatic `objectID` assignement, you will be able to retrieve it in the answer.
 2. Passing your own `objectID`

You don't need to explicitely create an index, it will be automatically created the first time you add an object.
Objects are schema less, you don't need any configuration to start indexing. The settings section provide details about advanced settings.

Example with automatic `objectID` assignement:

```objc
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"San Francisco", @"name",
                                    [NSNumber numberWithInt:805235], @"population", nil];
[index addObject:newObject success:^(NSDictionary *object, NSDictionary *result) {
    NSLog(@"Object ID:%@", [result valueForKey:@"objectID"]);
} failure:nil];
```

Example with manual `objectID` assignement:

```objc
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"San Francisco", @"name",
                                    [NSNumber numberWithInt:805235], @"population", nil];
[index addObject:newObject withObjectID:@"myID" success:^(NSDictionary *object, NSString *objectID, NSDictionary *result) {
  NSLog(@"Object ID:%@", [result valueForKey:@"objectID"]);
} failure:nil];
```

Update an existing object in the Index
-------------

You have two options to update an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.

Example to replace all the content of an existing object:

```objc
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Los Angeles", @"name",
                                    [NSNumber numberWithInt:3792621], @"population", nil];
[index saveObject:newObject objectID:@"myID" success:nil failure:nil];
```

Example to update only the population attribute of an existing object:

```objc
NSDictionary *partialObject = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3792621], @"population", nil];
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Get an object
-------------

You can easily retrieve an object using its `objectID` and optionnaly a list of attributes you want to retrieve (using comma as separator):

```objc
// Retrieves all attributes
[index getObject:@"myID" success:^(NSString *objectID, NSDictionary *result) {
    NSLog(@"Object: %@", result);
} failure:nil];
// Retrieves only the name attribute
index getObject:@"myID" attributesToRetrieve:[NSArray arrayWithObject:@"name"] 
  success:^(NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result) {
    NSLog(@"Object: %@", result);
} failure:nil];
```

Delete an object
-------------

You can delete an object using its `objectID`:

```objc
[index deleteObject:@"myID" success:nil failure:nil];
```

Index Settings
-------------

You can retrieve all settings using the `getSettings` function. The result will contains the following attributes:

 * **minWordSizeForApprox1**: (integer) the minimum number of characters to accept one typo (default = 3).
 * **minWordSizeForApprox2**: (integer) the minimum number of characters to accept two typos (default = 7).
 * **hitsPerPage**: (integer) the number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) default list of attributes to retrieve in objects.
 * **attributesToHighlight**: (array of strings) default list of attributes to highlight
 * **attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords')<br/>By default no snippet is computed.
 * **attributesToIndex**: (array of strings) the list of fields you want to index.<br/>By default all textual attributes of your objects are indexed, but you should update it to get optimal results.<br/>This parameter has two important uses:
 * *Limit the attributes to index*.<br/>For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
 * *Control part of the ranking*.<br/>Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. 
 * **ranking**: (array of strings) controls the way results are sorted.<br/>We have four available criteria: 
  * **typo**: sort according to number of typos,
  * **geo**: sort according to decreassing distance when performing a geo-location based search,
  * **position**: sort according to the proximity of query words in the object, 
  * **custom**: sort according to a user defined formula set in **customRanking** attribute.<br/>The standard order is ["typo", "geo", position", "custom"]
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes (default behavior).
  * **prefixLast**: only the last word is interpreted as a prefix. This option is recommended if you have a lot of content to speedup the processing.
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **customRanking**: (array of strings) lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
 For example `"customRanking" => ["desc(population)", "asc(name)"]`

You can easily retrieve settings or update them:

```objc
[index getSettings:^(NSDictionary *result) {
    NSLog(@"Settings: %@", result);
} failure:nil];
```

```objc
NSArray *customRanking = [NSArray arrayWithObjects:@"desc(population)", @"asc(name)", nil];
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:customRanking, @"customRanking", nil];
[index setSettings:settings success:nil failure:nil];
```
