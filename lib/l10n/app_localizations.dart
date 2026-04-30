import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Local Sharer'**
  String get app_name;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noFileFound.
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get noFileFound;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'items selected'**
  String get itemsSelected;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get send;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'RECEIVE'**
  String get receive;

  /// No description provided for @sendFiles.
  ///
  /// In en, this message translates to:
  /// **'SEND FILES'**
  String get sendFiles;

  /// No description provided for @searchingForNearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Searching for nearby devices...'**
  String get searchingForNearbyDevices;

  /// No description provided for @qrDevice.
  ///
  /// In en, this message translates to:
  /// **'QR Device'**
  String get qrDevice;

  /// No description provided for @noDevicesFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No devices found yet'**
  String get noDevicesFoundYet;

  /// No description provided for @connectTo.
  ///
  /// In en, this message translates to:
  /// **'Connect to'**
  String get connectTo;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @connectAndSend.
  ///
  /// In en, this message translates to:
  /// **'Connect & Send'**
  String get connectAndSend;

  /// No description provided for @sendingFilesToReceiver.
  ///
  /// In en, this message translates to:
  /// **'Sending files to receiver...'**
  String get sendingFilesToReceiver;

  /// No description provided for @myDevice.
  ///
  /// In en, this message translates to:
  /// **'My Device'**
  String get myDevice;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @invalidQRData.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Data'**
  String get invalidQRData;

  /// No description provided for @receivesFiles.
  ///
  /// In en, this message translates to:
  /// **'RECEIVES FILES'**
  String get receivesFiles;

  /// No description provided for @setYourCredentials.
  ///
  /// In en, this message translates to:
  /// **'SET YOUR CREDENTIALS'**
  String get setYourCredentials;

  /// No description provided for @otherUserWillNeedTheseToSendYouFiles.
  ///
  /// In en, this message translates to:
  /// **'Other users will need these to send you files'**
  String get otherUserWillNeedTheseToSendYouFiles;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @startWaiting.
  ///
  /// In en, this message translates to:
  /// **'START WAITING'**
  String get startWaiting;

  /// No description provided for @scanToConnect.
  ///
  /// In en, this message translates to:
  /// **'SCAN TO CONNECT'**
  String get scanToConnect;

  /// No description provided for @stopReceiving.
  ///
  /// In en, this message translates to:
  /// **'STOP RECEIVING'**
  String get stopReceiving;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categories;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @fileReceiveSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'File(s) received successfully!'**
  String get fileReceiveSuccessfully;

  /// No description provided for @anErrorOccurredDuringTransfer.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during transfer.'**
  String get anErrorOccurredDuringTransfer;

  /// No description provided for @incomingConnection.
  ///
  /// In en, this message translates to:
  /// **'Incoming connection...'**
  String get incomingConnection;

  /// No description provided for @receiving.
  ///
  /// In en, this message translates to:
  /// **'Receiving...'**
  String get receiving;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @noFileFoundInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No files found in this category'**
  String get noFileFoundInThisCategory;

  /// No description provided for @itemSelected.
  ///
  /// In en, this message translates to:
  /// **'items selected'**
  String get itemSelected;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @connectToPc.
  ///
  /// In en, this message translates to:
  /// **'Connect to PC'**
  String get connectToPc;

  /// No description provided for @serverIsActive.
  ///
  /// In en, this message translates to:
  /// **'Server is Active'**
  String get serverIsActive;

  /// No description provided for @transferViaPcBrowserOrWinscp.
  ///
  /// In en, this message translates to:
  /// **'Transfer via Browser/WinSCP'**
  String get transferViaPcBrowserOrWinscp;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'SERVER ADDRESS'**
  String get serverAddress;

  /// No description provided for @connectionGuide.
  ///
  /// In en, this message translates to:
  /// **'Connection Guide'**
  String get connectionGuide;

  /// No description provided for @ensurePcAndPhoneAreOnTheSameWiFiNetwork.
  ///
  /// In en, this message translates to:
  /// **'Ensure PC and Phone are on the same Wi-Fi network.'**
  String get ensurePcAndPhoneAreOnTheSameWiFiNetwork;

  /// No description provided for @onYourPcOpenFileExplorerOrWinSCP.
  ///
  /// In en, this message translates to:
  /// **'On your PC, open File Explorer or WinSCP.'**
  String get onYourPcOpenFileExplorerOrWinSCP;

  /// No description provided for @typeTheAddress.
  ///
  /// In en, this message translates to:
  /// **'Type the address'**
  String get typeTheAddress;

  /// No description provided for @whenPromptedEnter.
  ///
  /// In en, this message translates to:
  /// **'When prompted, enter'**
  String get whenPromptedEnter;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @serverOnline.
  ///
  /// In en, this message translates to:
  /// **'SERVER ONLINE'**
  String get serverOnline;

  /// No description provided for @serverOffline.
  ///
  /// In en, this message translates to:
  /// **'SERVER OFFLINE'**
  String get serverOffline;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @shutDownServer.
  ///
  /// In en, this message translates to:
  /// **'SHUTDOWN SERVER'**
  String get shutDownServer;

  /// No description provided for @initializeServer.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZE SERVER'**
  String get initializeServer;

  /// No description provided for @waitingForInitialization.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR INITIALIZATION...'**
  String get waitingForInitialization;

  /// No description provided for @waitingForReceiverToAccept.
  ///
  /// In en, this message translates to:
  /// **'Waiting for receiver to accept...'**
  String get waitingForReceiverToAccept;

  /// No description provided for @streamingDataToDestination.
  ///
  /// In en, this message translates to:
  /// **'Streaming data to destination...'**
  String get streamingDataToDestination;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermissionRequired;

  /// No description provided for @establishingConnection.
  ///
  /// In en, this message translates to:
  /// **'Establishing connection...'**
  String get establishingConnection;

  /// No description provided for @transferCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully!'**
  String get transferCompletedSuccessfully;

  /// No description provided for @alignQRCodeWithinTheFrame.
  ///
  /// In en, this message translates to:
  /// **'Align QR code within the frame'**
  String get alignQRCodeWithinTheFrame;

  /// No description provided for @manualConnect.
  ///
  /// In en, this message translates to:
  /// **'Manual Connect'**
  String get manualConnect;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @receiverIP.
  ///
  /// In en, this message translates to:
  /// **'Receiver IP'**
  String get receiverIP;

  /// No description provided for @manualDevice.
  ///
  /// In en, this message translates to:
  /// **'Manual Device'**
  String get manualDevice;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @webShare.
  ///
  /// In en, this message translates to:
  /// **'WEB SHARE'**
  String get webShare;

  /// No description provided for @webServer.
  ///
  /// In en, this message translates to:
  /// **'Web Server'**
  String get webServer;

  /// No description provided for @hostFilesOnLocalWeb.
  ///
  /// In en, this message translates to:
  /// **'Host files on local web'**
  String get hostFilesOnLocalWeb;

  /// No description provided for @scanToAccess.
  ///
  /// In en, this message translates to:
  /// **'SCAN TO ACCESS'**
  String get scanToAccess;

  /// No description provided for @securityPin.
  ///
  /// In en, this message translates to:
  /// **'SECURITY PIN'**
  String get securityPin;

  /// No description provided for @openThisLinkInYourPCBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open this link in your PC browser'**
  String get openThisLinkInYourPCBrowser;

  /// No description provided for @sharedFiles.
  ///
  /// In en, this message translates to:
  /// **'SHARED FILES'**
  String get sharedFiles;

  /// No description provided for @addFiles.
  ///
  /// In en, this message translates to:
  /// **'Add Files'**
  String get addFiles;

  /// No description provided for @noFilesAddedToWebShareYet.
  ///
  /// In en, this message translates to:
  /// **'No files added to web share yet'**
  String get noFilesAddedToWebShareYet;

  /// No description provided for @filesAddedToWebShare.
  ///
  /// In en, this message translates to:
  /// **'files added to Web Share'**
  String get filesAddedToWebShare;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get view;

  /// No description provided for @webSharePC.
  ///
  /// In en, this message translates to:
  /// **'Web Share (PC)'**
  String get webSharePC;

  /// No description provided for @accessFilesViaAnyBrowser.
  ///
  /// In en, this message translates to:
  /// **'Access files via any browser'**
  String get accessFilesViaAnyBrowser;

  /// No description provided for @allFiles.
  ///
  /// In en, this message translates to:
  /// **'All Files'**
  String get allFiles;

  /// No description provided for @imageCategory.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get imageCategory;

  /// No description provided for @musicCategory.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicCategory;

  /// No description provided for @videosCategory.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videosCategory;

  /// No description provided for @explorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorer;

  /// No description provided for @internalStorage.
  ///
  /// In en, this message translates to:
  /// **'Internal Storage'**
  String get internalStorage;

  /// No description provided for @noTransferHistory.
  ///
  /// In en, this message translates to:
  /// **'No Transfer History'**
  String get noTransferHistory;

  /// No description provided for @yourRecentTransfersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your recent transfers will appear here'**
  String get yourRecentTransfersWillAppearHere;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @thisWillPermanentlyDeleteAllTransferLogs.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all transfer logs.'**
  String get thisWillPermanentlyDeleteAllTransferLogs;

  /// No description provided for @storagePermissionsAreRequiredToReceiveFiles.
  ///
  /// In en, this message translates to:
  /// **'Storage permissions are required to receive files.'**
  String get storagePermissionsAreRequiredToReceiveFiles;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @requireAuthenticationToOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Require authentication to open app'**
  String get requireAuthenticationToOpenApp;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// No description provided for @useFingerprintOrFaceRecognition.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face recognition'**
  String get useFingerprintOrFaceRecognition;

  /// No description provided for @changeMasterPIN.
  ///
  /// In en, this message translates to:
  /// **'Change Master PIN'**
  String get changeMasterPIN;

  /// No description provided for @updateYour6digitSecurityCode.
  ///
  /// In en, this message translates to:
  /// **'Update your 6-digit security code'**
  String get updateYour6digitSecurityCode;

  /// No description provided for @set6DigitPIN.
  ///
  /// In en, this message translates to:
  /// **'Set 6-Digit PIN'**
  String get set6DigitPIN;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @cancell.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancell;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @secureVault.
  ///
  /// In en, this message translates to:
  /// **'Secure Vault'**
  String get secureVault;

  /// No description provided for @moveToSecureVault.
  ///
  /// In en, this message translates to:
  /// **'Move to Secure Vault'**
  String get moveToSecureVault;

  /// No description provided for @selectedFilesWillBeMovedToAPrivateFolderAndHiddenFromOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Selected files will be moved to a private folder and hidden from other apps.'**
  String get selectedFilesWillBeMovedToAPrivateFolderAndHiddenFromOtherApps;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'MOVE'**
  String get move;

  /// No description provided for @moveToVault.
  ///
  /// In en, this message translates to:
  /// **'Move to Vault'**
  String get moveToVault;

  /// No description provided for @restoreToStorage.
  ///
  /// In en, this message translates to:
  /// **'Restore to Storage'**
  String get restoreToStorage;

  /// No description provided for @vaultIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Vault is Empty'**
  String get vaultIsEmpty;

  /// No description provided for @moveSensitiveFilesHereToProtectThem.
  ///
  /// In en, this message translates to:
  /// **'Move sensitive files here to protect them'**
  String get moveSensitiveFilesHereToProtectThem;

  /// No description provided for @filesBackToPublicStorage.
  ///
  /// In en, this message translates to:
  /// **'files back to public storage'**
  String get filesBackToPublicStorage;

  /// No description provided for @moves.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moves;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get restore;

  /// No description provided for @restoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Restore Files'**
  String get restoreFiles;

  /// No description provided for @enterYour6digitPINToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN to unlock'**
  String get enterYour6digitPINToUnlock;

  /// No description provided for @authenticateToAccessLocalSharer.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access Local Sharer'**
  String get authenticateToAccessLocalSharer;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @errorGettingLocalIP.
  ///
  /// In en, this message translates to:
  /// **'Error getting local IP'**
  String get errorGettingLocalIP;

  /// No description provided for @storagePermissionNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Storage permission not granted'**
  String get storagePermissionNotGranted;

  /// No description provided for @couldNotGetLocalIPAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not get local IP address'**
  String get couldNotGetLocalIPAddress;

  /// No description provided for @ftpServerStartAt.
  ///
  /// In en, this message translates to:
  /// **'FTP Server started at'**
  String get ftpServerStartAt;

  /// No description provided for @errorStartingFTPServer.
  ///
  /// In en, this message translates to:
  /// **'Error starting FTP server'**
  String get errorStartingFTPServer;

  /// No description provided for @clientConnected.
  ///
  /// In en, this message translates to:
  /// **'Client connected'**
  String get clientConnected;

  /// No description provided for @localSharerFTPServerReady.
  ///
  /// In en, this message translates to:
  /// **'Local Sharer FTP Server ready'**
  String get localSharerFTPServerReady;

  /// No description provided for @passwordRequiredFor.
  ///
  /// In en, this message translates to:
  /// **'Password required for'**
  String get passwordRequiredFor;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Invalid username'**
  String get invalidUsername;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @userAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User authenticated'**
  String get userAuthenticated;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @isCurrentDirectory.
  ///
  /// In en, this message translates to:
  /// **'is current directory'**
  String get isCurrentDirectory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
