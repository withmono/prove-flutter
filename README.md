# Mono Prove Flutter SDK

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

The Mono Prove SDK is a quick and secure way to onboard your users from within your Flutter app. Mono Prove is a customer onboarding product that offers businesses faster customer onboarding and prevents fraudulent sign-ups, powered by the MDN and facial recognition technology.

For accessing customer accounts and interacting with Mono's API (Identity, Transactions, Income, DirectPay) use the server-side [Mono API](https://docs.mono.co/docs).

## Documentation

For complete information about Mono Prove, head to the [docs](https://docs.mono.co/docs).

## Getting Started

1. Register on the [Mono](https://app.mono.com) website and get your public and secret keys.
2. Retrieve a `sessionId` for a customer by calling the [initiate endpoint](https://docs.mono.co/api)

## Installation Guide

**❗ In order to start using Mono Prove you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
flutter pub add mono_prove
```
## Additional Setup
### iOS

- Add the key `Privacy - Camera Usage Description` and a usage description to your `Info.plist`.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
```

- Add the following to your `Podfile` file:

```ruby
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings(target)

      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',

          ## dart: PermissionGroup.camera
          'PERMISSION_CAMERA=1',
        ]
      end
    end
  end
  ```

### Android

State the camera permission in your `android/app/src/main/AndroidManifest.xml` file.

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

## Usage

#### Import Mono Prove SDK
```dart
import 'package:mono_prove/mono_prove.dart';
```

#### Create a ProveConfiguration
```dart
final config = ProveConfiguration(
  sessionId: 'PRV...',
  onSuccess: () {
    print('Successfully verified.');
  },
  reference: 'testref',
  onEvent: (event) {
    print(event);
  },
  onClose: () {
    print('Widget closed.');
  },
);
```

#### Show the Widget
```dart
ElevatedButton(
    onPressed: () {
      MonoProve.launch(
        context,
        config: config,
        showLogs: true,
      )
    },
    child: Text('Launch Prove Widget'),
)
```

## Configuration Options

- [`sesssionId`](#sesssionId)
- [`onSuccess`](#onSuccess)
- [`onClose`](#onClose)
- [`onEvent`](#onEvent)
- [`reference`](#reference)

### <a name="sesssionId"></a> `sesssionId`
**String: Required**

This is the session ID returned after calling the [initiate endpoint](https://docs.mono.co/api).

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...', // sessionId
  onSuccess: () {
    print('Successfully verified.');
  }, // onSuccess function
);
```

### <a name="onSuccess"></a> `onSuccess`
**void Function(): Required**

The closure is called when a user has successfully verified their identity.

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...', // sessionId
  onSuccess: () {
    print('Successfully verified.');
  }, // onSuccess function
);
```

### <a name="onClose"></a> `onClose`
**void Function(): Optional**

The optional closure is called when a user has specifically exited the Mono Prove flow. It does not take any arguments.

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...', // sessionId
  onSuccess: () {
    print('Successfully verified.');
  }, // onSuccess function
  onClose: () {
    print('Widget closed.');
  }, // onClose function
);
```

### <a name="onEvent"></a> `onEvent`
**void Function(ProveEvent): Optional**

This optional closure is called when certain events in the Mono Prove flow have occurred, for example, when the user opens or closes the widget. This enables your application to gain further insight into what is going on as the user goes through the Mono Prove flow.

See the [ProveEvent](#ProveEvent) object below for details.

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...', // sessionId
  onSuccess: () {
    print('Successfully verified.');
  }, // onSuccess function
  onEvent: (event) {
    print(event);
  }, // onEvent function
);
```

### <a name="reference"></a> `reference`
**String: Optional**

When passing a reference to the configuration it will be passed back on all onEvent calls.

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...', // sessionId
  onSuccess: () {
    print('Successfully verified.');
  }, // onSuccess function
  reference: 'random_string',
);
```

## API Reference

### MonoProve Object

The MonoProve Object exposes methods that take a [ProveConfiguration](#ProveConfiguration) for easy interaction with the Mono Prove Widget.

### <a name="ProveConfiguration"></a> ProveConfiguration

The configuration option is passed to the different launch methods from the MonoProve Object.

```dart
sessionId: String // required
onSuccesss: VoidCallback // required
onClose: VoidCallback // optional
onEvent: void Function(ProveEvent) // optional
reference: String // optional
```
#### Usage

```dart
final config = ProveConfiguration(
  sessionId: 'PRV...',
  onSuccess: () {
    print('Successfully verified.');
  },
  reference: 'testref',
  onEvent: (event) {
    print(event);
  },
  onClose: () {
    print('Widget closed.');
  },
);
```

### <a name="proveEvent"></a> ProveEvent

#### <a name="type"></a> `type: EventType`

Event types correspond to the `type` key returned by the event data. Possible options are in the table below.

| Event type        | Description                                                   |
|-------------------|---------------------------------------------------------------|
| opened            | Triggered when the user opens the Prove Widget.               |
| closed            | Triggered when the user closes the Prove Widget.              |
| identityVerified | Triggered when the user successfully verifies their identity. |
| error             | Triggered when the widget reports an error.                   |

#### <a name="dataObject"></a> `data: EventData`
The data object of type EventData returned from the onEvent callback.

```dart
eventType: String // type of event mono.prove.xxxx
reference: String? // reference passed through the prove config
pageName: String? // name of page the widget exited on
errorType: String? // error thrown by widget
errorMessage: String? // error message describing the error
reason: String? // reason for exiting the widget
timestamp: Date // timestamp of the event as a Date object
```

## Support
If you're having general trouble with Mono Prove Android SDK or your Mono integration, please reach out to us at <hi@mono.co> or come chat with us on Slack. We're proud of our level of service, and we're more than happy to help you out with your integration to Mono.

## Contributing
If you would like to contribute to the Mono Prove Android SDK, please make sure to read our [contributor guidelines](https://github.com/withmono/prove-flutter/tree/main/CONTRIBUTING.md).


## License

[MIT](https://github.com/withmono/prove-flutter/tree/main/LICENSE) for more information.

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
