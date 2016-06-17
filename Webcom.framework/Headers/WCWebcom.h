/*
 * Webcom iOS Client SDK
 * Build realtime apps. Share and sync data instantly between your clients
 *
 * Copyright (C) <2015> Orange
 *
 * This software is confidential and proprietary information of Orange.
 * You shall not disclose such Confidential Information and shall use it only in
 * accordance with the terms of the agreement you entered into.
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 *
 * If you are Orange employee you shall use this software in accordance with
 * the Orange Source Charter (http://opensource.itn.ftgroup/index.php/Orange_Source_Charter)
 */

//
//  WCWebcom.h
//  Webcom
//
//  Created by Christophe Azemar.
//
//


#import <Foundation/Foundation.h>
#import "WCDataSnapshot.h"
#import "WCWebcomError.h"
#import "WCAuthInfo.h"
#import "WCQuery.h"
#import "WCOnDisconnect.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A Webcom instance represents a particular location in your namespace and can be used for reading or writing data to that 
 * location.
 * Reading data can be done with on() and once() and writing data can be done with set, push, update:, remove
 * A Webcom instance is useful to read and write data at a defined location, specified by url parameter. You can also use 
 * specific methods (child:, parent, or root) to navigate into data structure.
 */
@interface WCWebcom : WCQuery

/** @name Initialize Webcom */

/**
 *  Instantiate a Webcom location with specified URL
 *
 *  @param uri Server url
 *
 *  @return Webcom instance
 */
- (nullable id)initWithURL:(NSString *)uri;

/** @name Access to parent and child location */

/**
 *  Webcom parent for instance.
 */
@property(nonatomic, readonly, nullable) WCWebcom * parent;

/**
 *  Webcom root of current namespace.
 */
@property(nonatomic, readonly, nullable) WCWebcom * root;

/**
 *  Returns Webcom reference for the location
 */
@property(nonatomic, readonly, nullable) WCWebcom * ref;

/**
 *  Returns the key name of Webcom instance.
 */
@property(nonatomic, readonly, nullable) NSString * name;

/**
 *  Retrieve a Webcom instance at specific path.
 *
 *  @param path relative path from current location.
 *
 *  @return Webcom instance which targets specified path.
 */
- (nullable WCWebcom *)child:(NSString *)path;

/** @name Authentication */

/**
 *  Authenticating user with token or Webcom secret
 *
 *  @param token            token or Webcom secret. Only use secret for server authentication. Be careful, It gives full 
 *  control over namespace.
 *  @param completeCallback block to receive authentication results. On failure, first argument contains error details and 
 *  second argument contains auth object, with expiration delay (in seconds since the Unix epoch)
 */
- (void)authWithToken:(NSString *)token onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/**
 *  Authenticating user with token or Webcom secret
 *
 *  @param token            token or Webcom secret. Only use secret for server authentication. Be careful, It gives full
 *  control over namespace.
 *  @param completeCallback block to receive authentication results. On failure, first argument contains error details and
 *  second argument contains auth object, with expiration delay (in seconds since the Unix epoch)
 *  @param cancelCallback   function called when authentication is canceled, because of expired token. First argument contains error details.
 */
- (void)authWithToken:(NSString *)token onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback onCancel:(nullable void ( ^ ) (NSError * __nullable error))cancelCallback;

/**
 *  Authenticates user using email & password.
 *
 *  @param mail             user's email
 *  @param password         user's password
 *  @param rememberMe       Indicates if the session should last
 *  @param completeCallback block to receive authentication results. On failure, first argument contains error details and
 *  second argument contains auth object, with expiration delay (in seconds since the Unix epoch)
 */
- (void)authWithMail:(NSString *)mail andPassword:(NSString *)password andRememberMe:(BOOL)rememberMe onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/**
 *  Unauthenticates user
 */
- (void)unauth;

/**
 *  Logout the currently authenticated user
 */
- (void)logout;

