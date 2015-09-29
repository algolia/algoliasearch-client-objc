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

#import "ASQuery.h"
#import "ASAPIClient+Network.h"

@implementation ASQuery

+(instancetype) queryWithFullTextQuery:(NSString *)fullTextQuery
{
    return [[ASQuery alloc] initWithFullTextQuery:fullTextQuery];
}

-(instancetype) init
{
    return [self initWithFullTextQuery:nil];
}

-(instancetype) initWithFullTextQuery:(NSString *)pfullTextQuery
{
    self = [super init];
    if (self) {
        _minWordSizeForApprox1 = 3;
        _minWordSizeForApprox2 = 7;
        _getRankingInfo = NO;
        _ignorePlural = NO;
        _distinct = 0;
        _aroundPrecision = 0;
        _aroundRadius = 0;
        _page = 0;
        _hitsPerPage = 20;
        _minProximity = 1;
        _attributesToHighlight = nil;
        _disableTypoToleranceOnAttributes = nil;
        _attributesToRetrieve = nil;
        _attributesToSnippet = nil;
        _tagFilters = nil;
        _numericFilters = nil;
        _fullTextQuery = pfullTextQuery;
        _queryType = nil;
        _removeWordsIfNoResult = nil;
        _typoTolerance = nil;
        _typosOnNumericTokens = YES;
        _analytics = YES;
        _synonyms = YES;
        _replaceSynonyms = YES;
        _optionalWordsMinimumMatched = 0;
        _insideBoundingBox = nil;
        _insidePolygon = nil;
        _aroundLatLong = nil;
        _aroundLatLongViaIP = NO;
        _optionalWords = nil;
        _facetFilters = nil;
        _facetFiltersRaw = nil;
        _facets = nil;
        _restrictSearchableAttributes = nil;
        _highlightPreTag = nil;
        _highlightPostTag = nil;
        _analyticsTags = nil;
    }
    return self;
}

-(instancetype) copyWithZone:(NSZone*)zone {
    ASQuery *new = [[ASQuery alloc] init];
    
    new.minWordSizeForApprox1 = self.minWordSizeForApprox1;
    new.minWordSizeForApprox2 = self.minWordSizeForApprox2;
    new.getRankingInfo = self.getRankingInfo;
    new.ignorePlural = self.ignorePlural;
    new.distinct = self.distinct;
    new.aroundRadius = new.aroundRadius;
    new.aroundPrecision = new.aroundPrecision;
    new.page = self.page;
    new.hitsPerPage = self.hitsPerPage;
    new.minProximity = self.minProximity;
    new.attributesToHighlight = [self.attributesToHighlight copyWithZone:zone];
    new.disableTypoToleranceOnAttributes = [self.disableTypoToleranceOnAttributes copyWithZone:zone];
    new.attributesToRetrieve = [self.attributesToRetrieve copyWithZone:zone];
    new.attributesToSnippet = [self.attributesToSnippet copyWithZone:zone];
    new.tagFilters = [self.tagFilters copyWithZone:zone];
    new.numericFilters = [self.numericFilters copyWithZone:zone];
    new.fullTextQuery = [self.fullTextQuery copyWithZone:zone];
    new.queryType = [self.queryType copyWithZone:zone];
    new.removeWordsIfNoResult = [self.removeWordsIfNoResult copyWithZone:zone];
    new.typoTolerance = [self.typoTolerance copyWithZone:zone];
    new.typosOnNumericTokens = self.typosOnNumericTokens;
    new.analytics = self.analytics;
    new.synonyms = self.synonyms;
    new.replaceSynonyms = self.replaceSynonyms;
    new.optionalWordsMinimumMatched = self.optionalWordsMinimumMatched;
    new.insideBoundingBox = [self.insideBoundingBox copyWithZone:zone];
    new.insidePolygon = [self.insidePolygon copyWithZone:zone];
    new.aroundLatLong = [self.aroundLatLong copyWithZone:zone];
    new.aroundLatLongViaIP = self.aroundLatLongViaIP;
    new.optionalWords = [self.optionalWords copyWithZone:zone];
    new.facetFilters = [self.facetFilters copyWithZone:zone];
    new.facetFiltersRaw = [self.facetFiltersRaw copyWithZone:zone];
    new.facets = [self.facets copyWithZone:zone];
    new.restrictSearchableAttributes = [self.restrictSearchableAttributes copyWithZone:zone];
    new.highlightPreTag = [self.highlightPreTag copyWithZone:zone];
    new.highlightPostTag = [self.highlightPostTag copyWithZone:zone];
    new.analyticsTags = [self.analyticsTags copyWithZone:zone];
    
    return new;
}

