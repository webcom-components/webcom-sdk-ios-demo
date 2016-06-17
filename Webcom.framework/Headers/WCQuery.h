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
//  WCQuery.h
//  Webcom
//
//  Created by Christophe Azemar.
//
//

#import <Foundation/Foundation.h>
#import "WCDataSnapshot.h"
#import "WCWebcomError.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Event type which can be watched on a Webcom location.
 */
typedef NS_ENUM(NSInteger, WCEventType) {
    /**
     *  a new child node is added to a location
     */
    WCEventTypeChildAdded,
    /**
     *  a child node is removed from a location
     */
    WCEventTypeChildRemoved,
    /**
     *  a child node at a location changes
     */
    WCEventTypeChildChanged,
    /**
     *  a child node moves relative to the other child nodes at a location
     */
    WCEventTypeChildMoved,
    /**
     *  triggered when any data changes at a location and, recursively, any children
     */
    WCEventTypeValue
};

/**
 * Query sort and filters data at a Webcom location.
 * Can order and restrict data to a smallest subset.
 * Queries can be chained easily with filter functions. They return Query objects.
 */
@interface WCQuery : NSObject

/** @name Properties */

/**
 *  Query reference for the location that generated this Query.
 */
@property(nonatomic, readonly) WCQuery * ref;

/**
 *  Identifier as a string containing query criteria
 */
@property(nonatomic, readonly) NSString * queryIdentifier;

/**
 *  Serialized object as a dictionary
 */
@property(nonatomic, readonly) NSDictionary * queryObject;

/** @name Listen event on Webcom location */

/**
 *  Watching data changes at current Webcom reference location.
 *
 *  @param type     event type to watched.
 *  @param callback callback function called when desired event occurs.
 */
- (void)onEventType:(WCEventType)type withCallback:(void ( ^ ) (WCDataSnapshot * __nullable snapshot , NSString * __nullable prevKey))callback;

/**
 *  Watching data changes at current Webcom reference location.
 *
 *  @param type     event type to watched.
 *  @param callback callback function called when desired event occurs.
 *  @param cancelCallback callback function called when user lost read permission at this location
 */
- (void)onEventType:(WCEventType)type withCallback:(void (^)(WCDataSnapshot * __nullable snapshot , NSString * __nullable prevKey))callback andCancelCallback:(nullable void ( ^ ) (NSError * __nullable error))cancelCallback;

/**
 *  Watching data changes only one time at current Webcom reference location.
 *
 *  @param type     event type to watched.
 *  @param callback callback function called when desired event occurs.
 */
- (void)onceEventType:(WCEventType)type withCallback:(void ( ^ ) (WCDataSnapshot * __nullable snapshot , NSString * __nullable prevKey))callback;

/**
 *  Watching data changes only one time at current Webcom reference location.
 *
 *  @param type     event type to watched.
 *  @param callback callback function called when desired event occurs.
 *  @param cancelCallback callback function called when user lost read permission at this location
 */
- (void)onceEventType:(WCEventType)type withCallback:(void (^)(WCDataSnapshot * __nullable snapshot , NSString * __nullable prevKey))callback andCancelCallback:(nullable void ( ^ ) (NSError * __nullable error))cancelCallback;

/** @name Removing listeners */

/**
 *  Unwatch data changes at current Webcom reference location.
 *
 *  @param type event type watched.
 */
- (void)offEventType:(WCEventType)type;

@end

NS_ASSUME_NONNULL_END