/**
 *  Logout the currently authenticated user.
 *
 *  @param completeCallback function called when server has finished logout action. An error can be passed in parameter if
 *  something goes wrong.
 */
- (void)logoutWithCallback:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Resume authentication.
 *
 *  @param callback function called when session is resumed.
 */
- (void)resumeWithCallback:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))callback;

/** @name User management */

/**
 *  Creates a new user account using email & password.
 *
 *  @param userMail         user's mail
 *  @param password         user's password
 *  @param completeCallback callback called when user acccount has been created. On failure, there is an error with details.
 */
- (void)createUser:(NSString *)userMail withPassword:(NSString *)password onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/**
 *  Removes an existing user account using email & password.
 *
 *  @param userMail         user's mail
 *  @param password         user's password
 *  @param completeCallback callback called when user acccount has been deleted. On failure, there is an error with details.
 */
- (void)removeUser:(NSString *)userMail withPassword:(NSString *)password onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/**
 *  Changes the password of an existing user using email & password.
 *
 *  @param userMail    user's mail
 *  @param oldPassword user's old password
 *  @param newPassword user's new password
 *  @param completeCallback callback called when user acccount has been changed. On failure, there is an error with details.
 */
- (void)changePasswordForUser:(NSString *)userMail fromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/**
 *  Sends a password-reset email to the owner of the account, containing a token that may be used to authenticate and change the user's password.
 *
 *  @param userMail         user's mail
 *  @param completeCallback callback called when mail has beed sent. On failure, there is an error with details.
 */
- (void)sendPasswordResetForUser:(NSString *)userMail onComplete:(void ( ^ ) (NSError * __nullable error, WCAuthInfo * __nullable authInfo))completeCallback;

/** @name Connection management */

/**
 * Force reconnection and enable retry connection feature.
 */
- (void)goOnline;

/**
 * Force disconnection and disable retry connection feature.
 */
- (void)goOffline;

/** @name OnDisconnect property */

/**
 *  Retrieve OnDisconnect object attached to this Webcom location.
 */
@property(nonatomic, readonly, nullable) WCOnDisconnect * onDisconnect;

/** @name Writing data */

/**
 *  Adding new child (nil) at current location. Its key is automatically generated and it is always unique.
 */
- (WCWebcom *)push;

/**
 *  Adding new child at current location. Its key is automatically generated and it is always unique.
 *
 *  @param value new child value
 */
- (WCWebcom *)push:(nullable NSObject *)value;

/**
 *  Adding new child at current location. Its key is automatically generated and it is always unique.
 *
 *  @param value new child value
 *  @param completeCallback function called after synchronization with the server. An error can be passed in arguments.
 */
- (WCWebcom *)push:(nullable NSObject *)value onComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Writing data (nil) at current location.
 */
- (void)set;

/**
 *  Writing data at current location.
 *
 *  @param value new object value
 */
- (void)set:(nullable NSObject *)value;

/**
 *  Writing data at current location.
 *
 *  @param value new object value
 *  @param completeCallback function called after synchronization with the server. An error can be passed in arguments
 */
- (void)set:(nullable NSObject *)value onComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Removing data at current location.
 */
- (void)remove;

/**
 *  Removing data at current location.
 *
 *  @param completeCallback function called after synchronization with the server. An error can be passed in arguments.
 */
- (void)removeOnComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Update data at current location.
 *
 *  @param value child to be updated/added.
 */
- (void)update:(NSObject *)value;

/**
 *  Update data at current location.
 *
 *  @param value           child to be updated/added
 *  @param completeCallback function called after synchronization with the server. An error can be passed in arguments.
 */
- (void)update:(NSObject *)value onComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/** @name Additional methods */

/**
 *  Returns absolute url of Webcom instance
 *
 *  @return absolute url of Webcom instance
 */
- (nullable NSString *)toString;

@end

NS_ASSUME_NONNULL_END