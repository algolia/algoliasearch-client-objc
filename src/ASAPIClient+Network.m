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

#import "ASAPIClient+Network.h"

@implementation ASAPIClient (Network)

+(NSString *) urlEncode:(NSString*)originalStr {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)originalStr, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 ));
}

-(void) cancelQueries:(NSString*)method path:(NSString*)path
{
    NSUInteger count = [self.searchOperationManagers count];
    for (NSUInteger i = 0; i < count; ++i) {
        AFHTTPRequestOperationManager *httpRequestOperationManager = (self.searchOperationManagers)[i];
        for (AFHTTPRequestOperation *operation in httpRequestOperationManager.operationQueue.operations) {
            if ([operation.request.URL.path isEqualToString:path]) {
                if ([operation.request.HTTPMethod isEqualToString:method]) {
                    [operation cancel];
                }
            }
        }
    }
    count = [self.writeOperationManagers count];
    for (NSUInteger i = 0; i < count; ++i) {
        AFHTTPRequestOperationManager *httpRequestOperationManager = (self.writeOperationManagers)[i];
        for (AFHTTPRequestOperation *operation in httpRequestOperationManager.operationQueue.operations) {
            if ([operation.request.URL.path isEqualToString:path]) {
                if ([operation.request.HTTPMethod isEqualToString:method]) {
                    [operation cancel];
                }
            }
        }
    }
}

-(void) performHTTPQuery: (NSString*)path method:(NSString*)method body:(NSDictionary*)body managers:(NSArray*)managers index:(NSUInteger)index timeout:(NSTimeInterval)timeout
                 success:(void(^)(id JSON))success failure:(void(^)(NSString *errorMessage))failure
{
    assert(index < [managers count]);
    AFHTTPRequestOperationManager *httpRequestOperationManager = (managers)[index];
    NSMutableURLRequest *request = [httpRequestOperationManager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:httpRequestOperationManager.baseURL] absoluteString]  parameters:body error:nil];
    [httpRequestOperationManager.requestSerializer setTimeoutInterval:timeout];
    
    AFHTTPRequestOperation *operation = [httpRequestOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        if ((operation.response.statusCode / 100) == 2) {
            success(JSON);
        } else {
            failure(@"No error message");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 400) {
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            failure([NSString stringWithFormat:@"Bad request argument: %@", JSON[@"message"]]);
        } else if (operation.response.statusCode == 403) {
            failure(@"Invalid Application-ID or API-Key");
        } else if(operation.response.statusCode == 404) {
            failure(@"Resource does not exist");
        } else {
            if ((index + 1) < [managers count]) {
                [self performHTTPQuery:path method:method body:body index:(index + 1) timeout:(timeout + 10) success:success failure:failure];
            } else {
                failure(error.description);
            }
        }
    }];
    
    [httpRequestOperationManager.operationQueue addOperation:operation];
}

@end
