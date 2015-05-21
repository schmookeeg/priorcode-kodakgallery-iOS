//
//  SettingsDataSource.h
//  MobileApp
//
//  Created by Darron Schall on 8/25/11.
//

#import <Three20/Three20.h>
#import "UserModel.h"

typedef enum
{
	SDSAccountSection = 0,
	SDSGeneralSection,
	SDSResizeSection,
	SDSNotificationSection,
	SDSSupportSection,
	SDSInfoSection,
	SDSDefaultSection,

} SDSSection;

@interface SettingsDataSource : TTSectionedDataSource

+ (SettingsDataSource *)dataSourceWithArrays:(id)object, ...;

@end
