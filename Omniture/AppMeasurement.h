//
//  AppMeasurement.h
//  AppMeasurement
//
//  Copyright 1996-2011. Adobe, Inc. All Rights Reserved

#import <UIKit/UIKit.h>

#pragma mark AppMeasurement interface

@class ChurnMeasurement;

@class AppMeasurementModuleMedia;
@protocol AppMeasurementDelegate;

@interface AppMeasurement : NSObject
{
@private
	BOOL _ssl;
	BOOL _linkLeaveQueryString;
	BOOL _debugTracking;
	BOOL _usePlugins;
    BOOL _useBestPractices;
	BOOL _forceOffline;	
    
	NSString * _version;
	NSMutableArray * _requiredVarList;
	NSMutableArray * _accountVarList;
	NSMutableArray * _accountConfigList;
	NSMutableArray * _lightRequiredVarList;
	NSMutableArray * _lightVarList;
	NSMutableDictionary * _accountVars;
	id<AppMeasurementDelegate> _delegate;
	AppMeasurementModuleMedia * _Media;
	NSMutableArray * _queuedMessages;
	NSNumber * offlineThrottleDelay;
    NSMutableDictionary * connectionToRequest;
    NSTimer * t;
}

#pragma mark AppMeasurement public methods

+ (AppMeasurement *)getInstance;
- (id)init;
- (id)initWithDelegate:(id<AppMeasurementDelegate>)delegate;
- (void)track;
- (void)track:(NSDictionary *)variableOverrides;
- (void)trackLink:(NSString *)linkURL linkType:(NSString *)linkType linkName:(NSString *)linkName;
- (void)trackLink:(NSString *)linkURL linkType:(NSString *)linkType linkName:(NSString *)linkName variableOverrides:(NSDictionary *)variableOverrides;
- (void)clearVars;
- (void)forceOffline;
- (void)forceOnline;
- (void) timerHandler:(NSTimer*) timer;
- (NSString *)getFormattedTimestamp;
- (NSString *)getQueryString;
- (NSString*) serializeToQueryString:(NSDictionary*)dict varFilter:(NSString*)filter;
- (void)trackLight:(NSString*) profileID storeForSeconds:(NSNumber*)StoreForSeconds incrementBy:(NSNumber*)incrementBy variableOverrides:(NSDictionary*)variableOverrides;
- (void)trackLight:(NSString*) profileID storeForSeconds:(NSNumber*)StoreForSeconds incrementBy:(NSNumber*)incrementBy;
- (void)trackLight:(NSString*) profileID storeForSeconds:(NSNumber*)StoreForSeconds;
- (void)trackLight:(NSString*) profileID;
- (ChurnMeasurement *)getChurnInstance;  // TODO this needs to handle populate defaults
- (ChurnMeasurement *)getChurnInstancePopulateDefaults:(BOOL)populateDefaults;

// reserved for internal use only
- (BOOL)isSet:(NSString *)var;
- (NSString *)escape:(NSString *)unescapedString;
- (NSString *)escape:(NSString *)unescapedString escapedCharacters:(NSString*)escapedCharacters;

-(NSNumber*) OfflineThrottleDelay;
-(void) setOfflineThrottleDelay:(NSNumber *)value;

