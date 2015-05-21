//
//  ShareEmailTemplates.m
//  MobileApp
//
//  Created by Bryan on 9/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareEmailTemplates.h"
#import "UserModel.h"

@implementation ShareEmailTemplates

// Header for the share email - includes the logo and placeholder for the album image
NSString *const shareEmailHeaderTemplate =
		@"<html>\n"
				@"	<body style='margin:0; padding:0'>\n"
				@"	<table border='0' cellpadding='0' cellspacing='0'>\n"
				@"  <tr><td>\n"
				@"	<table border='0' cellpadding='0' cellspacing='10px'>\n"
				@"		<tr><td valign='bottom'><img src='%@/A/external/gallery/images/mobile/kodak_gallery_logo.png' height='21px' alt='Kodak Gallery'/></td></tr>\n"
				@"	</table>\n"
				@"	<hr style='color: #dadada; background-color: #dadada; height:1px; border:0; margin:0; padding:0'/>\n"
				@"	<table border='0' cellpadding='0' cellspacing='0'>\n"
				@"		<tr height='10px'><td width='10px'></td><td></td></tr>\n"
				@"		<tr><td></td><td>%@</td></tr>\n"
				@"	</table>\n"
				@"	<table border='0' cellpadding='0' cellspacing='10px'>\n"
				@"		<tr>\n"
				@"			<td width='10px'></td>\n"
				@"			<td><a href='%@' style='text-decoration:none;border: none;'><img src='%@' width='145px' style='border: none;'></a></td>\n"
				@"			<td>\n";

NSString *const shareSingleImageEmailHeaderTemplate =
		@"<html>\n"
				@"	<body style='margin:0; padding:0'>\n"
				@"	<table border='0' cellpadding='0' cellspacing='0'>\n"
				@"  <tr><td>\n"
				@"	<table border='0' cellpadding='0' cellspacing='10px'>\n"
				@"		<tr><td valign='bottom'><img src='%@/A/external/gallery/images/mobile/kodak_gallery_logo.png' height='21px' alt='Kodak Gallery'/></td></tr>\n"
				@"	</table>\n"
				@"	<hr style='color: #dadada; background-color: #dadada; height:1px; border:0; margin:0; padding:0'/>\n"
				@"	<table border='0' cellpadding='0' cellspacing='0'>\n"
				@"		<tr height='10px'><td width='10px'></td><td></td></tr>\n"
				@"		<tr><td></td><td>%@</td></tr>\n"
				@"	</table>\n"
				@"	<table border='0' cellpadding='0' cellspacing='10px'>\n"
				@"		<tr>\n"
				@"			<td width='10px'></td>\n"
				@"			<td><img src='%@'></td>\n"
				@"			<td>\n";


// Group album buttons - one for add photos and one for view album
NSString *const shareEmailGroupAlbumButtonsTemplate =
		@"				<a href='%@' style='text-decoration:none;border: none;color: #2160E3'><img src='%@/A/external/gallery/images/mobile/add_photos_yellow_button.jpg' style='border: none;margin-bottom:5px'width='120px' alt='Add Photos'/></a><br />\n"
				@"				<a href='%@' style='text-decoration:none;border: none;color: #2160E3'><img src='%@/A/external/gallery/images/mobile/view_albums_grey_button.jpg' style='border: none;' width='120px' alt='View Album'/></a>\n";

// Personal album buttons - one for view albums
NSString *const shareEmailPersonalAlbumButtonsTemplate =
		@"				<a href='%@' style='text-decoration:none;border: none;color: #2160E3'><img src='%@/A/external/gallery/images/mobile/view_albums_yellow_button.jpg' width='120px' style='border: none;' alt='View My Album'/></a>\n";

// Footer - closing tags and the shared with KODAK Gallery app link
NSString *const shareEmailFooterTemplate =
		@"			</td>\n"
				@"		</tr>\n"
				@"	</table>\n"
				@"	<hr style='color: #dadada; background-color: #dadada; height:1px; border:0; margin:0; padding:0' />\n"
				@"	<table border='0' cellpadding='0' cellspacing='10px'>\n"
				@"		<tr><td>Shared with the <a href='%@' style='text-decoration:none;color: #2160E3'>KODAK Gallery app</a></td></tr>\n"
				@"	</table>\n"
				@"  </td></tr>\n"
				@"	</table>\n"
				@"	</body>\n"
				@"</html>";

+ (NSString *)shareEmailPersonalURL:(NSString *)shareToken albumTitle:(NSString *)albumTitle thumbUrl:(NSString *)thumbUrl
{
	return [NSString stringWithFormat:@"%@%@&sourceId=%@&cm_mmc=%@", kRestKitBaseUrl, [NSString stringWithFormat:kPersonalShareURL, shareToken, albumTitle, thumbUrl], kSourceId, kShareEmailPersonalMmcCode];
}

