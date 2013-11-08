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

#import "ASQuery.h"
#import "ASAPIClient+Network.h"

@implementation ASQuery

+(id) queryWithFullTextQuery:(NSString *)fullTextQuery
{
    return [[ASQuery alloc] initWithFullTextQuery:fullTextQuery];
}

-(id) init
{
    self = [super init];
    if (self) {
        self.minWordSizeForApprox1 = 3;
        self.minWordSizeForApprox2 = 7;
        self.getRankingInfo = NO;
        self.page = 0;
        self.hitsPerPage = 20;
        self.attributesToHighlight = nil;
        self.attributesToRetrieve = nil;
        self.attributesToSnippet = nil;
        self.tagsFilter = nil;
        self.numericsFilter = nil;
        self.fullTextQuery = nil;
        self.insideBoundingBox = nil;
        self.aroundLatLong = nil;
        self.queryType = nil;
    }
    return self;
}

-(id) initWithFullTextQuery:(NSString *)pfullTextQuery
{
    self = [super init];
    if (self) {
        self.minWordSizeForApprox1 = 3;
        self.minWordSizeForApprox2 = 7;
        self.getRankingInfo = NO;
        self.page = 0;
        self.hitsPerPage = 20;
        self.fullTextQuery = pfullTextQuery;
        self.attributesToHighlight = nil;
        self.attributesToRetrieve = nil;
        self.attributesToSnippet = nil;
        self.tagsFilter = nil;
        self.numericsFilter = nil;
        self.insideBoundingBox = nil;
        self.aroundLatLong = nil;
        self.queryType = nil;
    }
    return self;
}

-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist
{
    self.aroundLatLong = [NSString stringWithFormat:@"aroundLatLng=%f,%f&aroundRadius=%zd", latitude, longitude, maxDist];
    return self;
}

-(ASQuery*) searchAroundLatitude:(float)latitude longitude:(float)longitude maxDist:(NSUInteger)maxDist precision:(NSUInteger)precision
{
    self.aroundLatLong = [NSString stringWithFormat:@"aroundLatLng=%f,%f&aroundRadius=%zd&aroundPrecision=%zd", latitude, longitude, maxDist, precision];
    return self;
}

-(ASQuery*) searchInsideBoundingBoxWithLatitudeP1:(float)latitudeP1 longitudeP1:(float)longitudeP1 latitudeP2:(float)latitudeP2 longitudeP2:(float)longitudeP2
{
    self.insideBoundingBox = [NSString stringWithFormat:@"insideBoundingBox=%f,%f,%f,%f", latitudeP1, longitudeP1, latitudeP2, longitudeP2];
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
    if (self.facetsFilter != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"facetsFilter="];
        NSError* err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:facetsFilter options:NSJSONWritingPrettyPrinted error:&err];
        if (err == nil) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [stringBuilder appendString:[ASAPIClient urlEncode:jsonString]];
        } else {
            @throw [NSException exceptionWithName:@"InvalidArgument" reason:@"Invalid facetsFilter (should be an array of string)" userInfo:nil];
        }
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
    if (self.getRankingInfo) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:@"getRankingInfo=1"];
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
    if (self.queryType != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"queryType=%@", [ASAPIClient urlEncode:self.queryType]];
    }
    if (self.tagsFilter != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"tags=%@", [ASAPIClient urlEncode:self.tagsFilter]];
    }
    if (self.numericsFilter != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"numerics=%@", [ASAPIClient urlEncode:self.numericsFilter]];
    }
    if (self.insideBoundingBox != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:self.insideBoundingBox];
    } else if (self.aroundLatLong != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendString:self.aroundLatLong];
    }
    if (self.fullTextQuery != nil) {
        if ([stringBuilder length] > 0)
            [stringBuilder appendString:@"&"];
        [stringBuilder appendFormat:@"query=%@", [ASAPIClient urlEncode:self.fullTextQuery]];
    }
    return stringBuilder;
}

@synthesize attributesToRetrieve;
@synthesize attributesToHighlight;
@synthesize attributesToSnippet;
@synthesize tagsFilter;
@synthesize numericsFilter;
@synthesize insideBoundingBox;
@synthesize aroundLatLong;
@synthesize fullTextQuery;
@synthesize minWordSizeForApprox1;
@synthesize minWordSizeForApprox2;
@synthesize page;
@synthesize hitsPerPage;
@synthesize getRankingInfo;
@synthesize queryType;
@synthesize facetsFilter;
@synthesize facets;
@synthesize optionalWords;
@end
