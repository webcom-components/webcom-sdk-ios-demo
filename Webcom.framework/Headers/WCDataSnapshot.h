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
//  WCDataSnapshot.h
//  Webcom
//
//  Created by Christophe Azemar.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WCWebcom;

/**
 * DataSnapshot is useful to read data from a specific Webcom location. Callbacks passed to [Query onEventType:withCallback:] and [Query onceEventType:withCallback:] are called
 * with DataSnapshot instances as first parameter. To get data, use value method. DataSnapshot instance are immutables. 
 * To update data, use instead [Webcom set], [Webcom update], [Webcom push] or [Webcom remove] method.
 */
@interface WCDataSnapshot : NSObject

/** @name Properties */

/**
 * value object for this DataSnapshot
 *
 * value can be:
 *
 * - NSDictionary
 * - NSArray
 * - NSNumber (includes booleans (0 or 1))
 * - NSString
 *
 */
@property(nonatomic, readonly, nullable) id value;

/**
 * Indicates if instance DataSnapshot has at least one child.YES if it has any children, else NO.
 */
@property(nonatomic, readonly) BOOL hasChildren;

/**
 * name of the Webcom location targeted by this DataSnapshot.
 */
@property(nonatomic, readonly, nullable) NSString * name;

/**
 * children's number for this DataSnapshot.
 */
@property(nonatomic, readonly, nullable) NSNumber * numChildren;

/**
 * Webcom reference for the location of this DataSnapshot instance.
 */
@property(nonatomic, readonly, nullable) WCWebcom * ref;

/** @name Export */

/**
 *  Retrieve value object for this DataSnapshot with priority data.
 *
 *  @return snapshot
 */
- (nullable id)exportVal;

/** @name Access to child */

/**
 * Retrieve child DataSnapshot corresponding to specified relative path
 *
 * @param childPathString A relative path (can be "friends" or "friends/fred").
 * @return DataSnapshot for the child location.
 */
- (nullable WCDataSnapshot *)child:(NSString *) childPathString;

/**
 *  Iterate over DataSnapshot's children
 *
 *  @param action For each child, this function is called with child as parameter. You can return YES to stop loop.
 *
 *  @return YES if loop was stopped intentionaly, NO otherwise.
 */
- (BOOL)forEach:(BOOL ( ^ ) (WCDataSnapshot *child))action;

/**
 * Indicates if specified child exists
 *
 * @param childPathString relative path (can be "friends" or "friends/fred").
 * @return YES if child exists, NO otherwise.
 */
- (BOOL)hasChild:(NSString *)childPathString;

@end

NS_ASSUME_NONNULL_END