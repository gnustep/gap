#
# GNUmakefile for SimpleWeather
#
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME=SimpleWeather

SimpleWeather_LOCALIZED_RESOURCE_FILES=

SimpleWeather_LANGUAGES= English 

SimpleWeather_RESOURCE_FILES= NWS.plist WUnderground.plist \
	English.lproj/WeatherPreferences.nib \
	./WMIcons/permission.txt \
	./WMIcons/blizzard.png ./WMIcons/blowingsnow.png ./WMIcons/chancetstorm.png ./WMIcons/chancetstormn.png ./WMIcons/cloudy.png ./WMIcons/drizzle.png ./WMIcons/fair.png ./WMIcons/fdrizzle.png ./WMIcons/flurries.png ./WMIcons/fog.png ./WMIcons/freezingrain.png ./WMIcons/hazy.png ./WMIcons/mcloudy.png ./WMIcons/mcloudyn.png ./WMIcons/mcloudynr.png ./WMIcons/mcloudyns.png ./WMIcons/mcloudyr.png ./WMIcons/na.png ./WMIcons/pcloudy.png ./WMIcons/pcloudyn.png ./WMIcons/pcloudyr.png ./WMIcons/pcloudyrn.png ./WMIcons/rain.png ./WMIcons/rainandsnow.png ./WMIcons/showers.png ./WMIcons/smoke.png ./WMIcons/snow.png ./WMIcons/snowshowers.png ./WMIcons/sunny.png ./WMIcons/sunnyn.png ./WMIcons/tstorm.png ./WMIcons/tstormn.png ./WMIcons/wind.png

SimpleWeather_HEADER_FILES= \
GNUstep.h \
WeatherDataParser.h \
WeatherPreferencesController.h \
WeatherView.h

SimpleWeather_OBJC_FILES= \
WeatherDataParser.m \
WeatherPreferencesController.m \
WeatherView.m

SimpleWeather_C_FILES= 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
