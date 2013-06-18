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

#import "ASAPIClient+Network.h"

@implementation ASAPIClient (Network)

+(NSString *) urlEncode:(NSString*)originalStr {
    return [originalStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void) performHTTPQuery:(NSString*)path method:(NSString*)method body:(NSDictionary*)body index:(NSUInteger)index
                 success:(void(^)(id JSON))success failure:(void(^)(NSString *errorMessage))failure
{
    assert(index < [self.clients count]);
    AFHTTPClient *httpClient = [self.clients objectAtIndex:index];
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:path parameters:body];
    [request setValue:self.apiKey forHTTPHeaderField:@"X-Algolia-API-Key"];
    [request setValue:self.applicationID forHTTPHeaderField:@"X-Algolia-Application-Id"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (index < [self.hostnames count]) {
            if (response.statusCode == 403) {
                failure(@"Invalid Application-ID or API-Key");
            } else if(response.statusCode == 404) {
                failure(@"Resource does not exist");
            } else {
                if ((index + 1) < [self.clients count]) {
                    [self performHTTPQuery:path method:method body:body index:(index + 1) success:success failure:failure];
                } else {
                    if (JSON != nil) {
                        NSDictionary *json = (NSDictionary*)JSON;
                        failure([json objectForKey:@"message"]);
                    } else {
                        failure(error.localizedDescription);
                    }
                }
            }
        }
    }];
    [operation start];
}
@end
