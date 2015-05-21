#import "Environment.h"


/* GLOBAL CONSTANTS */

NSString* const kServiceCreateAnonymousAccount = @"/ecomm/xml/createAnonymousAccount.jsp";

NSString* const kServiceAllAlbumList = @"/site/rest/v1.0/allAlbumList";
NSString* const kServiceEventAlbumList = @"/site/rest/v1.0/user/%@/eventAlbumList";

NSString* const kServiceEventAlbumFull = @"/site/rest/v1.0/groupFull/%@";
NSString* const kServiceEventAlbum = @"/site/rest/v1.0/group/%@";
NSString* const kServiceCreateEventAlbum = @"/site/rest/v1.0/group/0";
NSString* const kServiceUploadEventAlbumWithEK = @"/site/rest/v1.0/group/%@/album/%@/upload?upload_source=%@&DYN_EMAIL=%@&EK_S=%@&EK_E=%@";
NSString* const kServiceUploadEventAlbum = @"/site/rest/v1.0/group/%@/album/%@/upload?upload_source=%@&DYN_EMAIL=%@";
NSString* const kServiceUploadAlbumWithEK = @"/site/rest/v1.0/album/%@/upload?upload_source=%@&DYN_EMAIL=%@&EK_S=%@&EK_E=%@";
NSString* const kServiceUploadAlbum = @"/site/rest/v1.0/album/%@/upload?upload_source=%@&DYN_EMAIL=%@";
NSString* const kServiceUploadAlbumRearrange = @"/site/rest/v1.0/album/%@/arrange?action=put";
NSString* const kServiceAlbumPicture = @"/site/rest/v1.0/album/%@/picture/%@";
NSString* const kServiceAlbumAnnotations = @"/site/rest/v1.0/album/%@/annotations";
NSString* const kServiceAlbumPictureRotate = @"/site/rest/v1.0/album/%@/picture/%@/edit/rotate/%d";
NSString* const kServicePictureMetadataBasic = @"/site/rest/v1.0/picture/%@/pictureMetaDataBasic";
NSString* const kServicePhotoComments = @"/site/rest/v1.0/picture/%@/comments"; // @"/api/photoCommentsList/%@";
NSString* const kServicePhotoComment = @"/site/rest/v1.0/picture/%@/comment";
NSString* const kServicePhotoAnnotation = @"/site/rest/v1.0/annotation/%@";
NSString* const kServicePhotoLike = @"/site/rest/v1.0/picture/%@/annotation/like";
NSString* const kServiceUserAvatar = @"/site/rest/v1.0/user/%@/avatar/jpeg";

NSString* const kServicePrintToStoreStoreList = @"/ecomm/json/storeSearch.jsp?postalCode=%@&distance=%@";
NSString* const kServicePrintToStoreCatalog = @"/ecomm/json/printToStoreCatalog.jsp";

NSString* const kServiceEventList = @"/site/rest/v1.0/activity/events";

NSString* const kServiceForgetPassword = @"/gallery/ma_reset_password.jsp";
NSString* const kServiceMyAlbum = @"/site/rest/v1.0/album/%@";
NSString* const kServiceCreateMyAlbum = @"/site/rest/v1.0/album/0";
NSString* const kServiceFriendsAlbum = @"/site/rest/v1.0/friendsAlbum/%@";
NSString* const kServiceRedeemAlbum = @"/site/rest/v1.0/share/redeem/%@";
NSString* const kServiceAnonymousAlbum = @"/site/rest/v1.0/album/anon?asaf=%@";

NSString* const kProductListMobileSkusURL = @"/ecomm/xml/getMobileSkus.jsp?sourceId=%@";
NSString* const kServiceSpmProjectTemplate = @"/site/rest/v1.0/projectTemplate/product/%@";
NSString* const kServiceSpmProjectSave = @"/site/rest/ssis/v1.0/project/%@";
NSString* const kServiceAddToCart = @"/gallery/cart/mobileCart.jsp?mobileCartAction=checkout&mobileFlow=true&json=true&sourceId=%@";

NSString* const kPersonalShareURL = @"/gallery/sharing/shareRedirect.jsp?token=%@&fbTitle=%@&fbThumbURI=%@";
NSString* const kGroupShareURL = @"/gallery/sharing/landingPageSwitchboard.jsp?token=%@&fbTitle=%@&fbThumbURI=%@";
NSString* const kPendingShareURL = @"/gallery/mobile/shareLanding.jsp?launchPendingAppShare=true";
NSString* const kAppStoreLink = @"/gallery/mobile/download.jsp";
NSString* const kEmptyAlbumIcon = @"/A/external/gallery/images/mobile/empty_album.jpg";
NSString* const kTutorialsLink = @"/gallery/mobile/app/mobile_app_tutorial.jsp";
NSString* const kAlternateThumbURL = @"/imaging-site/services/doc/%@/jpeg/SM/.jpeg?p=%@";

