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
    
    NSString* appID = [[NSProcessInfo processInfo] environment][@"ALGOLIA_APPLICATION_ID"];
    NSString* apiKey = [[NSProcessInfo processInfo] environment][@"ALGOLIA_API_KEY"];
    self.client = [ASAPIClient apiClientWithApplicationID :appID apiKey:apiKey];
    self.index = [self.client getIndex:@"algol?à-objc"];
    self.httpRequestOperationManager = (self.client.operationManagers)[0];
    
    XCTestExpectation *expecatation = [self expectationWithDescription:@"Delete index"];
    [self.client deleteIndex:@"algol?à-objc" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        [expecatation fulfill];
    } failure:nil];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)tearDown
{
    [super tearDown];
    
    XCTestExpectation *expecatation = [self expectationWithDescription:@"Delete index"];
    [self.client deleteIndex:@"algol?à-objc" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        [expecatation fulfill];
    } failure:nil];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testAdd
{
    XCTestExpectation *expecation = [self expectationWithDescription:@"testAdd"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
            ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
            [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                [expecation fulfill];
            } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                XCTFail("@Error during search: %@", errorMessage);
                [expecation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expecation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expecation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testAddWithObjectID
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAddWithObjectID"];
    NSDictionary *obj = @{@"city": @"San Francisco"};
    
    [self.index addObject:obj withObjectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *object, NSString *objectID, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
            [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                XCTAssertEqualObjects(@"San Francisco", city, "Get object return a bad object");
                [expectation fulfill];
            } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                XCTFail("@Error during getObject: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString* objectID, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testDelete
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testDelete"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index deleteObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Wrong number of object in the index");
                    [expectation fulfill];
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testGet
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGet"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
            [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                XCTAssertEqualObjects(@"San Francisco", city, "Get object return a bad object");
                [expectation fulfill];
            }
            failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                XCTFail("@Error during getObject: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testPartialUpdateObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPartialUpdateObject"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index partialUpdateObject:@{@"city": @"Los Angeles"} objectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
                [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                    NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",result[@"initial"]];
                    XCTAssertEqualObjects(@"Los Angeles", city, "Partial update is not applied");
                    XCTAssertEqualObjects(@"SF", initial, "Partial update failed");
                    [expectation fulfill];
                }
                failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during partialUpdateObject: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testSaveObject
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSaveObject"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index saveObject:@{@"city": @"Los Angeles"} objectID:@"a/go/?à" success:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
                [self.index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                    XCTAssertEqualObjects(@"Los Angeles", city, "Save object is not applied");
                    XCTAssertTrue(result[@"initial"] == nil, "Save object failed");
                    [expectation fulfill];
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSDictionary *partialObject, NSString *objectID, NSString *errorMessage) {
            XCTFail("@Error during partialUpdateObject: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testClear
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClear"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [self.index clearIndex:^(ASRemoteIndex *index, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Clear index failed");
                    [expectation fulfill];
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
            XCTFail("@Error during clearIndex: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testSettings
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSettings"];
    
    [self.index setSettings:@{@"attributesToRetrieve": @[@"name"]} success:^(ASRemoteIndex *index, NSDictionary *settings, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [self.index getSettings:^(ASRemoteIndex *index, NSDictionary *result) {
                NSMutableString *attributesToRetrieve = [NSMutableString stringWithFormat:@"%@",result[@"attributesToRetrieve"][0]];
                XCTAssertEqualObjects(attributesToRetrieve, @"name", @"set settings failed");
                [expectation fulfill];
            } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                XCTFail("@Error during getSettings: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *settings, NSString *errorMessage) {
        XCTFail("@Error during setSettings: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testIndexACL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testIndexACL"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index addUserKey:@[@"search"] success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                [index getUserKeyACL:result[@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    [index updateUserKey:result[@"value"] withACL:@[@"addObject"] success:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:5.0]; // wait the backend
                        [index getUserKeyACL:result[@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [index deleteUserKey:result[@"value"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                                [index listUserKeys:^(ASRemoteIndex *index, NSDictionary *result) {
                                    NSArray *keys = result[@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:keys[i][@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    [expectation fulfill];
                                } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    [expectation fulfill];
                                }];
                            } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                [expectation fulfill];
                            }];
                        } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKeyACL: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
 
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testIndexACLWithValidity
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testIndexACLWithValidity"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index addUserKey:@[@"search"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASRemoteIndex *index, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                [index getUserKeyACL:result[@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",result[@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [index updateUserKey:result[@"value"] withACL:@[@"addObject"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:5.0]; // wait the backend
                        [index getUserKeyACL:result[@"key"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [index deleteUserKey:result[@"value"] success:^(ASRemoteIndex *index, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                                [index listUserKeys:^(ASRemoteIndex *index, NSDictionary *result) {
                                    NSArray *keys = result[@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:keys[i][@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    [expectation fulfill];
                                } failure:^(ASRemoteIndex *index, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    [expectation fulfill];
                                }];
                            } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                [expectation fulfill];
                            }];
                        } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASRemoteIndex *index, NSString *key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKeyACL: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testBrowse
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBrowse"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index browse:0 success:^(ASRemoteIndex *index, NSUInteger page, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                [expectation fulfill];
            } failure:^(ASRemoteIndex *index, NSUInteger page, NSString *errorMessage) {
                XCTFail("@Error during browse: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testBrowseWithHitsPerPage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBrowseWithHitsPerPage"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index browse:0 hitsPerPage:1 success:^(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                [expectation fulfill];
            } failure:^(ASRemoteIndex *index, NSUInteger page, NSUInteger hitsPerPage, NSString *errorMessage) {
                XCTFail("@Error during browse: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testListIndexes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testListIndexes"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client listIndexes:^(ASAPIClient *client, NSDictionary *result) {
                NSArray *indexes = result[@"items"];
                BOOL found = false;
                for (int i = 0; i < [indexes count]; i++) {
                    if ([index.indexName isEqualToString:indexes[i][@"name"]]) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    XCTFail("List indexes failed");
                }
                [expectation fulfill];
            } failure:^(ASAPIClient *client, NSString *errorMessage) {
                XCTFail("@Error during listIndexes: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testMoveIndex
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMoveIndex"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client moveIndex:@"algol?à-objc" to:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
                [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                    ASRemoteIndex *index2 = [self.client getIndex:@"algol?à-objc2"];
                    ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                    [index2 search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                        NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                        XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                        [expectation fulfill];
                    } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                        XCTFail("@Error during search: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                    XCTFail("@Error during waitTask: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
                XCTFail("@Error during moveIndex: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    XCTestExpectation *deleteExpectation = [self expectationWithDescription:@"Delete index"];
    [self.client deleteIndex:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        [deleteExpectation fulfill];
    } failure:nil];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testCpoyIndex
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCpoyIndex"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client copyIndex:@"algol?à-objc" to:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSDictionary *result) {
                [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                    ASRemoteIndex *index2 = [self.client getIndex:@"algol?à-objc2"];
                    ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                    [index2 search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                        NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                        XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                        ASRemoteIndex *indexOrigin = [self.client getIndex:@"algol?à-objc"];
                        query = [[ASQuery alloc] initWithFullTextQuery:@""];
                        [indexOrigin search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                            NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                            XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                            [expectation fulfill];
                        } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                            XCTFail("@Error during search: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                        XCTFail("@Error during search: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                    XCTFail("@Error during waitTask: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASAPIClient *client, NSString *srcIndexName, NSString *dstIndexName, NSString *errorMessage) {
                XCTFail("@Error during moveIndex: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    XCTestExpectation *deleteExpectation = [self expectationWithDescription:@"Delete index"];
    [self.client deleteIndex:@"algol?à-objc2" success:^(ASAPIClient *client, NSString *indexName, NSDictionary *result) {
        [deleteExpectation fulfill];
    } failure:nil];
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

-(void)testGetLogs
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetLogs"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client getLogs:^(ASAPIClient *client, NSDictionary *result) {
                XCTAssertNotEqual(0, [result[@"logs"] count], "Get logs failed");
                [expectation fulfill];
            } failure:^(ASAPIClient *client, NSString *errorMessage) {
                XCTFail("@Error during getLogs: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

-(void)testGetLogsWithOffset
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetLogsWithOffset"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client getLogsWithOffset:0 length:1 success:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSDictionary *result) {
                XCTAssertEqual(1, [result[@"logs"] count], "Get logs failed");
                [expectation fulfill];
            } failure:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString *errorMessage) {
                XCTFail("@Error during getLogs: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

-(void)testGetLogsWithType
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetLogsWithType"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client getLogsWithType:0 length:1 type:@"error" success:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSDictionary *result) {
                XCTAssertEqual(1, [result[@"logs"] count], "Get logs failed");
                [expectation fulfill];
            } failure:^(ASAPIClient *client, NSUInteger offset, NSUInteger length, NSString* type, NSString *errorMessage) {
                XCTFail("@Error during getLogs: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testClientACL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientACL"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    [_client updateUserKey:result[@"value"] withACL:@[@"addObject"] success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:5.0]; // wait the backend
                        [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:result[@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = result[@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:keys[i][@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    [expectation fulfill];
                        } failure:^(ASAPIClient *client, NSString *errorMessage) {
                            XCTFail("@Error during listUserKeys: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                        XCTFail("@Error during deleteUserKey: %@", errorMessage);
                        [expectation fulfill];
                    }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testClientACLWithIndexes
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientACLWithIndexes"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] withIndexes:@[@"algol?à-objc"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSDictionary *result) {
                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",result[@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [_client updateUserKey:result[@"value"] withACL:@[@"addObject"] withIndexes:@[@"algol?à-objc"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSArray *indexes, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:5.0]; // wait the backend
                        [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:result[@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = result[@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:keys[i][@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                    XCTFail("DeleteUserKey failed");
                                }
                                    [expectation fulfill];
                                } failure:^(ASAPIClient *client, NSString *errorMessage) {
                                XCTFail("@Error during listUserKeys: %@", errorMessage);
                                [expectation fulfill];
                                }];
                            } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                [expectation fulfill];
                            }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSArray *indexes, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSArray *indexes, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testClientACLWithValidity
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testClientACLWithValidity"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [_client addUserKey:@[@"search"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSArray *acls, NSDictionary *result) {
                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                    NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                    NSMutableString *validity = [NSMutableString stringWithFormat:@"%@",result[@"validity"]];
                    XCTAssertEqualObjects(acl, @"search", @"add user key failed");
                    XCTAssertNotEqualObjects(validity, @"0", @"add user key failed");
                    [_client updateUserKey:result[@"value"] withACL:@[@"addObject"] withValidity:3000 maxQueriesPerIPPerHour:42 maxHitsPerQuery:42 success:^(ASAPIClient *client, NSString *key, NSArray *acls, NSDictionary *result) {
                        [NSThread sleepForTimeInterval:5.0]; // wait the backend
                        [client getUserKeyACL:result[@"key"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                            NSMutableString *acl = [NSMutableString stringWithFormat:@"%@",result[@"acl"][0]];
                            XCTAssertEqualObjects(acl, @"addObject", @"add user key failed");
                            [client deleteUserKey:result[@"value"] success:^(ASAPIClient *client, NSString *key, NSDictionary *result) {
                                [NSThread sleepForTimeInterval:5.0]; // wait the backend
                                [client listUserKeys:^(ASAPIClient *client, NSDictionary *result) {
                                    NSArray *keys = result[@"keys"];
                                    BOOL found = false;
                                    for (int i = 0; i < [keys count]; i++) {
                                        if ([key isEqualToString:keys[i][@"value"]]) {
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) {
                                        XCTFail("DeleteUserKey failed");
                                    }
                                    [expectation fulfill];
                                } failure:^(ASAPIClient *client, NSString *errorMessage) {
                                    XCTFail("@Error during listUserKeys: %@", errorMessage);
                                    [expectation fulfill];
                                }];
                            } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                                XCTFail("@Error during deleteUserKey: %@", errorMessage);
                                [expectation fulfill];
                            }];
                        } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                            XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                            [expectation fulfill];
                        }];
                    } failure:^(ASAPIClient *client, NSString* key, NSArray *acls, NSString *errorMessage) {
                        XCTFail("@Error during updateUserKey: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASAPIClient *client, NSString *key, NSString *errorMessage) {
                    XCTFail("@Error during getUserKeyACL: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASAPIClient *client, NSArray *acls, NSString *errorMessage) {
                XCTFail("@Error during addUserKey: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testDeleteObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testDeleteObjects"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index deleteObjects:@[@"a/go/?à", @"à/go/?à"] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
                [self.index search:query success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *result) {
                    NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"nbHits"]];
                    XCTAssertEqualObjects(nbHits, @"0", @"Wrong number of object in the index");
                    [expectation fulfill];
                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                    XCTFail("@Error during search: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObjects: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObjects: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testSaveObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSaveObjects"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index saveObjects:@[@{@"city": @"Los Angeles", @"objectID": @"a/go/?à"}, @{@"city": @"San Francisco", @"objectID": @"à/go/?à"}] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                [index getObject:@"à/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                    XCTAssertEqualObjects(city, @"San Francisco", @"saveObjects failed");
                    [index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                        NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                        XCTAssertEqualObjects(city, @"Los Angeles", @"saveObjects failed");
                        [expectation fulfill];
                    } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                        XCTFail("@Error during getObject n°2: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testPartialUpdateObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testPartialUpdateObjects"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"initial": @"SF", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"initial": @"LA", @"objectID": @"à/go/?à"};
    
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index partialUpdateObjects:@[@{@"city": @"Los Angeles", @"objectID": @"a/go/?à"}, @{@"city": @"San Francisco", @"objectID": @"à/go/?à"}] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
            [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
                [index getObject:@"à/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                    NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                    NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",result[@"initial"]];
                    XCTAssertEqualObjects(city, @"San Francisco", @"partialUpdateObjects failed");
                    XCTAssertEqualObjects(initial, @"LA", @"saveObjects failed");
                    [index getObject:@"a/go/?à" success:^(ASRemoteIndex *index, NSString *objectID, NSDictionary *result) {
                        NSMutableString *city = [NSMutableString stringWithFormat:@"%@",result[@"city"]];
                        NSMutableString *initial = [NSMutableString stringWithFormat:@"%@",result[@"initial"]];
                        XCTAssertEqualObjects(city, @"Los Angeles", @"partialUpdateObjects failed");
                        XCTAssertEqualObjects(initial, @"SF", @"saveObjects failed");
                        [expectation fulfill];
                    } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                        XCTFail("@Error during getObject n°2: %@", errorMessage);
                        [expectation fulfill];
                    }];
                } failure:^(ASRemoteIndex *index, NSString *objectID, NSString *errorMessage) {
                    XCTFail("@Error during getObject: %@", errorMessage);
                    [expectation fulfill];
                }];
            } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
                XCTFail("@Error during waitTask: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
            XCTFail("@Error during deleteObject: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testMultipleQueries
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMultipleQueries"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    
    [self.index addObject:obj success:^(ASRemoteIndex *index, NSDictionary *object, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            XCTAssertEqualObjects(result[@"status"], @"published", "Wait task failed");
            ASQuery *query = [[ASQuery alloc] initWithFullTextQuery:@""];
            [_client multipleQueries:@[@{@"indexName":@"algol?à-objc", @"query": query}] success:^(ASAPIClient *client, NSArray *queries, NSDictionary *result) {
                NSMutableString *nbHits = [NSMutableString stringWithFormat:@"%@",result[@"results"][0][@"nbHits"]];
                XCTAssertEqualObjects(nbHits, @"1", @"Wrong number of object in the index");
                [expectation fulfill];
            } failure:^(ASAPIClient *client, NSArray *queries, NSString *errorMessage) {
                XCTFail("@Error during multipleQueries: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSDictionary *object, NSString *errorMessage) {
        XCTFail("@Error during addObject: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testGetObjects
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetObjects"];
    NSDictionary *obj = @{@"city": @"San Francisco", @"objectID": @"a/go/?à"};
    NSDictionary *obj2 = @{@"city": @"Los Angeles", @"objectID": @"à/go/?à"};
    
    [self.index addObjects:@[obj, obj2] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
        [index waitTask:result[@"taskID"] success:^(ASRemoteIndex *index, NSString *taskID, NSDictionary *result) {
            [index getObjects:@[@"a/go/?à", @"à/go/?à"] success:^(ASRemoteIndex *index, NSArray *objects, NSDictionary *result) {
                NSMutableString *city1 = [NSMutableString stringWithFormat:@"%@",result[@"results"][0][@"city"]];
                NSMutableString *city2 = [NSMutableString stringWithFormat:@"%@",result[@"results"][1][@"city"]];
                XCTAssertEqualObjects(city1, @"San Francisco", @"GetObject return the wrong object");
                XCTAssertEqualObjects(city2, @"Los Angeles", @"GetObject return the wrong object");
                [expectation fulfill];
            } failure:^(ASRemoteIndex *index, NSArray *objectIDs, NSString *errorMessage) {
                XCTFail("@Error during getObjects: %@", errorMessage);
                [expectation fulfill];
            }];
        } failure:^(ASRemoteIndex *index, NSString *taskID, NSString *errorMessage) {
            XCTFail("@Error during waitTask: %@", errorMessage);
            [expectation fulfill];
        }];
    } failure:^(ASRemoteIndex *index, NSArray *objects, NSString *errorMessage) {
        XCTFail("@Error during addObjects: %@", errorMessage);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
}

@end