-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude
{
    self.aroundLatLong = [NSString stringWithFormat:@"aroundLatLng=%f,%f", latitude, longitude];
    return self;    
}

-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist
{
    self.aroundLatLong = [NSString stringWithFormat:@"aroundLatLng=%f,%f", latitude, longitude];
    self.aroundRadius = maxDist;
    return self;
}

-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist precision:(NSUInteger)precision
{
    self.aroundLatLong = [NSString stringWithFormat:@"aroundLatLng=%f,%f", latitude, longitude];
    self.aroundRadius = maxDist;
    self.aroundPrecision = precision;
    return self;
}

-(ASQuery*) searchAroundLatitudeLongitudeViaIP
{
    self.aroundLatLongViaIP = YES;
    return self;
}

-(ASQuery*) searchAroundLatitudeLongitudeViaIP:(NSUInteger)maxDist
{
    self.aroundRadius = maxDist;
    self.aroundLatLongViaIP = YES;
    return self;
}

-(ASQuery*) searchAroundLatitudeLongitudeViaIP:(NSUInteger)maxDist precision:(NSUInteger)precision
{
    self.aroundRadius = maxDist;
    self.aroundPrecision = precision;
    self.aroundLatLongViaIP = YES;
    return self;
}


-(ASQuery*) searchInsideBoundingBoxWithLatitudeP1:(float)latitudeP1 longitudeP1:(float)longitudeP1 latitudeP2:(float)latitudeP2 longitudeP2:(float)longitudeP2
{
    if (self.insideBoundingBox != nil) {
        self.insideBoundingBox = [NSString stringWithFormat:@"%@,%f,%f,%f,%f", self.insideBoundingBox, latitudeP1, longitudeP1, latitudeP2, longitudeP2];
    } else {
        self.insideBoundingBox = [NSString stringWithFormat:@"insideBoundingBox=%f,%f,%f,%f", latitudeP1, longitudeP1, latitudeP2, longitudeP2];
    }
    return self;
}

-(ASQuery*) addInsidePolygon:(float)latitude longitude:(float)longitude
{
    if (self.insidePolygon != nil) {
        self.insidePolygon = [NSString stringWithFormat:@"%@,%f,%f", self.insidePolygon, latitude, longitude];
    } else {
        self.insidePolygon = [NSString stringWithFormat:@"insidePolygon=%f,%f", latitude, longitude];
    }
    return self;
}

