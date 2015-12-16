# [Archive] f8 app #

**Note:** *This repository is not under active development.*

This is the entire source code of the official [f8 2014](http://www.fbf8.com) apps, available on the [App Store](https://itunes.apple.com/us/app/f8/id853467066?mt=8) as well as on [Google Play](https://play.google.com/store/apps/details?id=com.parse.f8).

Read more about these apps on our blog: [Open Sourcing the f8 Conference Apps](http://blog.parse.com/2014/08/28/open-sourcing-the-f8-conference-apps/)

## Initial Setup ##

First, you need to clone the repository.

Next, you'll need to create a new Parse app. For simplicity, we've included a JSON export of the f8 app which you can use for an initial import of data into your own app.

You'll also need to create a Facebook app and configure it for the platforms you wish to test on.

### Parse App Setup ###

1. Go to your [Parse Dashboard](https://parse.com/apps) and create a new Parse app.
2. Copy your new Parse application id and client key. You will need these later. Remember that you can always get your keys from your app's Settings page.
3. Locate the `data` folder in your local clone of the repo. Here you will find `GeneralInfo.json`, `Message.json`, `Room.json`, `Slot.json`, `Speaker.json`, and `Talk.json` . These can be imported into your brand new Parse app.
4. Go to your app's Data Browser, and click on the "Import" button. Choose `GeneralInfo.json` and give your new class the name "GeneralInfo". Repeat this for each of the json files in the `data` folder, giving them the appropriate class name.
5. When the data is imported, images files are not brought over. We've provided images for the `Room` icons that you can use. To add these:
    1. Locate the `assets` folder in your local repo.
    2. Go to `Room` class in your Data Browser.
    3. Delete the `gameslounge.png` entry in the `icon` field.
    4. Upload the `gameslounge.png` file from the `assets` folder.
    5. Repeat these steps for all other images you find in the `assets` folder.

6. We've also provided images for the `Talk` class `icon` fields that are set. Replace these images in the `Talk` class with the corresponding ones in the `assets` folder: `afterparty.png`, `registration.png`, and `lunch.png`.

Other images, such as speaker images will show up as blank. You can upload your own images to make them visible.

### Facebook App Setup ###

1. Go to the [Facebook App Dashboard](https://developers.facebook.com/apps) and create a new Facebook app.
2. Configure your Facebook app:

    + [iOS Setup](https://developers.facebook.com/docs/ios/getting-started#appid). During this step, you may initially set the `Bundle Identifier` to "com.parse.f8". If you later change the bundle identifier in your Xcode project, be sure to return to the app dashboard and modify this setting.
    + [Android Setup](https://developers.facebook.com/docs/android/getting-started#create-app). During this step, you may initially set `Package Name` to "com.parse.f8" and `Clas Name` to "com.parse.f8.DispatchActivity". If you later change the Android package name in the code, be sure to return to the app dashboard and modify these settings.

3. Add your Facebook app id and app secret to your Parse app's `Settings > User authentication > Facebook` properties.
4. Note your Facebook `App ID` and `Display Name`. You will need these later.

Next, go through the setup instructions for iOS and/or Android.

## iOS Setup ##

First, make sure you've gone through the "Initial Setup" instructions.

Then, to install the f8 app on iOS you need to configure the project with your app keys:

1. Open `ios/F8 Developer Conference.xcodeproj` in Xcode.
2. Modify `PDDAppDelegate.m` to use your Parse application id and client key.
3. Modify `F8 Developer Conference-Info.plist` to configure your Facebook settings:
    + Set your Facebook app id in the `FacebookAppID` property.
    + Set your Facebook app id in the `URL types > Item 0 > URL Schemes > Item 0` using the format fbYour_App_id (ex. for 12345, enter fb12345).
    + Set the `Bundle identifier` property to match your Facebook app dashboard's `Bundle ID` setting.
    + Set the `FacebookDisplayName` property to match your Facebook app dashboard's `Display Name` setting.
4. Build and Run.

Once you've confirmed that everything is working correctly, you may modify the general conference info and the list of Talks, Speakers, and Rooms to suit your conference.

## Android Setup ##

First, make sure you've gone through the "Initial Setup" instructions.

Then to install the f8 app on Android, you need to import the f8 project and supporting library projects. You'll then configure the f8 project with your app keys. You also need to obtain a YouTube API key from Google if you wish to see video playback in action:

you need to configure the project with your app keys. The app depends on Android's [v7 appcompat Support Library](http://developer.android.com/tools/support-library/features.html#v7) so you'll need to set that up. You also need to obtain a YouTube API key from Google if you wish to see video playback in action:

1. Import the `android` f8 project in your IDE of choice, such as Eclipse.
2. Import the `appcompat` Android Support library project from the local repo.
3. Import the `facebook-android-sdk` Facebook SDK library project from the local repo.
3. Follow the instructions on Google's developer site to [register your application and obtain a YouTube developer key](https://developers.google.com/youtube/android/player/register). Set up an API key for Android.
4. Modify the f8 project's `strings.xml` file to use your Parse application id, Parse client key, Facebook app id, and YouTube developer key.
5. Build and Run.

## Further Customizations ##

Once you've confirmed that everything is working correctly, you may  modify the general conference info, the list of Talks, Speakers, and Rooms to suit your conference.
