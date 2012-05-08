/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "JRAccounts.h"

@implementation JRAccounts
{
    NSInteger _accountsId;
    NSString *_domain;
    BOOL _primary;
    NSString *_userid;
    NSString *_username;
}
@dynamic accountsId;
@dynamic domain;
@dynamic primary;
@dynamic userid;
@dynamic username;

- (NSInteger)accountsId
{
    return _accountsId;
}

- (void)setAccountsId:(NSInteger)newAccountsId
{
    [self.dirtyPropertySet addObject:@"accountsId"];

    _accountsId = newAccountsId;
}

- (NSString *)domain
{
    return _domain;
}

- (void)setDomain:(NSString *)newDomain
{
    [self.dirtyPropertySet addObject:@"domain"];

    if (!newDomain)
        _domain = [NSNull null];
    else
        _domain = [newDomain copy];
}

- (BOOL)primary
{
    return _primary;
}

- (void)setPrimary:(BOOL)newPrimary
{
    [self.dirtyPropertySet addObject:@"primary"];

    _primary = newPrimary;
}

- (NSString *)userid
{
    return _userid;
}

- (void)setUserid:(NSString *)newUserid
{
    [self.dirtyPropertySet addObject:@"userid"];

    if (!newUserid)
        _userid = [NSNull null];
    else
        _userid = [newUserid copy];
}

- (NSString *)username
{
    return _username;
}

- (void)setUsername:(NSString *)newUsername
{
    [self.dirtyPropertySet addObject:@"username"];

    if (!newUsername)
        _username = [NSNull null];
    else
        _username = [newUsername copy];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.captureObjectPath = @"/profiles/profile/accounts";
    }
    return self;
}

+ (id)accounts
{
    return [[[JRAccounts alloc] init] autorelease];
}

- (id)copyWithZone:(NSZone*)zone
{
    JRAccounts *accountsCopy =
                [[JRAccounts allocWithZone:zone] init];

    accountsCopy.accountsId = self.accountsId;
    accountsCopy.domain = self.domain;
    accountsCopy.primary = self.primary;
    accountsCopy.userid = self.userid;
    accountsCopy.username = self.username;

    return accountsCopy;
}

+ (id)accountsObjectFromDictionary:(NSDictionary*)dictionary
{
    JRAccounts *accounts =
        [JRAccounts accounts];

    accounts.accountsId = [(NSNumber*)[dictionary objectForKey:@"id"] intValue];
    accounts.domain = [dictionary objectForKey:@"domain"];
    accounts.primary = [(NSNumber*)[dictionary objectForKey:@"primary"] boolValue];
    accounts.userid = [dictionary objectForKey:@"userid"];
    accounts.username = [dictionary objectForKey:@"username"];

    return accounts;
}

- (NSDictionary*)dictionaryFromAccountsObject
{
    NSMutableDictionary *dict = 
        [NSMutableDictionary dictionaryWithCapacity:10];

    if (self.accountsId)
        [dict setObject:[NSNumber numberWithInt:self.accountsId] forKey:@"id"];

    if (self.domain && self.domain != [NSNull null])
        [dict setObject:self.domain forKey:@"domain"];
    else
        [dict setObject:[NSNull null] forKey:@"domain"];

    if (self.primary)
        [dict setObject:[NSNumber numberWithBool:self.primary] forKey:@"primary"];

    if (self.userid && self.userid != [NSNull null])
        [dict setObject:self.userid forKey:@"userid"];
    else
        [dict setObject:[NSNull null] forKey:@"userid"];

    if (self.username && self.username != [NSNull null])
        [dict setObject:self.username forKey:@"username"];
    else
        [dict setObject:[NSNull null] forKey:@"username"];

    return dict;
}

- (void)updateLocallyFromNewDictionary:(NSDictionary*)dictionary
{
    if ([dictionary objectForKey:@"id"])
        _accountsId = [(NSNumber*)[dictionary objectForKey:@"id"] intValue];

    if ([dictionary objectForKey:@"domain"])
        _domain = [dictionary objectForKey:@"domain"];

    if ([dictionary objectForKey:@"primary"])
        _primary = [(NSNumber*)[dictionary objectForKey:@"primary"] boolValue];

    if ([dictionary objectForKey:@"userid"])
        _userid = [dictionary objectForKey:@"userid"];

    if ([dictionary objectForKey:@"username"])
        _username = [dictionary objectForKey:@"username"];
}

- (void)replaceLocallyFromNewDictionary:(NSDictionary*)dictionary
{
    _accountsId = [(NSNumber*)[dictionary objectForKey:@"id"] intValue];
    _domain = [dictionary objectForKey:@"domain"];
    _primary = [(NSNumber*)[dictionary objectForKey:@"primary"] boolValue];
    _userid = [dictionary objectForKey:@"userid"];
    _username = [dictionary objectForKey:@"username"];
}

- (void)updateObjectOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate withContext:(NSObject *)context
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    if ([self.dirtyPropertySet containsObject:@"accountsId"])
        [dict setObject:[NSNumber numberWithInt:self.accountsId] forKey:@"id"];

    if ([self.dirtyPropertySet containsObject:@"domain"])
        [dict setObject:self.domain forKey:@"domain"];

    if ([self.dirtyPropertySet containsObject:@"primary"])
        [dict setObject:[NSNumber numberWithBool:self.primary] forKey:@"primary"];

    if ([self.dirtyPropertySet containsObject:@"userid"])
        [dict setObject:self.userid forKey:@"userid"];

    if ([self.dirtyPropertySet containsObject:@"username"])
        [dict setObject:self.username forKey:@"username"];

    NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     self, @"captureObject",
                                                     delegate, @"delegate",
                                                     context, @"callerContext", nil];

    [JRCaptureInterface updateCaptureObject:dict
                                     withId:0
                                     atPath:self.captureObjectPath
                                  withToken:[JRCaptureData accessToken]
                                forDelegate:self
                                withContext:newContext];
}

- (void)replaceObjectOnCaptureForDelegate:(id<JRCaptureObjectDelegate>)delegate withContext:(NSObject *)context
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:[NSNumber numberWithInt:self.accountsId] forKey:@"id"];
    [dict setObject:self.domain forKey:@"domain"];
    [dict setObject:[NSNumber numberWithBool:self.primary] forKey:@"primary"];
    [dict setObject:self.userid forKey:@"userid"];
    [dict setObject:self.username forKey:@"username"];

    NSDictionary *newContext = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     self, @"captureObject",
                                                     delegate, @"delegate",
                                                     context, @"callerContext", nil];

    [JRCaptureInterface replaceCaptureObject:dict
                                      withId:0
                                      atPath:self.captureObjectPath
                                   withToken:[JRCaptureData accessToken]
                                 forDelegate:self
                                 withContext:newContext];
}

- (void)dealloc
{
    [_domain release];
    [_userid release];
    [_username release];

    [super dealloc];
}
@end