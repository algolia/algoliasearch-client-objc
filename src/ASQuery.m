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
        _minWordSizeForApprox1Set = _minWordSizeForApprox2Set = _getRankingInfoSet = _ignorePluralSet = _distinctSet = _hitsPerPageSet = _minProximitySet = NO;
        _typosOnNumericTokensSet = _analyticsSet = _synonymsSet = _replaceSynonymsSet = _optionalWordsMinimumMatchedSet = _aroundLatLongViaIPSet = NO;
        _advancedSyntaxSet = _removeStopWordsSet = _aroundPrecisionSet = _aroundRadiusSet = NO;
        _page = 0;
        _attributesToHighlight = nil;
        _disableTypoToleranceOnAttributes = nil;
        _attributesToRetrieve = nil;
        _attributesToSnippet = nil;
        _tagFilters = nil;
        _numericFilters = nil;
        _fullTextQuery = pfullTextQuery;
        _queryType = nil;
        _similarQuery = nil;
        _removeWordsIfNoResult = nil;
        _typoTolerance = nil;
        _insideBoundingBox = nil;
        _insidePolygon = nil;
        _aroundLatLong = nil;
        _optionalWords = nil;
        _filters = nil;
        _facetFilters = nil;
        _facetFiltersRaw = nil;
        _facets = nil;
        _restrictSearchableAttributes = nil;
        _highlightPreTag = nil;
        _highlightPostTag = nil;
        _analyticsTags = nil;
        _userToken = nil;
        _referers = nil;
    }
    return self;
}

