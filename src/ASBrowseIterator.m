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
    NSString *cursor;
    BOOL end;
}

-(instancetype)initWithIndex:(ASRemoteIndex*)index
                       query:(ASQuery*)query
                    andBlock:(BrowseIteratorHandler)pblock
{
    self = [super init];
    if (self) {
        _index = index;
        _query = query;
        block = [pblock copy];
        
        queryURL = [query buildURL];
        path = [NSString stringWithFormat:@"/1/indexes/%@/browse?%@", index.urlEncodedIndexName, queryURL];
        
        end = false;
    }
    return self;
}

-(void) next
{
    NSMutableString *requestPath = [path mutableCopy];
    if (self->cursor != nil) {
        if ([self->queryURL length] > 0) {
            [requestPath appendString:@"&"];
        }

        [requestPath appendFormat:@"cursor=%@", [ASAPIClient urlEncode:self->cursor]];
    }
    
    [self.index.apiClient performHTTPQuery:requestPath method:@"GET" body:nil managers:self.index.apiClient.searchOperationManagers index:0 timeout:self.index.apiClient.timeout success:^(id JSON) {
        self.result = JSON;
        self->cursor = JSON[@"cursor"];
        if (self->cursor == nil) {
            self->end = true;
        }
        
        self->block(self, self->end, nil);
    } failure:^(NSString *errorMessage) {
        self->block(self, false, errorMessage);
    }];
}

@end