#pragma mark AppMeasurement properties
@property(readwrite, copy) NSNumber * timestamp; 
@property(readwrite) BOOL trackOffline;
@property(readwrite) BOOL isOffline;
@property(readwrite, copy) NSNumber * offlineLimit;
@property(readwrite, copy) NSString * account;
@property(readwrite, copy) NSString * linkURL;
@property(readwrite, copy) NSString * linkName;
@property(readwrite, copy) NSString * linkType;
@property(readwrite, copy) NSString * linkTrackVars;
@property(readwrite, copy) NSString * linkTrackEvents;
@property(readwrite, copy) NSString * dc;
@property(readwrite, copy) NSString * trackingServer;
@property(readwrite, copy) NSString * trackingServerSecure;
@property(readwrite, copy) NSString * userAgent;
@property(readwrite, copy) NSString * dynamicVariablePrefix;
@property(readwrite, copy) NSString * visitorID;
@property(readwrite, copy) NSString * charSet;
@property(readwrite, copy) NSString * visitorNamespace;
@property(readwrite, copy) NSString * pageName;
@property(readwrite, copy) NSString * pageURL;
@property(readwrite, copy) NSString * referrer;
@property(readwrite, copy) NSString * currencyCode;
@property(readwrite, copy) NSString * purchaseID;
@property(readwrite, copy) NSString * channel;
@property(readwrite, copy) NSString * server;
@property(readwrite, copy) NSString * pageType;
@property(readwrite, copy) NSString * transactionID;
@property(readwrite, copy) NSString * campaign;
@property(readwrite, copy) NSString * state;
@property(readwrite, copy) NSString * zip;
@property(readwrite, copy) NSString * events;
@property(readwrite, copy) NSString * products;
@property(readwrite, copy) NSString * list1;
@property(readwrite, copy) NSString * list2;
@property(readwrite, copy) NSString * list3;
@property(readwrite, copy) NSString * hier1;
@property(readwrite, copy) NSString * hier2;
@property(readwrite, copy) NSString * hier3;
@property(readwrite, copy) NSString * hier4;
@property(readwrite, copy) NSString * hier5;
@property(readwrite, copy) NSString * prop1;
@property(readwrite, copy) NSString * prop2;
@property(readwrite, copy) NSString * prop3;
@property(readwrite, copy) NSString * prop4;
@property(readwrite, copy) NSString * prop5;
@property(readwrite, copy) NSString * prop6;
@property(readwrite, copy) NSString * prop7;
@property(readwrite, copy) NSString * prop8;
@property(readwrite, copy) NSString * prop9;
@property(readwrite, copy) NSString * prop10;
@property(readwrite, copy) NSString * prop11;
@property(readwrite, copy) NSString * prop12;
@property(readwrite, copy) NSString * prop13;
@property(readwrite, copy) NSString * prop14;
@property(readwrite, copy) NSString * prop15;
@property(readwrite, copy) NSString * prop16;
@property(readwrite, copy) NSString * prop17;
@property(readwrite, copy) NSString * prop18;
@property(readwrite, copy) NSString * prop19;
@property(readwrite, copy) NSString * prop20;
@property(readwrite, copy) NSString * prop21;
@property(readwrite, copy) NSString * prop22;
@property(readwrite, copy) NSString * prop23;
@property(readwrite, copy) NSString * prop24;
@property(readwrite, copy) NSString * prop25;
@property(readwrite, copy) NSString * prop26;
@property(readwrite, copy) NSString * prop27;
@property(readwrite, copy) NSString * prop28;
@property(readwrite, copy) NSString * prop29;
@property(readwrite, copy) NSString * prop30;
@property(readwrite, copy) NSString * prop31;
@property(readwrite, copy) NSString * prop32;
@property(readwrite, copy) NSString * prop33;
@property(readwrite, copy) NSString * prop34;
@property(readwrite, copy) NSString * prop35;
@property(readwrite, copy) NSString * prop36;
@property(readwrite, copy) NSString * prop37;
@property(readwrite, copy) NSString * prop38;
@property(readwrite, copy) NSString * prop39;
@property(readwrite, copy) NSString * prop40;
@property(readwrite, copy) NSString * prop41;
@property(readwrite, copy) NSString * prop42;
@property(readwrite, copy) NSString * prop43;
@property(readwrite, copy) NSString * prop44;
@property(readwrite, copy) NSString * prop45;
@property(readwrite, copy) NSString * prop46;
@property(readwrite, copy) NSString * prop47;
@property(readwrite, copy) NSString * prop48;
@property(readwrite, copy) NSString * prop49;
@property(readwrite, copy) NSString * prop50;
@property(readwrite, copy) NSString * prop51;
@property(readwrite, copy) NSString * prop52;
@property(readwrite, copy) NSString * prop53;
@property(readwrite, copy) NSString * prop54;
@property(readwrite, copy) NSString * prop55;
@property(readwrite, copy) NSString * prop56;
@property(readwrite, copy) NSString * prop57;
@property(readwrite, copy) NSString * prop58;
@property(readwrite, copy) NSString * prop59;
@property(readwrite, copy) NSString * prop60;
@property(readwrite, copy) NSString * prop61;
@property(readwrite, copy) NSString * prop62;
@property(readwrite, copy) NSString * prop63;
@property(readwrite, copy) NSString * prop64;
@property(readwrite, copy) NSString * prop65;
@property(readwrite, copy) NSString * prop66;
@property(readwrite, copy) NSString * prop67;
@property(readwrite, copy) NSString * prop68;
@property(readwrite, copy) NSString * prop69;
@property(readwrite, copy) NSString * prop70;
@property(readwrite, copy) NSString * prop71;
@property(readwrite, copy) NSString * prop72;
@property(readwrite, copy) NSString * prop73;
@property(readwrite, copy) NSString * prop74;
@property(readwrite, copy) NSString * prop75;
@property(readwrite, copy) NSString * eVar1;
@property(readwrite, copy) NSString * eVar2;
@property(readwrite, copy) NSString * eVar3;
@property(readwrite, copy) NSString * eVar4;
@property(readwrite, copy) NSString * eVar5;
@property(readwrite, copy) NSString * eVar6;
@property(readwrite, copy) NSString * eVar7;
@property(readwrite, copy) NSString * eVar8;
@property(readwrite, copy) NSString * eVar9;
@property(readwrite, copy) NSString * eVar10;
@property(readwrite, copy) NSString * eVar11;
@property(readwrite, copy) NSString * eVar12;
@property(readwrite, copy) NSString * eVar13;
@property(readwrite, copy) NSString * eVar14;
@property(readwrite, copy) NSString * eVar15;
@property(readwrite, copy) NSString * eVar16;
@property(readwrite, copy) NSString * eVar17;
@property(readwrite, copy) NSString * eVar18;
@property(readwrite, copy) NSString * eVar19;
@property(readwrite, copy) NSString * eVar20;
@property(readwrite, copy) NSString * eVar21;
@property(readwrite, copy) NSString * eVar22;
@property(readwrite, copy) NSString * eVar23;
@property(readwrite, copy) NSString * eVar24;
@property(readwrite, copy) NSString * eVar25;
@property(readwrite, copy) NSString * eVar26;
@property(readwrite, copy) NSString * eVar27;
@property(readwrite, copy) NSString * eVar28;
@property(readwrite, copy) NSString * eVar29;
@property(readwrite, copy) NSString * eVar30;
@property(readwrite, copy) NSString * eVar31;
@property(readwrite, copy) NSString * eVar32;
@property(readwrite, copy) NSString * eVar33;
@property(readwrite, copy) NSString * eVar34;
@property(readwrite, copy) NSString * eVar35;
@property(readwrite, copy) NSString * eVar36;
@property(readwrite, copy) NSString * eVar37;
@property(readwrite, copy) NSString * eVar38;
@property(readwrite, copy) NSString * eVar39;
@property(readwrite, copy) NSString * eVar40;
@property(readwrite, copy) NSString * eVar41;
@property(readwrite, copy) NSString * eVar42;
@property(readwrite, copy) NSString * eVar43;
@property(readwrite, copy) NSString * eVar44;
@property(readwrite, copy) NSString * eVar45;
@property(readwrite, copy) NSString * eVar46;
@property(readwrite, copy) NSString * eVar47;
@property(readwrite, copy) NSString * eVar48;
@property(readwrite, copy) NSString * eVar49;
@property(readwrite, copy) NSString * eVar50;
@property(readwrite, copy) NSString * eVar51;
@property(readwrite, copy) NSString * eVar52;
@property(readwrite, copy) NSString * eVar53;
@property(readwrite, copy) NSString * eVar54;
@property(readwrite, copy) NSString * eVar55;
@property(readwrite, copy) NSString * eVar56;
@property(readwrite, copy) NSString * eVar57;
@property(readwrite, copy) NSString * eVar58;
@property(readwrite, copy) NSString * eVar59;
@property(readwrite, copy) NSString * eVar61;
@property(readwrite, copy) NSString * eVar62;
@property(readwrite, copy) NSString * eVar63;
@property(readwrite, copy) NSString * eVar64;
@property(readwrite, copy) NSString * eVar65;
@property(readwrite, copy) NSString * eVar66;
@property(readwrite, copy) NSString * eVar67;
@property(readwrite, copy) NSString * eVar68;
@property(readwrite, copy) NSString * eVar69;
@property(readwrite, copy) NSString * eVar70;
@property(readwrite, copy) NSString * eVar71;
@property(readwrite, copy) NSString * eVar72;
@property(readwrite, copy) NSString * eVar73;
@property(readwrite, copy) NSString * eVar74;
@property(readwrite, copy) NSString * eVar75;
@property(readwrite) BOOL ssl;
@property(readwrite) BOOL linkLeaveQueryString;
@property(readwrite) BOOL debugTracking;
@property(readwrite) BOOL usePlugins;
@property(readwrite, nonatomic) BOOL useBestPractices;
@property(readwrite, assign) id<AppMeasurementDelegate> delegate;
@property(readwrite, retain) AppMeasurementModuleMedia * Media;
@property(readwrite,retain) NSMutableArray * queuedMessages;
@property(readwrite, retain) NSMutableDictionary * contextData;
@property(readwrite, retain) NSMutableDictionary * retrieveLightData;
@property(readwrite, copy) NSString * lightProfileID;
@property(readwrite, copy) NSString * lightStoreForSeconds;
@property(readwrite, copy) NSString * lightIncrementBy;
@property(readwrite, copy) NSString * lightTrackVars;
@property(readwrite, copy) NSString * deleteLightProfiles;
@property(readwrite, copy) NSString * retrieveLightProfiles;
@end