-(instancetype) copyWithZone:(NSZone*)zone {
    ASQuery *new = [[ASQuery alloc] init];
    
    new.minWordSizeForApprox1 = self.minWordSizeForApprox1;
    new.minWordSizeForApprox1Set = self.minWordSizeForApprox1Set;
    new.minWordSizeForApprox2 = self.minWordSizeForApprox2;
    new.minWordSizeForApprox2Set = self.minWordSizeForApprox2Set;
    new.getRankingInfo = self.getRankingInfo;
    new.getRankingInfoSet = self.getRankingInfoSet;
    new.ignorePlural = self.ignorePlural;
    new.ignorePluralSet = self.ignorePluralSet;
    new.distinct = self.distinct;
    new.distinctSet = self.distinctSet;
    new.aroundRadius = self.aroundRadius;
    new.aroundRadiusSet = self.aroundRadiusSet;
    new.aroundPrecision = self.aroundPrecision;
    new.aroundPrecisionSet = self.aroundPrecisionSet;
    new.page = self.page;
    new.hitsPerPage = self.hitsPerPage;
    new.hitsPerPageSet = self.hitsPerPageSet;
    new.minProximity = self.minProximity;
    new.minProximitySet = self.minProximitySet;
    new.attributesToHighlight = [self.attributesToHighlight copyWithZone:zone];
    new.disableTypoToleranceOnAttributes = [self.disableTypoToleranceOnAttributes copyWithZone:zone];
    new.attributesToRetrieve = [self.attributesToRetrieve copyWithZone:zone];
    new.attributesToSnippet = [self.attributesToSnippet copyWithZone:zone];
    new.tagFilters = [self.tagFilters copyWithZone:zone];
    new.numericFilters = [self.numericFilters copyWithZone:zone];
    new.fullTextQuery = [self.fullTextQuery copyWithZone:zone];
    new.queryType = [self.queryType copyWithZone:zone];
    new.similarQuery = [self.similarQuery copyWithZone:zone];
    new.removeWordsIfNoResult = [self.removeWordsIfNoResult copyWithZone:zone];
    new.typoTolerance = [self.typoTolerance copyWithZone:zone];
    new.typosOnNumericTokens = self.typosOnNumericTokens;
    new.typosOnNumericTokensSet = self.typosOnNumericTokensSet;
    new.analytics = self.analytics;
    new.analyticsSet = self.analyticsSet;
    new.synonyms = self.synonyms;
    new.synonymsSet = self.synonymsSet;
    new.replaceSynonyms = self.replaceSynonyms;
    new.replaceSynonymsSet = self.replaceSynonymsSet;
    new.optionalWordsMinimumMatched = self.optionalWordsMinimumMatched;
    new.optionalWordsMinimumMatchedSet = self.optionalWordsMinimumMatchedSet;
    new.insideBoundingBox = [self.insideBoundingBox copyWithZone:zone];
    new.insidePolygon = [self.insidePolygon copyWithZone:zone];
    new.aroundLatLong = [self.aroundLatLong copyWithZone:zone];
    new.aroundLatLongViaIP = self.aroundLatLongViaIP;
    new.aroundLatLongViaIPSet = self.aroundLatLongViaIPSet;
    new.optionalWords = [self.optionalWords copyWithZone:zone];
    new.filters = [self.filters copyWithZone:zone];
    new.facetFilters = [self.facetFilters copyWithZone:zone];
    new.facetFiltersRaw = [self.facetFiltersRaw copyWithZone:zone];
    new.facets = [self.facets copyWithZone:zone];
    new.restrictSearchableAttributes = [self.restrictSearchableAttributes copyWithZone:zone];
    new.highlightPreTag = [self.highlightPreTag copyWithZone:zone];
    new.highlightPostTag = [self.highlightPostTag copyWithZone:zone];
    new.analyticsTags = [self.analyticsTags copyWithZone:zone];
    new.advancedSyntax = self.advancedSyntax;
    new.advancedSyntaxSet = self.advancedSyntaxSet;
    new.removeStopWords = self.removeStopWords;
    new.removeStopWordsSet = self.removeStopWordsSet;
    new.userToken = self.userToken;
    new.referers = self.referers;
    
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
        [stringBuilder appendString:@"attributesToHighlight="];
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
        [stringBuilder appendString:@"disableTypoToleranceOnAttributes="];
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
    if (self.filters != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"filters="];
        [stringBuilder appendString:[ASAPIClient urlEncode:self.filters]];
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
    if (self.optionalWordsMinimumMatchedSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"optionalWordsMinimumMatched=%zd", self.optionalWordsMinimumMatched];
    }
    if (self.minWordSizeForApprox1Set) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minWordSizefor1Typo=%zd", self.minWordSizeForApprox1];
    }
    if (self.minWordSizeForApprox2Set) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minWordSizefor2Typos=%zd", self.minWordSizeForApprox2];
    }
    if (self.ignorePluralSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"ignorePlural=%d", self.ignorePlural];
    }
    if (self.getRankingInfoSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"getRankingInfo=%d", self.getRankingInfo];
    }
    if (self.typosOnNumericTokensSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"allowTyposOnNumericTokens=%d", self.typosOnNumericTokens];
    }
    if (self.typoTolerance  != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"typoTolerance="];
        [stringBuilder appendString:self.typoTolerance];
    }
    if (self.aroundRadiusSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"aroundRadius=%zd", self.aroundRadius];
    }
    if (self.aroundPrecisionSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"aroundPrecision=%zd", self.aroundPrecision];
    }
    if (self.distinctSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];

        [stringBuilder appendFormat:@"distinct=%zd", self.distinct];
    }
    if (self.analyticsSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"analytics=%d", self.analytics];
    }
    if (self.synonymsSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"synonyms=%d", self.synonyms];
    }
    if (self.replaceSynonymsSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"replaceSynonymsInHighlight=%d", self.replaceSynonyms];
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
    if (self.minProximitySet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"minProximity=%zd", self.minProximity];
    }
    if (self.queryType != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"queryType=%@", [ASAPIClient urlEncode:self.queryType]];
    }
    if (self.similarQuery != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"similarQuery=%@", [ASAPIClient urlEncode:self.similarQuery]];
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
    if (self.aroundLatLongViaIPSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"aroundLatLngViaIP=%d", self.aroundLatLongViaIP];
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
    if (self.advancedSyntaxSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"advancedSyntax=%d", self.advancedSyntax];
    }
    if (self.removeStopWordsSet) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"removeStopWords=%d", self.removeStopWords];
    }
    if (self.userToken != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"userToken=%@", [ASAPIClient urlEncode:self.userToken]];
    }
    if (self.referers != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"referer=%@", [ASAPIClient urlEncode:self.referers]];
    }

    return stringBuilder;
}

@synthesize minWordSizeForApprox1 = _minWordSizeForApprox1;
-(void) setMinWordSizeForApprox1:(NSUInteger)minWordSizeForApprox1 {
    _minWordSizeForApprox1 = minWordSizeForApprox1;
    self.minWordSizeForApprox1Set = true;
}

-(NSUInteger)minWordSizeForApprox1 {
    self.minWordSizeForApprox1Set = true;
    return _minWordSizeForApprox1;
}

@synthesize minWordSizeForApprox2 = _minWordSizeForApprox2;
-(void) setMinWordSizeForApprox2:(NSUInteger)minWordSizeForApprox2 {
    _minWordSizeForApprox2 = minWordSizeForApprox2;
    self.minWordSizeForApprox2Set = true;
}

-(NSUInteger)minWordSizeForApprox2 {
    self.minWordSizeForApprox2Set = true;
    return _minWordSizeForApprox2;
}

@synthesize hitsPerPage = _hitsPerPage;
-(void) setHitsPerPage:(NSUInteger)hitsPerPage {
    _hitsPerPage = hitsPerPage;
    self.hitsPerPageSet = true;
}

-(NSUInteger)hitsPerPage {
    self.hitsPerPageSet = true;
    return _hitsPerPage;
}

