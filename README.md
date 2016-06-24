<!--NO_HTML-->

# Algolia Search API Client for iOS and OS X

<!--/NO_HTML-->


**WARNING: Deprecated.** In July 2015, we released our [Swift API Client](https://github.com/algolia/algoliasearch-client-swift), able to work with Swift and Objective-C. As of version 3 (April 2016), Swift has become the reference implementation for both Swift and Objective-C projects.

*This Objective-C API Client is no longer under active development.* It is still supported for bug fixes, but will not receive new features.





<!--NO_HTML-->

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.

<!--/NO_HTML-->

Our Objective-C client lets you easily use the [Algolia Search API](https://www.algolia.com/doc/rest) from your iOS & OS X applications. It wraps the [Algolia Search REST API](https://www.algolia.com/doc/rest).



[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-objc.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-objc)
[![CocoaPods](https://img.shields.io/cocoapods/v/AlgoliaSearch-Client.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/p/AlgoliaSearch-Client.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/AlgoliaSearch-Client.svg)]()





<!--NO_HTML-->

Table of Contents
-----------------
**Getting Started**

1. [Setup](#setup)
1. [Quick Start](#quick-start)
1. [Guides & Tutorials](#guides-tutorials)


**Commands Reference**

1. [Add a new object](#add-a-new-object-to-the-index)
1. [Update an object](#update-an-existing-object-in-the-index)
1. [Search](#search)
1. [Search cache](#search-cache)
1. [Multiple queries](#multiple-queries)
1. [Get an object](#get-an-object)
1. [Delete an object](#delete-an-object)
1. [Delete by query](#delete-by-query)
1. [Index settings](#index-settings)
1. [List indices](#list-indices)
1. [Delete an index](#delete-an-index)
1. [Clear an index](#clear-an-index)
1. [Wait indexing](#wait-indexing)
1. [Batch writes](#batch-writes)
1. [Copy / Move an index](#copy--move-an-index)
1. [Backup / Export an index](#backup--export-an-index)


<!--/NO_HTML-->



Setup
============
To setup your project, follow these steps:




 1. [Download and add sources](https://github.com/algolia/algoliasearch-client-objc/archive/master.zip) to your project or use cocoapods by adding `pod 'AlgoliaSearch-Client', '~> 3.5'` in your Podfile (or `pod 'AlgoliaSearch-Client', '~> 2.0'` if your are using AFNetworking 1.x in your project)  or drop the source folder on your project (If you are not using a Podfile, you will also need to add [AFNetworking library](https://github.com/AFNetworking/AFNetworking) in your project).
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







<!--NO_HTML-->

Guides & Tutorials
================
Check our [online guides](https://www.algolia.com/doc):
 * [Data Formatting](https://www.algolia.com/doc/indexing/formatting-your-data)
 * [Import and Synchronize data](https://www.algolia.com/doc/indexing/import-synchronize-data/objc)
 * [Autocomplete](https://www.algolia.com/doc/search/auto-complete)
 * [Instant search page](https://www.algolia.com/doc/search/instant-search)
 * [Filtering and Faceting](https://www.algolia.com/doc/search/filtering-faceting)
 * [Sorting](https://www.algolia.com/doc/relevance/sorting)
 * [Ranking Formula](https://www.algolia.com/doc/relevance/ranking)
 * [Typo-Tolerance](https://www.algolia.com/doc/relevance/typo-tolerance)
 * [Geo-Search](https://www.algolia.com/doc/geo-search/geo-search-overview)
 * [Security](https://www.algolia.com/doc/security/best-security-practices)
 * [API-Keys](https://www.algolia.com/doc/security/api-keys)
 * [REST API](https://www.algolia.com/doc/rest)


<!--/NO_HTML-->






Add a new object to the Index
==================

Each entry in an index has a unique identifier called `objectID`. There are two ways to add an entry to the index:

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
==================

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
 2. Add a string or number element to an array
 3. Remove an element from an array
 4. Add a string or number element to an array if it doesn't exist
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

Note: Here we are incrementing the value by `42`. To increment just by one, put
`value:1`.

Example to decrement a numeric value:

```objc
NSDictionary *operation = @{
	@"value": 42,
	@"_operation": @"Decrement"
};
NSDictionary *partialObject = @{@"price": operation};
[index partialUpdateObject:partialObject objectID:@"myID" success:nil failure:nil];
```

Note: Here we are decrementing the value by `42`. To decrement just by one, put
`value:1`.

Search
==================



To perform a search, you only need to initialize the index and perform a call to the search function.

The search query allows only to retrieve 1000 hits, if you need to retrieve more than 1000 hits for seo, you can use [Backup / Retrieve all index content](#backup--export-an-index)

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

You can use the following optional arguments on ASQuery class:

## Full Text Search Parameters
<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>fullTextQuery</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The instant search query string, used to set the string you want to search in your index. If no query parameter is set, the textual search will match with all the objects.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>setQueryType</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>prefixLast</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Selects how the query words are interpreted. It can be one of the following values:</p>

<ul>
<li><code>prefixAll</code>: All query words are interpreted as prefixes. This option is not recommended.</li>
<li><code>prefixLast</code>: Only the last word is interpreted as a prefix (default behavior).</li>
<li><code>prefixNone</code>: No query word is interpreted as a prefix. This option is not recommended.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>setRemoveWordsIfNoResults</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>none</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This option is used to select a strategy in order to avoid having an empty result page. There are three different options:</p>

<ul>
<li><code>lastWords</code>: When a query does not return any results, the last word will be added as optional. The process is repeated with n-1 word, n-2 word, ... until there are results.</li>
<li><code>firstWords</code>: When a query does not return any results, the first word will be added as optional. The process is repeated with second word, third word, ... until there are results.</li>
<li><code>allOptional</code>: When a query does not return any results, a second trial will be made with all words as optional. This is equivalent to transforming the AND operand between query terms to an OR operand.</li>
<li><code>none</code>: No specific processing is done when a query does not return any results (default behavior).</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>minWordSizeForApprox1</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>number</strong></em></div><div><em>Default: <strong>4</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 4.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>minWordSizeForApprox2</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>number</strong></em></div><div><em>Default: <strong>8</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 8.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>setTypoTolerance</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This option allows you to control the number of typos allowed in the result set:</p>

<ul>
<li><code>true</code>: The typo tolerance is enabled and all matching hits are retrieved (default behavior).</li>
<li><code>false</code>: The typo tolerance is disabled. All results with typos will be hidden.</li>
<li><code>min</code>: Only keep results with the minimum number of typos. For example, if one result matches without typos, then all results with typos will be hidden.</li>
<li><code>strict</code>: Hits matching with 2 typos are not retrieved if there are some matching without typos.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>allowTyposOnNumericTokens</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, disables typo tolerance on numeric tokens (numbers). Defaults to true.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>ignorePlural</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to true, plural won&#39;t be considered as a typo. For example, car and cars, or foot and feet will be considered as equivalent. Defaults to false.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>disableTypoToleranceOnAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>[]</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of attributes on which you want to disable typo tolerance (must be a subset of the <code>attributesToIndex</code> index setting). Attributes are separated with a comma such as <code>&quot;name,address&quot;</code>. You can also use JSON string array encoding such as <code>encodeURIComponent(&quot;[\&quot;name\&quot;,\&quot;address\&quot;]&quot;)</code>. By default, this list is empty.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>restrictSearchableAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>attributesToIndex</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of attributes you want to use for textual search (must be a subset of the <code>attributesToIndex</code> index setting). Attributes are separated with a comma such as <code>&quot;name,address&quot;</code>. You can also use JSON string array encoding such as <code>encodeURIComponent(&quot;[\&quot;name\&quot;,\&quot;address\&quot;]&quot;)</code>. By default, all attributes specified in the <code>attributesToIndex</code> settings are used to search.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>removeStopWords</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Remove stop words from the query <strong>before</strong> executing it. Defaults to <code>false</code>. Use a boolean to enable/disable all 41 supported languages and a comma separated list of iso codes of the languages you want to use consider to enable the stopwords removal on a subset of them (select the one you have in your records). In most use-cases, you shouldn&#39;t need to enable this option.</p>

<p>List of 41 supported languages with their associated iso code: Arabic=ar, Armenian=hy, Basque=eu, Bengali=bn, Brazilian=pt-br, Bulgarian=bg, Catalan=ca, Chinese=zh, Czech=cs, Danish=da, Dutch=nl, English=en, Finnish=fi, French=fr, Galician=gl, German=de, Greek=el, Hindi=hi, Hungarian=hu, Indonesian=id, Irish=ga, Italian=it, Japanese=ja, Korean=ko, Kurdish=ku, Latvian=lv, Lithuanian=lt, Marathi=mr, Norwegian=no, Persian (Farsi)=fa, Polish=pl, Portugese=pt, Romanian=ro, Russian=ru, Slovak=sk, Spanish=es, Swedish=sv, Thai=th, Turkish=tr, Ukranian=uk, Urdu=ur</p>

<p>Stop words removal is applied on query words that are not interpreted as a prefix. The behavior depends of the queryType parameter:</p>

<ul>
<li><p><code>queryType=prefixLast</code> means the last query word is a prefix and it won’t be considered for stop words removal</p></li>
<li><p><code>queryType=prefixNone</code> means no query word are prefix, stop words removal will be applied on all query words</p></li>
<li><p><code>queryType=prefixAll</code> means all query terms are prefix, stop words won’t be removed</p></li>
</ul>

<p>This parameter is useful when you have a query in natural language like “what is a record?”. In this case, before executing the query, we will remove “what”, “is” and “a” in order to just search for “record”. This removal will remove false positive because of stop words, especially when combined with optional words. For most use cases, it is better to not use this feature as people search by keywords on search engines.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>exactOnSingleWordQuery</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>attribute</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This parameter control how the <code>exact</code> ranking criterion is computed when the query contains one word. There is three different values:</p>

<ul>
<li><p><code>none</code>: no exact on single word query</p></li>
<li><p><code>word</code>: exact set to 1 if the query word is found in the record. The query word needs to have at least 3 chars and not be part of our stop words dictionary</p></li>
<li><p><code>attribute</code> (default): exact set to 1 if there is an attribute containing a string equals to the query</p></li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>alternativesAsExact</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>["ignorePlurals", "singleWordSynonym"]</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the list of approximation that should be considered as an exact match in the ranking formula:</p>

<ul>
<li><p><code>ignorePlurals</code>: alternative words added by the ignorePlurals feature</p></li>
<li><p><code>singleWordSynonym</code>: single-word synonym (For example &quot;NY&quot; = &quot;NYC&quot;)</p></li>
<li><p><code>multiWordsSynonym</code>: multiple-words synonym (For example &quot;NY&quot; = &quot;New York&quot;)</p></li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>advancedSyntax</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>0 (false)</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Enables the advanced query syntax. Defaults to 0 (false).</p>

<ul>
<li><strong>Phrase query</strong>: A phrase query defines a particular sequence of terms. A phrase query is built by Algolia&#39;s query parser for words surrounded by <code>&quot;</code>. For example, <code>&quot;search engine&quot;</code> will retrieve records having <code>search</code> next to <code>engine</code> only. Typo tolerance is <em>disabled</em> on phrase queries.</li>
<li><strong>Prohibit operator</strong>: The prohibit operator excludes records that contain the term after the <code>-</code> symbol. For example, <code>search -engine</code> will retrieve records containing <code>search</code> but not <code>engine</code>.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>analytics</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, this query will not be taken into account in the analytics feature. Defaults to true.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>synonyms</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, this query will not use synonyms defined in the configuration. Defaults to true.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>replaceSynonymsInHighlight</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, words matched via synonym expansion will not be replaced by the matched synonym in the highlight results. Defaults to true.</p>

      </td>
    </tr>
    

      
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>optionalWords</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>[]</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>An array of strings that contain the list of words that should be considered as optional when found in the query.</p>

      </td>
    </tr>
    
  
</tbody></table>

## Pagination Parameters

<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>page</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div><div><em>Default: <strong>0</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Pagination parameter used to select the page to retrieve.<br/>Page is zero based and defaults to 0. Thus, to retrieve the 10th page you need to set <code>page=9</code>.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>hitsPerPage</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div><div><em>Default: <strong>20</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Pagination parameter used to select the number of hits per page. Defaults to 20.</p>

      </td>
    </tr>
    

</tbody></table>


## Geo-search Parameters
<table><tbody>
  

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchAroundLatitude:longitude:</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>float,float</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search for entries around a given latitude/longitude.<br/>The maximum distance is automatically guessed depending of the density of the area but you also manually specify the maximum distance in meters with the <code>maxDist</code> parameter.<br/>At indexing, you should specify the geo location of an object with the <code>_geoloc</code> attribute in the form <code>{&quot;_geoloc&quot;:{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800}}</code>.</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchAroundLatitude:longitude:maxDist:precision</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search for entries around a given latitude/longitude with a given precision for ranking. For example, if you set aroundPrecision=100, the distances will be considered by ranges of 100m, for example all distances 0 and 100m will be considered as identical for the &quot;geo&quot; ranking parameter.</p>

      </td>
    </tr>
    
  

  

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchAroundLatitudeLongitudeViaIP</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search for entries around the latitude/longitude automatically computed from user IP address.<br/>The radius is automatically guessed based on density but you can also specify it manually with the <code>maxDist</code> parameter (optional).<br/>At indexing, you should specify the geo location of an object with the <code>_geoloc</code> attribute in the form <code>{&quot;_geoloc&quot;:{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800}}</code>.</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchAroundLatitudeLlongitude:precision</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search for entries around a latitude/longitude automatically computed from user IP address with a given precision for ranking. For example if you set precision=100, two objects that are a distance of less than 100 meters will be considered as identical for the &quot;geo&quot; ranking parameter.</p>

      </td>
    </tr>
    

  

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchInsideBoundingBoxWithLatitudeP1:longitudeP1:latitudeP2:longitudeP2</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).<br/>For example, <code>searchInsideBoundingBoxWithLatitudeP1(47.3165, 4.9665, 47.3424, 5.0201)</code>).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form <code>&quot;_geoloc&quot;:{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800}</code> or <code>&quot;_geoloc&quot;:[{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800},{&quot;lat&quot;:48.547456, &quot;lng&quot;:2.972075}]</code> if you have several geo-locations in your record). You can use several bounding boxes (OR) by passing more than 4 values. For example instead of having 4 values you can pass 8 to search inside the UNION of two bounding boxes.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>searchInsidePolygon:</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Search entries inside a given area defined by a set of points (defined by a minimum of 6 floats: p1Lat,p1Lng,p2Lat,p2Lng,p3Lat,p3Long).<br/>For example <code>searchInsidePolygon(47.3165, 4.9665, 47.3424, 5.0201, 47.32, 4.98)</code>).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form <code>&quot;_geoloc&quot;:{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800}</code> or <code>&quot;_geoloc&quot;:[{&quot;lat&quot;:48.853409, &quot;lng&quot;:2.348800},{&quot;lat&quot;:48.547456, &quot;lng&quot;:2.972075}]</code> if you have several geo-locations in your record).</p>

      </td>
    </tr>
    

</tbody></table>


## Parameters to Control Results Content

<table><tbody>
  

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToRetrieve</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of attributes you want to retrieve in order to minimize the size of the JSON answer. By default, all attributes are retrieved. You can also use <code>*</code> to retrieve all values when an <strong>attributesToRetrieve</strong> setting is specified for your index.</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToHighlight</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of attributes you want to highlight according to the query. If an attribute has no match for the query, the raw value is returned. By default, all indexed attributes are highlighted. You can use <code>*</code> if you want to highlight all attributes. A matchLevel is returned for each highlighted attribute and can contain:</p>

<ul>
<li><code>full</code>: If all the query terms were found in the attribute.</li>
<li><code>partial</code>: If only some of the query terms were found.</li>
<li><code>none</code>: If none of the query terms were found.</li>
</ul>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToSnippet</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of attributes to snippet alongside the number of words to return (syntax is <code>attributeName:nbWords</code>). By default, no snippet is computed.</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>getRankingInfo</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to YES, the result hits will contain ranking information in the <strong>_rankingInfo</strong> attribute.</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>setHighlightingTags</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string, string</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the string that is inserted before the highlighted parts in the query result (defaults to &quot;&lt;em&gt;&quot;) and the string that is inserted after the highlighted parts in the query result (defaults to &quot;&lt;/em&gt;&quot;)..</p>

      </td>
    </tr>
    

    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>setSnippetEllipsisText</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>String used as an ellipsis indicator when a snippet is truncated (defaults to empty).</p>

      </td>
    </tr>
    

  

</tbody></table>

## Numeric Search Parameters

<table><tbody>
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>numericFilters</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>A string that contains the comma separated list of numeric filters you want to apply. The filter syntax is <code>attributeName</code> followed by <code>operand</code> followed by <code>value</code>. Supported operands are <code>&lt;</code>, <code>&lt;=</code>, <code>=</code>, <code>&gt;</code> and <code>&gt;=</code>.</p>

      </td>
    </tr>
    
</tbody></table>

You can easily perform range queries via the `:` operator. This is equivalent to combining a `>=` and `<=` operand. For example, `numericFilters=price:10 to 1000`.

You can also mix OR and AND operators. The OR operator is defined with a parenthesis syntax. For example, `(code=1 AND (price:[0-100] OR price:[1000-2000]))` translates to `encodeURIComponent("code=1,(price:0 to 100,price:1000 to 2000)")`.

You can also use a string array encoding (for example `numericFilters: ["price>100","price<1000"]`).

## Category Search Parameters

<table><tbody>
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>tagFilters</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Filter the query by a set of tags. You can AND tags by separating them with commas. To OR tags, you must add parentheses. For example, <code>tagFilters=tag1,(tag2,tag3)</code> means <em>tag1 AND (tag2 OR tag3)</em>. You can also use a string array encoding. For example, <code>tagFilters: [&quot;tag1&quot;,[&quot;tag2&quot;,&quot;tag3&quot;]]</code> means <em>tag1 AND (tag2 OR tag3)</em>. Negations are supported via the <code>-</code> operator, prefixing the value. For example: <code>tagFilters=tag1,-tag2</code>.</p>

<p>At indexing, tags should be added in the <strong>_tags</strong> attribute of objects. For example <code>{&quot;_tags&quot;:[&quot;tag1&quot;,&quot;tag2&quot;]}</code>.</p>

      </td>
    </tr>
    
</tbody></table>

## Faceting Parameters

<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>facetFilters</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Filter the query with a list of facets. Facets are separated by commas and is encoded as <code>attributeName:value</code>. To OR facets, you must add parentheses. For example: <code>facetFilters=(category:Book,category:Movie),author:John%20Doe</code>. You can also use a string array encoding. For example, <code>[[&quot;category:Book&quot;,&quot;category:Movie&quot;],&quot;author:John%20Doe&quot;]</code>.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>facets</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of object attributes that you want to use for faceting. For each of the declared attributes, you&#39;ll be able to retrieve a list of the most relevant facet values, and their associated count for the current query.</p>

<p>Attributes are separated by a comma. For example, <code>&quot;category,author&quot;</code>. You can also use JSON string array encoding. For example, <code>[&quot;category&quot;,&quot;author&quot;]</code>. Only the attributes that have been added in <strong>attributesForFaceting</strong> index setting can be used in this parameter. You can also use <code>*</code> to perform faceting on all attributes specified in <code>attributesForFaceting</code>. If the number of results is important, the count can be approximate, the attribute <code>exhaustiveFacetsCount</code> in the response is true when the count is exact.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>maxValuesPerFacet</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Limit the number of facet values returned for each facet. For example, <code>maxValuesPerFacet=10</code> will retrieve a maximum of 10 values per facet.</p>

      </td>
    </tr>
    

</tbody></table>

## Unified Filter Parameter (SQL - like)

<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>filters</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Filter the query with numeric, facet or/and tag filters. The syntax is a SQL like syntax, you can use the OR and AND keywords. The syntax for the underlying numeric, facet and tag filters is the same than in the other filters:
<code>available=1 AND (category:Book OR NOT category:Ebook) AND _tags:public</code>
<code>date: 1441745506 TO 1441755506 AND inStock &gt; 0 AND author:&quot;John Doe&quot;</code></p>

<p>If no attribute name is specified, the filter applies to <code>_tags</code>. For example: <code>public OR user_42</code> will translate to <code>_tags:public OR _tags:user_42</code>.</p>

<p>The list of keywords is:</p>

<ul>
<li><code>OR</code>: create a disjunctive filter between two filters.</li>
<li><code>AND</code>: create a conjunctive filter between two filters.</li>
<li><code>TO</code>: used to specify a range for a numeric filter.</li>
<li><code>NOT</code>: used to negate a filter. The syntax with the <code>-</code> isn’t allowed.</li>
</ul>

      </td>
    </tr>
    
</tbody></table>
*Note*: To specify a value with spaces or with a value equal to a keyword, it's possible to add quotes.

**Warning:**

* Like for the other filters (for performance reasons), it's not possible to have FILTER1 OR (FILTER2 AND FILTER3).
* It's not possible to mix different categories of filters inside an OR like: num=3 OR tag1 OR facet:value
* It's not possible to negate a group, it's only possible to negate a filter:  NOT(FILTER1 OR (FILTER2) is not allowed.


## Distinct Parameter

<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>distinct</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to YES, enables the distinct feature, disabled by default, if the <code>attributeForDistinct</code> index setting is set. This feature is similar to the SQL &quot;distinct&quot; keyword. When enabled in a query with the <code>distinct=1</code> parameter, all hits containing a duplicate value for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is <code>show_name</code> and several hits have the same value for <code>show_name</code>, then only the best one is kept and the others are removed.</p>

      </td>
    </tr>
    

</tbody></table>

To get a full understanding of how `Distinct` works, you can have a look at our [guide on distinct](https://www.algolia.com/doc/search/distinct).



Search cache
==================

You can easily cache the results of the search queries by enabling the search cache.
The results will be cached during a defined amount of time (default: 2 min).
There is no pre-caching mechanism but you can simulate it by making a preemptive search query.

By default, the cache is disabled.

```objc
[myIndex enableSearchCache];
```

Or:

```objc
[myIndex enableSearchCacheWithExpiringTimeInterval:300];
```





Multiple queries
==================

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

The resulting JSON answer contains a ```results``` array storing the underlying queries answers. The answers order is the same than the requests order.

You can specify a `strategy` parameter to optimize your multiple queries:
- `none`: Execute the sequence of queries until the end.
- `stopIfEnoughMatches`: Execute the sequence of queries until the number of hits is reached by the sum of hits.



Get an object
==================

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
==================

You can delete an object using its `objectID`:

```objc
[index deleteObject:@"myID" success:nil failure:nil];
```

Delete by query
==================

You can delete all objects matching a single query with the following code. Internally, the API client performs the query, deletes all matching hits, and waits until the deletions have been applied.


```objc
ASQuery *query = /* [...] */;
[index deleteByQuery:query success:nil failure:nil];
```


Index Settings
==================

You can easily retrieve or update settings:

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


## Indexing parameters

<table><tbody>

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToIndex</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of attributes you want index (i.e. to make searchable).</p>

<p>If set to null, all textual and numerical attributes of your objects are indexed. Make sure you updated this setting to get optimal results.</p>

<p>This parameter has two important uses:</p>

<ul>
<li><em>Limit the attributes to index</em>.<br/>For example, if you store the URL of a picture, you want to store it and be able to retrieve it, but you probably don&#39;t want to search in the URL.</li>
<li><em>Control part of the ranking</em>.<br/> Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after. You can disable this behavior if you add your attribute inside <code>unordered(AttributeName)</code>. For example, <code>attributesToIndex: [&quot;title&quot;, &quot;unordered(text)&quot;]</code>.
You can decide to have the same priority for two attributes by passing them in the same string using a comma as a separator. For example <code>title</code> and <code>alternative_title</code> have the same priority in this example, which is different than text priority: <code>attributesToIndex:[&quot;title,alternative_title&quot;, &quot;text&quot;]</code>.
To get a full description of how the Ranking works, you can have a look at our <a href="https://www.algolia.com/doc/relevance/ranking">Ranking guide</a>.</li>
<li><strong>numericAttributesToIndex</strong>: (array of strings) All numerical attributes are automatically indexed as numerical filters (allowing filtering operations like <code>&lt;</code> and <code>&lt;=</code>). If you don&#39;t need filtering on some of your numerical attributes, you can specify this list to speed up the indexing.<br/> If you only need to filter on a numeric value with the operator &#39;=&#39;, you can speed up the indexing by specifying the attribute with <code>equalOnly(AttributeName)</code>. The other operators will be disabled.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesForFaceting</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributeForDistinct</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The name of the attribute used for the <code>Distinct</code> feature. This feature is similar to the SQL &quot;distinct&quot; keyword. When enabled in queries with the <code>distinct=1</code> parameter, all hits containing a duplicate value for this attribute are removed from the results. For example, if the chosen attribute is <code>show_name</code> and several hits have the same value for <code>show_name</code>, then only the first one is kept and the others are removed from the results. To get a full understanding of how <code>Distinct</code> works, you can have a look at our <a href="https://www.algolia.com/doc/search/distinct">guide on distinct</a>.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>ranking</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Controls the way results are sorted.</p>

<p>We have nine available criteria:</p>

<ul>
<li><code>typo</code>: Sort according to number of typos.</li>
<li><code>geo</code>: Sort according to decreasing distance when performing a geo location based search.</li>
<li><code>words</code>: Sort according to the number of query words matched by decreasing order. This parameter is useful when you use the <code>optionalWords</code> query parameter to have results with the most matched words first.</li>
<li><code>proximity</code>: Sort according to the proximity of the query words in hits.</li>
<li><code>attribute</code>: Sort according to the order of attributes defined by attributesToIndex.</li>
<li><code>exact</code>:

<ul>
<li>If the user query contains one word: sort objects having an attribute that is exactly the query word before others. For example, if you search for the TV show &quot;V&quot;, you want to find it with the &quot;V&quot; query and avoid getting all popular TV shows starting by the letter V before it.</li>
<li>If the user query contains multiple words: sort according to the number of words that matched exactly (not as a prefix).</li>
</ul></li>
<li><code>custom</code>: Sort according to a user defined formula set in the <code>customRanking</code> attribute.</li>
<li><code>asc(attributeName)</code>: Sort according to a numeric attribute using ascending order. <code>attributeName</code> can be the name of any numeric attribute in your records (integer, double or boolean).</li>
<li><code>desc(attributeName)</code>: Sort according to a numeric attribute using descending order. <code>attributeName</code> can be the name of any numeric attribute in your records (integer, double or boolean). <br/>The standard order is <code>[&quot;typo&quot;, &quot;geo&quot;, &quot;words&quot;, &quot;proximity&quot;, &quot;attribute&quot;, &quot;exact&quot;, &quot;custom&quot;]</code>.
To get a full description of how the Ranking works, you can have a look at our <a href="https://www.algolia.com/doc/relevance/ranking">Ranking guide</a>.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>customRanking</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Lets you specify part of the ranking.</p>

<p>The syntax of this condition is an array of strings containing attributes prefixed by the asc (ascending order) or desc (descending order) operator. For example, <code>&quot;customRanking&quot; =&gt; [&quot;desc(population)&quot;, &quot;asc(name)&quot;]</code>.</p>

<p>To get a full description of how the Custom Ranking works, you can have a look at our <a href="https://www.algolia.com/doc/relevance/ranking">Ranking guide</a>.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>queryType</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>prefixLast</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Select how the query words are interpreted. It can be one of the following values:</p>

<ul>
<li><code>prefixAll</code>: All query words are interpreted as prefixes.</li>
<li><code>prefixLast</code>: Only the last word is interpreted as a prefix (default behavior).</li>
<li><code>prefixNone</code>: No query word is interpreted as a prefix. This option is not recommended.</li>
</ul>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>separatorsToIndex</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>empty</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the separators (punctuation characters) to index. By default, separators are not indexed. Use <code>+#</code> to be able to search Google+ or C#.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>slaves</code></div>
            
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of indices on which you want to replicate all write operations. In order to get response times in milliseconds, we pre-compute part of the ranking during indexing. If you want to use different ranking configurations depending of the use case, you need to create one index per ranking configuration. This option enables you to perform write operations only on this index and automatically update slave indices with the same operations.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>unretrievableAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>empty</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The list of attributes that cannot be retrieved at query time. This feature allows you to have attributes that are used for indexing and/or ranking but cannot be retrieved. Defaults to null. Warning: for testing purposes, this setting is ignored when you&#39;re using the ADMIN API Key.</p>

      </td>
    </tr>
    

  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>allowCompressionOfIntegerArray</code></div>
            <div class="client-readme-param-meta"><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Allows compression of big integer arrays. In data-intensive use-cases, we recommended enabling this feature and then storing the list of user IDs or rights as an integer array. When enabled, the integer array is reordered to reach a better compression ratio. Defaults to false.</p>

      </td>
    </tr>
    

</tbody></table>

## Query expansion

<table><tbody>
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>synonyms</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of array of string considered as equals</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>For example, you may want to retrieve the <strong>black ipad</strong> record when your users are searching for <strong>dark ipad</strong>, even if the word <strong>dark</strong> is not part of the record. To do this, you need to configure <strong>black</strong> as a synonym of <strong>dark</strong>. For example, <code>&quot;synomyms&quot;: [ [ &quot;black&quot;, &quot;dark&quot; ], [ &quot;small&quot;, &quot;little&quot;, &quot;mini&quot; ], ... ]</code>. The Synonym feature also supports multi-words expressions like <code>&quot;synonyms&quot;: [ [&quot;NYC&quot;, &quot;New York City&quot;] ]</code></p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>placeholders</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>hash of array of words</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This is an advanced use-case to define a token substitutable by a list of words without having the original token searchable. It is defined by a hash associating placeholders to lists of substitutable words. For example, <code>&quot;placeholders&quot;: { &quot;&lt;streetnumber&gt;&quot;: [&quot;1&quot;, &quot;2&quot;, &quot;3&quot;, ..., &quot;9999&quot;]}</code> would allow it to be able to match all street numbers. We use the <code>&lt; &gt;</code> tag syntax to define placeholders in an attribute. For example:</p>

<ul>
<li>Push a record with the placeholder: <code>{ &quot;name&quot; : &quot;Apple Store&quot;, &quot;address&quot; : &quot;&amp;lt;streetnumber&amp;gt; Opera street, Paris&quot; }</code>.</li>
<li>Configure the placeholder in your index settings: <code>&quot;placeholders&quot;: { &quot;&lt;streetnumber&gt;&quot; : [&quot;1&quot;, &quot;2&quot;, &quot;3&quot;, &quot;4&quot;, &quot;5&quot;, ... ], ... }</code>.</li>
</ul>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>disableTypoToleranceOnWords</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string array</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify a list of words on which automatic typo tolerance will be disabled.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>disableTypoToleranceOnAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string array</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of attributes on which you want to disable typo tolerance (must be a subset of the <code>attributesToIndex</code> index setting). By default the list is empty.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>disablePrefixOnAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string array</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of attributes on which you want to disable prefix matching (must be a subset of the <code>attributesToIndex</code> index setting). This setting is useful on attributes that contain string that should not be matched as a prefix (for example a product SKU). By default the list is empty.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>disableExactOnAttributes</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string array</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>List of attributes on which you want to disable the computation of <code>exact</code> criteria (must be a subset of the <code>attributesToIndex</code> index setting). By default the list is empty.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>altCorrections</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>object array</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify alternative corrections that you want to consider. Each alternative correction is described by an object containing three attributes:</p>

<ul>
<li><strong>word</strong>: The word to correct.</li>
<li><strong>correction</strong>: The corrected word.</li>
<li><strong>nbTypos</strong> The number of typos (1 or 2) that will be considered for the ranking algorithm (1 typo is better than 2 typos).</li>
</ul>

<p>For example <code>&quot;altCorrections&quot;: [ { &quot;word&quot; : &quot;foot&quot;, &quot;correction&quot;: &quot;feet&quot;, &quot;nbTypos&quot;: 1 }, { &quot;word&quot;: &quot;feet&quot;, &quot;correction&quot;: &quot;foot&quot;, &quot;nbTypos&quot;: 1 } ]</code>.</p>

      </td>
    </tr>
    

</tbody></table>

## Default query parameters (can be overwritten by queries)

<table><tbody>
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>minWordSizefor1Typo</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div><div><em>Default: <strong>4</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The minimum number of characters needed to accept one typo (default = 4).</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>minWordSizefor2Typos</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div><div><em>Default: <strong>8</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The minimum number of characters needed to accept two typos (default = 8).</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>hitsPerPage</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div><div><em>Default: <strong>10</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>The number of hits per page (default = 10).</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToRetrieve</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToHighlight</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Default list of attributes to highlight. If set to null, all indexed attributes are highlighted.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>attributesToSnippet</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Default list of attributes to snippet alongside the number of words to return (syntax is <code>attributeName:nbWords</code>).<br/>By default, no snippet is computed. If set to null, no snippet is computed.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>highlightPreTag</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the string that is inserted before the highlighted parts in the query result (defaults to <code>&lt;em&gt;</code>).</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>highlightPostTag</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the string that is inserted after the highlighted parts in the query result (defaults to <code>&lt;/em&gt;</code>).</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>optionalWords</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>array of strings</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify a list of words that should be considered optional when found in the query.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>allowTyposOnNumericTokens</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>boolean</strong></em></div><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, disable typo-tolerance on numeric tokens (=numbers) in the query word. For example the query <code>&quot;304&quot;</code> will match with <code>&quot;30450&quot;</code>, but not with <code>&quot;40450&quot;</code> that would have been the case with typo-tolerance enabled. Can be very useful on serial numbers and zip codes searches. Defaults to false.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>ignorePlurals</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>boolean</strong></em></div><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to true, singular/plural forms won’t be considered as typos (for example car/cars and foot/feet will be considered as equivalent). Defaults to false.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>advancedSyntax</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer (0 or 1)</strong></em></div><div><em>Default: <strong>0</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Enable the advanced query syntax. Defaults to 0 (false).</p>

<ul>
<li><p><strong>Phrase query:</strong> a phrase query defines a particular sequence of terms. A phrase query is build by Algolia&#39;s query parser for words surrounded by <code>&quot;</code>. For example, <code>&quot;search engine&quot;</code> will retrieve records having <code>search</code> next to <code>engine</code> only. Typo-tolerance is disabled on phrase queries.</p></li>
<li><p><strong>Prohibit operator:</strong> The prohibit operator excludes records that contain the term after the <code>-</code> symbol. For example <code>search -engine</code> will retrieve records containing <code>search</code> but not <code>engine</code>.</p></li>
</ul>

      </td>
    </tr>
    
    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>replaceSynonymsInHighlight</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>boolean</strong></em></div><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>If set to false, words matched via synonyms expansion will not be replaced by the matched synonym in the highlighted result. Defaults to true.</p>

      </td>
    </tr>
    
    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>maxValuesPerFacet</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Limit the number of facet values returned for each facet. For example: <code>maxValuesPerFacet=10</code> will retrieve max 10 values per facet.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>distinct</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>integer (0 or 1)</strong></em></div><div><em>Default: <strong>0</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Enable the distinct feature (disabled by default) if the <code>attributeForDistinct</code> index setting is set. This feature is similar to the SQL &quot;distinct&quot; keyword: when enabled in a query with the <code>distinct=1</code> parameter, all hits containing a duplicate value for the<code>attributeForDistinct</code> attribute are removed from results. For example, if the chosen attribute is <code>show_name</code> and several hits have the same value for <code>show_name</code>, then only the best one is kept and others are removed.</p>

<p>To get a full understanding of how <code>Distinct</code> works, you can have a look at our <a href="https://www.algolia.com/doc/search/distinct">guide on distinct</a>.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>typoTolerance</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div><div><em>Default: <strong>true</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This setting has four different options:</p>

<ul>
<li><p><code>true:</code> activate the typo-tolerance (default value).</p></li>
<li><p><code>false:</code> disable the typo-tolerance</p></li>
<li><p><code>min:</code> keep only results with the lowest number of typos. For example if one result matches without typos, then all results with typos will be hidden.</p></li>
<li><p><code>strict:</code> if there is a match without typo, then all results with 2 typos or more will be removed.</p></li>
</ul>

      </td>
    </tr>
    
    
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>removeStopWords</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>boolean or string array</strong></em></div><div><em>Default: <strong>false</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Remove stop words from the query <strong>before</strong> executing it. Defaults to <code>false</code>. Use a boolean to enable/disable all 41 supported languages and an array of string listing the iso codes of the languages you want to use consider to enable the stop words removal on a subset of them (select the one you have in your records).</p>

<p>List of 41 supported languages with their associated iso code: Arabic=ar, Armenian=hy, Basque=eu, Bengali=bn, Brazilian=pt-br, Bulgarian=bg, Catalan=ca, Chinese=zh, Czech=cs, Danish=da, Dutch=nl, English=en, Finnish=fi, French=fr, Galician=gl, German=de, Greek=el, Hindi=hi, Hungarian=hu, Indonesian=id, Irish=ga, Italian=it, Japanese=ja, Korean=ko, Kurdish=ku, Latvian=lv, Lithuanian=lt, Marathi=mr, Norwegian=no, Persian (Farsi)=fa, Polish=pl, Portugese=pt, Romanian=ro, Russian=ru, Slovak=sk, Spanish=es, Swedish=sv, Thai=th, Turkish=tr, Ukranian=uk, Urdu=ur.</p>

<p>Stop words removal is applied on query words that are not interpreted as a prefix. The behavior depends of the queryType setting:</p>

<ul>
<li><p><code>queryType=prefixLast</code> means the last query word is a prefix and it won’t be considered for stop words removal</p></li>
<li><p><code>queryType=prefixNone</code> means no query word are prefix, stop words removal will be applied on all query words</p></li>
<li><p><code>queryType=prefixAll</code> means all query terms are prefix, stop words won’t be removed</p></li>
</ul>

<p>This index setting is useful when you have queries in natural language like “what is a record?”. In this case, before executing the query, we will remove “what”, “is” and “a” in order to just search for “record”. This removal will remove false positive because of stop words. For most use cases, it is better to not use this feature as people search by keywords on search engines.</p>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>exactOnSingleWordQuery</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string</strong></em></div><div><em>Default: <strong>attribute</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>This parameter controls how the <code>exact</code> ranking criterion is computed when the query contains one word. There is three different values:</p>

<ul>
<li><p><code>none</code>: no <code>exact</code> on single word query</p></li>
<li><p><code>word</code>: <code>exact</code> set to 1 if the query word is found in the record. The query word needs to have at least 3 chars and not be part of our stop words dictionary</p></li>
<li><p><code>attribute</code> (default): exact set to 1 if there is an attribute containing a string equals to the query</p></li>
</ul>

      </td>
    </tr>
    
  
    <tr>
      <td valign='top'>
        <div class='client-readme-param-container'>
          <div class='client-readme-param-container-inner'>
            <div class='client-readme-param-name'><code>alternativesAsExact</code></div>
            <div class="client-readme-param-meta"><div><em>Type: <strong>string array</strong></em></div><div><em>Default: <strong>["ignorePlurals", "singleWordSynonym"]</strong></em></div></div>
          </div>
        </div>
      </td>
      <td class='client-readme-param-content'>
        <p>Specify the list of approximation that should be considered as an exact match in the ranking formula:</p>

<ul>
<li><p><code>ignorePlurals</code>: alternative words added by the ignorePlurals feature</p></li>
<li><p><code>singleWordSynonym</code>: single-word synonym (For example &quot;NY&quot; = &quot;NYC&quot;)</p></li>
<li><p><code>multiWordsSynonym</code>: multiple-words synonym (For example &quot;NY&quot; = &quot;New York&quot;)</p></li>
</ul>

      </td>
    </tr>
    
  </tbody></table>




List indices
==================
You can list all your indices along with their associated information (number of entries, disk size, etc.) with the `listIndexes` method:

```objc
[client listIndexes:^(ASAPIClient *client, NSDictionary *result) {
    NSLog(@"Indexes: %@", result);
} failure:nil];
```





Delete an index
==================
You can delete an index using its name:

```objc
[client deleteIndex:@"contacts" success:nil 
  failure:^(ASAPIClient *client, NSString *indexName, NSString *errorMessage) {
    NSLog(@"Could not delete: %@", errorMessage);
}];
```





Clear an index
==================
You can delete the index contents without removing settings and index specific API keys by using the clearIndex command:

```objc
[index clearIndex:nil 
  failure:^(ASRemoteIndex *index, NSString *errorMessage) {
    NSLog(@"Could not clear index: %@", errorMessage);
}];
```

Wait indexing
==================

All write operations in Algolia are asynchronous by design.

It means that when you add or update an object to your index, our servers will
reply to your request with a `taskID` as soon as they understood the write
operation.

The actual insert and indexing will be done after replying to your code.

You can wait for a task to complete using the `waitTask` method on the `taskID` returned by a write operation.

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

If you want to ensure multiple objects have been indexed, you only need to check
the biggest `taskID`.

Batch writes
==================

You may want to perform multiple operations with one API call to reduce latency.
We expose four methods to perform batch operations:
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



If you have one index per user, you may want to perform a batch operations across severals indexes.
We expose a method to perform this type of batch:
```objc
NSArray *requests = @[
@{@"action": @"addObject", @"indexName": @"index1", @"body": @{@"firstname": @"Jimmie", @"lastname": @"Barninger"}},
@{@"action": @"addObject", @"indexName": @"index2", @"body": @{@"firstname": @"Warren", @"lastname": @"Speach"}}
];
[client batch:requests 
  success:^(ASRemoteIndex *index, NSArray *request, NSDictionary *result) {
    NSLog(@"Object IDs: %@", result);
} failure:nil];
```

The attribute **action** can have these values:
- addObject
- updateObject
- partialUpdateObject
- partialUpdateObjectNoCreate
- deleteObject

Copy / Move an index
==================

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

Backup / Export an index
==================

The `search` method cannot return more than 1,000 results. If you need to
retrieve all the content of your index (for backup, SEO purposes or for running
a script on it), you should use the `browse` method instead. This method lets
you retrieve objects beyond the 1,000 limit.

This method is optimized for speed. To make it fast, distinct, typo-tolerance,
word proximity, geo distance and number of matched words are disabled. Results
are still returned ranked by attributes and custom ranking.


It will return a `cursor` alongside your data, that you can then use to retrieve
the next chunk of your records.

You can specify custom parameters (like `page` or `hitsPerPage`) on your first
`browse` call, and these parameters will then be included in the `cursor`. Note
that it is not possible to access records beyond the 1,000th on the first call.

Example:

```objc
// Iterate with a filter over the index
[index browseWithQuery:query block:^(ASBrowseIterator *iterator, BOOL end, NSString *error) {
	// Retrieve the next cursor from the browse method
	NSLog(iterator.cursor);
    if (error != nil) {
        // Handle errors
    } else if (end) {
        // End of the index
    } else {
        // Do something
        [iterator next];
    }
}];
```








