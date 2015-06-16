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

-(instancetype)initWithIndex:(ASRemoteIndex*)index
                       query:(ASQuery*)query
                    andBlock:(BrowseIteratorHandler)pblock;

-(void) next;

@property (nonatomic) ASRemoteIndex *index;
@property (nonatomic) ASQuery *query;
@property (nonatomic) NSDictionary *result;

@end