@synthesize minProximity = _minProximity;
-(void) setMinProximity:(NSUInteger)minProximity {
    _minProximity = minProximity;
    self.minProximitySet = true;
}

-(NSUInteger)minProximity {
    self.minProximitySet = true;
    return _minProximity;
}

@synthesize getRankingInfo = _getRankingInfo;
-(void) setGetRankingInfo:(BOOL)getRankingInfo {
    _getRankingInfo = getRankingInfo;
    self.getRankingInfoSet = true;
}

-(BOOL)getRankingInfo {
    self.getRankingInfoSet = true;
    return _getRankingInfo;
}

@synthesize ignorePlural = _ignorePlural;
-(void) setIgnorePlural:(BOOL)ignorePlural {
    _ignorePlural = ignorePlural;
    self.ignorePluralSet = true;
}

-(BOOL)ignorePlural {
    self.ignorePluralSet = true;
    return _ignorePlural;
}

@synthesize typosOnNumericTokens = _typosOnNumericTokens;
-(void) setTyposOnNumericTokens:(BOOL)typosOnNumericTokens {
    _typosOnNumericTokens = typosOnNumericTokens;
    self.typosOnNumericTokensSet = true;
}

-(BOOL)typosOnNumericTokens {
    self.typosOnNumericTokensSet = true;
    return _typosOnNumericTokens;
}

@synthesize analytics = _analytics;
-(void) setAnalytics:(BOOL)analytics {
    _analytics = analytics;
    self.analyticsSet = true;
}

-(BOOL)analytics {
    self.analyticsSet = true;
    return _analytics;
}

@synthesize synonyms = _synonyms;
-(void) setSynonyms:(BOOL)synonyms {
    _synonyms = synonyms;
    self.synonymsSet = true;
}

-(BOOL)synonyms {
    self.synonymsSet = true;
    return _synonyms;
}

@synthesize replaceSynonyms = _replaceSynonyms;
-(void) setReplaceSynonyms:(BOOL)replaceSynonyms {
    _replaceSynonyms = replaceSynonyms;
    self.replaceSynonymsSet = true;
}

-(BOOL)replaceSynonyms {
    self.replaceSynonymsSet = true;
    return _replaceSynonyms;
}

@synthesize distinct = _distinct;
-(void) setDistinct:(NSUInteger)distinct {
    _distinct = distinct;
    self.distinctSet = true;
}

-(NSUInteger)distinct {
    self.distinctSet = true;
    return _distinct;
}

@synthesize optionalWordsMinimumMatched = _optionalWordsMinimumMatched;
-(void)setOptionalWordsMinimumMatched:(NSUInteger)optionalWordsMinimumMatched {
    _optionalWordsMinimumMatched = optionalWordsMinimumMatched;
    self.optionalWordsMinimumMatchedSet = true;
}

-(NSUInteger)optionalWordsMinimumMatched {
    self.optionalWordsMinimumMatchedSet = true;
    return _optionalWordsMinimumMatched;
}
@synthesize aroundRadius = _aroundRadius;
-(void) setAroundRadius:(NSUInteger)aroundRadius {
    _aroundRadius = aroundRadius;
    self.aroundRadiusSet = true;
}

-(NSUInteger)aroundRadius {
    self.aroundRadiusSet = true;
    return _aroundRadius;
}

@synthesize aroundPrecision = _aroundPrecision;
-(void) setAroundPrecision:(NSUInteger)aroundPrecision {
    _aroundPrecision = aroundPrecision;
    self.aroundPrecisionSet = true;
}

-(NSUInteger)aroundPrecision {
    self.aroundPrecisionSet = true;
    return _aroundPrecision;
}

@synthesize aroundLatLongViaIP = _aroundLatLongViaIP;
-(void) setAroundLatLongViaIP:(BOOL)aroundLatLongViaIP {
    _aroundLatLongViaIP = aroundLatLongViaIP;
    self.aroundLatLongViaIPSet = true;
}

-(BOOL)aroundLatLongViaIP {
    self.aroundLatLongViaIPSet = true;
    return _aroundLatLongViaIP;
}

@synthesize advancedSyntax = _advancedSyntax;
-(void)setAdvancedSyntax:(BOOL)advancedSyntax {
    _advancedSyntax = advancedSyntax;
    self.advancedSyntaxSet = true;
}

-(BOOL)advancedSyntax {
    self.advancedSyntaxSet = true;
    return _advancedSyntax;
}

@synthesize removeStopWords = _removeStopWords;
-(void) setRemoveStopWords:(BOOL)removeStopWords {
    _removeStopWords = removeStopWords;
    self.removeStopWordsSet = true;
}

-(BOOL)removeStopWords {
    self.removeStopWordsSet = true;
    return _removeStopWords;
}

@end