+ (NSString *)shareEmailGroupViewURL:(NSString *)shareToken albumTitle:(NSString *)albumTitle thumbUrl:(NSString *)thumbUrl
{
	return [NSString stringWithFormat:@"%@%@&sourceId=%@&cm_mmc=%@", kRestKitBaseUrl, [NSString stringWithFormat:kGroupShareURL, shareToken, albumTitle, thumbUrl], kSourceId, kShareEmailGroupViewMmcCode];
}

+ (NSString *)shareEmailGroupAddURL:(NSString *)shareToken albumTitle:(NSString *)albumTitle thumbUrl:(NSString *)thumbUrl
{
	return [NSString stringWithFormat:@"%@%@&upload=1&sourceId=%@&cm_mmc=%@", kRestKitBaseUrl, [NSString stringWithFormat:kGroupShareURL, shareToken, albumTitle, thumbUrl], kSourceId, kShareEmailGroupAddMmcCode];
}

+ (NSString *)appDownloadUrl
{
	return [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kAppStoreLink];
}

// Creates the Group email template using the header, group buttons, and footer
+ (NSString *)shareGroupEmailTemplate:(NSString *)shareToken albumTitle:(NSString *)albumTitle thumbUrl:(NSString *)thumbUrl
{
	NSString *escapedTitle = [NSString stringWithString:albumTitle];
	[UserModel encodeString:&escapedTitle];
	NSString *escapedThumbUrl = [NSString stringWithString:thumbUrl];
	[UserModel encodeString:&escapedThumbUrl];

	// Add header plus album thumbnail
	NSMutableString *emailHTML = [NSMutableString stringWithFormat:shareEmailHeaderTemplate,
																   kRestKitBaseUrl,
																   [NSString stringWithFormat:@"You can add your photos to our album \"%@\"", albumTitle],
																   [ShareEmailTemplates shareEmailGroupAddURL:shareToken albumTitle:escapedTitle thumbUrl:escapedThumbUrl],
																   thumbUrl];

	// 2 share buttons - add photos and view album
	[emailHTML appendFormat:shareEmailGroupAlbumButtonsTemplate,
							[ShareEmailTemplates shareEmailGroupAddURL:shareToken albumTitle:escapedTitle thumbUrl:escapedThumbUrl], kRestKitBaseUrl,
							[ShareEmailTemplates shareEmailGroupViewURL:shareToken albumTitle:escapedTitle thumbUrl:escapedThumbUrl], kRestKitBaseUrl];

	// Footer
	[emailHTML appendFormat:shareEmailFooterTemplate, [ShareEmailTemplates appDownloadUrl]];

	return emailHTML;
}

// Creates the Person email template using the header, personal view album button, and footer
+ (NSString *)sharePersonalEmailTemplate:(NSString *)shareToken albumTitle:(NSString *)albumTitle thumbUrl:(NSString *)thumbUrl
{
	NSString *escapedTitle = [NSString stringWithString:albumTitle];
	[UserModel encodeString:&escapedTitle];
	NSString *escapedThumbUrl = [NSString stringWithString:thumbUrl];
	[UserModel encodeString:&escapedThumbUrl];

	// Add header plus album thumbnail
	NSMutableString *emailHTML = [NSMutableString stringWithFormat:shareEmailHeaderTemplate,
																   kRestKitBaseUrl,
																   [NSString stringWithFormat:@"View my album \"%@\"", albumTitle],
																   [ShareEmailTemplates shareEmailPersonalURL:shareToken albumTitle:escapedTitle thumbUrl:escapedThumbUrl],
																   thumbUrl];

	// 1 share button - view album
	[emailHTML appendFormat:shareEmailPersonalAlbumButtonsTemplate, [ShareEmailTemplates shareEmailPersonalURL:shareToken albumTitle:escapedTitle thumbUrl:escapedThumbUrl], kRestKitBaseUrl];

	// Footer
	[emailHTML appendFormat:shareEmailFooterTemplate, [ShareEmailTemplates appDownloadUrl]];

	return emailHTML;
}

+ (NSString *)shareSingleImageEmailTemplate:(NSString *)photoTitle
									  BGUrl:(NSString *)BGUrl
{

	NSString *escapedBGUrl = [NSString stringWithString:BGUrl];
	[UserModel encodeString:&escapedBGUrl];

	// Add header plus album thumbnail
	NSMutableString *emailHTML;
	NSString *albumTitleStr;

	if ( photoTitle != nil )
	{
		albumTitleStr = [NSString stringWithFormat:@"View my photo \"%@\"", photoTitle];
	}
	else
	{
		albumTitleStr = [NSString stringWithString:@"View my photo"];
	}

	emailHTML = [NSMutableString stringWithFormat:shareSingleImageEmailHeaderTemplate,
												  kRestKitBaseUrl,
												  albumTitleStr,
												  BGUrl];

	// Footer
	[emailHTML appendFormat:shareEmailFooterTemplate, [ShareEmailTemplates appDownloadUrl]];

	return emailHTML;
}


@end