#pragma mark AppMeasurementDelegate protocol

@protocol AppMeasurementDelegate<NSObject>
@optional

// Called before the track data is sent to Omniture collection servers
- (void)appMeasurementDoPlugins:(AppMeasurement *)s;

@end

#pragma mark Modules

#pragma mark AppMeasurementModuleMedia interface

@protocol AppMeasurementModuleMediaDelegate;

@interface AppMeasurementModuleMedia : NSObject {
	
@private
	AppMeasurement * _s;
	NSMutableDictionary * _list;
	NSString * _playerName;
	NSString * _trackVars;
	NSString * _trackEvents;
	int _trackSeconds;
	NSString * _trackMilestones;
	BOOL _trackAtCuePoints;
	NSString * _cuePoints;
	id<AppMeasurementModuleMediaDelegate> _delegate;
}

#pragma mark AppMeasurementModuleMedia public methods

- (id)init:(AppMeasurement *)s;
- (void)open:(NSString *)name length:(double)length playerName:(NSString *)playerName cuePoints:(NSString *)cuePoints playerID:(NSString *)playerID;
- (void)open:(NSString *)name length:(double)length playerName:(NSString *)playerName cuePoints:(NSString *)cuePoints;
- (void)open:(NSString *)name length:(double)length playerName:(NSString *)playerName;
- (void)close:(NSString *)name;
- (void)play:(NSString *)name offset:(double)offset;
- (void)stop:(NSString *)name offset:(double)offset;
- (void)track:(NSString *)name;
- (void)cuePoint:(NSString *)name offset:(double)offset cuePointName:(NSString *)cuePointName;
- (void)cuePoint:(NSString *)name offset:(double)offset;