NSString* const kUploadSourceID = @"60091";
NSString* const kUploadCompressedSourceID = @"60092";
// kMobileSourceId = SourceId to indicate the request is coming from a mobile device. It will be used for site experience.
NSString* const kMobileSourceId = @"6425002450103";
NSString* const kSourceId = @"294496977803";
NSString* const kShareEmailPersonalMmcCode = @"Share-_-Personal-_-Email-_-Sharee-_-View";
NSString* const kShareEmailGroupAddMmcCode = @"Share-_-Event-_-Email-_-Invitee-_-Add";
NSString* const kShareEmailGroupViewMmcCode = @"Share-_-Event-_-Email-_-Invitee-_-View";
NSString* const kShareTextPersonalMmcCode = @"Share-_-Personal-_-SMS-_-Sharee-_-View";
NSString* const kShareTextGroupAddMmcCode = @"Share-_-Event-_-SMS-_-Invitee-_-Add";

NSString* const kJSWebBridgeVersion = @"1";

int const kCommentButtonTag = 10;
int const kRotateLeftButtonTag = 3;
int const kRotateRightButtonTag = 2;

// Tag for the delete button in the toolbar so that we can easily replace it.
int const kToolbarDeleteButtonTag = 14;
int const kToolbarDeleteButtonDisabledTag = 15;

int const kAllAlbumType = 90; /* arbitrary constant for internal use, doesn't map to a real album type */
int const kFriendAlbumType = 91; /* arbitrary constant for internal use, doesn't map to a real album type */
int const kImageUploadResizeMaxEdge = 1600;
float const kImageUploadResizeCompression = .85;
float const kAlbumListRefreshSeconds = 300 /* Number of seconds before album list is refreshed when redisplaying the albumlist view */;

NSString* const kThumbnailLongSide = @"190";

// Short code base URL
NSString* const kShortCodeBaseUrl = @"http://pix.kg";

// Base URL
#if ENVIRONMENT == ENVIRONMENT_DEVELOPMENT
NSString* const kRestKitBaseUrl = @"http://loc.ofoto.com";
NSString* const kRestKitSecureUrl = @"http://loc.ofoto.com";
NSString* const kCookieBaseUrl = @".ofoto.com";
NSString* const kFacebookAPIKey = @"f7cfcef7f31db5f7bbfe39f5fe2d1f3f";
#elif ENVIRONMENT == ENVIRONMENT_QA
NSString* const kRestKitBaseUrl = @"http://uqmh-gallery.qa.ofoto.com";
NSString* const kRestKitSecureUrl = @"https://uqmh-gallery.qa.ofoto.com";
NSString* const kCookieBaseUrl = @".qa.ofoto.com";
NSString* const kFacebookAPIKey = @"f7cfcef7f31db5f7bbfe39f5fe2d1f3f";
#elif ENVIRONMENT == ENVIRONMENT_PRODUCTION
NSString* const kRestKitBaseUrl = @"http://www.kodakgallery.com";
NSString* const kRestKitSecureUrl = @"https://www.kodakgallery.com";
NSString* const kCookieBaseUrl = @".kodakgallery.com";
NSString* const kFacebookAPIKey = @"f7cfcef7f31db5f7bbfe39f5fe2d1f3f";
#endif

// Omniture Configuration 
#if ENVIRONMENT != ENVIRONMENT_PRODUCTION
// Dev/simulator account
NSString* const kOmnitureAccountId = @"kinIphoneAppDevelopment";
#else
// Production/ad-hoc account
NSString* const kOmnitureAccountId = @"kiniphoneappproduction";
#endif
NSString* const kOmnitureTrackingServer = @"kodakimagingnetwork.122.2o7.net";

NSString* const kApplicationName = @"Kodak Gallery";

NSString *const kAddThisProfileId = @"ra-4d877cb47ce680db";
NSString* const kAddThisApplicationId = @"4ebc2e0b29c406ca";
NSString* const kYahooApplicationID = @"5wUvIl32";



int const kEventAlbumType = 101;
int const kMyAlbumType = 0;
int const kVidSlideshowAlbumType = 110;


