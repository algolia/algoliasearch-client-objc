//
//  ASBrowseIterator.m
//  algoliasearch-client-objc
//
//  Created by Thibault Deutsch on 10/06/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

#import "ASBrowseIterator.h"
#import "ASAPIClient.h"
#import "ASAPIClient+Network.h"
#import "ASQuery.h"
#import "ASRemoteIndex.h"


@implementation ASBrowseIterator
{
    NSString *path;
    NSString *queryURL;
    BrowseIteratorHandler block;
    BOOL end;
}

- (instancetype)initWithIndex:(ASRemoteIndex*)index
                        query:(ASQuery*)query
                       cursor:(NSString*)cursor
                     andBlock:(BrowseIteratorHandler)pblock
{
    self = [super init];
    if (self) {
        _index = index;
        _cursor = (cursor != nil) ? cursor : nil;
        block = [pblock copy];
        
        queryURL = (query != nil) ? [query buildURL] : @"";
        path = [NSString stringWithFormat:@"/1/indexes/%@/browse?", index.urlEncodedIndexName];
        
        end = false;
    }
    return self;
}

- (void)next
{
    NSMutableString *requestPath = [path mutableCopy];
    if (self.cursor != nil) {
        [requestPath appendFormat:@"cursor=%@", [ASAPIClient urlEncode:self.cursor]];
    } else {
        [requestPath appendString:queryURL];
    }
    
    [self.index.apiClient performHTTPQuery:requestPath method:@"GET" body:nil managers:self.index.apiClient.searchOperationManagers index:0 timeout:self.index.apiClient.timeout success:^(id JSON) {
        self.result = JSON;
        self.cursor = JSON[@"cursor"];
        if (self.cursor == nil) {
            end = true;
        }
        
        block(self, end, nil);
    } failure:^(NSString *errorMessage) {
        block(self, false, errorMessage);
    }];
}

@end