#pragma mark AppMeasurementModuleMedia properties

@property(readwrite, copy) NSString * playerName;
@property(readwrite, copy) NSString * trackVars;
@property(readwrite, copy) NSString * trackEvents;
@property(readwrite) int trackSeconds;
@property(readwrite, copy) NSString * trackMilestones;
@property(readwrite) BOOL trackAtCuePoints;
@property(readwrite, copy) NSString * cuePoints;
@property(readwrite, assign) id<AppMeasurementModuleMediaDelegate> delegate;

@end

#pragma mark AppMeasurementModuleMediaState (see AppMeasurementModuleMediaDelegate protocol)

@interface AppMeasurementModuleMediaState : NSObject {

@private
	NSString * _name;
	double _length;
	NSString * _playerName;
	NSString * _mediaEvent;
	BOOL _eventFirstTime;
	NSDate * _openTime;
	double _offset;
	NSString * _offsetName;
	double _percent;
	double _timePlayed;
	double _milestone;
}

#pragma mark AppMeasurementModuleMediaState properties

@property(readwrite, copy) NSString * name;
@property(readwrite) double length;
@property(readwrite, copy) NSString * playerName;
@property(readwrite, copy) NSString * mediaEvent;
@property(readwrite) BOOL eventFirstTime;
@property(readwrite, copy) NSDate * openTime;
@property(readwrite) double offset;
@property(readwrite, copy) NSString * offsetName;
@property(readwrite) double percent;
@property(readwrite) double timePlayed;
@property(readwrite) double milestone;

