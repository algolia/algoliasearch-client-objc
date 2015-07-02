//
//  ASBrowseIterator.h
//  algoliasearch-client-objc
//
//  Created by Thibault Deutsch on 10/06/15.
//  Copyright (c) 2015 Algolia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASRemoteIndex;
@class ASQuery;

@interface ASBrowseIterator : NSObject

typedef void(^BrowseIteratorHandler)(ASBrowseIterator *iterator, BOOL end, NSString *error);

- (instancetype)initWithIndex:(ASRemoteIndex*)index
                       query:(ASQuery*)query
                      cursor:(NSString*)cursor
                    andBlock:(BrowseIteratorHandler)pblock;

- (void)next;

@property (nonatomic) ASRemoteIndex *index;
@property (nonatomic) NSString *cursor;
@property (nonatomic) NSDictionary *result;

@end
