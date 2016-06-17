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
//  WCAuthInfo.h
//  Webcom
//
//  Created by Christophe Azemar.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Object Response when authentication is successful
 */
@interface WCAuthInfo : NSObject
/**
 * user's unique id
 */
@property(nonatomic, readonly, nullable) NSString * uid;
/**
 * authentication provider
 */
@property(nonatomic, readonly, nullable) NSString * provider;
/**
 * authentication token
 */
@property(nonatomic, readonly, nullable) NSString * authToken;
/**
 * Expires date
 */
@property(nonatomic, readonly, nullable) NSNumber * expires;
/**
 *  User email
 */
@property(nonatomic, readonly, nullable) NSString * email;

@end

NS_ASSUME_NONNULL_END