@end

#pragma mark AppMeasurementModuleMediaDelegate protocol

@protocol AppMeasurementModuleMediaDelegate<NSObject>
@optional

// Media Monitor
- (void)appMeasurementModuleMediaMonitor:(AppMeasurement *)s media:(AppMeasurementModuleMediaState *)media;

@end

@interface ChurnMeasurement : NSObject<AppMeasurementDelegate> {
    
@private
	NSString * _appInstallEvent;
	NSString * _appUpgradeEvent;
	NSString * _dailyEngagedUserEvent;
	NSString * _monthlyEngagedUserEvent;
	NSString * _appLaunchEvent;
	NSString * _appScreenViewEvent;
	NSString * _appCrashEvent;
	
	NSString * _appInstallDateEvar;
	NSString * _appIdEvar;
	NSString * _engagedDaysLifetimeEvar;
	NSString * _daysSinceFirstUseEvar;
	NSString * _daysSinceLastUseEvar;
	NSString * _appLaunchNumberEvar;
	NSString * _hourOfDayEvar;
	NSString * _dayOfWeekEvar;
	NSString * _appEnvironmentEvar;
	NSString * _daysSinceLastUpgradeEvar;
	NSString * _appLaunchNumberSinceLastUpgradeEvar;
	NSString * _engagedDaysMonthEvar;
	NSString * _engagedDaysLastUpgradeEvar;
	
	NSString * _appIdProp;
	NSString * _appLaunchNumberProp;
	NSString * _appLaunchNumberSinceLastUpgradeProp;	
	
	NSMutableDictionary * _variables;
	NSMutableArray * _events;
	AppMeasurement * _s;
	id<AppMeasurementDelegate> _subDelegate;
}

+ (ChurnMeasurement *)getInstanceWithAppMeasurement:(AppMeasurement *)s populateDefaults:(BOOL)populateDefaults;
+ (ChurnMeasurement *)getInstanceWithAppMeasurement:(AppMeasurement *)s;
- (id)initWithAppMeasurement:(AppMeasurement *)s populateDefaults:(BOOL)populateDefaults;
- (id)initWithAppMeasurement:(AppMeasurement *)s;
- (void)start;
+ (void)quit;

@property(readwrite, copy) NSString * appInstallEvent;
@property(readwrite, copy) NSString * appUpgradeEvent;
@property(readwrite, copy) NSString * dailyEngagedUserEvent;
@property(readwrite, copy) NSString * monthlyEngagedUserEvent;
@property(readwrite, copy) NSString * appLaunchEvent;
@property(readwrite, copy) NSString * appScreenViewEvent;
@property(readwrite, copy) NSString * appCrashEvent;

@property(readwrite, copy) NSString * appInstallDateEvar;
@property(readwrite, copy) NSString * appIdEvar;
@property(readwrite, copy) NSString * engagedDaysLifetimeEvar;
@property(readwrite, copy) NSString * daysSinceFirstUseEvar;
@property(readwrite, copy) NSString * daysSinceLastUseEvar;
@property(readwrite, copy) NSString * appLaunchNumberEvar;
@property(readwrite, copy) NSString * hourOfDayEvar;
@property(readwrite, copy) NSString * dayOfWeekEvar;
@property(readwrite, copy) NSString * appEnvironmentEvar;
@property(readwrite, copy) NSString * daysSinceLastUpgradeEvar;
@property(readwrite, copy) NSString * appLaunchNumberSinceLastUpgradeEvar;
@property(readwrite, copy) NSString * engagedDaysMonthEvar;
@property(readwrite, copy) NSString * engagedDaysLastUpgradeEvar;

@property(readwrite, copy) NSString * appIdProp;
@property(readwrite, copy) NSString * appLaunchNumberProp;
@property(readwrite, copy) NSString * appLaunchNumberSinceLastUpgradeProp;

@end

