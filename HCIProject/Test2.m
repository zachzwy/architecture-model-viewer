//
//  Test2.m
//  HCIProject
//
//  Created by AB Brooks on 11/11/18.
//  Copyright © 2018 AB Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>
/*! @file AppAuthExampleViewController.m
 @brief GTMAppAuth SDK iOS Example
 @copyright
 Copyright 2016 Google Inc. All Rights Reserved.
 @copydetails
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "HCIProject-Bridging-Header.h"

#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>
#import <SafariServices/SafariServices.h>

#import "AppDelegate.h"
#import "GTLRDrive.h"
//#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

/*! @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */

static NSString *const kClientID = @"625786834143-99o3l600rp2skk7ju8jt7t0renpc9r8b.apps.googleusercontent.com";
//YOUR_CLIENT.apps.googleusercontent.com
/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
static NSString *const kRedirectURI =
@"com.googleusercontent.apps.625786834143-99o3l600rp2skk7ju8jt7t0renpc9r8b:/oauthredirect";

/*! @brief @c NSCoding key for the authState property.
 */
static NSString *const kExampleAuthorizerKey = @"authorization";

@interface GTMAppAuthExampleViewController () <OIDAuthStateChangeDelegate,
OIDAuthStateErrorDelegate>
@end

@implementation GTMAppAuthExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if !defined(NS_BLOCK_ASSERTIONS)
    // NOTE:
    //
    // To run this sample, you need to register your own iOS client at
    // https://console.developers.google.com/apis/credentials?project=_ and update three configuration
    // points in the sample: kClientID and kRedirectURI constants in AppAuthExampleViewController.m
    // and the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0).
    // Full instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md
    
    NSAssert(![kClientID isEqualToString:@"YOUR_CLIENT.apps.googleusercontent.com"],
             @"Update kClientID with your own client ID. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
    NSAssert(![kRedirectURI isEqualToString:@"com.googleusercontent.apps.YOUR_CLIENT:/oauthredirect"],
             @"Update kRedirectURI with your own redirect URI. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
    // verifies that the custom URI scheme has been updated in the Info.plist
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSAssert(urlTypes.count > 0, @"No custom URI scheme has been configured for the project.");
    NSArray *urlSchemes = ((NSDictionary *)urlTypes.firstObject)[@"CFBundleURLSchemes"];
    NSAssert(urlSchemes.count > 0, @"No custom URI scheme has been configured for the project.");
    NSString *urlScheme = urlSchemes.firstObject;
    
    NSAssert(![urlScheme isEqualToString:@"com.googleusercontent.apps.YOUR_CLIENT"],
             @"Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) "
             "with the scheme of your redirect URI. Full instructions: "
             "https://github.com/openid/AppAuth-iOS/blob/master/Example/README.md");
    
#endif // !defined(NS_BLOCK_ASSERTIONS)
    
    _logTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    _logTextView.layer.borderWidth = 1.0f;
    _logTextView.alwaysBounceVertical = YES;
    _logTextView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    _logTextView.text = @"";
    
    [self loadState];
    [self updateUI];
}

/*! @brief Saves the @c GTMAppAuthFetcherAuthorization to @c NSUSerDefaults.
 */
- (void)saveState {
    if (_authorization.canAuthorize) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kExampleAuthorizerKey];
    } else {
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kExampleAuthorizerKey];
    }
}

/*! @brief Loads the @c GTMAppAuthFetcherAuthorization from @c NSUSerDefaults.
 */
- (void)loadState {
    GTMAppAuthFetcherAuthorization* authorization =
    [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kExampleAuthorizerKey];
    [self setGtmAuthorization:authorization];
}

- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
    if ([_authorization isEqual:authorization]) {
        return;
    }
    _authorization = authorization;
    self.driveService.authorizer = self.authorization;
    
    [self stateChanged];
}

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {
    _userinfoButton.enabled = _authorization.canAuthorize;
    _clearAuthStateButton.enabled = _authorization.canAuthorize;
    _driveAPIButton.enabled = _authorization.canAuthorize;
    
    // dynamically changes authorize button text depending on authorized state
    if (!_authorization.canAuthorize) {
        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateNormal];
        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateHighlighted];
    } else {
        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateNormal];
        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateHighlighted];
    }
}

- (void)stateChanged {
    [self saveState];
    [self updateUI];
}

