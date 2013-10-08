Algolia Search API Client for iOS and OS X
==================

This Objective-C client let you easily use the Algolia Search API from your application.
The service is currently in Beta, you can request an invite on our [website](http://www.algolia.com/pricing/).

Table of Content
-------------
**Get started**

1. [Setup](#setup) 
1. [Quick Start](#quick-start)

**Commands reference**

1. [Search](#search)
1. [Add a new object](#add-a-new-object-in-the-index)
1. [Update an object](#update-an-existing-object-in-the-index)
1. [Get an object](#get-an-object)
1. [Delete an object](#delete-an-object)
1. [Index settings](#index-settings)
1. [List indexes](#list-indexes)
1. [Delete an index](#delete-an-index)
1. [Wait indexing](#wait-indexing)
1. [Batch writes](#batch-writes)
1. [Security / User API Keys](#security--user-api-keys)
1. [Copy or rename an index](#copy-or-rename-an-index)
1. [Logs](#logs)

Setup
-------------
To setup your project, follow these steps:

 1. [Download and add sources](https://github.com/algolia/algoliasearch-client-objc/archive/master.zip) to your project or use cocoapods by adding `pod 'AlgoliaSearch-Client', '~> 1.0'`in your Podfile or drop the source folder on your project (If you are not using a Podfile, you will also need to add [AFNetworking library](https://github.com/AFNetworking/AFNetworking) in your project).
 2. Add the `#import "ASAPIClient.h"` call to your project
 3. Initialize the client with your ApplicationID and API-Key. You can find all of them on [your Algolia account](http://www.algolia.com/users/edit).

```objc
  ASAPIClient *apiClient = 
    [ASAPIClient apiClientWithApplicationID:@"YourApplicationID" apiKey:@"YourAPIKey"];
```

Quick Start
-------------
This quick start is a 30 seconds tutorial where you can discover how to index and search objects.


Without any prior-configuration, you can index [500 contacts](https://github.com/algolia/algoliasearch-client-objc/blob/master/contacts.json) in the ```contacts``` index with the following code:
```objc
// Load JSON file
NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"json"];
NSData* jsonData = [NSData dataWithContentsOfFile:jsonPath];
NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
// Load all objects of json file in an index named "contacts"
ASRemoteIndex *index = [apiClient getIndex:@"contacts"];
[index addObjects:[dict objectForKey:@"objects"] success:nil failure:nil];
```

You can then start to search for a contact firstname, lastname, company, ... (even with typos):
```objc
// search by firstname
[index search:[ASQuery queryWithFullTextQuery:@"jimmie"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
// search a firstname with typo
[index search:[ASQuery queryWithFullTextQuery:@"jimie"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
// search for a company
[index search:[ASQuery queryWithFullTextQuery:@"california paint"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
// search for a firstname & company
[index search:[ASQuery queryWithFullTextQuery:@"jimmie paint"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

Settings can be customized to tune the search behavior. For example you can add a custom sort by number of followers to the already good out-of-the-box relevance:
```objc
NSArray *customRanking = [NSArray arrayWithObjects:@"desc(followers)", nil];
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:customRanking, @"customRanking", nil];
[index setSettings:settings success:nil
  failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
    NSLog(@"Error when applying settings: %@", errorMessage);
}];
```
You can also configure the list of attributes you want to index by order of importance (first = most important):
```objc
NSArray *customRanking = [NSArray arrayWithObjects:@"lastname", "firstname", "company", "email", "city", "address", nil];
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:customRanking, @"attributesToIndex", nil];
[index setSettings:settings success:nil
  failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
    NSLog(@"Error when applying settings: %@", errorMessage);
}];
```

Since the engine is designed to suggest results as you type, you'll generally search by prefix. In this case the order of attributes is very important to decide which hit is the best:
```objc
[index search:[ASQuery queryWithFullTextQuery:@"or"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];

[index search:[ASQuery queryWithFullTextQuery:@"jim"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

Search
-------------
To perform a search, you just need to initialize the index and perform a call to the search function.<br/>
You can use the following optional arguments on ASQuery class:

 * **fullTextQuery**: the full text query.
 * **attributesToRetrieve**: specify the list of attribute names to retrieve.<br/>By default all attributes are retrieved.
 * **attributesToHighlight**: specify the list of attribute names to highlight.<br/>By default indexed attributes are highlighted. Numerical attributes cannot be highlighted. A **matchLevel** is returned for each highlighted attribute and can contain: "full" if all the query terms were found in the attribute, "partial" if only some of the query terms were found, or "none" if none of the query terms were found.
 * **attributesToSnippet**: specify the list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords').<br/>By default no snippet is computed.
 * **minWordSizefor1Typo**: the minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 3.
 * **minWordSizefor2Typos**: the minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 7.
 * **getRankingInfo**: if set to YES, the result hits will contain ranking information in _rankingInfo attribute.
 * **page**: *(pagination parameter)* page to retrieve (zero base).<br/>Defaults to 0.
 * **hitsPerPage**: *(pagination parameter)* number of hits per page.<br/>Defaults to 10.
 * **searchAroundLatitude:longitude:maxDist**: search for entries around a given latitude/longitude.<br/>You specify the maximum distance in meters with the **radius** parameter (in meters).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **searchInsideBoundingBoxWithLatitudeP1:longitudeP1:latitudeP2:longitudeP2:**: search for entries inside a given area defined by the two extreme points of a rectangle.<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **numerics**: specify the list of numeric filters you want to apply separated by a comma. The syntax of one filter is `attributeName` followed by `operand` followed by `value`. Supported operands are `<`, `<=`, `=`, `>` and `>=`. 
 You can have multiple conditions on one attribute like for example `numerics=price>100,price<1000`.
 * **tags**: filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example, `tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the _tags attribute of objects (for example `{"_tags":["tag1","tag2"]}` )

```objc
ASRemoteIndex *index = [apiClient getIndex:@"contacts"];
[index search:[ASQuery queryWithFullTextQuery:@"s"] 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];

ASQuery *query = [ASQuery queryWithFullTextQuery:@"s"];
query.attributesToRetrieve = [NSArray arrayWithObjects:@"firstname", @"lastname", nil];
query.hitsPerPage = 50;
[index search:query 
  success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
    NSLog(@"Result:%@", result);
} failure:nil];
```

The server response will look like:

```javascript
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "company": "California Paint & Wlpaper Str",
      "address": "Box #-4038",
      "city": "Modesto",
      "county": "Stanislaus",
      "state": "CA",
      "zip": "95352",
      "phone": "209-525-7568",
      "fax": "209-525-4389",
      "email": "jimmie@barninger.com",
      "web": "http://www.jimmiebarninger.com",
      "followers": 3947,
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
        },
        "address": {
          "value": "Box #-4038",
          "matchLevel": "none"
        },
        "city": {
          "value": "Modesto",
          "matchLevel": "none"
        },
        "email": {
          "value": "<em>jimmie</em>@barninger.com",
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
  "params": "query=jimmie+paint&"
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
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Jimmie", @"firstname",
                                        @"Barninger", @"lastname", nil];
[index addObject:newObject 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
    NSLog(@"Object ID:%@", [result valueForKey:@"objectID"]);
} failure:nil];
```

Example with manual `objectID` assignement:

```objc
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Jimmie", @"firstname",
                                        @"Barninger", @"lastname", nil];
[index addObject:newObject withObjectID:@"myID" 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result) {
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
NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:@"Jimmie", @"firstname",
                                        @"Barninger", @"lastname", @"New York", @"city", nil];
[index saveObject:newObject objectID:@"myID" success:nil failure:nil];
```

Example to update only the city attribute of an existing object:

```objc
NSDictionary *partialObject = [NSDictionary dictionaryWithObjectsAndKeys:@"San Francisco", @"city", nil];
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Get an object
-------------

You can easily retrieve an object using its `objectID` and optionnaly a list of attributes you want to retrieve (using comma as separator):

```objc
// Retrieves all attributes
[index getObject:@"myID" 
  success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
    NSLog(@"Object: %@", result);
} failure:nil];
// Retrieves only the firstname attribute
[index getObject:@"myID" attributesToRetrieve:[NSArray arrayWithObject:@"firstname"] 
  success:^(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result) {
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

 * **minWordSizefor1Typo**: (integer) the minimum number of characters to accept one typo (default = 3).
 * **minWordSizefor2Typos**: (integer) the minimum number of characters to accept two typos (default = 7).
 * **hitsPerPage**: (integer) the number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) default list of attributes to retrieve in objects.
 * **attributesToHighlight**: (array of strings) default list of attributes to highlight.
 * **attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords')<br/>By default no snippet is computed.
 * **attributesToIndex**: (array of strings) the list of fields you want to index.<br/>By default all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results.<br/>This parameter has two important uses:
  * *Limits the attributes to index*.<br/>For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
  * *Controls part of the ranking*.<br/>Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable this behavior if you add your attribute inside `unordered(AttributeName)`, for example `attributesToIndex:["title", "unordered(text)"]`.
 * **ranking**: (array of strings) controls the way hits are sorted.<br/>We have six available criteria:
  * **typo**: sort according to number of typos,
  * **geo**: sort according to decreasing distance when performing a geo-location based search,
  * **proximity**: sort according to the proximity of query words in hits, 
  * **attribute**: sort according to the order of attributes defined by **attributesToIndex**,
  * **exact**: sort according to the number of words that are matched identical to query word (and not as a prefix),
  * **custom**: sort according to a user defined formula set in **customRanking** attribute.
  <br/>The default order is `["typo", "geo", "proximity", "attribute", "exact", "custom"]`. We strongly recommend to keep this configuration.
 * **customRanking**: (array of strings) lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
 For example `"customRanking" => ["desc(population)", "asc(name)"]`
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.

You can easily retrieve settings or update them:

```objc
[index getSettings:^(NSDictionary *result) {
    NSLog(@"Settings: %@", result);
} failure:nil];
```

```objc
NSArray *customRanking = [NSArray arrayWithObjects:@"desc(followers)", @"asc(name)", nil];
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:customRanking, @"customRanking", nil];
[index setSettings:settings success:nil failure:nil];

```
List indexes
-------------
You can list all your indexes with their associated information (number of entries, disk size, etc.) with the `listIndexes` method:

```objc
[client listIndexes:^(id result) {
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

Wait indexing
-------------

All write operations return a `taskID` when the job is securely stored on our infrastructure but not when the job is published in your index. Even if it's extremely fast, you can easily ensure indexing is complete using the `waitTask` method on the `taskID` returned by a write operation.

For example, to wait for indexing of a new object:
```objc
[index addObject:newObject 
  success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
    // Wait task
    [index waitTask:[result valueForKey:@"objectID"] 
      success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
        NSLog(@"New object is indexed");
    } failure:nil];
} failure:nil];
```

If you want to ensure multiple objects have been indexed, you can only check the biggest taskID.

Batch writes
-------------

You may want to perform multiple operations with one API call to reduce latency.
We expose two methods to perform batch:
 * `addObjects`: add an array of object using automatic `objectID` assignement
 * `saveObjects`: add or update an array of object that contains an `objectID` attribute

Example using automatic `objectID` assignement
```objc
NSDictionary *obj1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Jimmie", @"firstname",
                             @"Barninger", @"lastname", nil];
NSDictionary *obj2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Warren", @"firstname",
                             @"Speach", @"lastname", nil];
[index addObjects:[NSArray arrayWithObjects:obj1, obj2, nil] 
  success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```

Example with user defined `objectID` (add or update):
```objc
NSDictionary *obj1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Jimmie", @"firstname",
                            @"Barninger", @"lastname",
                            @"myID1", @"objectID", nil];
NSDictionary *obj2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Warren", @"firstname",
                            @"Speach", @"lastname",
                            @"myID2", @"objectID", nil];
[index saveObjects:[NSArray arrayWithObjects:obj1, obj2, nil] 
  success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```

Security / User API Keys
-------------

The admin API key provides full control of all your indexes. 
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

Each key is defined by a set of rights that specify the authorized actions. The different rights are:
 * **search**: allows to search,
 * **addObject**: allows to add/update an object in the index,
 * **deleteObject**: allows to delete an existing object,
 * **deleteIndex**: allows to delete index content,
 * **settings**: allows to get index settings,
 * **editSettings**: allows to change index settings.

Example of API Key creation:
```objc
// Creates a new global API key that can only perform search actions
[apiClient addUserKey:[NSArray arrayWithObject:@"search"] 
  success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key:%@", [result objectForKey:@"key"]);
} failure:nil];
// Creates a new API key that can only perform search action on this index
[index addUserKey:[NSArray arrayWithObject:@"search"] 
  success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key:%@", [result objectForKey:@"key"]);
} failure:nil];
```

You can also create a temporary API key that will be valid only for a specific period of time (in seconds):
```objc
// Creates a new global API key that is valid for 300 seconds
[apiClient addUserKey:[NSArray arrayWithObject:@"search"] withValidity:300 
  success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key:%@", [result objectForKey:@"key"]);
} failure:nil];
// Creates a new index specific API key valid for 300 seconds
[index addUserKey:[NSArray arrayWithObject:@"search"] withValidity:300 
  success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
    NSLog(@"API Key:%@", [result objectForKey:@"key"]);
} failure:nil];
```

Get the rights of a given key:
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
**Note**: Move and copy commands overwrite destination index.

The move command is particularly useful is you want to update a big index atomically from one version to another. For example, if you recreate your index `MyIndex` each night from a database by batch, you just have to:
 1. Import your database in a new index using [batches](#batch-writes). Let's call this new index `MyNewIndex`.
 1. Rename `MyNewIndex` in `MyIndex` using the move command. This will automatically override the old index and new queries will be served on the new one.

```objc
// Rename MyNewIndex in MyIndex
[apiClient moveIndex:@"MyNewIndex" to:@"MyIndex" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
    NSLog(@"Move Success: %@", result);
} failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
    NSLog(@"Move Failure: %@", errorMessage);
}];
// Copy MyNewIndex in MyIndex
[apiClient copyIndex:@"MyNewIndex" to:@"MyIndex" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
    NSLog(@"Copy Success: %@", result);
} failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
    NSLog(@"Copy Failure: %@", errorMessage);
}];
```

Logs
-------------

You can retrieve the last logs via this API. Each log entry contains: 
 * Timestamp in ISO-8601 format
 * Client IP
 * Request Headers (API-Key is obfuscated)
 * Request URL
 * Request method
 * Request body
 * Answer HTTP code
 * Answer body
 * SHA1 ID of entry

You can retrieve the logs of your last 1000 API calls and browse them using the offset/length parameters:
 * ***offset***: Specify the first entry to retrieve (0-based, 0 is the most recent log entry). Default to 0.
 * ***length***: Specify the maximum number of entries to retrieve starting at offset. Defaults to 10. Maximum allowed value: 1000.

```objc
// Get last 10 log entries
[apiClient getLogs:^(ASAPIClient *client, NSDictionary *result) {
    NSLog(@"GetLogs success: %@", result);
} failure:^(ASAPIClient *client, NSString *errorMessage) {
    NSLog(@"GetLogs failure: %@", errorMessage);
}];
// Get last 100 log entries
[apiClient getLogsWithOffset:0 length:100 success:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result) {
    NSLog(@"GetLog success: %@", result);
} failure:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage) {
    NSLog(@"GetLogs failure: %@", errorMessage);
}];
```