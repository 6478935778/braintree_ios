//
//  PPDataCollector.h
//  PayPalDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDataCollector : NSObject

/// Returns a client metadata ID.
///
/// @param pairingID a pairing ID to associate with this clientMetadataID must be 10-32 chars long or null
/// @return a client metadata ID to send as a header
+ (nonnull NSString *)clientMetadataID:(nullable NSString *)pairingID;

/// Returns a client metadata ID.
///
/// @return a client metadata ID to send as a header
+ (nonnull NSString *)clientMetadataID;

/// Collects device data for PayPal.
///
/// This should be used when the user is paying with PayPal or Venmo only.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`,
///         for PayPal transactions. This JSON serialized string contains a PayPal fraud ID.
+ (nonnull NSString *)collectPayPalDeviceData;

@end