- (void)didChangeState:(OIDAuthState *)state {
    [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(NSError *)error {
    [self logMessage:@"Received authorization error: %@", error];
}

- (IBAction)authWithAutoCodeExchange:(nullable id)sender {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    [self logMessage:@"Fetching configuration for issuer: %@", issuer];
    
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
                                                            
                                                            if (!configuration) {
                                                                [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
                                                                [self setGtmAuthorization:nil];
                                                                return;
                                                            }
                                                            
                                                            [self logMessage:@"Got configuration: %@", configuration];
                                                            
                                                            // builds authentication request
                                                            NSArray<NSString *> *scopes = @[ kGTLRAuthScopeDrive, OIDScopeOpenID, OIDScopeEmail ];
                                                            OIDAuthorizationRequest *request =
                                                            [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                                                                          clientId:kClientID
                                                                                                            scopes:scopes
                                                                                                       redirectURL:redirectURI
                                                                                                      responseType:OIDResponseTypeCode
                                                                                              additionalParameters:nil];
                                                            // performs authentication request
                                                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                            [self logMessage:@"Initiating authorization request with scope: %@", request.scope];
                                                            
                                                            appDelegate.currentAuthorizationFlow =
                                                            [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                                           presentingViewController:self
                                                                                                           callback:^(OIDAuthState *_Nullable authState,
                                                                                                                      NSError *_Nullable error) {
                                                                                                               if (authState) {
                                                                                                                   GTMAppAuthFetcherAuthorization *authorization =
                                                                                                                   [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                                                                                                                   
                                                                                                                   [self setGtmAuthorization:authorization];
                                                                                                                   [self logMessage:@"Got authorization tokens. Access token: %@",
                                                                                                                    authState.lastTokenResponse.accessToken];
                                                                                                               } else {
                                                                                                                   [self setGtmAuthorization:nil];
                                                                                                                   [self logMessage:@"Authorization error: %@", [error localizedDescription]];
                                                                                                               }
                                                                                                           }];
                                                        }];
}

- (IBAction)clearAuthState:(nullable id)sender {
    [self setGtmAuthorization:nil];
}

- (IBAction)clearLog:(nullable id)sender {
    _logTextView.text = @"";
}

- (IBAction)userinfo:(nullable id)sender {
    [self logMessage:@"Performing userinfo request"];
    
    // Creates a GTMSessionFetcherService with the authorization.
    // Normally you would save this service object and re-use it for all REST API calls.
    GTMSessionFetcherService *fetcherService = [[GTMSessionFetcherService alloc] init];
    fetcherService.authorizer = self.authorization;
    
    // Creates a fetcher for the API call.
    NSURL *userinfoEndpoint = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v3/userinfo"];
    GTMSessionFetcher *fetcher = [fetcherService fetcherWithURL:userinfoEndpoint];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        // Checks for an error.
        if (error) {
            // OIDOAuthTokenErrorDomain indicates an issue with the authorization.
            if ([error.domain isEqual:OIDOAuthTokenErrorDomain]) {
                [self setGtmAuthorization:nil];
                [self logMessage:@"Authorization error during token refresh, clearing state. %@", error];
                // Other errors are assumed transient.
            } else {
                [self logMessage:@"Transient error during token refresh. %@", error];
            }
            return;
        }
        
        // Parses the JSON response.
        NSError *jsonError = nil;
        id jsonDictionaryOrArray =
        [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // JSON error.
        if (jsonError) {
            [self logMessage:@"JSON decoding error %@", jsonError];
            return;
        }
        
        // Success response!
        [self logMessage:@"Success: %@", jsonDictionaryOrArray];
    }];
}

- (GTLRDriveService *)driveService {
    static GTLRDriveService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRDriveService alloc] init];
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    });
    return service;
}

- (void)fetchFileList:(id)sender {
    GTLRDriveService *service = self.driveService;
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    
    // Because GTLRDrive_FileList is derived from GTLCollectionObject and the service
    // property shouldFetchNextPages is enabled, this may do multiple fetches to
    // retrieve all items in the file list.
    
    // Google APIs typically allow the fields returned to be limited by the "fields" property.
    // The Drive API uses the "fields" property differently by not sending most of the requested
    // resource's fields unless they are explicitly specified.
    query.fields = @"kind,nextPageToken,files(mimeType,id,kind,name,webViewLink,thumbnailLink,trashed)";
    
    [service executeQuery:query
        completionHandler:^(GTLRServiceTicket *callbackTicket,
                            GTLRDrive_FileList *fileList,
                            NSError *error) {
            if (error) {
                [self logMessage:@"Error: %@", error];
            } else {
                for (GTLRDrive_File *item in fileList) {
                    
                    
                    // here we start to download everyitems.
                    
                    NSString *str= item.webViewLink; // is your str
                    NSArray *items = [str componentsSeparatedByString:@"/"];  // take one array for split string
                    NSString *fileId = [items objectAtIndex:5];    // show description
                    
                    
                    
                    GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:fileId];
                    [self.driveService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                              GTLRDataObject *file,
                                                                              NSError *error) {
                        if (error == nil) {
                            NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES );
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            NSLog(@"documentsDirectory%@",documentsDirectory);
                            
                            NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,item.name];
                            [file.data writeToFile:filePath atomically:YES];
                            
                            NSLog(@"Downloaded %lu bytes", file.data.length);
                        } else {
                            NSLog(@"An error occurred: %@", error);
                        }
                    }];
                    
                    
                    
                    
                    [self logMessage:@"Item: %@ (%@)", item.name, item.webViewLink];
                }
            }
        }];
}


/*! @brief Logs a message to stdout and the textfield.
 @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    // gets message as string
    va_list argp;
    va_start(argp, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);
    
    // outputs to stdout
    NSLog(@"%@", log);
    
    // appends to output log
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
                         _logTextView.text,
                         ([_logTextView.text length] > 0) ? @"\n" : @"",
                         dateString,
                         log];
}

#pragma mark UITextViewDelegate methods

-(BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)URL
        inRange:(NSRange)characterRange {
    
    SFSafariViewController* svc = [[SFSafariViewController alloc] initWithURL:URL];
    [self presentViewController:svc animated:YES completion:nil];
    
    return NO;
}

#pragma mark -

@end
