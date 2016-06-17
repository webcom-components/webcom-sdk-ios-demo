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
//  WCOnDisconnect.h
//  Webcom
//
//  Created by Christophe Azemar.
//
//

#import <Foundation/Foundation.h>
#import "WCWebcomError.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Useful class to write and remove data if user lost connection with server. It can be a connection problem or an app crash.
 * Registered actions are executed only once. Register again your actions if you need it.
 * Managing presence is a common use case. You can prevent other friends if you are connected or not.
 * Set actions as soon as possible to catch early connection problems.
 */
@interface WCOnDisconnect : NSObject

/**
 * Cancelling any set:, update: or remove actions at current location.
 */
- (void)cancel;

/**
 * Cancelling any set:, update: or remove actions
 * at current location.
 *
 *  @param completeCallback function called when server has canceled actions. An error can be passed in parameter if something
 *  goes wrong.
 */
- (void)cancelOnComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Remove data at current location when a disconnection event occurs.
 */
- (void)remove;

/**
 *  Remove data at current location when a disconnection event occurs.
 *
 *  @param completeCallback function called when server has registered remove action. An error can be passed in parameter if
 *  something goes wrong.
 */
- (void)removeOnComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Set data at current location when a disconnection event occurs.
 *
 *  @param object new value
 */
- (void)set:(nullable NSObject *)object;

/**
 *  Set data at current location when a disconnection event occurs.
 *
 *  @param object           new value
 *  @param completeCallback function called when server has registered set action. An error can be passed in parameter if 
 *  something goes wrong.
 */
- (void)set:(nullable NSObject *)object onComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

/**
 *  Update data at current location when a disconnection event occurs.
 *
 *  @param object children to be added
 */
- (void)update:(NSObject *)object;

/**
 *  Update data at current location when a disconnection event occurs.
 *
 *  @param object           children to be added
 *  @param completeCallback function called when server has registered update action. An error can be passed in parameter if 
 *  something goes wrong.
 */
- (void)update:(NSObject *)object onComplete:(nullable void ( ^ ) (NSError * __nullable error))completeCallback;

@end

NS_ASSUME_NONNULL_END