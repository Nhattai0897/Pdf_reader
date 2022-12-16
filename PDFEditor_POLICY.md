PDF Editor: Privacy policy

Welcome to the PDF Editor app for Android!

This is an open source Android app developed by Tai Nguyen. The source code is available on GitHub under the MIT license; the app is also available on Google Play.

As an avid Android user myself, I take privacy very seriously. I know how irritating it is when apps collect your data without your knowledge.

I hereby state, to the best of my knowledge and belief, that I have not programmed this app to collect any personally identifiable information. All data (app preferences (like theme, etc.) and PDF file) created by the you (the user) is stored on your device only, and can be simply erased by clearing the app's data or uninstalling it.

Explanation of permissions requested in the app

The list of permissions required by the app can be found in the AndroidManifest.xml file:

pdf_reader/android/app/src/main/AndroidManifest.xml 
Lines 3 to 7 
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/> 
    <uses-permission android:name="android.permission.VIBRATE"/>

Permission	Why it is required
1.android.permission.READ_EXTERNAL_STORAGE: The purpose of this permission is used for reading data of the device's external storage, used for the feature that allows the user to retrieve files from the machine for viewing and editing.

2.android.permission.WRITE_EXTERNAL_STORAGE: This permission is used to write data, after the user edits, the file will be saved to the device's memory 

3.android.permission.MANAGE_EXTERNAL_STORAGE: This permission is used for the purpose of statistics of files in a number of folders of the device, and displayed in the form of a list of suggestions, for a better user experience and faster operation when you want to select a file from device

4.android.permission.USE_FINGERPRINT: The purpose of this permission is to authenticate when the user wants to display the list of files in the private tab

5.android.permission.VIBRATE: This permission is intended to make the device vibrate to notify the user when the file is successfully downloade
 
If you find any security vulnerability that has been inadvertently caused by me, or have any question regarding how the app protectes your privacy, please send me an email or post a discussion on GitHub, and I will surely try to fix it/help you.

Yours sincerely,
Tai Nguyen.
HoChiMinh, VietNam.
tainguyen0897@gmail.com
