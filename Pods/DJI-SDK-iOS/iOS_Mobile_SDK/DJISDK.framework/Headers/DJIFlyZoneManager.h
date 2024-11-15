//
//  DJIFlyZoneManager.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKCircle.h>
#import <DJISDK/DJIFlyZoneInformation.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIFlyZoneManager;
@class DJICustomUnlockZone;


/**
 *  This protocol provides the delegate method to receive updated fly zone
 *  information.
 */
@protocol DJIFlyZoneDelegate <NSObject>


/**
 *  Called when the latest fly zone status is received.
 *  
 *  @param manager The fly zone manager that updates state.
 *  @param state An enum value of `DJIFlyZoneState`.
 */
-(void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateFlyZoneState:(DJIFlyZoneState)state;


/**
 *  Called when the basic database upgrade progress changes or an error occurs.
 *  
 *  @param manager The fly zone manager that updates progress.
 *  @param progress The upgrade progress of the basic database.
 *  @param error Error if there is any.
 */
-(void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateBasicDatabaseUpgradeProgress:(float)progress andError:(NSError * _Nullable)error;

@end


/**
 *  Fly Zone Manager gives information about nearby fly zones, and APIs to unlock
 *  zones that can be unlocked. Depending on location, there are three types of fly
 *  zones possible:
 *   - `DJIFlyZoneTypeCircle`: Cylinder or truncated cone volume with four levels of
 *  restriction:
 *      - Warning Zones : no restriction
 *      - Enhanced warning zones : Flight restricted, can be unlocked for
 *          flight when the user logs into their DJI account
 *      - Authorization zones : Flight restricted, can be unlocked for
 *          flight when the user logs into their DJI account and the account
 *          has been authorized to unlock authorization zones.
 *      - Restricted zones : Flight restricted
 *  - `DJIFlyZoneTypePoly`: Fly zone that consists of one or more sub fly zones that
 *  are cylinders or  complex volumes with different height limitations. A height
 *  limitation of 0 means flight is completely restricted. This is used by Spark,
 *  Mavic, Phantom 4 Series, Inspire 2 and Matrice 200 series.
 *  On the Phantom 3, Inspire 1, M100, M600, A3/N3 series of products, there can
 *  also be a buffer area with radius about 23 km around a restricted  fly zone
 *  where flight height is limited to 120m.</br>
 */
@interface DJIFlyZoneManager : NSObject

- (instancetype)init OBJC_UNAVAILABLE("You must use the singleton");

+ (instancetype)new OBJC_UNAVAILABLE("You must use the singleton");


/**
 *  Delegate to receive the updated status.
 */
@property(nonatomic, weak) id<DJIFlyZoneDelegate> delegate;


/**
 *  `YES` if an aircraft is connected with flight controller firmware that  supports
 *  Custom Unlock Zones. Aircraft that support Custom Unlock  zones are also able to
 *  disable unlocked fly zones temporarily.
 */
@property(nonatomic, readonly) BOOL isCustomUnlockZoneSupported;


/**
 *  The fly zone database state in the firmware of the aircraft. The SDK will
 *  compare the version of the database on the aircraft against  the latest one
 *  online. When the aircraft database is out-of-date, the user should use DJI Go or
 *  Assistant 2 to update the firmware. This  database is supported by Phantom 4
 *  series, Inspire 2, M200 series, Mavic and Spark.  For older products, use
 *  `basicDatabaseState`.
 */
@property(nonatomic, readonly) DJIFlyZoneDatabaseState preciseDatabaseState;


/**
 *  The version of the precise fly zone database in the firmware of the aircraft.
 *  It is `nil` if `preciseDatabaseState` is `DJIFlyZoneDatabaseStateInitializing`.
 *  The precise database is supported by Phantom 4 series, Inspire 2, M200 series,
 *  Mavic and Spark.
 */
@property(nonatomic, readonly, nullable) NSString *preciseDatabaseVersion;


/**
 *  The state of the basic fly zone database on the mobile device. The SDK will
 *  compare the version  of the local database against the latest one online. When
 *  the local database is out-of-date,  call
 *  `startBasicDatabaseUpgradeWithCompletion` to start updating the database. If the
 *  update  is compulsory (for safety reasons), SDK will start the update
 *  automatically. The basic database is used  by DJI aircraft that do not support
 *  the precise database (e.g. Phantom 3 series, Inspire 1 series).
 */
@property(nonatomic, readonly) DJIFlyZoneDatabaseState basicDatabaseState;


/**
 *  The version of the basic fly zone database on the mobile device. It is `nil` if
 *  the local file cannot  be parsed by SDK. The basic database is used by DJI
 *  aircraft that do not support the precise database (e.g.  Phantom 3 series,
 *  Inspire 1 series).
 */
@property(nonatomic, readonly, nullable) NSString *basicDatabaseVersion;


/**
 *  Starts the upgrde of the basic database. Internet access is required. When the
 *  upgrade is started successfully,  use
 *  `flyZoneManager:didUpdateBasicDatabaseUpgradeProgress:andError` to monitor the
 *  progress.
 *  
 *  @param completion Completion block that will be called if the update is started successfully or an error occurs.
 */
-(void)startBasicDatabaseUpgradeWithCompletion:(DJICompletionBlock)completion;


/**
 *  Stops the in-progress upgrade of the basic database.
 *  
 *  @param completion Completion block that will be called if the update is started successfully or an error occurs.
 */
-(void)stopBasicDatabaseUpgradeWithCompletion:(DJICompletionBlock)completion;


/**
 *  Gets all the fly zones within 20km of the aircraft. During simulation, this
 *  method is available only when the aircraft location is within 50km of
 *  (37.460484, -122.115312) or within 50km of (22.5726, 113.8124499). Use of the
 *  geographic information provided by DJIFlyZoneManager is restricted. Refer to the
 *  DJI Developer Policy.
 *  
 *  @param infos Array of `DJIFlyZoneInformation` objects.
 *  @param error Error retrieving the value.
 *  @param completion Completion block to receive the result.
 */
-(void)getFlyZonesInSurroundingAreaWithCompletion:(void (^_Nonnull)(NSArray<DJIFlyZoneInformation*> *_Nullable infos, NSError* _Nullable error))completion;


/**
 *  Gets a list of unlocked fly zones of the authorized account from the server.
 *  The list contains the fly zones unlocked by the Flight Planner
 *  (http://www.dji.com/flysafe/geo-system#planner), and the fly zones unlocked
 *  during flight using DJI Go or any DJI Mobile SDK based application.
 *  
 *  @param infos The array of the `DJIFlyZoneInformation` objects.
 *  @param error Error retrieving the value.
 *  @param completion Completion block to receive the result.
 */
-(void)getUnlockedFlyZonesWithCompletion:(void (^_Nonnull)(NSArray<DJIFlyZoneInformation*> *_Nullable infos, NSError* _Nullable error))completion;


/**
 *  Unlocks the selected fly zones. This method can be used to unlock  enhanced
 *  warning and authorization zones. After unlocking the zones, flight will be
 *  unrestricted in those zones until the unlock expires.  The unlocking record will
 *  be linked to the user's account and will  be accessible to DJI Go and other DJI
 *  Mobile SDK based applications.
 *  
 *  @param flyZoneIDs The IDs of EnhancedWarningZones or AuthorizedWarningZones.
 *  @param completion The execution block with the returned execution result.
 */
-(void)unlockFlyZones:(NSArray<NSNumber *> *_Nonnull)flyZoneIDs withCompletion:(DJICompletionBlock)completion;


/**
 *  When an Custom Unlock Zone is approved, the approval and zone information needs
 *  to be  downloaded from the Fly Zone server and uploaded to the aircraft. For
 *  each product  connection state change, or network connection state change this
 *  is done automatically.  However, if the Custom Unlock Zone is approved and needs
 *  to be uploaded to the aircraft  without changing the network connectivity or
 *  product  connectivity state, then this method  can be used to force the  Custom
 *  Unlock  Zone update. For this method to work, the user  must already be logged
 *  in. Custom  Unlock Zones are associated with an aircraft serial  number, and so,
 *  to upload to  the aircraft, the right aircraft must also be connected.  This
 *  method can only be  used when `isCustomUnlockZoneSupported` is `YES`.
 *  
 *  @param completion `completion block` to receive the result.
 */
-(void)loadCustomUnlockZonesFromServerWithCompletion:(DJICompletionBlock)completion;


/**
 *  Gets the Custom Unlock Zones currently on the aircraft. This method can  only be
 *  used when `isCustomUnlockZoneSupported`  is `YES`.
 *  
 *  @param zones Array of `DJICustomUnlockZone` objects.
 *  @param error Error retrieving the value.
 *  @param completion Completion block to receive the result.
 */
-(void)getCustomUnlockZonesWithCompletion:(void (^_Nonnull)(NSArray<DJICustomUnlockZone *> *_Nullable zones, NSError *_Nullable error))completion;


/**
 *  Enables an Custom Unlock Zones that is on the aircraft. All Custom Unlock Zones
 *  on the  aircraft can be retrieved with `getCustomUnlockZonesWithCompletion`.  At
 *  any time,  only one Custom Unlock Zone can be enabled. Enabling an Custom Unlock
 *  Zone will  disable the previously enabled zone. This method can only be used
 *  when  `isCustomUnlockZoneSupported` is `YES`.
 *  
 *  @param zone Custom Unlock Zone to enabled. If `zone` is `nil`, only the  previously enabled zone will be disabled.
 *  @param completion `completion block` to receive the result.
 */
-(void)enableCustomUnlockZone:(DJICustomUnlockZone *_Nullable)zone
               withCompletion:(DJICompletionBlock)completion;


/**
 *  Gets the currently enabled Custom Unlock Zone. This method can only be used
 *  when `isCustomUnlockZoneSupported` is `YES`.
 *  
 *  @param zone The enabled Custom Unlock Zone. `nil` if no zones are enabled.
 *  @param error Error if there is any.
 *  @param completion Completion block to receive the result.
 */
-(void)getEnabledCustomUnlockZoneWithCompletion:(void (^_Nonnull)(DJICustomUnlockZone *_Nullable zone, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