-(NSString*) buildURL
{
    NSMutableString *stringBuilder = [[NSMutableString alloc] init];
    if (self.attributesToRetrieve != nil) {
        [stringBuilder appendString:@"attributes="];
        BOOL first = YES;
        for (NSString* attribute in self.attributesToRetrieve) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:attribute]];
            first = NO;
        }
    }
    if (self.attributesToHighlight != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"disableTypoToleranceOnAttributes="];
        BOOL first = YES;
        for (NSString* attribute in self.attributesToHighlight) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:attribute]];
            first = NO;
        }
    }
    if (self.disableTypoToleranceOnAttributes != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"attributesToHighlight="];
        BOOL first = YES;
        for (NSString* attribute in self.disableTypoToleranceOnAttributes) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:attribute]];
            first = NO;
        }
    }
    if (self.attributesToSnippet != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"attributesToSnippet="];
        BOOL first = YES;
        for (NSString* attribute in self.attributesToSnippet) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:attribute]];
            first = NO;
        }
    }
    if (self.facetFilters != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"facetFilters="];
        NSError* err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.facetFilters options:NSJSONWritingPrettyPrinted error:&err];
        if (err == nil) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [stringBuilder appendString:[ASAPIClient urlEncode:jsonString]];
        } else {
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"Invalid facetFilters (should be an array of string)" userInfo:nil];
        }
    } else if (self.facetFiltersRaw != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"facetFilters="];
        [stringBuilder appendString:[ASAPIClient urlEncode:self.facetFiltersRaw]];
    }

    if (self.facets != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"facets="];
        BOOL first = YES;
        for (NSString* attribute in self.facets) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:attribute]];
            first = NO;
        }
    }
    if (self.optionalWords != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"optionalWords="];
        BOOL first = YES;
        for (NSString* word in self.optionalWords) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:word]];
            first = NO;
        }
    }
    if (self.optionalWordsMinimumMatched > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"optionalWordsMinimumMatched=%zd", self.optionalWordsMinimumMatched];
    }
    if (self.minWordSizeForApprox1 != 3) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minWordSizefor1Typo=%zd", self.minWordSizeForApprox1];
    }
    if (self.minWordSizeForApprox2 != 7) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minWordSizefor2Typos=%zd", self.minWordSizeForApprox2];
    }
    if (self.ignorePlural) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"ignorePlural=true"];
    }
    if (self.getRankingInfo) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"getRankingInfo=1"];
    }
    if (!self.typosOnNumericTokens) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"allowTyposOnNumericTokens=false"];
    }
    if (self.typoTolerance  != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"typoTolerance="];
        [stringBuilder appendString:self.typoTolerance];
    }
    if (self.aroundRadius > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"aroundRadius=%zd", self.aroundRadius];
    }
    if (self.aroundPrecision > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"aroundPrecision=%zd", self.aroundPrecision];
    }
    if (self.distinct > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"distinct=%zd", self.distinct];
    }
    if (!self.analytics) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"analytics=0"];
    }
    if (!self.synonyms) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"synonyms=0"];
    }
    if (!self.replaceSynonyms) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"replaceSynonymsInHighlight=0"];
    }
    if (self.page > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"page=%zd", self.page];
    }
    if (self.hitsPerPage != 20 && self.hitsPerPage > 0) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"hitsPerPage=%zd", self.hitsPerPage];
    }
    if (self.minProximity > 1) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minProximity=%zd", self.minProximity];
    }
    if (self.queryType != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"queryType=%@", [ASAPIClient urlEncode:self.queryType]];
    }
    if (self.removeWordsIfNoResult != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"removeWordsIfNoResult=%@", [ASAPIClient urlEncode:self.removeWordsIfNoResult]];
    }
    if (self.tagFilters != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"tagFilters=%@", [ASAPIClient urlEncode:self.tagFilters]];
    }
    if (self.numericFilters != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"numericFilters=%@", [ASAPIClient urlEncode:self.numericFilters]];
    }
    if (self.insideBoundingBox != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:self.insideBoundingBox];
    } else if (self.aroundLatLong != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:self.aroundLatLong];
    } else if (self.insidePolygon != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:self.insidePolygon];        
    }
    if (self.aroundLatLongViaIP) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"aroundLatLngViaIP=true"];
    }
    if (self.fullTextQuery != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"query=%@", [ASAPIClient urlEncode:self.fullTextQuery]];
    }
    if (self.restrictSearchableAttributes != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"restrictSearchableAttributes=%@", [ASAPIClient urlEncode:self.restrictSearchableAttributes]];
    }
    if (self.highlightPreTag != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"highlightPreTag=%@", [ASAPIClient urlEncode:self.highlightPreTag]];
    }
    if (self.highlightPostTag != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"highlightPostTag=%@", [ASAPIClient urlEncode:self.highlightPostTag]];
    }
    if (self.analyticsTags != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"analyticsTags="];
        BOOL first = YES;
        for (NSString* tag in self.analyticsTags) {
            if (!first)
                [stringBuilder appendString:@","];
            [stringBuilder appendString:[ASAPIClient urlEncode:tag]];
            first = NO;
        }
    }
    return stringBuilder;
}

@end
