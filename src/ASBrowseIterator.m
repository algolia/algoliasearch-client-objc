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
