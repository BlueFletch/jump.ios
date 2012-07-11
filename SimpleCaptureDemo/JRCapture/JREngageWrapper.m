


#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#import "JREngageWrapper.h"
#import "JRCaptureData.h"
#import "JRCaptureUser+Extras.h"
#import "JREngage+CustomInterface.h"
#import "JSONKit.h"

@interface JREngageWrapperErrorWriter : NSObject
@end

@implementation JREngageWrapperErrorWriter
+ (NSError *)invalidPayloadError:(NSObject *)payload
{
    return [JRCaptureError errorFromResult:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"error", @"stat",
                                                     @"invalid_endpoint_response", @"error",
                                                     [NSString stringWithFormat:@"The Capture Mobile Endpoint Url did not have the expected data: %@", [payload description]], @"error_description",
                                                     [NSNumber numberWithInteger:JRCaptureWrappedEngageErrorInvalidEndpointPayload], @"code", nil]];
}
@end

typedef enum
{
    JREngageDialogStateAuthentication,
    JREngageDialogStateSharing,
} JREngageDialogState;


@interface JREngageWrapper ()
@property (retain) JRNativeSigninViewController *nativeSigninViewController;
@property (retain) id<JRCaptureSigninDelegate> delegate;
@property          JREngageDialogState dialogState;
@end

@implementation JREngageWrapper
@synthesize nativeSigninViewController;
@synthesize delegate;
@synthesize dialogState;

static JREngageWrapper *singleton = nil;

- (JREngageWrapper *)init
{
    if ((self = [super init])) { }

    return self;
}

+ (JREngageWrapper *)singletonInstance
{
    if (singleton == nil) {
        singleton = [((JREngageWrapper*)[super allocWithZone:NULL]) init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self singletonInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release { }

- (id)autorelease
{
    return self;
}

+ (void)configureEngageWithCaptureMobileEndpointUrlAndAppId:(NSString *)appId
{
    [JREngage setEngageAppId:appId tokenUrl:nil andDelegate:[JREngageWrapper singletonInstance]];
}

+ (void)startAuthenticationDialogWithNativeSignin:(JRConventionalSigninType)nativeSigninType
                      andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                      forDelegate:(id <JRCaptureSigninDelegate>)delegate
{
    [JREngage updateTokenUrl:[JRCaptureData captureMobileEndpointUrl]];

    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];

    NSMutableDictionary *expandedCustomInterfaceOverrides =
                                [NSMutableDictionary dictionaryWithDictionary:customInterfaceOverrides];

    if (nativeSigninType != JRConventionalSigninNone)
    {
        //kJRCaptureNativeSigninTitleString
        //kJRCaptureNativeSigninTitleView

        NSString *nativeSigninTitleString =
                         ([expandedCustomInterfaceOverrides objectForKey:kJRCaptureNativeSigninTitleString] ?
                                 [expandedCustomInterfaceOverrides objectForKey:kJRCaptureNativeSigninTitleString] :
                                 (nativeSigninType == JRConventionalSigninEmailPassword ?
                                        @"Sign In With Your Email and Password" :
                                        @"Sign In With Your Username and Password"));

        if (![expandedCustomInterfaceOverrides objectForKey:kJRProviderTableSectionHeaderTitleString])
            [expandedCustomInterfaceOverrides setObject:@"Sign In With a Social Provider"
                                                 forKey:kJRProviderTableSectionHeaderTitleString];

        [[JREngageWrapper singletonInstance] setNativeSigninViewController:
                [JRNativeSigninViewController
                        nativeSigninViewControllerWithNativeSigninType:nativeSigninType
                                                           titleString:nativeSigninTitleString
                                                             titleView:[expandedCustomInterfaceOverrides
                                                                               objectForKey:kJRCaptureNativeSigninTitleView]
                                                              delegate:[JREngageWrapper singletonInstance]]];

        [expandedCustomInterfaceOverrides setObject:[[JREngageWrapper singletonInstance] nativeSigninViewController].view
                                             forKey:kJRProviderTableHeaderView];
    }

    [JREngage showAuthenticationDialogWithCustomInterfaceOverrides:
                      [NSDictionary dictionaryWithDictionary:expandedCustomInterfaceOverrides]];
}

+ (void)startAuthenticationDialogOnProvider:(NSString *)provider
               withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                forDelegate:(id <JRCaptureSigninDelegate>)delegate
{
    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateAuthentication];

    [JREngage showAuthenticationDialogForProvider:provider withCustomInterfaceOverrides:customInterfaceOverrides];
}

+ (void)startSocialPublishingDialogWithActivity:(JRActivityObject *)activity
                   withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                    forDelegate:(id <JRCaptureSocialSharingDelegate>)delegate
{
    [[JREngageWrapper singletonInstance] setDelegate:delegate];
    [[JREngageWrapper singletonInstance] setDialogState:JREngageDialogStateSharing];

    [JREngage showSharingDialogWithActivity:activity withCustomInterfaceOverrides:customInterfaceOverrides];
}

- (void)engageLibraryTearDown
{
    [JREngage updateTokenUrl:[JRCaptureData captureMobileEndpointUrl]];
    [self setNativeSigninViewController:nil];
}

- (void)authenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    if ([delegate respondsToSelector:@selector(captureAuthenticationDidFailWithError:)])
        [delegate captureAuthenticationDidFailWithError:error];

    [self engageLibraryTearDown];
}

