
extern NSString* const kShortCodeBaseUrl;
extern NSString* const kRestKitBaseUrl;
extern NSString* const kRestKitSecureUrl;
extern NSString* const kCookieBaseUrl;
extern NSString* const kFacebookAPIKey;
extern NSString* const kOmnitureAccountId;
extern NSString* const kOmnitureTrackingServer;
extern NSString* const kApplicationName;
extern NSString* const kYahooApplicationID;

extern NSString* const kAddThisProfileId;
extern NSString* const kAddThisApplicationId;

extern int const kAllAlbumType;
extern int const kEventAlbumType;
extern int const kMyAlbumType;
extern int const kVidSlideshowAlbumType;
extern int const kFriendAlbumType;

extern int const kCommentButtonTag;
extern int const kRotateLeftButtonTag;
extern int const kRotateRightButtonTag;
extern int const kToolbarDeleteButtonTag;
extern int const kToolbarDeleteButtonDisabledTag;

extern int const kImageUploadResizeMaxEdge;
extern float const kImageUploadResizeCompression;
extern float const kAlbumListRefreshSeconds;

extern NSString* const kServiceCreateAnonymousAccount;

extern NSString* const kServiceAllAlbumList;
extern NSString* const kServiceEventAlbumList;

extern NSString* const kServiceEventAlbumFull;
extern NSString* const kServiceEventAlbum;
extern NSString* const kServiceCreateEventAlbum;
extern NSString* const kServiceJoinEventAlbum;
extern NSString* const kServiceMyAlbum;
extern NSString* const kServiceCreateMyAlbum;
extern NSString* const kServiceFriendsAlbum;
extern NSString* const kServiceRedeemAlbum;
extern NSString* const kServiceUploadEventAlbumWithEK;
extern NSString* const kServiceUploadEventAlbum;
extern NSString* const kServiceUploadAlbumWithEK;
extern NSString* const kServiceUploadAlbum;
extern NSString* const kServiceUploadAlbumRearrange;
extern NSString* const kServiceAlbumPicture;
extern NSString* const kServiceAlbumAnnotations;
extern NSString* const kServiceAlbumPictureRotate;
extern NSString* const kServicePictureMetadataBasic;
extern NSString* const kServicePhotoComments;
extern NSString* const kServicePhotoComment;
extern NSString* const kServicePhotoAnnotation;
extern NSString* const kServicePhotoLike;
extern NSString* const kServiceUserAvatar;
extern NSString* const kServicePrintToStoreCatalog;
extern NSString* const kServicePrintToStoreStoreList;

extern NSString* const kServiceEventList;

extern NSString* const kServiceSpmProjectTemplate;
extern NSString* const kServiceSpmProjectSave;
extern NSString* const kServiceAddToCart;

extern NSString* const kServiceForgetPassword;
extern NSString* const kPersonalShareURL;
extern NSString* const kGroupShareURL;
extern NSString* const kPendingShareURL;
extern NSString* const kAlternateThumbURL;
extern NSString* const kServiceAnonymousAlbum;
extern NSString* const kThumbnailLongSide;
extern NSString* const kAppStoreLink;
extern NSString* const kEmptyAlbumIcon;
extern NSString* const kTutorialsLink;

extern NSString* const kProductListMobileSkusURL;

extern NSString* const kUploadSourceID;
extern NSString* const kUploadCompressedSourceID;
extern NSString* const kSourceId;
extern NSString* const kMobileSourceId;
extern NSString* const kShareEmailPersonalMmcCode;
extern NSString* const kShareEmailGroupAddMmcCode;
extern NSString* const kShareEmailGroupViewMmcCode;
extern NSString* const kShareTextPersonalMmcCode;
extern NSString* const kShareTextGroupAddMmcCode;

extern NSString* const kJSWebBridgeVersion;

typedef enum
{
	kAlbumTypeOptionEnableUpload = 1 << 0,
	kAlbumTypeOptionEnableMemberList = 1 << 1
} kAlbumTypeOptions;

typedef enum
{
	kAlbumTypeEnabledOptionsAllAlbum = kAlbumTypeOptionEnableUpload,
	kAlbumTypeEnabledOptionsEventAlbum = kAlbumTypeOptionEnableUpload + kAlbumTypeOptionEnableMemberList,
	kAlbumTypeEnabledOptionsMyAlbum = kAlbumTypeOptionEnableUpload,
	kAlbumTypeEnabledOptionsFriendAlbum = 0
} kAlbumTypeEnabledOptions;

/**
 * Server Environments for conditional compilation
 */
#define ENVIRONMENT_DEVELOPMENT 0
#define ENVIRONMENT_QA 1
#define ENVIRONMENT_PRODUCTION 2

// Use Production by default
#ifndef ENVIRONMENT
#define ENVIRONMENT ENVIRONMENT_PRODUCTION
#endif

#ifndef RELEASE
#define RELEASE 0
#endif
