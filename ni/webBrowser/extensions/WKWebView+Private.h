//
//  WKWebView+Private.h
//  Enai
//
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, _WKMediaCaptureStateDeprecated) {
	_WKMediaCaptureStateDeprecatedNone = 0,
	_WKMediaCaptureStateDeprecatedActiveMicrophone = 1 << 0,
	_WKMediaCaptureStateDeprecatedActiveCamera = 1 << 1,
	_WKMediaCaptureStateDeprecatedMutedMicrophone = 1 << 2,
	_WKMediaCaptureStateDeprecatedMutedCamera = 1 << 3,
} API_AVAILABLE(macos(10.13), ios(11.0));

typedef NS_OPTIONS(NSUInteger, _WKMediaMutedState) {
	_WKMediaNoneMuted = 0,
	_WKMediaAudioMuted = 1 << 0,
	_WKMediaCaptureDevicesMuted = 1 << 1,
	_WKMediaScreenCaptureMuted = 1 << 2,
} API_AVAILABLE(macos(10.13), ios(11.0));

typedef NS_OPTIONS(NSUInteger, _WKCaptureDevices) {
	_WKCaptureDeviceMicrophone = 1 << 0,
	_WKCaptureDeviceCamera = 1 << 1,
	_WKCaptureDeviceDisplay = 1 << 2,
} API_AVAILABLE(macos(10.13), ios(11.0));

typedef NS_OPTIONS(NSUInteger, _WKFindOptions) {
	_WKFindOptionsCaseInsensitive = 1 << 0,
	_WKFindOptionsAtWordStarts = 1 << 1,
	_WKFindOptionsTreatMedialCapitalAsWordStart = 1 << 2,
	_WKFindOptionsBackwards = 1 << 3,
	_WKFindOptionsWrapAround = 1 << 4,
	_WKFindOptionsShowOverlay = 1 << 5,
	_WKFindOptionsShowFindIndicator = 1 << 6,
	_WKFindOptionsShowHighlight = 1 << 7,
	_WKFindOptionsNoIndexChange = 1 << 8,
	_WKFindOptionsDetermineMatchIndex = 1 << 9,
} API_AVAILABLE(macos(10.10));

@interface WKWebView (Private)

- (void)_restoreFromSessionStateData:(NSData *)data;
- (NSData * _Nullable)_sessionStateData;

@property (nonatomic, readonly) _WKMediaCaptureStateDeprecated _mediaCaptureState API_AVAILABLE(macos(10.15), ios(13.0));

- (void)_stopMediaCapture API_AVAILABLE(macos(10.15.4), ios(13.4));
- (void)_stopAllMediaPlayback;

@end

NS_ASSUME_NONNULL_END