- (void)authenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    if ([delegate respondsToSelector:@selector(engageAuthenticationDidFailWithError:forProvider:)])
        [delegate engageAuthenticationDidFailWithError:error forProvider:provider];

    [self engageLibraryTearDown];
}

- (void)authenticationDidNotComplete
{
    if ([delegate respondsToSelector:@selector(engageSigninDidNotComplete)])
        [delegate engageSigninDidNotComplete];

    [self engageLibraryTearDown];
}

- (void)authenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider
{
    NSString     *payload     = [[[NSString alloc] initWithData:tokenUrlPayload encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *payloadDict = [payload objectFromJSONString];

    DLog(@"%@", payload);

    if (!payloadDict)
        return [self authenticationCallToTokenUrl:tokenUrl
                                   didFailWithError:[JREngageWrapperErrorWriter invalidPayloadError:payload]
                                        forProvider:provider];

    if (![(NSString *)[payloadDict objectForKey:@"stat"] isEqualToString:@"ok"])
        return [self authenticationCallToTokenUrl:tokenUrl
                                   didFailWithError:[JREngageWrapperErrorWriter invalidPayloadError:payload]
                                        forProvider:provider];

    NSString *accessToken   = [payloadDict objectForKey:@"access_token"];
    NSString *creationToken = [payloadDict objectForKey:@"creation_token"];
    BOOL      isNew         = [(NSNumber*)[payloadDict objectForKey:@"is_new"] boolValue];
    BOOL      notYetCreated = creationToken ? YES: NO;

    NSDictionary *captureProfile = [payloadDict objectForKey:@"capture_user"];

    if (!captureProfile || !(accessToken || creationToken))
        return [self authenticationCallToTokenUrl:tokenUrl
                                   didFailWithError:[JREngageWrapperErrorWriter invalidPayloadError:payload]
                                        forProvider:provider];

    JRCaptureUser *captureUser = [JRCaptureUser captureUserObjectFromDictionary:captureProfile];

    if (!captureUser)
        return [self authenticationCallToTokenUrl:tokenUrl
                                   didFailWithError:[JREngageWrapperErrorWriter invalidPayloadError:payload]
                                        forProvider:provider];

    NSString *uuid = [captureUser performSelector:NSSelectorFromString(@"uuid")];

    if (accessToken)
        [JRCaptureData setAccessToken:accessToken forUser:uuid];
    else if (creationToken)
        [JRCaptureData setCreationToken:creationToken];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    JRCaptureRecordStatus recordStatus;

    if (notYetCreated)
        recordStatus = JRCaptureRecordMissingRequiredFields;
    else if (isNew)
        recordStatus = JRCaptureRecordNewlyCreated;
    else
        recordStatus = JRCaptureRecordExists;

    if ([delegate respondsToSelector:@selector(captureAuthenticationDidSucceedForUser:status:)])
        [delegate captureAuthenticationDidSucceedForUser:captureUser status:recordStatus];

    [self engageLibraryTearDown];
}

- (void)authenticationDidSucceedForUser:(NSDictionary *)auth_info forProvider:(NSString *)provider
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    if ([delegate respondsToSelector:@selector(engageSigninDidSucceedForUser:forProvider:)])
            [delegate engageSigninDidSucceedForUser:auth_info forProvider:provider];
}

- (void)engageDialogDidFailToShowWithError:(NSError *)error
{
    if (dialogState == JREngageDialogStateAuthentication)
    {
        if ([delegate respondsToSelector:@selector(engageSigninDialogDidFailToShowWithError:)])
            [delegate engageSigninDialogDidFailToShowWithError:error];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(engageSocialSharingDialogDidFailToShowWithError:)])
            [(id<JRCaptureSocialSharingDelegate>)delegate engageSocialSharingDialogDidFailToShowWithError:error];
    }

    [self engageLibraryTearDown];
}

- (void)socialSharingDidComplete
{
    if ([delegate respondsToSelector:@selector(engageSocialSharingDidComplete)])
        [(id<JRCaptureSocialSharingDelegate>)delegate engageSocialSharingDidComplete];

    [self engageLibraryTearDown];
}

- (void)socialSharingDidNotCompletePublishing
{
    if ([delegate respondsToSelector:@selector(engageSocialSharingDidNotComplete)])
        [(id<JRCaptureSocialSharingDelegate>)delegate engageSocialSharingDidNotComplete];

    [self engageLibraryTearDown];
}

- (void)socialSharingDidSucceedForActivity:(JRActivityObject *)activity forProvider:(NSString *)provider
{
    if ([delegate respondsToSelector:@selector(engageSocialSharingDidSucceedForActivity:onProvider:)])
        [(id<JRCaptureSocialSharingDelegate>)delegate engageSocialSharingDidSucceedForActivity:activity onProvider:provider];
}

- (void)jrSocialSharingDidFailForActivity:(JRActivityObject *)activity withError:(NSError *)error forProvider:(NSString *)provider
{
    if ([delegate respondsToSelector:@selector(engageSocialSharingDidFailForActivity:withError:onProvider:)])
        [(id<JRCaptureSocialSharingDelegate>)delegate engageSocialSharingDidFailForActivity:activity withError:error onProvider:provider];

    [self engageLibraryTearDown];
}

- (void)dealloc
{
    [delegate release];

    [nativeSigninViewController release];
    [super dealloc];
}
@end
