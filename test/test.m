//
//  test.m
//  test
//
//  Created by Xavier Grand on 26/03/2014.
//  Copyright (c) 2014 Algolia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../src/ASAPIClient.h"

@interface test : XCTestCase
@property (strong, nonatomic) ASAPIClient *client;
@property (strong, nonatomic) ASRemoteIndex *index;
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpRequestOperationManager;
@end

@implementation test

- (void)setUp
{
    [super setUp];
    NSString* appID = [[[NSProcessInfo processInfo] environment] objectForKey:@"ALGOLIA_APPLICATION_ID"];
    NSString* apiKey = [[[NSProcessInfo processInfo] environment] objectForKey:@"ALGOLIA_API_KEY"];
    self.client = [ASAPIClient apiClientWithApplicationID :appID apiKey:apiKey];
    self.index = [self.client getIndex:@"algol?à-objc"];
    self.httpRequestOperationManager = [self.client.operationManagers objectAtIndex:0];
    __block int done = 0;
    [self.client deleteIndex:@"algol?à-objc" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        done = 1;
    } failure:nil];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)tearDown
{
    [super tearDown];
    __block int done = 0;
    [self.client deleteIndex:@"algol?à-objc" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        done = 1;
    } failure:nil];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testAdd
{
    
    __block int done = 0;

    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
            ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
            [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                done = 1;
            } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                XCTFail("@Error during search: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testAddWithObjectID
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj withObjectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
            [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                XCTAssertEqualObjects(@"San Francisco", city, "Get object return a bad object");
                done = 1;
            } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                XCTFail("@Error during getObject: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString* objectID, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testDelete
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index deleteObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Wrong number of object in the index");
                    done = 1;
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
    
}

- (void)testGet
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
            [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                XCTAssertEqualObjects(@"San Francisco", city, "Get object return a bad object");
                done = 1;
            }
            failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                XCTFail("@Error during getObject: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

/*- (void)testGetWithAttributesToRetrieve
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
            [self.index getObject:@"a/go/?à" attributesToRetrieve:@[@"city"] success:^(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSDictionary *result) {
                NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                XCTAssertEqualObjects(@"San Francisco", city, "Get object return a bad object");
                NSLog([result objectForKey:@"objectID"]);
                XCTAssertTrue([result objectForKey:@"objectID"] == nil, "Get object fail, objectID is available");
                done = 1;
            }
            failure:^(ASRemoteIndex *index, NSString *objectID, NSArray *attributesToRetrieve, NSString *errorMessage) {
                XCTFail("@Error during getObject: %@", errorMessage);
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
    
    XCTAssertEqual(done, 1, "Failed to Add");
}*/

- (void)testPartialUpdateObject
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index partialUpdateObject:@{@"city": @"Los Angeles"} objectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
                [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                    NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"initial"]];
                    XCTAssertEqualObjects(@"Los Angeles", city, "Partial update is not applied");
                    XCTAssertEqualObjects(@"SF", initial, "Partial update failed");
                    done = 1;
                }
                failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during partialUpdateObject: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testSaveObject
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index saveObject:@{@"city": @"Los Angeles"} objectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
                [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                    XCTAssertEqualObjects(@"Los Angeles", city, "Save object is not applied");
                    XCTAssertTrue([result objectForKey:@"initial"] == nil, "Save object failed");
                    done = 1;
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during partialUpdateObject: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testClear
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index clearIndex:^(ASRemoteIndex *index, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Clear index failed");
                    done = 1;
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
            XCTFail("@Error during clearIndex: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testSettings
{
    __block int done = 0;
    [self.index setSettings:@{@"attributesToRetrieve": @[@"name"]} success:^(ASRemoteIndex *index, NSDictionary *settings, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [self.index getSettings:^(ASRemoteIndex *index, NSDictionary *result) {
                NSMutableString *attributesToRetrieve = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"attributesToRetrieve"] objectAtIndex:0]];
                XCTAssertEqualObjects(attributesToRetrieve, @"name", @"set settings failed");
                done = 1;
            } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                XCTFail("@Error during getSettings: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
        XCTFail("@Error during setSettings: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testIndexACL
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index addUserKey:@[@"search"] success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                [index getUserKeyACL:[result objectForKey:@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    [index updateUserKey:[result objectForKey:@"value"] withACL:@[@"addObject"] success:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:3.0]; // wait the backend
                        [index getUserKeyACL:[result objectForKey:@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [index deleteUserKey:[result objectForKey:@"value"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                                [index listUserKeys:^(ASRemoteIndex *index, NSDictionary *result) {
                                    NSArray *keys = [result objectForKey:@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:[[keys objectAtIndex:i] objectForKey:@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    done = 1;
                                } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    done = 1;
                                }];
                            } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                done = 1;
                            }];
                        } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKeyACL: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
 
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testIndexACLWithValidity
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index addUserKey:@[@"search"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                [index getUserKeyACL:[result objectForKey:@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [index updateUserKey:[result objectForKey:@"value"] withACL:@[@"addObject"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:3.0]; // wait the backend
                        [index getUserKeyACL:[result objectForKey:@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [index deleteUserKey:[result objectForKey:@"value"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                                [index listUserKeys:^(ASRemoteIndex *index, NSDictionary *result) {
                                    NSArray *keys = [result objectForKey:@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:[[keys objectAtIndex:i] objectForKey:@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    done = 1;
                                } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    done = 1;
                                }];
                            } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                done = 1;
                            }];
                        } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKeyACL: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testBrowse
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index browse:0 success:^(ASRemoteIndex *index, NSUInteger page, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                done = 1;
            } failure:^(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage) {
                XCTFail("@Error during browse: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testBrowseWithHitsPerPage
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index browse:0 hitsPerPage:1 success:^(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                done = 1;
            } failure:^(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSString *errorMessage) {
                XCTFail("@Error during browse: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testListIndexes
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client listIndexes:^(ASAPIClient *client, NSDictionary *result) {
                NSArray *indexes = [result objectForKey:@"items"];
                BOOL found = false;
                for (int i = 0; i < [indexes count]; i++) {
                    if ([index.indexName isEqualToString:[[indexes objectAtIndex:i] objectForKey:@"name"]]) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    XCTFail("List indexes failed");
                }
                done = 1;
            } failure:^(ASAPIClient *client, NSString *errorMessage) {
                XCTFail("@Error during listIndexes: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testMoveIndex
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client moveIndex:@"algol?à-objc" to:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
                [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                    ASRemoteIndex *index2 = [self.client getIndex:@"algol?à-objc2"];
                    ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                    [index2 search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                        NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                        XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                        done = 1;
                    } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                        XCTFail("@Error during search: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                    XCTFail("@Error during waitTask: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
                XCTFail("@Error during moveIndex: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
    
    done = 0;
    [self.client deleteIndex:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        done = 1;
    } failure:nil];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }

}

- (void)testCpoyIndex
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client copyIndex:@"algol?à-objc" to:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
                [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                    ASRemoteIndex *index2 = [self.client getIndex:@"algol?à-objc2"];
                    ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                    [index2 search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                        NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                        XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                        ASRemoteIndex *indexOrigin = [self.client getIndex:@"algol?à-objc"];
                        query = [[ASQuery alloc] initWithFullTextQuery:@""];
                        [indexOrigin search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                            NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                            XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                            done = 1;
                        } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                            XCTFail("@Error during search: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                        XCTFail("@Error during search: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                    XCTFail("@Error during waitTask: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
                XCTFail("@Error during moveIndex: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
    
    done = 0;
    [self.client deleteIndex:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        done = 1;
    } failure:nil];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
    
}

-(void)testGetLogs
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client getLogs:^(ASAPIClient *client, NSDictionary *result) {
                XCTAssertNotEqual(0, [[result objectForKey:@"logs"] count], "Get logs failed");
                done = 1;
            } failure:^(ASAPIClient *client, NSString *errorMessage) {
                XCTFail("@Error during getLogs: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

-(void)testGetLogsWithOffset
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client getLogsWithOffset:0 length:1 success:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result) {
                XCTAssertEqual(1, [[result objectForKey:@"logs"] count], "Get logs failed");
                done = 1;
            } failure:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage) {
                XCTFail("@Error during getLogs: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testClientACL
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    [_client updateUserKey:[result objectForKey:@"value"] withACL:@[@"addObject"] success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:3.0]; // wait the backend
                        [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:[result objectForKey:@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = [result objectForKey:@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:[[keys objectAtIndex:i] objectForKey:@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    done = 1;
                        } failure:^(ASAPIClient *client, NSString *errorMessage) {
                            XCTFail("@Error during listUserKeys: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                        XCTFail("@Error during deleteUserKey: %@", errorMessage);
                        done = 1;
                    }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testClientACLWithIndexes
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] withIndexes:@[@"algol?à-objc"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSDictionary *result) {
                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [_client updateUserKey:[result objectForKey:@"value"] withACL:@[@"addObject"] withIndexes:@[@"algol?à-objc"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:3.0]; // wait the backend
                        [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:[result objectForKey:@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = [result objectForKey:@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:[[keys objectAtIndex:i] objectForKey:@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                    XCTFail("DeleteUserKey failed");
                                }
                                    done = 1;
                                } failure:^(ASAPIClient *client, NSString *errorMessage) {
                                XCTFail("@Error during listUserKeys: %@", errorMessage);
                                done = 1;
                                }];
                            } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                done = 1;
                            }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSArray *indexes, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testClientACLWithValidity
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [_client updateUserKey:[result objectForKey:@"value"] withACL:@[@"addObject"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:3.0]; // wait the backend
                        [client getUserKeyACL:[result objectForKey:@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",[[result objectForKey:@"acl"] objectAtIndex:0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:[result objectForKey:@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:3.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = [result objectForKey:@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:[[keys objectAtIndex:i] objectForKey:@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    done = 1;
                                } failure:^(ASAPIClient *client, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    done = 1;
                                }];
                            } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                done = 1;
                            }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            done = 1;
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testDeleteObjects
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index deleteObjects:@[@"a/go/?à", @"à/go/?à"] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Wrong number of object in the index");
                    done = 1;
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObjects: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObjects: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testSaveObjects
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index saveObjects:@[@{@"city": @"Los Angeles", @"objectID": @"a/go/?à"}, @{@"city": @"San Francisco", @"objectID": @"à/go/?à"}] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                [index getObject:@"à/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                    XCTAssertEqualObjects(city, @"San Francisco", @"saveObjects failed");
                    [index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                        NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                        XCTAssertEqualObjects(city, @"Los Angeles", @"saveObjects failed");
                        done = 1;
                    } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                        XCTFail("@Error during getObject n°2: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testPartialUpdateObjects
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"initial": @"LA", @"objectID": @"à/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index partialUpdateObjects:@[@{@"city": @"Los Angeles", @"objectID": @"a/go/?à"}, @{@"city": @"San Francisco", @"objectID": @"à/go/?à"}] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                [index getObject:@"à/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                    NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"initial"]];
                    XCTAssertEqualObjects(city, @"San Francisco", @"partialUpdateObjects failed");
                    XCTAssertEqualObjects(initial, @"LA", @"saveObjects failed");
                    [index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                        NSMutableString *city = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"city"]];
                        NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",[result objectForKey:@"initial"]];
                        XCTAssertEqualObjects(city, @"Los Angeles", @"partialUpdateObjects failed");
                        XCTAssertEqualObjects(initial, @"SF", @"saveObjects failed");
                        done = 1;
                    } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                        XCTFail("@Error during getObject n°2: %@", errorMessage);
                        done = 1;
                    }];
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    done = 1;
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testMultipleQueries
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects([result objectForKey:@"status"], @"published", "Wait task failed");
            ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
            [_client multipleQueries:@[@{@"indexName":@"algol?à-objc", @"query": query}] success:^(ASAPIClient *client, NSArray *queries, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",[[[result objectForKey:@"results"] objectAtIndex:0] objectForKey:@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                done = 1;
            } failure:^(ASAPIClient *client, NSArray *queries, NSString *errorMessage) {
                XCTFail("@Error during multipleQueries: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

- (void)testGetObjects
{
    __block int done = 0;
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    NSLog(@"%s doing test...", __PRETTY_FUNCTION__);
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index waitTask:[result objectForKey:@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index getObjects:@[@"a/go/?à", @"à/go/?à"] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
                NSMutableString *city1 = [NSMutableString stringWithFormat:@"%@",[[[result objectForKey:@"results"] objectAtIndex:0] objectForKey:@"city"]];
                NSMutableString *city2 = [NSMutableString stringWithFormat:@"%@",[[[result objectForKey:@"results"] objectAtIndex:1] objectForKey:@"city"]];
                XCTAssertEqualObjects(city1, @"San Francisco", @"GetObject return the wrong object");
                XCTAssertEqualObjects(city2, @"Los Angeles", @"GetObject return the wrong object");
                done = 1;
            } failure:^(ASRemoteIndex *index, NSArray *objectIDs, NSString *errorMessage) {
                XCTFail("@Error during getObjects: %@", errorMessage);
                done = 1;
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            done = 1;
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObjects: %@", errorMessage);
        done = 1;
    }];
    
    [self.httpRequestOperationManager.operationQueue waitUntilAllOperationsAreFinished];
    while (done == 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate date]];
    }
}

@end
