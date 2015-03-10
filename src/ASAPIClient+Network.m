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
    NSUInteger count = [self.operationManagers count];
    for (NSUInteger i = 0; i < count; ++i) {
        AFHTTPRequestOperationManager *httpRequestOperationManager = (self.operationManagers)[i];
        for (AFHTTPRequestOperation *operation in httpRequestOperationManager.operationQueue.operations) {
            if ([operation.request.URL.path isEqualToString:path]) {
                if ([operation.request.HTTPMethod isEqualToString:method]) {
                    [operation cancel];
                }
            }
        }
    }
}

-(void) performHTTPQuery:(NSString*)path method:(NSString*)method body:(NSDictionary*)body index:(NSUInteger)index timeout:(NSTimeInterval)timeout
                 success:(void(^)(id JSON))success failure:(void(^)(NSString *errorMessage))failure
{
    assert(index < [self.operationManagers count]);
    AFHTTPRequestOperationManager *httpRequestOperationManager = (self.operationManagers)[index];
    NSMutableURLRequest *request = [httpRequestOperationManager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:httpRequestOperationManager.baseURL] absoluteString]  parameters:body error:nil];
    [httpRequestOperationManager.requestSerializer setTimeoutInterval:timeout];
    AFHTTPRequestOperation *operation = [httpRequestOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id JSON) {
        if (operation.response.statusCode == 200 || operation.response.statusCode == 201) {
            success(JSON);
        } else if (operation.response.statusCode == 400) {
            failure(@"Bad request argument");
        } else if (operation.response.statusCode == 403) {
            failure(@"Invalid Application-ID or API-Key");
        } else if(operation.response.statusCode == 404) {
            failure(@"Resource does not exist");
        } else {
            if ((index + 1) < [self.operationManagers count]) {
                [self performHTTPQuery:path method:method body:body index:(index + 1) timeout:timeout success:success failure:failure];
            } else {
                if (JSON != nil) {
                    NSDictionary *json = (NSDictionary*)JSON;
                    failure(json[@"message"]);
                } else {
                    failure(@"No error message");
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ((index + 1) < [self.operationManagers count]) {
            [self performHTTPQuery:path method:method body:body index:(index + 1) timeout:timeout success:success failure:failure];
        } else {
            failure(error.localizedDescription);
        }
    }];
    [httpRequestOperationManager.operationQueue addOperation:operation];
}
@end
